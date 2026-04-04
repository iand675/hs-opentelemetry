{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

{- |
Module      :  OpenTelemetry.Instrumentation.Hedis
Copyright   :  (c) Ian Duncan, 2026
License     :  BSD-3
Description :  OpenTelemetry instrumentation for the hedis Redis client
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)

Automatic tracing for Redis commands via the hedis client library.

= Quick start

@
import qualified OpenTelemetry.Instrumentation.Hedis as Redis

conn <- Redis.'checkedConnect' Redis.'defaultConnectInfo'

Redis.'runTracedRedis' Redis.'defaultConnectInfo' conn $ do
  Redis.'set' \"mykey\" \"myval\"
  result <- Redis.'get' \"mykey\"
  pure result
@

All commands in this module are pre-traced: each invocation creates a
client span following the
<https://opentelemetry.io/docs/specs/semconv/database/redis/ OTel Redis semantic conventions>.

= How it works

Commands are defined against a traced 'sendRequest' that intercepts the
raw Redis protocol bytes. The first element of the @[ByteString]@ is
always the Redis command name, so span names and @db.operation.name@
are derived automatically — no manual command-name strings.

For commands not wrapped by this module, use 'sendRequest' directly:

@
result <- 'sendRequest' [\"OBJECT\", \"REFCOUNT\", key]
@

= Span attributes

Each span includes:

* @db.system.name@ = @\"redis\"@
* @db.operation.name@ = the Redis command name (e.g. @\"GET\"@, @\"HSET\"@)
* @db.namespace@ = the database index from 'ConnectInfo'
* @server.address@ = the host from 'ConnectInfo'
* @server.port@ = the port from 'ConnectInfo' (omitted for unix sockets)

On Redis error replies, the span records @db.response.status_code@
and sets the span status to 'Error'.
-}
module OpenTelemetry.Instrumentation.Hedis (
  -- * Configuration
  RedisInstrumentationConfig (..),
  defaultRedisInstrumentationConfig,

  -- * Running traced Redis
  TracedRedis,
  runTracedRedis,
  runTracedRedisWith,

  -- * Traced command dispatch
  --
  -- | Build any Redis command as a traced span. The command name is
  -- extracted from the first element of the @[ByteString]@.
  --
  -- @
  -- myCustomCmd :: ByteString -> TracedRedis (Either Reply ByteString)
  -- myCustomCmd key = 'sendRequest' [\"MYCMD\", key]
  -- @
  sendRequest,
  traced,

  -- * String commands
  get,
  set,
  getset,
  setnx,
  setex,
  psetex,
  mget,
  mset,
  msetnx,
  incr,
  incrby,
  incrbyfloat,
  decr,
  decrby,
  append,
  getrange,
  setrange,
  strlen,

  -- * Hash commands
  hget,
  hset,
  hsetnx,
  hdel,
  hexists,
  hgetall,
  hkeys,
  hvals,
  hlen,
  hmget,
  hmset,
  hincrby,
  hincrbyfloat,

  -- * List commands
  lpush,
  rpush,
  lpushx,
  rpushx,
  lpop,
  rpop,
  blpop,
  brpop,
  rpoplpush,
  llen,
  lrange,
  lindex,
  lrem,
  lset,
  ltrim,
  linsertBefore,
  linsertAfter,

  -- * Set commands
  sadd,
  srem,
  smembers,
  sismember,
  scard,
  sunion,
  sunionstore,
  sinter,
  sinterstore,
  sdiff,
  sdiffstore,
  srandmember,
  spop,
  smove,

  -- * Sorted set commands
  zadd,
  zrem,
  zrange,
  zrangeWithscores,
  zrangebyscore,
  zrangebyscoreLimit,
  zrevrange,
  zrevrangeWithscores,
  zrevrangebyscore,
  zrevrangebyscoreLimit,
  zcard,
  zscore,
  zrank,
  zrevrank,
  zincrby,

  -- * Key commands
  del,
  exists,
  expire,
  expireat,
  pexpire,
  pexpireat,
  persist,
  ttl,
  pttl,
  getType,
  keys,
  rename,
  renamenx,
  scan,

  -- * Server commands
  ping,
  echo,
  select,
  dbsize,
  flushdb,
  flushall,
  info,

  -- * Pub\/Sub (publish side)
  publish,

  -- * Scripting
  eval,
  evalsha,

  -- * HyperLogLog
  pfadd,
  pfcount,
  pfmerge,

  -- * Transactions
  multiExec,

  -- * Re-exports from hedis
  Connection,
  ConnectInfo (..),
  PortID (..),
  defaultConnectInfo,
  checkedConnect,
  connect,
  disconnect,
  Reply (..),
  Status (..),
  RedisType (..),
  Cursor,
  cursor0,
  TxResult (..),
  Queued,
  RedisTx,
  RedisResult,
  MonadRedis (..),
) where

import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as C
import Data.Int (Int64)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Database.Redis (
  ConnectInfo (..),
  Connection,
  Cursor,
  MonadRedis (..),
  PortID (..),
  Queued,
  Redis,
  RedisCtx (..),
  RedisResult,
  RedisTx,
  RedisType (..),
  Reply (..),
  Status (..),
  TxResult (..),
  checkedConnect,
  connect,
  cursor0,
  defaultConnectInfo,
  disconnect,
  runRedis,
 )
import qualified Database.Redis as Redis
import Control.Monad.IO.Class (MonadIO, liftIO)
import Control.Monad.Reader (ReaderT, ask, runReaderT)
import Control.Monad.Trans (lift)
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Context.ThreadLocal (getContext)
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.Trace.Core hiding (Error)
import qualified OpenTelemetry.Trace.Core as OTel


-- | Static configuration for Redis instrumentation, derived from 'ConnectInfo'.
data RedisInstrumentationConfig = RedisInstrumentationConfig
  { redisHost :: Text
  , redisPort :: Int64
  , redisDatabaseIndex :: Int
  }
  deriving (Show, Eq)


-- | Build instrumentation config from hedis 'ConnectInfo'.
defaultRedisInstrumentationConfig :: ConnectInfo -> RedisInstrumentationConfig
defaultRedisInstrumentationConfig ConnInfo {..} =
  RedisInstrumentationConfig
    { redisHost = T.pack connectHost
    , redisPort = case connectPort of
        PortNumber pn -> fromIntegral pn
        UnixSocket _ -> 0
    , redisDatabaseIndex = fromIntegral connectDatabase
    }


data TracedRedisEnv = TracedRedisEnv
  { treTracer :: {-# UNPACK #-} !Tracer
  , treStaticAttrs :: !AttrsBuilder
  }


staticAttrs :: RedisInstrumentationConfig -> AttrsBuilder
staticAttrs RedisInstrumentationConfig {..} =
  SC.db_system_name .@ ("redis" :: Text)
    <> SC.db_namespace .@ T.pack (show redisDatabaseIndex)
    <> SC.server_address .@ redisHost
    <> SC.server_port .@? (if redisPort > 0 then Just redisPort else Nothing)


{- | A Redis monad with automatic OpenTelemetry tracing.

All hedis commands that are polymorphic over 'RedisCtx' work directly
in 'TracedRedis' (untraced). Use the pre-traced wrappers exported by
this module, or build your own via 'sendRequest'.
-}
newtype TracedRedis a = TracedRedis (ReaderT TracedRedisEnv Redis a)
  deriving newtype (Functor, Applicative, Monad, MonadIO)


instance MonadRedis TracedRedis where
  liftRedis = TracedRedis . lift


instance RedisCtx TracedRedis (Either Reply) where
  returnDecode = liftRedis . returnDecode


{- | Run a 'TracedRedis' block, deriving instrumentation config from
'ConnectInfo'.

@
conn <- 'checkedConnect' 'defaultConnectInfo'
'runTracedRedis' 'defaultConnectInfo' conn $ do
  'set' \"key\" \"val\"
  'get' \"key\"
@
-}
runTracedRedis :: ConnectInfo -> Connection -> TracedRedis a -> IO a
runTracedRedis ci = runTracedRedisWith (defaultRedisInstrumentationConfig ci)


-- | Like 'runTracedRedis' but with an explicit 'RedisInstrumentationConfig'.
runTracedRedisWith :: RedisInstrumentationConfig -> Connection -> TracedRedis a -> IO a
runTracedRedisWith cfg conn (TracedRedis action) = do
  tp <- getGlobalTracerProvider
  let tracer = makeTracer tp $detectInstrumentationLibrary tracerOptions
      env = TracedRedisEnv tracer (staticAttrs cfg)
  runRedis conn (runReaderT action env)


-------------------------------------------------------------------------------
-- Traced command dispatch
-------------------------------------------------------------------------------

{- | Send a raw Redis command with automatic tracing.

The command name is extracted from the first element of the
@[ByteString]@ and used as the span name and @db.operation.name@.
This is the primitive that all pre-traced commands in this module are
built on.

@
\-- Custom command:
myCmd :: ByteString -> TracedRedis (Either Reply ByteString)
myCmd key = 'sendRequest' [\"MYCMD\", key]

\-- Equivalent to the built-in 'get':
myGet :: ByteString -> TracedRedis (Either Reply (Maybe ByteString))
myGet key = 'sendRequest' [\"GET\", key]
@
-}
sendRequest :: (RedisResult a) => [B.ByteString] -> TracedRedis (Either Reply a)
sendRequest [] = Redis.sendRequest []
sendRequest bs@(cmd : _) = do
  TracedRedisEnv {..} <- TracedRedis ask
  ctx <- liftIO getContext
  let cmdName = TE.decodeUtf8 cmd
      cmdAttrs = treStaticAttrs <> SC.db_operation_name .@ cmdName
      spanArgs = defaultSpanArguments {kind = Client, attributes = A.buildAttrs cmdAttrs}
  s <- liftIO $ createSpanWithoutCallStack treTracer ctx cmdName spanArgs
  result <- Redis.sendRequest bs
  liftIO $ do
    case result of
      Left reply -> do
        let errText = replyErrorPrefix reply
        addAttributes' s (SC.db_response_statusCode .@ errText)
        setStatus s (OTel.Error errText)
      Right _ -> pure ()
    endSpan s Nothing
  pure result


{- | Wrap an arbitrary 'TracedRedis' action with a traced span.

Use this for commands that involve opaque hedis types (like 'Cursor')
where you can't express the command as raw protocol bytes via
'sendRequest'. The hedis-polymorphic command runs untraced inside
'TracedRedis'; this wrapper provides the span.

@
scanMatch :: Cursor -> ByteString -> TracedRedis (Either Reply (Cursor, [ByteString]))
scanMatch c pat = 'traced' \"SCAN\" (Redis.scanOpts c (Redis.ScanOpts (Just pat) Nothing))
@
-}
traced :: Text -> TracedRedis (Either Reply a) -> TracedRedis (Either Reply a)
traced cmdName action = do
  TracedRedisEnv {..} <- TracedRedis ask
  ctx <- liftIO getContext
  let cmdAttrs = treStaticAttrs <> SC.db_operation_name .@ cmdName
      spanArgs = defaultSpanArguments {kind = Client, attributes = A.buildAttrs cmdAttrs}
  s <- liftIO $ createSpanWithoutCallStack treTracer ctx cmdName spanArgs
  result <- action
  liftIO $ do
    case result of
      Left reply -> do
        let errText = replyErrorPrefix reply
        addAttributes' s (SC.db_response_statusCode .@ errText)
        setStatus s (OTel.Error errText)
      Right _ -> pure ()
    endSpan s Nothing
  pure result


replyErrorPrefix :: Reply -> Text
replyErrorPrefix (Error bs) =
  let prefix = C.takeWhile (/= ' ') bs
  in if C.null prefix then TE.decodeUtf8 bs else TE.decodeUtf8 prefix
replyErrorPrefix _ = "UNKNOWN"


-------------------------------------------------------------------------------
-- Argument encoding (mirrors hedis internals)
-------------------------------------------------------------------------------

encodeInt :: Integer -> B.ByteString
encodeInt = C.pack . show
{-# INLINE encodeInt #-}


encodeDbl :: Double -> B.ByteString
encodeDbl a
  | isInfinite a && a > 0 = "+inf"
  | isInfinite a && a < 0 = "-inf"
  | otherwise = C.pack (show a)
{-# INLINE encodeDbl #-}


-------------------------------------------------------------------------------
-- String commands
-------------------------------------------------------------------------------

get :: B.ByteString -> TracedRedis (Either Reply (Maybe B.ByteString))
get key = sendRequest ["GET", key]

set :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply Status)
set key val = sendRequest ["SET", key, val]

getset :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply (Maybe B.ByteString))
getset key val = sendRequest ["GETSET", key, val]

setnx :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply Bool)
setnx key val = sendRequest ["SETNX", key, val]

setex :: B.ByteString -> Integer -> B.ByteString -> TracedRedis (Either Reply Status)
setex key secs val = sendRequest ["SETEX", key, encodeInt secs, val]

psetex :: B.ByteString -> Integer -> B.ByteString -> TracedRedis (Either Reply Status)
psetex key ms val = sendRequest ["PSETEX", key, encodeInt ms, val]

mget :: [B.ByteString] -> TracedRedis (Either Reply [Maybe B.ByteString])
mget ks = sendRequest ("MGET" : ks)

mset :: [(B.ByteString, B.ByteString)] -> TracedRedis (Either Reply Status)
mset kvs = sendRequest ("MSET" : concatMap (\(k, v) -> [k, v]) kvs)

msetnx :: [(B.ByteString, B.ByteString)] -> TracedRedis (Either Reply Bool)
msetnx kvs = sendRequest ("MSETNX" : concatMap (\(k, v) -> [k, v]) kvs)

incr :: B.ByteString -> TracedRedis (Either Reply Integer)
incr key = sendRequest ["INCR", key]

incrby :: B.ByteString -> Integer -> TracedRedis (Either Reply Integer)
incrby key n = sendRequest ["INCRBY", key, encodeInt n]

incrbyfloat :: B.ByteString -> Double -> TracedRedis (Either Reply Double)
incrbyfloat key n = sendRequest ["INCRBYFLOAT", key, encodeDbl n]

decr :: B.ByteString -> TracedRedis (Either Reply Integer)
decr key = sendRequest ["DECR", key]

decrby :: B.ByteString -> Integer -> TracedRedis (Either Reply Integer)
decrby key n = sendRequest ["DECRBY", key, encodeInt n]

append :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply Integer)
append key val = sendRequest ["APPEND", key, val]

getrange :: B.ByteString -> Integer -> Integer -> TracedRedis (Either Reply B.ByteString)
getrange key start end = sendRequest ["GETRANGE", key, encodeInt start, encodeInt end]

setrange :: B.ByteString -> Integer -> B.ByteString -> TracedRedis (Either Reply Integer)
setrange key offset val = sendRequest ["SETRANGE", key, encodeInt offset, val]

strlen :: B.ByteString -> TracedRedis (Either Reply Integer)
strlen key = sendRequest ["STRLEN", key]


-------------------------------------------------------------------------------
-- Hash commands
-------------------------------------------------------------------------------

hget :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply (Maybe B.ByteString))
hget key field = sendRequest ["HGET", key, field]

hset :: B.ByteString -> B.ByteString -> B.ByteString -> TracedRedis (Either Reply Integer)
hset key field val = sendRequest ["HSET", key, field, val]

hsetnx :: B.ByteString -> B.ByteString -> B.ByteString -> TracedRedis (Either Reply Bool)
hsetnx key field val = sendRequest ["HSETNX", key, field, val]

hdel :: B.ByteString -> [B.ByteString] -> TracedRedis (Either Reply Integer)
hdel key fields = sendRequest ("HDEL" : key : fields)

hexists :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply Bool)
hexists key field = sendRequest ["HEXISTS", key, field]

hgetall :: B.ByteString -> TracedRedis (Either Reply [(B.ByteString, B.ByteString)])
hgetall key = sendRequest ["HGETALL", key]

hkeys :: B.ByteString -> TracedRedis (Either Reply [B.ByteString])
hkeys key = sendRequest ["HKEYS", key]

hvals :: B.ByteString -> TracedRedis (Either Reply [B.ByteString])
hvals key = sendRequest ["HVALS", key]

hlen :: B.ByteString -> TracedRedis (Either Reply Integer)
hlen key = sendRequest ["HLEN", key]

hmget :: B.ByteString -> [B.ByteString] -> TracedRedis (Either Reply [Maybe B.ByteString])
hmget key fields = sendRequest ("HMGET" : key : fields)

hmset :: B.ByteString -> [(B.ByteString, B.ByteString)] -> TracedRedis (Either Reply Status)
hmset key fvs = sendRequest ("HMSET" : key : concatMap (\(f, v) -> [f, v]) fvs)

hincrby :: B.ByteString -> B.ByteString -> Integer -> TracedRedis (Either Reply Integer)
hincrby key field n = sendRequest ["HINCRBY", key, field, encodeInt n]

hincrbyfloat :: B.ByteString -> B.ByteString -> Double -> TracedRedis (Either Reply Double)
hincrbyfloat key field n = sendRequest ["HINCRBYFLOAT", key, field, encodeDbl n]


-------------------------------------------------------------------------------
-- List commands
-------------------------------------------------------------------------------

lpush :: B.ByteString -> [B.ByteString] -> TracedRedis (Either Reply Integer)
lpush key vals = sendRequest ("LPUSH" : key : vals)

rpush :: B.ByteString -> [B.ByteString] -> TracedRedis (Either Reply Integer)
rpush key vals = sendRequest ("RPUSH" : key : vals)

lpushx :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply Integer)
lpushx key val = sendRequest ["LPUSHX", key, val]

rpushx :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply Integer)
rpushx key val = sendRequest ["RPUSHX", key, val]

