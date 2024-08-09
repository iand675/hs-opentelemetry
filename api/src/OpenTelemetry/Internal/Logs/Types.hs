{-# LANGUAGE NamedFieldPuns #-}

module OpenTelemetry.Internal.Logs.Types (
  LogRecordExporter,
  LogRecordExporterArguments (..),
  mkLogRecordExporter,
  logRecordExporterExport,
  logRecordExporterForceFlush,
  logRecordExporterShutdown,
  LogRecordProcessor (..),
  LoggerProvider (..),
  Logger (..),
  ReadWriteLogRecord,
  mkReadWriteLogRecord,
  ReadableLogRecord,
  mkReadableLogRecord,
  IsReadableLogRecord (..),
  IsReadWriteLogRecord (..),
  ImmutableLogRecord (..),
  LogRecordArguments (..),
  emptyLogRecordArguments,
  SeverityNumber (..),
  toShortName,
) where

import Control.Concurrent (MVar, newMVar, withMVar)
import Control.Concurrent.Async
import Data.Function (on)
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as H
import Data.IORef (IORef, atomicModifyIORef, modifyIORef, newIORef, readIORef)
import Data.Text (Text)
import Data.Vector (Vector)
import OpenTelemetry.Common (Timestamp, TraceFlags)
import OpenTelemetry.Context.Types (Context)
import OpenTelemetry.Internal.Common.Types (ExportResult, InstrumentationLibrary, ShutdownResult)
import OpenTelemetry.Internal.Trace.Id (SpanId, TraceId)
import OpenTelemetry.LogAttributes
import OpenTelemetry.Resource (MaterializedResources)


-- | See @LogRecordExporter@ for documentation
data LogRecordExporterArguments = LogRecordExporterArguments
  { logRecordExporterArgumentsExport :: Vector ReadableLogRecord -> IO ExportResult
  -- ^ See @logRecordExporterExport@ for documentation
  , logRecordExporterArgumentsForceFlush :: IO ()
  -- ^ See @logRecordExporterArgumentsForceFlush@ for documentation
  , logRecordExporterArgumentsShutdown :: IO ()
  -- ^ See @logRecordExporterArgumentsShutdown@ for documentation
  }


{- | @LogRecordExporter@ defines the interface that protocol-specific exporters must implement so that they can be plugged into OpenTelemetry SDK and support sending of telemetry data.

The goal of the interface is to minimize burden of implementation for protocol-dependent telemetry exporters. The protocol exporter is expected to be primarily a simple telemetry data encoder and transmitter.

@LogRecordExporter@s provide thread safety when calling @logRecordExporterExport@
-}
newtype LogRecordExporter = LogRecordExporter {unExporter :: MVar LogRecordExporterArguments}


mkLogRecordExporter :: LogRecordExporterArguments -> IO LogRecordExporter
mkLogRecordExporter = fmap LogRecordExporter . newMVar


{- | Exports a batch of ReadableLogRecords. Protocol exporters that will implement this function are typically expected to serialize
and transmit the data to the destination.

Export will never be called concurrently for the same exporter instance. Depending on the implementation the result of the export
may be returned to the Processor not in the return value of the call to Export but in a language specific way for signaling completion
of an asynchronous task. This means that while an instance of an exporter will never have it Export called concurrently it does not
mean that the task of exporting can not be done concurrently. How this is done is outside the scope of this specification.
Each implementation MUST document the concurrency characteristics the SDK requires of the exporter.

Export MUST NOT block indefinitely, there MUST be a reasonable upper limit after which the call must time out with an error result (Failure).

Concurrent requests and retry logic is the responsibility of the exporter. The default SDK’s LogRecordProcessors SHOULD NOT implement
retry logic, as the required logic is likely to depend heavily on the specific protocol and backend the logs are being sent to.
For example, the OpenTelemetry Protocol (OTLP) specification defines logic for both sending concurrent requests and retrying requests.

Result:
Success - The batch has been successfully exported. For protocol exporters this typically means that the data is sent over the wire and delivered to the destination server.
Failure - exporting failed. The batch must be dropped. For example, this can happen when the batch contains bad data and cannot be serialized.
-}
logRecordExporterExport :: LogRecordExporter -> Vector ReadableLogRecord -> IO ExportResult
logRecordExporterExport exporter lrs = withMVar (unExporter exporter) $ \e -> logRecordExporterArgumentsExport e lrs


{- | This is a hint to ensure that the export of any ReadableLogRecords the exporter has received prior to the call to ForceFlush SHOULD
be completed as soon as possible, preferably before returning from this method.

ForceFlush SHOULD provide a way to let the caller know whether it succeeded, failed or timed out.

ForceFlush SHOULD only be called in cases where it is absolutely necessary, such as when using some FaaS providers that may suspend
the process after an invocation, but before the exporter exports the ReadlableLogRecords.

ForceFlush SHOULD complete or abort within some timeout. ForceFlush can be implemented as a blocking API or an asynchronous API which
notifies the caller via a callback or an event. OpenTelemetry SDK authors MAY decide if they want to make the flush timeout configurable.
-}
logRecordExporterForceFlush :: LogRecordExporter -> IO ()
logRecordExporterForceFlush = flip withMVar logRecordExporterArgumentsForceFlush . unExporter


{- | Shuts down the exporter. Called when SDK is shut down. This is an opportunity for exporter to do any cleanup required.

Shutdown SHOULD be called only once for each LogRecordExporter instance. After the call to Shutdown subsequent calls to Export are not
allowed and SHOULD return a Failure result.

Shutdown SHOULD NOT block indefinitely (e.g. if it attempts to flush the data and the destination is unavailable).
OpenTelemetry SDK authors MAY decide if they want to make the shutdown timeout configurable.
-}
logRecordExporterShutdown :: LogRecordExporter -> IO ()
logRecordExporterShutdown = flip withMVar logRecordExporterArgumentsShutdown . unExporter


{- | LogRecordProcessor is an interface which allows hooks for LogRecord emitting.

Built-in processors are responsible for batching and conversion of LogRecords to exportable representation and passing batches to exporters.

LogRecordProcessors can be registered directly on SDK LoggerProvider and they are invoked in the same order as they were registered.

Each processor registered on LoggerProvider is part of a pipeline that consists of a processor and optional exporter. The SDK MUST allow each pipeline to end with an individual exporter.

The SDK MUST allow users to implement and configure custom processors and decorate built-in processors for advanced scenarios such as enriching with attributes.

The following diagram shows LogRecordProcessor’s relationship to other components in the SDK:

+-----+------------------------+   +------------------------------+   +-------------------------+
|     |                        |   |                              |   |                         |
|     |                        |   | Batching LogRecordProcessor  |   |    LogRecordExporter    |
|     |                        +---> Simple LogRecordProcessor    +--->     (OtlpExporter)      |
|     |                        |   |                              |   |                         |
| SDK | Logger.emit(LogRecord) |   +------------------------------+   +-------------------------+
|     |                        |
|     |                        |
|     |                        |
|     |                        |
|     |                        |
+-----+------------------------+
-}
data LogRecordProcessor = LogRecordProcessor
  { logRecordProcessorOnEmit :: ReadWriteLogRecord -> Context -> IO ()
  -- ^ Called when a LogRecord is emitted. This method is called synchronously on the thread that emitted the LogRecord, therefore it SHOULD NOT block or throw exceptions.
  --
  -- A LogRecordProcessor may freely modify logRecord for the duration of the OnEmit call. If logRecord is needed after OnEmit returns (i.e. for asynchronous processing) only reads are permitted.
  , logRecordProcessorShutdown :: IO (Async ShutdownResult)
  -- ^ Shuts down the processor. Called when SDK is shut down. This is an opportunity for processor to do any cleanup required.
  --
  -- Shutdown SHOULD be called only once for each LogRecordProcessor instance. After the call to Shutdown, subsequent calls to OnEmit are not allowed. SDKs SHOULD ignore these calls gracefully, if possible.
  --
  -- Shutdown SHOULD provide a way to let the caller know whether it succeeded, failed or timed out.
  --
  -- Shutdown MUST include the effects of ForceFlush.
  --
  -- Shutdown SHOULD complete or abort within some timeout. Shutdown can be implemented as a blocking API or an asynchronous API which notifies the caller via a callback or an event.
  -- OpenTelemetry SDK authors can decide if they want to make the shutdown timeout configurable.
  , logRecordProcessorForceFlush :: IO ()
  -- ^ This is a hint to ensure that any tasks associated with LogRecords for which the LogRecordProcessor had already received events prior to the call to ForceFlush SHOULD be completed
  -- as soon as possible, preferably before returning from this method.
  --
  -- In particular, if any LogRecordProcessor has any associated exporter, it SHOULD try to call the exporter’s Export with all LogRecords for which this was not already done and then invoke ForceFlush on it.
  -- The built-in LogRecordProcessors MUST do so. If a timeout is specified (see below), the LogRecordProcessor MUST prioritize honoring the timeout over finishing all calls. It MAY skip or abort some or all
  -- Export or ForceFlush calls it has made to achieve this goal.
  --
  -- ForceFlush SHOULD provide a way to let the caller know whether it succeeded, failed or timed out.
  --
  -- ForceFlush SHOULD only be called in cases where it is absolutely necessary, such as when using some FaaS providers that may suspend the process after an invocation, but before the LogRecordProcessor exports the emitted LogRecords.
  --
  -- ForceFlush SHOULD complete or abort within some timeout. ForceFlush can be implemented as a blocking API or an asynchronous API which notifies the caller via a callback or an event. OpenTelemetry SDK authors
  -- can decide if they want to make the flush timeout configurable.
  }


-- | @Logger@s can be created from @LoggerProvider@s
data LoggerProvider = LoggerProvider
  { loggerProviderProcessors :: Vector LogRecordProcessor
  , loggerProviderResource :: MaterializedResources
  -- ^ Describes the source of the log, aka resource. Multiple occurrences of events coming from the same event source can happen across time and they all have the same value of Resource.
  -- Can contain for example information about the application that emits the record or about the infrastructure where the application runs. Data formats that represent this data model
  -- may be designed in a manner that allows the Resource field to be recorded only once per batch of log records that come from the same source. SHOULD follow OpenTelemetry semantic conventions for Resources.
  -- This field is optional.
  , loggerProviderAttributeLimits :: AttributeLimits
  }


{- | @LogRecords@ can be created from @Loggers@. @Logger@s are uniquely identified by the @libraryName@, @libraryVersion@, @schemaUrl@ fields of @InstrumentationLibrary@.
Creating two @Logger@s with the same identity but different @libraryAttributes@ is a user error.
-}
data Logger = Logger
  { loggerInstrumentationScope :: InstrumentationLibrary
  -- ^ Details about the library that the @Logger@ instruments.
  , loggerLoggerProvider :: LoggerProvider
  -- ^ The @LoggerProvider@ that created this @Logger@. All configuration for the @Logger@ is contained in the @LoggerProvider@.
  }


{- | This is a data type that can represent logs from various sources: application log files, machine generated events, system logs, etc. [Specification outlined here.](https://opentelemetry.io/docs/specs/otel/logs/data-model/)
Existing log formats can be unambiguously mapped to this data type. Reverse mapping from this data type is also possible to the extent that the target log format has equivalent capabilities.
Uses an IORef under the hood to allow mutability.
-}
data ReadWriteLogRecord = ReadWriteLogRecord Logger (IORef ImmutableLogRecord)


mkReadWriteLogRecord :: Logger -> ImmutableLogRecord -> IO ReadWriteLogRecord
mkReadWriteLogRecord l = fmap (ReadWriteLogRecord l) . newIORef


newtype ReadableLogRecord = ReadableLogRecord {readableLogRecord :: ReadWriteLogRecord}


mkReadableLogRecord :: ReadWriteLogRecord -> ReadableLogRecord
mkReadableLogRecord = ReadableLogRecord


{- | This is a typeclass representing @LogRecord@s that can be read from.

A function receiving this as an argument MUST be able to access all the information added to the LogRecord. It MUST also be able to access the Instrumentation Scope and Resource information (implicitly) associated with the LogRecord.

The trace context fields MUST be populated from the resolved Context (either the explicitly passed Context or the current Context) when emitted.

Counts for attributes due to collection limits MUST be available for exporters to report as described in the transformation to non-OTLP formats specification.
-}
class IsReadableLogRecord r where
  -- | Reads the current state of the @LogRecord@ from its internal @IORef@. The implementation mirrors @readIORef@.
  readLogRecord :: r -> IO ImmutableLogRecord


  -- | Reads the @InstrumentationScope@ from the @Logger@ that emitted the @LogRecord@
  readLogRecordInstrumentationScope :: r -> InstrumentationLibrary


  -- | Reads the @Resource@ from the @LoggerProvider@ that emitted the @LogRecord@
  readLogRecordResource :: r -> MaterializedResources


{- | This is a typeclass representing @LogRecord@s that can be read from or written to. All @ReadWriteLogRecord@s are @ReadableLogRecord@s.

A function receiving this as an argument MUST additionally be able to modify the following information added to the LogRecord:

- Timestamp
- ObservedTimestamp
- SeverityText
- SeverityNumber
- Body
- Attributes (addition, modification, removal)
- TraceId
- SpanId
- TraceFlags
-}
class (IsReadableLogRecord r) => IsReadWriteLogRecord r where
  -- | Reads the attribute limits from the @LoggerProvider@ that emitted the @LogRecord@. These are needed to add more attributes.
  readLogRecordAttributeLimits :: r -> AttributeLimits


  -- | Modifies the @LogRecord@ using its internal @IORef@. This is lazy and is not an atomic operation. The implementation mirrors @modifyIORef@.
  modifyLogRecord :: r -> (ImmutableLogRecord -> ImmutableLogRecord) -> IO ()


  -- | An atomic version of @modifyLogRecord@. This function is lazy. The implementation mirrors @atomicModifyIORef@.
  atomicModifyLogRecord :: r -> (ImmutableLogRecord -> (ImmutableLogRecord, b)) -> IO b


instance IsReadableLogRecord ReadableLogRecord where
  readLogRecord = readLogRecord . readableLogRecord
  readLogRecordInstrumentationScope = readLogRecordInstrumentationScope . readableLogRecord
  readLogRecordResource = readLogRecordResource . readableLogRecord


instance IsReadableLogRecord ReadWriteLogRecord where
  readLogRecord (ReadWriteLogRecord _ ref) = readIORef ref
  readLogRecordInstrumentationScope (ReadWriteLogRecord (Logger {loggerInstrumentationScope}) _) = loggerInstrumentationScope
  readLogRecordResource (ReadWriteLogRecord Logger {loggerLoggerProvider = LoggerProvider {loggerProviderResource}} _) = loggerProviderResource


instance IsReadWriteLogRecord ReadWriteLogRecord where
  readLogRecordAttributeLimits (ReadWriteLogRecord Logger {loggerLoggerProvider = LoggerProvider {loggerProviderAttributeLimits}} _) = loggerProviderAttributeLimits
  modifyLogRecord (ReadWriteLogRecord _ ref) = modifyIORef ref
  atomicModifyLogRecord (ReadWriteLogRecord _ ref) = atomicModifyIORef ref


data ImmutableLogRecord = ImmutableLogRecord
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
  , logRecordBody :: AnyValue
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
  , logRecordAttributes :: LogAttributes
  -- ^ Additional information about the specific event occurrence. Unlike the Resource field, which is fixed for a particular source, Attributes can vary for each occurrence of the event coming from the same source.
  -- Can contain information about the request context (other than Trace Context Fields). The log attribute model MUST support any type, a superset of standard Attribute, to preserve the semantics of structured attributes
  -- emitted by the applications. This field is optional.
  }


{- | Arguments that may be set on LogRecord creation. If observedTimestamp is not set, it will default to the current timestamp.
If context is not specified it will default to the current context. Refer to the documentation of @LogRecord@ for descriptions
of the fields.
-}
data LogRecordArguments = LogRecordArguments
  { timestamp :: Maybe Timestamp
  , observedTimestamp :: Maybe Timestamp
  , context :: Maybe Context
  , severityText :: Maybe Text
  , severityNumber :: Maybe SeverityNumber
  , body :: AnyValue
  , attributes :: HashMap Text AnyValue
  }


emptyLogRecordArguments :: LogRecordArguments
emptyLogRecordArguments =
  LogRecordArguments
    { timestamp = Nothing
    , observedTimestamp = Nothing
    , context = Nothing
    , severityText = Nothing
    , severityNumber = Nothing
    , body = NullValue
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
  | Error
  | Error2
  | Error3
  | Error4
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
  toEnum 17 = Error
  toEnum 18 = Error2
  toEnum 19 = Error3
  toEnum 20 = Error4
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
  fromEnum Error = 17
  fromEnum Error2 = 18
  fromEnum Error3 = 19
  fromEnum Error4 = 20
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
toShortName Error = Just "ERROR"
toShortName Error2 = Just "ERROR2"
toShortName Error3 = Just "ERROR3"
toShortName Error4 = Just "ERROR4"
toShortName Fatal = Just "FATAL"
toShortName Fatal2 = Just "FATAL2"
toShortName Fatal3 = Just "FATAL3"
toShortName Fatal4 = Just "FATAL4"
toShortName (Unknown _) = Nothing
