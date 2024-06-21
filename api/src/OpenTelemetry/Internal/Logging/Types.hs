{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE InstanceSigs #-}

module OpenTelemetry.Internal.Logging.Types (
  LoggerProvider (..),
  Logger (..),
  LogRecord (..),
  LogRecordArguments (..),
  mkSeverityNumber,
  shortName,
  severityInt,
) where

import Data.Int (Int64)
import Data.Text (Text)
import OpenTelemetry.Common (Timestamp, TraceFlags)
import OpenTelemetry.Context.Types
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary)
import OpenTelemetry.Internal.Trace.Id (SpanId, TraceId)
import OpenTelemetry.LogAttributes (LogAttributes)
import OpenTelemetry.Resource (MaterializedResources)


-- | @Logger@s can be created from @LoggerProvider@s
data LoggerProvider = LoggerProvider
  { loggerProviderResource :: MaterializedResources
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
  , severityNumber :: Maybe Int
  , body :: body
  , attributes :: LogAttributes
  }


data SeverityNumber = SeverityNumber {shortName :: Maybe Text, severityInt :: !Int64} deriving (Read, Show)


instance Eq SeverityNumber where
  (==) :: SeverityNumber -> SeverityNumber -> Bool
  n == m = severityInt n == severityInt m


instance Ord SeverityNumber where
  compare :: SeverityNumber -> SeverityNumber -> Ordering
  compare n m = compare (severityInt n) (severityInt m)


mkSeverityNumber :: (Integral n) => n -> SeverityNumber
mkSeverityNumber n = SeverityNumber {..}
  where
    severityInt = fromIntegral n
    shortName = mkShortName n


mkShortName :: (Integral n) => n -> Maybe Text
mkShortName 1 = Just "TRACE"
mkShortName 2 = Just "TRACE2"
mkShortName 3 = Just "TRACE3"
mkShortName 4 = Just "TRACE4"
mkShortName 5 = Just "DEBUG"
mkShortName 6 = Just "DEBUG2"
mkShortName 7 = Just "DEBUG3"
mkShortName 8 = Just "DEBUG4"
mkShortName 9 = Just "INFO"
mkShortName 10 = Just "INFO2"
mkShortName 11 = Just "INFO3"
mkShortName 12 = Just "INFO4"
mkShortName 13 = Just "WARN"
mkShortName 14 = Just "WARN2"
mkShortName 15 = Just "WARN3"
mkShortName 16 = Just "WARN4"
mkShortName 17 = Just "ERROR"
mkShortName 18 = Just "ERROR2"
mkShortName 19 = Just "ERROR3"
mkShortName 20 = Just "ERROR4"
mkShortName 21 = Just "FATAL"
mkShortName 22 = Just "FATAL2"
mkShortName 23 = Just "FATAL3"
mkShortName 24 = Just "FATAL4"
mkShortName _ = Nothing