lpop :: B.ByteString -> TracedRedis (Either Reply (Maybe B.ByteString))
lpop key = sendRequest ["LPOP", key]

rpop :: B.ByteString -> TracedRedis (Either Reply (Maybe B.ByteString))
rpop key = sendRequest ["RPOP", key]

blpop :: [B.ByteString] -> Integer -> TracedRedis (Either Reply (Maybe (B.ByteString, B.ByteString)))
blpop ks timeout = sendRequest ("BLPOP" : ks <> [encodeInt timeout])

brpop :: [B.ByteString] -> Integer -> TracedRedis (Either Reply (Maybe (B.ByteString, B.ByteString)))
brpop ks timeout = sendRequest ("BRPOP" : ks <> [encodeInt timeout])

rpoplpush :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply (Maybe B.ByteString))
rpoplpush src dst = sendRequest ["RPOPLPUSH", src, dst]

llen :: B.ByteString -> TracedRedis (Either Reply Integer)
llen key = sendRequest ["LLEN", key]

lrange :: B.ByteString -> Integer -> Integer -> TracedRedis (Either Reply [B.ByteString])
lrange key start stop = sendRequest ["LRANGE", key, encodeInt start, encodeInt stop]

lindex :: B.ByteString -> Integer -> TracedRedis (Either Reply (Maybe B.ByteString))
lindex key ix = sendRequest ["LINDEX", key, encodeInt ix]

