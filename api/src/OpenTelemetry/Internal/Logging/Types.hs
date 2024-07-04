{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE InstanceSigs #-}

module OpenTelemetry.Internal.Logging.Types (
  LoggerProvider (..),
  Logger (..),
  LogRecord (..),
  LogRecordArguments (..),
  emptyLogRecordArguments,
  SeverityNumber (..),
  toShortName,
) where

import Data.Function (on)
import qualified Data.HashMap.Strict as H
import Data.Text (Text)
import OpenTelemetry.Attributes (AttributeLimits)
import OpenTelemetry.Common (Timestamp, TraceFlags)
import OpenTelemetry.Context.Types
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary)
import OpenTelemetry.Internal.Trace.Id (SpanId, TraceId)
import OpenTelemetry.LogAttributes (AnyValue, LogAttributes)
import OpenTelemetry.Resource (MaterializedResources)


-- | @Logger@s can be created from @LoggerProvider@s
data LoggerProvider = LoggerProvider
  { loggerProviderResource :: MaterializedResources
  , loggerProviderAttributeLimits :: AttributeLimits
  }


{- | @LogRecords@ can be created from @Loggers@. @Logger@s are uniquely identified by the @libraryName@, @libraryVersion@, @schemaUrl@ fields of @InstrumentationLibrary@.
Creating two @Logger@s with the same identity but different @libraryAttributes@ is a user error.
-}
data Logger = Logger
  { loggerInstrumentationScope :: InstrumentationLibrary
  -- ^ Details about the library that the @Logger@ instruments.
  , loggerProvider :: LoggerProvider
  -- ^ The @LoggerProvider@ that created this @Logger@. All configuration for the @Logger@ is contained in the @LoggerProvider@.
  }


