module OpenTelemetry.Logs where
import OpenTelemetry.Internal.Trace.Types
import OpenTelemetry.Internal.Trace.Id
import Data.Word
import Data.Text
import Data.HashMap.Strict (HashMap)
import OpenTelemetry.Resource
import Data.Int (Int32)

data LogRecord = LogRecord
  { timestamp :: Timestamp
  , traceId :: Maybe TraceId
  , spanId :: Maybe SpanId
  , traceFlags :: Word8
  , severityText :: Text
  , severityNumber :: Int32 -- TODO newtype
  , name :: Text
  , body :: Text
  , resource :: HashMap Text Attribute
  , attributes :: [(Text, Attribute)]
  }