lrem :: B.ByteString -> Integer -> B.ByteString -> TracedRedis (Either Reply Integer)
lrem key count val = sendRequest ["LREM", key, encodeInt count, val]

lset :: B.ByteString -> Integer -> B.ByteString -> TracedRedis (Either Reply Status)
lset key ix val = sendRequest ["LSET", key, encodeInt ix, val]

ltrim :: B.ByteString -> Integer -> Integer -> TracedRedis (Either Reply Status)
ltrim key start stop = sendRequest ["LTRIM", key, encodeInt start, encodeInt stop]

linsertBefore :: B.ByteString -> B.ByteString -> B.ByteString -> TracedRedis (Either Reply Integer)
linsertBefore key pivot val = sendRequest ["LINSERT", key, "BEFORE", pivot, val]

linsertAfter :: B.ByteString -> B.ByteString -> B.ByteString -> TracedRedis (Either Reply Integer)
linsertAfter key pivot val = sendRequest ["LINSERT", key, "AFTER", pivot, val]


-------------------------------------------------------------------------------
-- Set commands
-------------------------------------------------------------------------------

sadd :: B.ByteString -> [B.ByteString] -> TracedRedis (Either Reply Integer)
sadd key members = sendRequest ("SADD" : key : members)

srem :: B.ByteString -> [B.ByteString] -> TracedRedis (Either Reply Integer)
srem key members = sendRequest ("SREM" : key : members)

