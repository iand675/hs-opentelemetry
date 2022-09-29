{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module OpenTelemetry.Logging.Core where

import Data.Int (Int32, Int64)
import Data.Text (Text)
import OpenTelemetry.Attributes (Attribute)
import OpenTelemetry.Common
import OpenTelemetry.Resource (MaterializedResources)
import OpenTelemetry.Trace.Id (SpanId, TraceId)


data Log body = Log
  { timestamp :: Maybe Timestamp
  -- ^ Time when the event occurred measured by the origin clock. This field is optional, it may be missing if the timestamp is unknown.
  , tracingDetails :: Maybe (TraceId, SpanId, TraceFlags)
  -- ^ Tuple contains three fields:
  --
  -- - Request trace id as defined in W3C Trace Context. Can be set for logs that are part of request processing and have an assigned trace id.
  -- - Span id. Can be set for logs that are part of a particular processing span.
  -- - Trace flag as defined in W3C Trace Context specification. At the time of writing the specification defines one flag - the SAMPLED flag.
  , severityText :: Maybe Text
  -- ^ severity text (also known as log level). This is the original string representation of the severity as it is known at the source. If this field is missing and SeverityNumber is present then the short name that corresponds to the SeverityNumber may be used as a substitution. This field is optional.
  , severityNumber :: Maybe Int64
  -- ^ SeverityNumber is an integer number. Smaller numerical values correspond to less severe events (such as debug events), larger numerical values correspond to more severe events (such as errors and critical events). The following table defines the meaning of SeverityNumber value:
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
  , name :: Maybe Text
  -- ^ Short low cardinality event type that does not contain varying parts. Name describes what happened (e.g. "ProcessStarted"). Recommended to be no longer than 50 characters. Typically used for filtering and grouping purposes in backends.
  , body :: body
  -- ^ A value containing the body of the log record. Can be for example a human-readable string message (including multi-line) describing the event in a free form or it can be a structured data composed of arrays and maps of other values. First-party Applications SHOULD use a string message. However, a structured body may be necessary to preserve the semantics of some existing log formats. Can vary for each occurrence of the event coming from the same source. This field is optional.
  , {-
    Type any
      Value of type any can be one of the following:

      A scalar value: number, string or boolean,

      A byte array,

      An array (a list) of any values,

      A map<string, any>.
    -}

    resource :: Maybe MaterializedResources
  -- ^ Describes the source of the log, aka resource. Multiple occurrences of events coming from the same event source can happen across time and they all have the same value of Resource. Can contain for example information about the application that emits the record or about the infrastructure where the application runs. Data formats that represent this data model may be designed in a manner that allows the Resource field to be recorded only once per batch of log records that come from the same source. SHOULD follow OpenTelemetry semantic conventions for Resources. This field is optional.
  , attributes :: Maybe [(Text, Attribute)]
  -- ^ Additional information about the specific event occurrence. Unlike the Resource field, which is fixed for a particular source, Attributes can vary for each occurrence of the event coming from the same source. Can contain information about the request context (other than TraceId/SpanId). SHOULD follow OpenTelemetry semantic conventions for Log Attributes or semantic conventions for Span Attributes. This field is optional.
  }
  deriving stock (Functor)


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
  | Error
  | Error2
  | Error3
  | Error4
  | Fatal
  | Fatal2
  | Fatal3
  | Fatal4
  | Unknown !Int32
  deriving (Eq, Ord, Read, Show)

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