{- | This is a data type that can represent logs from various sources: application log files, machine generated events, system logs, etc. [Specification outlined here.](https://opentelemetry.io/docs/specs/otel/logs/data-model/)
Existing log formats can be unambiguously mapped to this data type. Reverse mapping from this data type is also possible to the extent that the target log format has equivalent capabilities.
-}
data LogRecord body = LogRecord
  { logRecordTimestamp :: Maybe Timestamp
  -- ^ Time when the event occurred measured by the origin clock. This field is optional, it may be missing if the timestamp is unknown.
  , logRecordObservedTimestamp :: Timestamp
  -- ^ Time when the event was observed by the collection system. For events that originate in OpenTelemetry (e.g. using OpenTelemetry Logging SDK)
  -- this timestamp is typically set at the generation time and is equal to Timestamp. For events originating externally and collected by OpenTelemetry (e.g. using Collector)
  -- this is the time when OpenTelemetry’s code observed the event measured by the clock of the OpenTelemetry code. This field SHOULD be set once the event is observed by OpenTelemetry.
  --
  -- For converting OpenTelemetry log data to formats that support only one timestamp or when receiving OpenTelemetry log data by recipients that support only one timestamp internally the following logic is recommended:
  -- - Use Timestamp if it is present, otherwise use ObservedTimestamp
  , logRecordTracingDetails :: Maybe (TraceId, SpanId, TraceFlags)
  -- ^ Tuple contains three fields:
  --
  -- - Request trace id as defined in W3C Trace Context. Can be set for logs that are part of request processing and have an assigned trace id.
  -- - Span id. Can be set for logs that are part of a particular processing span.
  -- - Trace flag as defined in W3C Trace Context specification. At the time of writing the specification defines one flag - the SAMPLED flag.
  , logRecordSeverityText :: Maybe Text
  -- ^ severity text (also known as log level). This is the original string representation of the severity as it is known at the source. If this field is missing
  -- and SeverityNumber is present then the short name that corresponds to the SeverityNumber may be used as a substitution. This field is optional.
  , logRecordSeverityNumber :: Maybe SeverityNumber
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
  , logRecordBody :: body
  -- ^ A value containing the body of the log record. Can be for example a human-readable string message (including multi-line) describing the event in a free form or it can be a
  -- structured data composed of arrays and maps of other values. Body MUST support any type to preserve the semantics of structured logs emitted by the applications.
  -- Can vary for each occurrence of the event coming from the same source. This field is optional.
  --
  -- Type any
  --    Value of type any can be one of the following:
  --    - A scalar value: number, string or boolean,
  --    - A byte array,
  --    - An array (a list) of any values,
  --    - A map<string, any>.
  , logRecordResource :: MaterializedResources
  -- ^ Describes the source of the log, aka resource. Multiple occurrences of events coming from the same event source can happen across time and they all have the same value of Resource.
  -- Can contain for example information about the application that emits the record or about the infrastructure where the application runs. Data formats that represent this data model
  -- may be designed in a manner that allows the Resource field to be recorded only once per batch of log records that come from the same source. SHOULD follow OpenTelemetry semantic conventions for Resources.
  -- This field is optional.
  , logRecordInstrumentationScope :: InstrumentationLibrary
  , logRecordAttributes :: LogAttributes
  -- ^ Additional information about the specific event occurrence. Unlike the Resource field, which is fixed for a particular source, Attributes can vary for each occurrence of the event coming from the same source.
  -- Can contain information about the request context (other than Trace Context Fields). The log attribute model MUST support any type, a superset of standard Attribute, to preserve the semantics of structured attributes
  -- emitted by the applications. This field is optional.
  }
  deriving (Functor)


{- | Arguments that may be set on LogRecord creation. If observedTimestamp is not set, it will default to the current timestamp.
If context is not specified it will default to the current context. Refer to the documentation of @LogRecord@ for descriptions
of the fields.
-}
data LogRecordArguments body = LogRecordArguments
  { timestamp :: Maybe Timestamp
  , observedTimestamp :: Maybe Timestamp
  , context :: Maybe Context
  , severityText :: Maybe Text
  , severityNumber :: Maybe SeverityNumber
  , body :: body
  , attributes :: H.HashMap Text AnyValue
  }


emptyLogRecordArguments :: body -> LogRecordArguments body
emptyLogRecordArguments body =
  LogRecordArguments
    { timestamp = Nothing
    , observedTimestamp = Nothing
    , context = Nothing
    , severityText = Nothing
    , severityNumber = Nothing
    , body = body
    , attributes = H.empty
    }


data SeverityNumber
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
  | Err
  | Err2
  | Err3
  | Err4
  | Fatal
  | Fatal2
  | Fatal3
  | Fatal4
  | Unknown !Int


instance Enum SeverityNumber where
  toEnum 1 = Trace
  toEnum 2 = Trace2
  toEnum 3 = Trace3
  toEnum 4 = Trace4
  toEnum 5 = Debug
  toEnum 6 = Debug2
  toEnum 7 = Debug3
  toEnum 8 = Debug4
  toEnum 9 = Info
  toEnum 10 = Info2
  toEnum 11 = Info3
  toEnum 12 = Info4
  toEnum 13 = Warn
  toEnum 14 = Warn2
  toEnum 15 = Warn3
  toEnum 16 = Warn4
  toEnum 17 = Err
  toEnum 18 = Err2
  toEnum 19 = Err3
  toEnum 20 = Err4
  toEnum 21 = Fatal
  toEnum 22 = Fatal2
  toEnum 23 = Fatal3
  toEnum 24 = Fatal4
  toEnum n = Unknown n


  fromEnum Trace = 1
  fromEnum Trace2 = 2
  fromEnum Trace3 = 3
  fromEnum Trace4 = 4
  fromEnum Debug = 5
  fromEnum Debug2 = 6
  fromEnum Debug3 = 7
  fromEnum Debug4 = 8
  fromEnum Info = 9
  fromEnum Info2 = 10
  fromEnum Info3 = 11
  fromEnum Info4 = 12
  fromEnum Warn = 13
  fromEnum Warn2 = 14
  fromEnum Warn3 = 15
  fromEnum Warn4 = 16
  fromEnum Err = 17
  fromEnum Err2 = 18
  fromEnum Err3 = 19
  fromEnum Err4 = 20
  fromEnum Fatal = 21
  fromEnum Fatal2 = 22
  fromEnum Fatal3 = 23
  fromEnum Fatal4 = 24
  fromEnum (Unknown n) = n


instance Eq SeverityNumber where
  (==) = on (==) fromEnum


instance Ord SeverityNumber where
  compare = on compare fromEnum


toShortName :: SeverityNumber -> Maybe Text
toShortName Trace = Just "TRACE"
toShortName Trace2 = Just "TRACE2"
toShortName Trace3 = Just "TRACE3"
toShortName Trace4 = Just "TRACE4"
toShortName Debug = Just "DEBUG"
toShortName Debug2 = Just "DEBUG2"
toShortName Debug3 = Just "DEBUG3"
toShortName Debug4 = Just "DEBUG4"
toShortName Info = Just "INFO"
toShortName Info2 = Just "INFO2"
toShortName Info3 = Just "INFO3"
toShortName Info4 = Just "INFO4"
toShortName Warn = Just "WARN"
toShortName Warn2 = Just "WARN2"
toShortName Warn3 = Just "WARN3"
toShortName Warn4 = Just "WARN4"
toShortName Err = Just "ERROR"
toShortName Err2 = Just "ERROR2"
toShortName Err3 = Just "ERROR3"
toShortName Err4 = Just "ERROR4"
toShortName Fatal = Just "FATAL"
toShortName Fatal2 = Just "FATAL2"
toShortName Fatal3 = Just "FATAL3"
toShortName Fatal4 = Just "FATAL4"
toShortName (Unknown _) = Nothing