smembers :: B.ByteString -> TracedRedis (Either Reply [B.ByteString])
smembers key = sendRequest ["SMEMBERS", key]

sismember :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply Bool)
sismember key member = sendRequest ["SISMEMBER", key, member]

scard :: B.ByteString -> TracedRedis (Either Reply Integer)
scard key = sendRequest ["SCARD", key]

sunion :: [B.ByteString] -> TracedRedis (Either Reply [B.ByteString])
sunion ks = sendRequest ("SUNION" : ks)

sunionstore :: B.ByteString -> [B.ByteString] -> TracedRedis (Either Reply Integer)
sunionstore dst ks = sendRequest ("SUNIONSTORE" : dst : ks)

sinter :: [B.ByteString] -> TracedRedis (Either Reply [B.ByteString])
sinter ks = sendRequest ("SINTER" : ks)

sinterstore :: B.ByteString -> [B.ByteString] -> TracedRedis (Either Reply Integer)
sinterstore dst ks = sendRequest ("SINTERSTORE" : dst : ks)

sdiff :: [B.ByteString] -> TracedRedis (Either Reply [B.ByteString])
sdiff ks = sendRequest ("SDIFF" : ks)

sdiffstore :: B.ByteString -> [B.ByteString] -> TracedRedis (Either Reply Integer)
sdiffstore dst ks = sendRequest ("SDIFFSTORE" : dst : ks)

