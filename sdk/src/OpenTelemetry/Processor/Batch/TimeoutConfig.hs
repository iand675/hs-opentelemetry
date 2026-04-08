module OpenTelemetry.Processor.Batch.TimeoutConfig where


-- | Configurable options for batch exporting frequence and size
data BatchTimeoutConfig = BatchTimeoutConfig
  { maxQueueSize :: Int
  -- ^ The maximum queue size. After the size is reached, spans are dropped.
  , scheduledDelayMillis :: Int
  -- ^ The delay interval in milliseconds between two consective exports.
  --   The default value is 5000.
  , exportTimeoutMillis :: Int
  -- ^ How long the export can run before it is cancelled.
  --   The default value is 30000.
  , maxExportBatchSize :: Int
  -- ^ The maximum batch size of every export. It must be
  --   smaller or equal to 'maxQueueSize'. The default value is 512.
  }
  deriving (Show)


-- | Default configuration values
batchTimeoutConfig :: BatchTimeoutConfig
batchTimeoutConfig =
  BatchTimeoutConfig
    { maxQueueSize = 1024
    , scheduledDelayMillis = 5000
    , exportTimeoutMillis = 30000
    , maxExportBatchSize = 512
    }
