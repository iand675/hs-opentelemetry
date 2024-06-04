{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module OpenTelemetry.Logging.Core (
  LogRecord (..),
) where

import Data.Int (Int64)
import Data.Text (Text)
import OpenTelemetry.Common
import OpenTelemetry.LogAttributes (LogAttributes)
import OpenTelemetry.Resource (MaterializedResources)
import OpenTelemetry.Trace.Id (SpanId, TraceId)


data LogRecord body = LogRecord
  { timestamp :: Maybe Timestamp
  -- ^ Time when the event occurred measured by the origin clock. This field is optional, it may be missing if the timestamp is unknown.
  , observedTimestamp :: Timestamp
  -- ^ Time when the event was observed by the collection system. For events that originate in OpenTelemetry (e.g. using OpenTelemetry Logging SDK)
  -- this timestamp is typically set at the generation time and is equal to Timestamp. For events originating externally and collected by OpenTelemetry (e.g. using Collector)
  -- this is the time when OpenTelemetry’s code observed the event measured by the clock of the OpenTelemetry code. This field SHOULD be set once the event is observed by OpenTelemetry.
  --
  -- For converting OpenTelemetry log data to formats that support only one timestamp or when receiving OpenTelemetry log data by recipients that support only one timestamp internally the following logic is recommended:
  -- - Use Timestamp if it is present, otherwise use ObservedTimestamp
  , tracingDetails :: Maybe (TraceId, SpanId, TraceFlags)
  -- ^ Tuple contains three fields:
  --
  -- - Request trace id as defined in W3C Trace Context. Can be set for logs that are part of request processing and have an assigned trace id.
  -- - Span id. Can be set for logs that are part of a particular processing span.
  -- - Trace flag as defined in W3C Trace Context specification. At the time of writing the specification defines one flag - the SAMPLED flag.
  , severityText :: Maybe Text
  -- ^ severity text (also known as log level). This is the original string representation of the severity as it is known at the source. If this field is missing
  -- and SeverityNumber is present then the short name that corresponds to the SeverityNumber may be used as a substitution. This field is optional.
  , severityNumber :: Maybe Int64
  -- ^ SeverityNumber is an integer number. Smaller numerical values correspond to less severe events (such as debug events), larger numerical values correspond to
  -- more severe events (such as errors and critical events). The following table defines the meaning of SeverityNumber value:
  --
  -- +-----------------------+-------------+------------------------------------------------------------------------------------------+
  -- | SeverityNumber range  | Range name  | Meaning                                                                                  |
  -- +=======================+=============+==========================================================================================+
  -- | 1-4                   | TRACE       | A fine-grained debugging event. Typically disabled in default configurations.            |
  -- +-----------------------+-------------+------------------------------------------------------------------------------------------+
  -- | 5-8                   | DEBUG       | A debugging event.                                                                       |
  -- +-----------------------+-------------+------------------------------------------------------------------------------------------+
  -- | 9-12                  | INFO        | An informational event. Indicates that an event happened.                                |
  -- +-----------------------+-------------+------------------------------------------------------------------------------------------+
  -- | 13-16                 | WARN        | A warning event. Not an error but is likely more important than an informational event.  |
  -- +-----------------------+-------------+------------------------------------------------------------------------------------------+
  -- | 17-20                 | ERROR       | An error event. Something went wrong.                                                    |
  -- +-----------------------+-------------+------------------------------------------------------------------------------------------+
  -- | 21-24                 | FATAL       | A fatal error such as application or system crash.                                       |
  -- +-----------------------+-------------+------------------------------------------------------------------------------------------+
  -- Smaller numerical values in each range represent less important (less severe) events. Larger numerical values in each range represent more important (more severe) events.
  -- For example SeverityNumber=17 describes an error that is less critical than an error with SeverityNumber=20.
  --
  -- Mappings from existing logging systems and formats (or source format for short) must define how severity (or log level) of that particular format corresponds to SeverityNumber
  -- of this data model based on the meaning given for each range in the above table. [More Information](https://opentelemetry.io/docs/specs/otel/logs/data-model/#mapping-of-severitynumber)
  --
  -- [These short names](https://opentelemetry.io/docs/specs/otel/logs/data-model/#displaying-severity) can be used to represent SeverityNumber in the UI
  --
  -- In the contexts where severity participates in less-than / greater-than comparisons SeverityNumber field should be used.
  -- SeverityNumber can be compared to another SeverityNumber or to numbers in the 1..24 range (or to the corresponding short names).
  , body :: body
  -- ^ A value containing the body of the log record. Can be for example a human-readable string message (including multi-line) describing the event in a free form or it can be a
  -- structured data composed of arrays and maps of other values. Body MUST support any type to preserve the semantics of structured logs emitted by the applications.
  -- Can vary for each occurrence of the event coming from the same source. This field is optional.
  --
  -- Type any (functions that use Log should have a Typeclass constraint of (ToValue body) => ...)
  --    Value of type any can be one of the following:
  --    - A scalar value: number, string or boolean,
  --    - A byte array,
  --    - An array (a list) of any values,
  --    - A map<string, any>.
  , resource :: Maybe MaterializedResources
  -- ^ Describes the source of the log, aka resource. Multiple occurrences of events coming from the same event source can happen across time and they all have the same value of Resource.
  -- Can contain for example information about the application that emits the record or about the infrastructure where the application runs. Data formats that represent this data model
  -- may be designed in a manner that allows the Resource field to be recorded only once per batch of log records that come from the same source. SHOULD follow OpenTelemetry semantic conventions for Resources.
  -- This field is optional.
  , attributes :: LogAttributes
  -- ^ Additional information about the specific event occurrence. Unlike the Resource field, which is fixed for a particular source, Attributes can vary for each occurrence of the event coming from the same source.
  -- Can contain information about the request context (other than Trace Context Fields). The log attribute model MUST support any type, a superset of standard Attribute, to preserve the semantics of structured attributes
  -- emitted by the applications. This field is optional.
  }
  deriving stock (Functor)

{- data SeverityNumber
  = Trace
  | Trace2
  | Trace3
  | Trace4
  | Debug
  | Debug2
  | Debug3
  | Debug4
  | Info
  | Info2
  | Info3
  | Info4
  | Warn
  | Warn2
  | Warn3
  | Warn4
  | Error
  | Error2
  | Error3
  | Error4
  | Fatal
  | Fatal2
  | Fatal3
  | Fatal4
  | Unknown !Int32
  deriving (Eq, Ord, Read, Show )

instance Enum SeverityNumber where
  toEnum 1 = Trace
  toEnum 2 = Trace2
  toEnum 3 = Trace3
  toEnum 4 = Trace4
  ... -}

-- severityTrace :: SeverityNumber
-- severityTrace = 1
-- severityTrace2 :: SeverityNumber
-- severityTrace2 = 2
-- severityTrace3 :: SeverityNumber
-- severityTrace3 = 3
-- severityTrace4 :: SeverityNumber
-- severityTrace4 = 4
-- severityDebug :: SeverityNumber
-- severityDebug = 5
-- severityDebug2 :: SeverityNumber
-- severityDebug2 = 6
-- severityDebug3 :: SeverityNumber
-- severityDebug3 = 7
-- severityDebug4 :: SeverityNumber
-- severityDebug4 = 8
-- severityInfo :: SeverityNumber
-- severityInfo = 9
-- severityInfo2 :: SeverityNumber
-- severityInfo2 = 10
-- severityInfo3 :: SeverityNumber
-- severityInfo3 = 11
-- severityInfo4 :: SeverityNumber
-- severityInfo4 = 12
-- severityWarn :: SeverityNumber
-- severityWarn = 13
-- severityWarn2 :: SeverityNumber
-- severityWarn2 = 14
-- severityWarn3 :: SeverityNumber
-- severityWarn3 = 15
-- severityWarn4 :: SeverityNumber
-- severityWarn4 = 16
-- severityError :: SeverityNumber
-- severityError = 17
-- severityError2 :: SeverityNumber
-- severityError2 = 18
-- severityError3 :: SeverityNumber
-- severityError3 = 19
-- severityError4 :: SeverityNumber
-- severityError4 = 20
-- severityFatal :: SeverityNumber
-- severityFatal = 21
-- severityFatal2 :: SeverityNumber
-- severityFatal2 = 22
-- severityFatal3 :: SeverityNumber
-- severityFatal3 = 23
-- severityFatal4 :: SeverityNumber
-- severityFatal4 = 24