srandmember :: B.ByteString -> TracedRedis (Either Reply (Maybe B.ByteString))
srandmember key = sendRequest ["SRANDMEMBER", key]

spop :: B.ByteString -> TracedRedis (Either Reply (Maybe B.ByteString))
spop key = sendRequest ["SPOP", key]

smove :: B.ByteString -> B.ByteString -> B.ByteString -> TracedRedis (Either Reply Bool)
smove src dst member = sendRequest ["SMOVE", src, dst, member]


-------------------------------------------------------------------------------
-- Sorted set commands
-------------------------------------------------------------------------------

zadd :: B.ByteString -> [(Double, B.ByteString)] -> TracedRedis (Either Reply Integer)
zadd key scoreMembers =
  sendRequest ("ZADD" : key : concatMap (\(s, m) -> [encodeDbl s, m]) scoreMembers)

zrem :: B.ByteString -> [B.ByteString] -> TracedRedis (Either Reply Integer)
zrem key members = sendRequest ("ZREM" : key : members)

zrange :: B.ByteString -> Integer -> Integer -> TracedRedis (Either Reply [B.ByteString])
zrange key start stop = sendRequest ["ZRANGE", key, encodeInt start, encodeInt stop]

zrangeWithscores :: B.ByteString -> Integer -> Integer -> TracedRedis (Either Reply [(B.ByteString, Double)])
zrangeWithscores key start stop =
  sendRequest ["ZRANGE", key, encodeInt start, encodeInt stop, "WITHSCORES"]

zrangebyscore :: B.ByteString -> Double -> Double -> TracedRedis (Either Reply [B.ByteString])
zrangebyscore key lo hi = sendRequest ["ZRANGEBYSCORE", key, encodeDbl lo, encodeDbl hi]

zrangebyscoreLimit :: B.ByteString -> Double -> Double -> Integer -> Integer -> TracedRedis (Either Reply [B.ByteString])
zrangebyscoreLimit key lo hi off cnt =
  sendRequest ["ZRANGEBYSCORE", key, encodeDbl lo, encodeDbl hi, "LIMIT", encodeInt off, encodeInt cnt]

zrevrange :: B.ByteString -> Integer -> Integer -> TracedRedis (Either Reply [B.ByteString])
zrevrange key start stop = sendRequest ["ZREVRANGE", key, encodeInt start, encodeInt stop]

zrevrangeWithscores :: B.ByteString -> Integer -> Integer -> TracedRedis (Either Reply [(B.ByteString, Double)])
zrevrangeWithscores key start stop =
  sendRequest ["ZREVRANGE", key, encodeInt start, encodeInt stop, "WITHSCORES"]

zrevrangebyscore :: B.ByteString -> Double -> Double -> TracedRedis (Either Reply [B.ByteString])
zrevrangebyscore key hi lo = sendRequest ["ZREVRANGEBYSCORE", key, encodeDbl hi, encodeDbl lo]

zrevrangebyscoreLimit :: B.ByteString -> Double -> Double -> Integer -> Integer -> TracedRedis (Either Reply [B.ByteString])
zrevrangebyscoreLimit key hi lo off cnt =
  sendRequest ["ZREVRANGEBYSCORE", key, encodeDbl hi, encodeDbl lo, "LIMIT", encodeInt off, encodeInt cnt]

zcard :: B.ByteString -> TracedRedis (Either Reply Integer)
zcard key = sendRequest ["ZCARD", key]

zscore :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply (Maybe Double))
zscore key member = sendRequest ["ZSCORE", key, member]

zrank :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply (Maybe Integer))
zrank key member = sendRequest ["ZRANK", key, member]

zrevrank :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply (Maybe Integer))
zrevrank key member = sendRequest ["ZREVRANK", key, member]

zincrby :: B.ByteString -> Integer -> B.ByteString -> TracedRedis (Either Reply Double)
zincrby key n member = sendRequest ["ZINCRBY", key, encodeInt n, member]


-------------------------------------------------------------------------------
-- Key commands
-------------------------------------------------------------------------------

del :: [B.ByteString] -> TracedRedis (Either Reply Integer)
del ks = sendRequest ("DEL" : ks)

exists :: B.ByteString -> TracedRedis (Either Reply Bool)
exists key = sendRequest ["EXISTS", key]

expire :: B.ByteString -> Integer -> TracedRedis (Either Reply Bool)
expire key secs = sendRequest ["EXPIRE", key, encodeInt secs]

expireat :: B.ByteString -> Integer -> TracedRedis (Either Reply Bool)
expireat key ts = sendRequest ["EXPIREAT", key, encodeInt ts]

pexpire :: B.ByteString -> Integer -> TracedRedis (Either Reply Bool)
pexpire key ms = sendRequest ["PEXPIRE", key, encodeInt ms]

pexpireat :: B.ByteString -> Integer -> TracedRedis (Either Reply Bool)
pexpireat key ts = sendRequest ["PEXPIREAT", key, encodeInt ts]

persist :: B.ByteString -> TracedRedis (Either Reply Bool)
persist key = sendRequest ["PERSIST", key]

ttl :: B.ByteString -> TracedRedis (Either Reply Integer)
ttl key = sendRequest ["TTL", key]

pttl :: B.ByteString -> TracedRedis (Either Reply Integer)
pttl key = sendRequest ["PTTL", key]

getType :: B.ByteString -> TracedRedis (Either Reply RedisType)
getType key = sendRequest ["TYPE", key]

keys :: B.ByteString -> TracedRedis (Either Reply [B.ByteString])
keys pattern = sendRequest ["KEYS", pattern]

rename :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply Status)
rename src dst = sendRequest ["RENAME", src, dst]

renamenx :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply Bool)
renamenx src dst = sendRequest ["RENAMENX", src, dst]

-- Cursor is opaque — can't decompose to protocol bytes, so delegate to hedis.
scan :: Cursor -> TracedRedis (Either Reply (Cursor, [B.ByteString]))
scan c = traced "SCAN" (Redis.scan c)


-------------------------------------------------------------------------------
-- Server commands
-------------------------------------------------------------------------------

ping :: TracedRedis (Either Reply Status)
ping = sendRequest ["PING"]

echo :: B.ByteString -> TracedRedis (Either Reply B.ByteString)
echo msg = sendRequest ["ECHO", msg]

select :: Integer -> TracedRedis (Either Reply Status)
select ix = sendRequest ["SELECT", encodeInt ix]

dbsize :: TracedRedis (Either Reply Integer)
dbsize = sendRequest ["DBSIZE"]

flushdb :: TracedRedis (Either Reply Status)
flushdb = sendRequest ["FLUSHDB"]

flushall :: TracedRedis (Either Reply Status)
flushall = sendRequest ["FLUSHALL"]

info :: TracedRedis (Either Reply B.ByteString)
info = sendRequest ["INFO"]


-------------------------------------------------------------------------------
-- Pub/Sub (publish side only; subscribe requires a different monad)
-------------------------------------------------------------------------------

publish :: B.ByteString -> B.ByteString -> TracedRedis (Either Reply Integer)
publish channel msg = sendRequest ["PUBLISH", channel, msg]


-------------------------------------------------------------------------------
-- Scripting
-------------------------------------------------------------------------------

eval :: (RedisResult a) => B.ByteString -> [B.ByteString] -> [B.ByteString] -> TracedRedis (Either Reply a)
eval script ks args =
  sendRequest (["EVAL", script, encodeInt (fromIntegral (length ks))] <> ks <> args)

evalsha :: (RedisResult a) => B.ByteString -> [B.ByteString] -> [B.ByteString] -> TracedRedis (Either Reply a)
evalsha sha ks args =
  sendRequest (["EVALSHA", sha, encodeInt (fromIntegral (length ks))] <> ks <> args)


-------------------------------------------------------------------------------
-- HyperLogLog
-------------------------------------------------------------------------------

pfadd :: B.ByteString -> [B.ByteString] -> TracedRedis (Either Reply Integer)
pfadd key elems = sendRequest ("PFADD" : key : elems)

pfcount :: [B.ByteString] -> TracedRedis (Either Reply Integer)
pfcount ks = sendRequest ("PFCOUNT" : ks)

pfmerge :: B.ByteString -> [B.ByteString] -> TracedRedis (Either Reply B.ByteString)
pfmerge dst srcs = sendRequest ("PFMERGE" : dst : srcs)


-------------------------------------------------------------------------------
-- Transactions
-------------------------------------------------------------------------------

{- | Run a Redis transaction with a span around the MULTI/EXEC lifecycle.

Commands inside the 'RedisTx' block are queued (not individually traced)
and executed atomically by Redis.

@
'runTracedRedis' ci conn $ do
  result <- 'multiExec' $ do
    q1 <- Redis.set \"k\" \"v\"
    q2 <- Redis.get \"k\"
    pure (q1, q2)
  case result of
    TxSuccess (s, g) -> ...
    TxAborted -> ...
    TxError err -> ...
@
-}
multiExec :: RedisTx (Queued a) -> TracedRedis (TxResult a)
multiExec txAction = do
  TracedRedisEnv {..} <- TracedRedis ask
  ctx <- liftIO getContext
  let cmdAttrs = treStaticAttrs <> SC.db_operation_name .@ ("MULTI/EXEC" :: Text)
      spanArgs = defaultSpanArguments {kind = Client, attributes = A.buildAttrs cmdAttrs}
  s <- liftIO $ createSpanWithoutCallStack treTracer ctx "MULTI/EXEC" spanArgs
  result <- liftRedis (Redis.multiExec txAction)
  liftIO $ do
    case result of
      TxSuccess _ -> pure ()
      TxAborted -> setStatus s (OTel.Error "Transaction aborted")
      TxError err -> setStatus s (OTel.Error (T.pack err))
    endSpan s Nothing
  pure result
