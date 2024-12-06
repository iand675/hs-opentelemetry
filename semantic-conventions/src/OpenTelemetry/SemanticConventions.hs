------------------------------------------
-- DO NOT EDIT. THIS FILE IS GENERATED. --
------------------------------------------

{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
-- | This module is OpenTelemetry Semantic Conventions for Haskell.
-- This is automatically generated
-- based on [semantic-conventions](https://github.com/open-telemetry/semantic-conventions/) v1.24.
module OpenTelemetry.SemanticConventions (
-- * general.client
-- $general_client

-- * general.server
-- $general_server

-- * general.source
-- $general_source

-- * general.destination
-- $general_destination

-- * peer
-- $peer

peer_service,
-- * identity
-- $identity

enduser_id,
enduser_role,
enduser_scope,
-- * thread
-- $thread

-- * code
-- $code

-- * metric.jvm.memory.init
-- $metric_jvm_memory_init

-- * metric.jvm.system.cpu.utilization
-- $metric_jvm_system_cpu_utilization

-- * metric.jvm.system.cpu.load_1m
-- $metric_jvm_system_cpu_load1m

-- * attributes.jvm.buffer
-- $attributes_jvm_buffer

jvm_buffer_pool_name,
-- * metric.jvm.buffer.memory.usage
-- $metric_jvm_buffer_memory_usage

-- * metric.jvm.buffer.memory.limit
-- $metric_jvm_buffer_memory_limit

-- * metric.jvm.buffer.count
-- $metric_jvm_buffer_count

-- * metric.faas.invoke_duration
-- $metric_faas_invokeDuration

-- * metric.faas.init_duration
-- $metric_faas_initDuration

-- * metric.faas.coldstarts
-- $metric_faas_coldstarts

-- * metric.faas.errors
-- $metric_faas_errors

-- * metric.faas.invocations
-- $metric_faas_invocations

-- * metric.faas.timeouts
-- $metric_faas_timeouts

-- * metric.faas.mem_usage
-- $metric_faas_memUsage

-- * metric.faas.cpu_usage
-- $metric_faas_cpuUsage

-- * metric.faas.net_io
-- $metric_faas_netIo

-- * attributes.metrics.rpc
-- $attributes_metrics_rpc

-- * metric.rpc.server.duration
-- $metric_rpc_server_duration

-- * metric.rpc.server.request.size
-- $metric_rpc_server_request_size

-- * metric.rpc.server.response.size
-- $metric_rpc_server_response_size

-- * metric.rpc.server.requests_per_rpc
-- $metric_rpc_server_requestsPerRpc

-- * metric.rpc.server.responses_per_rpc
-- $metric_rpc_server_responsesPerRpc

-- * metric.rpc.client.duration
-- $metric_rpc_client_duration

-- * metric.rpc.client.request.size
-- $metric_rpc_client_request_size

-- * metric.rpc.client.response.size
-- $metric_rpc_client_response_size

-- * metric.rpc.client.requests_per_rpc
-- $metric_rpc_client_requestsPerRpc

-- * metric.rpc.client.responses_per_rpc
-- $metric_rpc_client_responsesPerRpc

-- * attributes.process.cpu
-- $attributes_process_cpu

process_cpu_state,
-- * metric.process.cpu.time
-- $metric_process_cpu_time

-- * metric.process.cpu.utilization
-- $metric_process_cpu_utilization

-- * metric.process.memory.usage
-- $metric_process_memory_usage

-- * metric.process.memory.virtual
-- $metric_process_memory_virtual

-- * metric.process.disk.io
-- $metric_process_disk_io

-- * metric.process.network.io
-- $metric_process_network_io

-- * metric.process.thread.count
-- $metric_process_thread_count

-- * metric.process.open_file_descriptor.count
-- $metric_process_openFileDescriptor_count

-- * metric.process.context_switches
-- $metric_process_contextSwitches

process_contextSwitchType,
-- * metric.process.paging.faults
-- $metric_process_paging_faults

process_paging_faultType,
-- * attributes.db
-- $attributes_db

state,
pool_name,
-- * metric.db.client.connections.usage
-- $metric_db_client_connections_usage

-- * metric.db.client.connections.idle.max
-- $metric_db_client_connections_idle_max

-- * metric.db.client.connections.idle.min
-- $metric_db_client_connections_idle_min

-- * metric.db.client.connections.max
-- $metric_db_client_connections_max

-- * metric.db.client.connections.pending_requests
-- $metric_db_client_connections_pendingRequests

-- * metric.db.client.connections.timeouts
-- $metric_db_client_connections_timeouts

-- * metric.db.client.connections.create_time
-- $metric_db_client_connections_createTime

-- * metric.db.client.connections.wait_time
-- $metric_db_client_connections_waitTime

-- * metric.db.client.connections.use_time
-- $metric_db_client_connections_useTime

-- * attributes.system
-- $attributes_system

system_device,
-- * attributes.system.cpu
-- $attributes_system_cpu

system_cpu_state,
system_cpu_logicalNumber,
-- * metric.system.cpu.time
-- $metric_system_cpu_time

-- * metric.system.cpu.utilization
-- $metric_system_cpu_utilization

-- * metric.system.cpu.frequency
-- $metric_system_cpu_frequency

-- * metric.system.cpu.physical.count
-- $metric_system_cpu_physical_count

-- * metric.system.cpu.logical.count
-- $metric_system_cpu_logical_count

-- * attributes.system.memory
-- $attributes_system_memory

system_memory_state,
-- * metric.system.memory.usage
-- $metric_system_memory_usage

-- * metric.system.memory.limit
-- $metric_system_memory_limit

-- * metric.system.memory.utilization
-- $metric_system_memory_utilization

-- * attributes.system.paging
-- $attributes_system_paging

system_paging_state,
system_paging_type,
system_paging_direction,
-- * metric.system.paging.usage
-- $metric_system_paging_usage

-- * metric.system.paging.utilization
-- $metric_system_paging_utilization

-- * metric.system.paging.faults
-- $metric_system_paging_faults

-- * metric.system.paging.operations
-- $metric_system_paging_operations

-- * metric.system.disk.io
-- $metric_system_disk_io

-- * metric.system.disk.operations
-- $metric_system_disk_operations

-- * metric.system.disk.io_time
-- $metric_system_disk_ioTime

-- * metric.system.disk.operation_time
-- $metric_system_disk_operationTime

-- * metric.system.disk.merged
-- $metric_system_disk_merged

-- * attributes.system.filesystem
-- $attributes_system_filesystem

system_filesystem_state,
system_filesystem_type,
system_filesystem_mode,
system_filesystem_mountpoint,
-- * metric.system.filesystem.usage
-- $metric_system_filesystem_usage

-- * metric.system.filesystem.utilization
-- $metric_system_filesystem_utilization

-- * attributes.system.network
-- $attributes_system_network

system_network_state,
-- * metric.system.network.dropped
-- $metric_system_network_dropped

-- * metric.system.network.packets
-- $metric_system_network_packets

-- * metric.system.network.errors
-- $metric_system_network_errors

-- * metric.system.network.io
-- $metric_system_network_io

-- * metric.system.network.connections
-- $metric_system_network_connections

-- * attributes.system.process
-- $attributes_system_process

system_process_status,
-- * metric.system.process.count
-- $metric_system_process_count

-- * metric.system.process.created
-- $metric_system_process_created

-- * metric.system.linux.memory.available
-- $metric_system_linux_memory_available

-- * metric_attributes.http.server
-- $metricAttributes_http_server

-- * metric_attributes.http.client
-- $metricAttributes_http_client

-- * metric.http.server.request.duration
-- $metric_http_server_request_duration

-- * metric.http.server.active_requests
-- $metric_http_server_activeRequests

-- * metric.http.server.request.body.size
-- $metric_http_server_request_body_size

-- * metric.http.server.response.body.size
-- $metric_http_server_response_body_size

-- * metric.http.client.request.duration
-- $metric_http_client_request_duration

-- * metric.http.client.request.body.size
-- $metric_http_client_request_body_size

-- * metric.http.client.response.body.size
-- $metric_http_client_response_body_size

-- * metric.messaging.attributes
-- $metric_messaging_attributes

-- * metric.messaging.publish.duration
-- $metric_messaging_publish_duration

-- * metric.messaging.receive.duration
-- $metric_messaging_receive_duration

-- * metric.messaging.deliver.duration
-- $metric_messaging_deliver_duration

-- * metric.messaging.publish.messages
-- $metric_messaging_publish_messages

-- * metric.messaging.receive.messages
-- $metric_messaging_receive_messages

-- * metric.messaging.deliver.messages
-- $metric_messaging_deliver_messages

-- * attributes.jvm.memory
-- $attributes_jvm_memory

jvm_memory_type,
jvm_memory_pool_name,
-- * metric.jvm.memory.used
-- $metric_jvm_memory_used

-- * metric.jvm.memory.committed
-- $metric_jvm_memory_committed

-- * metric.jvm.memory.limit
-- $metric_jvm_memory_limit

-- * metric.jvm.memory.used_after_last_gc
-- $metric_jvm_memory_usedAfterLastGc

-- * metric.jvm.gc.duration
-- $metric_jvm_gc_duration

jvm_gc_name,
jvm_gc_action,
-- * metric.jvm.thread.count
-- $metric_jvm_thread_count

jvm_thread_daemon,
jvm_thread_state,
-- * metric.jvm.class.loaded
-- $metric_jvm_class_loaded

-- * metric.jvm.class.unloaded
-- $metric_jvm_class_unloaded

-- * metric.jvm.class.count
-- $metric_jvm_class_count

-- * metric.jvm.cpu.count
-- $metric_jvm_cpu_count

-- * metric.jvm.cpu.time
-- $metric_jvm_cpu_time

-- * metric.jvm.cpu.recent_utilization
-- $metric_jvm_cpu_recentUtilization

-- * common.kestrel.attributes
-- $common_kestrel_attributes

-- * metric.kestrel.active_connections
-- $metric_kestrel_activeConnections

-- * metric.kestrel.connection.duration
-- $metric_kestrel_connection_duration

-- * metric.kestrel.rejected_connections
-- $metric_kestrel_rejectedConnections

-- * metric.kestrel.queued_connections
-- $metric_kestrel_queuedConnections

-- * metric.kestrel.queued_requests
-- $metric_kestrel_queuedRequests

-- * metric.kestrel.upgraded_connections
-- $metric_kestrel_upgradedConnections

-- * metric.kestrel.tls_handshake.duration
-- $metric_kestrel_tlsHandshake_duration

-- * metric.kestrel.active_tls_handshakes
-- $metric_kestrel_activeTlsHandshakes

-- * metric.dotnet.dns.lookup.duration
-- $metric_dotnet_dns_lookup_duration

dns_question_name,
-- * dotnet.http.client.common.attributes
-- $dotnet_http_client_common_attributes

-- * dotnet.http.client.connection.attributes
-- $dotnet_http_client_connection_attributes

-- * dotnet.http.client.request.attributes
-- $dotnet_http_client_request_attributes

-- * metric.dotnet.http.client.open_connections
-- $metric_dotnet_http_client_openConnections

http_connection_state,
-- * metric.dotnet.http.client.connection.duration
-- $metric_dotnet_http_client_connection_duration

-- * metric.dotnet.http.client.active_requests
-- $metric_dotnet_http_client_activeRequests

-- * metric.dotnet.http.client.request.time_in_queue
-- $metric_dotnet_http_client_request_timeInQueue

-- * signalr.common_attributes
-- $signalr_commonAttributes

signalr_connection_status,
signalr_transport,
-- * metric.signalr.server.connection.duration
-- $metric_signalr_server_connection_duration

-- * metric.signalr.server.active_connections
-- $metric_signalr_server_activeConnections

-- * aspnetcore
-- $aspnetcore

aspnetcore_rateLimiting_policy,
aspnetcore_rateLimiting_result,
aspnetcore_routing_isFallback,
aspnetcore_diagnostics_handler_type,
aspnetcore_request_isUnhandled,
-- * metric.aspnetcore.routing.match_attempts
-- $metric_aspnetcore_routing_matchAttempts

aspnetcore_routing_matchStatus,
-- * metric.aspnetcore.diagnostics.exceptions
-- $metric_aspnetcore_diagnostics_exceptions

aspnetcore_diagnostics_exception_result,
-- * metric.aspnetcore.rate_limiting.active_request_leases
-- $metric_aspnetcore_rateLimiting_activeRequestLeases

-- * metric.aspnetcore.rate_limiting.request_lease.duration
-- $metric_aspnetcore_rateLimiting_requestLease_duration

-- * metric.aspnetcore.rate_limiting.request.time_in_queue
-- $metric_aspnetcore_rateLimiting_request_timeInQueue

-- * metric.aspnetcore.rate_limiting.queued_requests
-- $metric_aspnetcore_rateLimiting_queuedRequests

-- * metric.aspnetcore.rate_limiting.requests
-- $metric_aspnetcore_rateLimiting_requests

-- * otel.scope
-- $otel_scope

otel_scope_name,
otel_scope_version,
-- * otel.library
-- $otel_library

otel_library_name,
otel_library_version,
-- * attributes.faas.common
-- $attributes_faas_common

faas_trigger,
faas_invokedName,
faas_invokedProvider,
faas_invokedRegion,
-- * trace-exception
-- $trace-exception

-- * feature_flag
-- $featureFlag

featureFlag_key,
featureFlag_providerName,
featureFlag_variant,
-- * cloudevents
-- $cloudevents

cloudevents_eventId,
cloudevents_eventSource,
cloudevents_eventSpecVersion,
cloudevents_eventType,
cloudevents_eventSubject,
-- * rpc
-- $rpc

-- * rpc.client
-- $rpc_client

-- * rpc.server
-- $rpc_server

-- * rpc.grpc
-- $rpc_grpc

-- * rpc.jsonrpc
-- $rpc_jsonrpc

-- * rpc.message
-- $rpc_message

message_type,
message_id,
message_compressedSize,
message_uncompressedSize,
-- * rpc.connect_rpc
-- $rpc_connectRpc

-- * trace.http.common
-- $trace_http_common

-- * trace.http.client
-- $trace_http_client

-- * trace.http.server
-- $trace_http_server

-- * opentracing
-- $opentracing

opentracing_refType,
-- * faas_span
-- $faasSpan

faas_invocationId,
-- * faas_span.datasource
-- $faasSpan_datasource

faas_document_collection,
faas_document_operation,
faas_document_time,
faas_document_name,
-- * faas_span.http
-- $faasSpan_http

-- * faas_span.pubsub
-- $faasSpan_pubsub

-- * faas_span.timer
-- $faasSpan_timer

faas_time,
faas_cron,
-- * faas_span.in
-- $faasSpan_in

faas_coldstart,
-- * faas_span.out
-- $faasSpan_out

-- * messaging.message
-- $messaging_message

-- * messaging.destination
-- $messaging_destination

-- * messaging.destination_publish
-- $messaging_destinationPublish

-- * messaging
-- $messaging

-- * messaging.rabbitmq
-- $messaging_rabbitmq

-- * messaging.kafka
-- $messaging_kafka

-- * messaging.rocketmq
-- $messaging_rocketmq

-- * messaging.gcp_pubsub
-- $messaging_gcpPubsub

-- * messaging.servicebus
-- $messaging_servicebus

-- * messaging.eventhubs
-- $messaging_eventhubs

-- * db
-- $db

-- * db.mssql
-- $db_mssql

-- * db.cassandra
-- $db_cassandra

-- * db.hbase
-- $db_hbase

-- * db.couchdb
-- $db_couchdb

-- * db.redis
-- $db_redis

-- * db.mongodb
-- $db_mongodb

-- * db.elasticsearch
-- $db_elasticsearch

-- * db.sql
-- $db_sql

-- * db.cosmosdb
-- $db_cosmosdb

-- * aws.lambda
-- $aws_lambda

aws_lambda_invokedArn,
-- * otel_span
-- $otelSpan

otel_statusCode,
otel_statusDescription,
-- * aws
-- $aws

aws_requestId,
-- * dynamodb.all
-- $dynamodb_all

-- * dynamodb.shared
-- $dynamodb_shared

aws_dynamodb_tableNames,
aws_dynamodb_consumedCapacity,
aws_dynamodb_itemCollectionMetrics,
aws_dynamodb_provisionedReadCapacity,
aws_dynamodb_provisionedWriteCapacity,
aws_dynamodb_consistentRead,
aws_dynamodb_projection,
aws_dynamodb_limit,
aws_dynamodb_attributesToGet,
aws_dynamodb_indexName,
aws_dynamodb_select,
-- * dynamodb.batchgetitem
-- $dynamodb_batchgetitem

-- * dynamodb.batchwriteitem
-- $dynamodb_batchwriteitem

-- * dynamodb.createtable
-- $dynamodb_createtable

aws_dynamodb_globalSecondaryIndexes,
aws_dynamodb_localSecondaryIndexes,
-- * dynamodb.deleteitem
-- $dynamodb_deleteitem

-- * dynamodb.deletetable
-- $dynamodb_deletetable

-- * dynamodb.describetable
-- $dynamodb_describetable

-- * dynamodb.getitem
-- $dynamodb_getitem

-- * dynamodb.listtables
-- $dynamodb_listtables

aws_dynamodb_exclusiveStartTable,
aws_dynamodb_tableCount,
-- * dynamodb.putitem
-- $dynamodb_putitem

-- * dynamodb.query
-- $dynamodb_query

aws_dynamodb_scanForward,
-- * dynamodb.scan
-- $dynamodb_scan

aws_dynamodb_segment,
aws_dynamodb_totalSegments,
aws_dynamodb_count,
aws_dynamodb_scannedCount,
-- * dynamodb.updateitem
-- $dynamodb_updateitem

-- * dynamodb.updatetable
-- $dynamodb_updatetable

aws_dynamodb_attributeDefinitions,
aws_dynamodb_globalSecondaryIndexUpdates,
-- * aws.s3
-- $aws_s3

aws_s3_bucket,
aws_s3_key,
aws_s3_copySource,
aws_s3_uploadId,
aws_s3_delete,
aws_s3_partNumber,
-- * graphql
-- $graphql

graphql_operation_name,
graphql_operation_type,
graphql_document,
-- * url
-- $url

-- * session-id
-- $session-id

session_id,
session_previousId,
-- * registry.os
-- $registry_os

os_type,
os_description,
os_name,
os_version,
os_buildId,
-- * registry.network
-- $registry_network

network_carrier_icc,
network_carrier_mcc,
network_carrier_mnc,
network_carrier_name,
network_connection_subtype,
network_connection_type,
network_local_address,
network_local_port,
network_peer_address,
network_peer_port,
network_protocol_name,
network_protocol_version,
network_transport,
network_type,
network_io_direction,
-- * registry.exception
-- $registry_exception

exception_type,
exception_message,
exception_stacktrace,
exception_escaped,
-- * registry.browser
-- $registry_browser

browser_brands,
browser_platform,
browser_mobile,
browser_language,
-- * registry.user_agent
-- $registry_userAgent

userAgent_original,
userAgent_name,
userAgent_version,
-- * server
-- $server

server_address,
server_port,
-- * registry.device
-- $registry_device

device_id,
device_manufacturer,
device_model_identifier,
device_model_name,
-- * client
-- $client

client_address,
client_port,
-- * registry.process
-- $registry_process

process_pid,
process_parentPid,
process_executable_name,
process_executable_path,
process_command,
process_commandLine,
process_commandArgs,
process_owner,
process_runtime_name,
process_runtime_version,
process_runtime_description,
-- * registry.rpc
-- $registry_rpc

rpc_connectRpc_errorCode,
rpc_connectRpc_request_metadata,
rpc_connectRpc_response_metadata,
rpc_grpc_statusCode,
rpc_grpc_request_metadata,
rpc_grpc_response_metadata,
rpc_jsonrpc_errorCode,
rpc_jsonrpc_errorMessage,
rpc_jsonrpc_requestId,
rpc_jsonrpc_version,
rpc_method,
rpc_service,
rpc_system,
-- * destination
-- $destination

destination_address,
destination_port,
-- * registry.disk
-- $registry_disk

disk_io_direction,
-- * registry.thread
-- $registry_thread

thread_id,
thread_name,
-- * registry.http
-- $registry_http

http_request_body_size,
http_request_header,
http_request_method,
http_request_methodOriginal,
http_request_resendCount,
http_response_body_size,
http_response_header,
http_response_statusCode,
http_route,
-- * registry.error
-- $registry_error

error_type,
-- * registry.url
-- $registry_url

url_domain,
url_extension,
url_fragment,
url_full,
url_original,
url_path,
url_port,
url_query,
url_registeredDomain,
url_scheme,
url_subdomain,
url_topLevelDomain,
-- * registry.container
-- $registry_container

container_name,
container_id,
container_runtime,
container_image_name,
container_image_tags,
container_image_id,
container_image_repoDigests,
container_command,
container_commandLine,
container_commandArgs,
container_label,
-- * registry.tls
-- $registry_tls

tls_cipher,
tls_client_certificate,
tls_client_certificateChain,
tls_client_hash_md5,
tls_client_hash_sha1,
tls_client_hash_sha256,
tls_client_issuer,
tls_client_ja3,
tls_client_notAfter,
tls_client_notBefore,
tls_client_serverName,
tls_client_subject,
tls_client_supportedCiphers,
tls_curve,
tls_established,
tls_nextProtocol,
tls_protocol_name,
tls_protocol_version,
tls_resumed,
tls_server_certificate,
tls_server_certificateChain,
tls_server_hash_md5,
tls_server_hash_sha1,
tls_server_hash_sha256,
tls_server_issuer,
tls_server_ja3s,
tls_server_notAfter,
tls_server_notBefore,
tls_server_subject,
-- * registry.messaging
-- $registry_messaging

messaging_batch_messageCount,
messaging_clientId,
messaging_destination_name,
messaging_destination_template,
messaging_destination_anonymous,
messaging_destination_temporary,
messaging_destinationPublish_anonymous,
messaging_destinationPublish_name,
messaging_kafka_consumer_group,
messaging_kafka_destination_partition,
messaging_kafka_message_key,
messaging_kafka_message_offset,
messaging_kafka_message_tombstone,
messaging_message_conversationId,
messaging_message_envelope_size,
messaging_message_id,
messaging_message_body_size,
messaging_operation,
messaging_rabbitmq_destination_routingKey,
messaging_rabbitmq_message_deliveryTag,
messaging_rocketmq_clientGroup,
messaging_rocketmq_consumptionModel,
messaging_rocketmq_message_delayTimeLevel,
messaging_rocketmq_message_deliveryTimestamp,
messaging_rocketmq_message_group,
messaging_rocketmq_message_keys,
messaging_rocketmq_message_tag,
messaging_rocketmq_message_type,
messaging_rocketmq_namespace,
messaging_gcpPubsub_message_orderingKey,
messaging_system,
messaging_servicebus_message_deliveryCount,
messaging_servicebus_message_enqueuedTime,
messaging_servicebus_destination_subscriptionName,
messaging_servicebus_dispositionStatus,
messaging_eventhubs_message_enqueuedTime,
messaging_eventhubs_destination_partition_id,
messaging_eventhubs_consumer_group,
-- * registry.cloud
-- $registry_cloud

cloud_provider,
cloud_account_id,
cloud_region,
cloud_resourceId,
cloud_availabilityZone,
cloud_platform,
-- * registry.db
-- $registry_db

db_cassandra_coordinator_dc,
db_cassandra_coordinator_id,
db_cassandra_consistencyLevel,
db_cassandra_idempotence,
db_cassandra_pageSize,
db_cassandra_speculativeExecutionCount,
db_cassandra_table,
db_connectionString,
db_cosmosdb_clientId,
db_cosmosdb_connectionMode,
db_cosmosdb_container,
db_cosmosdb_operationType,
db_cosmosdb_requestCharge,
db_cosmosdb_requestContentLength,
db_cosmosdb_statusCode,
db_cosmosdb_subStatusCode,
db_elasticsearch_cluster_name,
db_elasticsearch_node_name,
db_elasticsearch_pathParts,
db_jdbc_driverClassname,
db_mongodb_collection,
db_mssql_instanceName,
db_name,
db_operation,
db_redis_databaseIndex,
db_sql_table,
db_statement,
db_system,
db_user,
db_instance_id,
-- * registry.code
-- $registry_code

code_function,
code_namespace,
code_filepath,
code_lineno,
code_column,
code_stacktrace,
-- * registry.host
-- $registry_host

host_id,
host_name,
host_type,
host_arch,
host_image_name,
host_image_id,
host_image_version,
host_ip,
host_mac,
host_cpu_vendor_id,
host_cpu_family,
host_cpu_model_id,
host_cpu_model_name,
host_cpu_stepping,
host_cpu_cache_l2_size,
-- * registry.k8s
-- $registry_k8s

k8s_cluster_name,
k8s_cluster_uid,
k8s_node_name,
k8s_node_uid,
k8s_namespace_name,
k8s_pod_uid,
k8s_pod_name,
k8s_pod_label,
k8s_pod_annotation,
k8s_container_name,
k8s_container_restartCount,
k8s_replicaset_uid,
k8s_replicaset_name,
k8s_deployment_uid,
k8s_deployment_name,
k8s_statefulset_uid,
k8s_statefulset_name,
k8s_daemonset_uid,
k8s_daemonset_name,
k8s_job_uid,
k8s_job_name,
k8s_cronjob_uid,
k8s_cronjob_name,
-- * registry.oci.manifest
-- $registry_oci_manifest

oci_manifest_digest,
-- * source
-- $source

source_address,
source_port,
-- * attributes.network.deprecated
-- $attributes_network_deprecated

net_sock_peer_name,
net_sock_peer_addr,
net_sock_peer_port,
net_peer_name,
net_peer_port,
net_host_name,
net_host_port,
net_sock_host_addr,
net_sock_host_port,
net_transport,
net_protocol_name,
net_protocol_version,
net_sock_family,
-- * attributes.http.deprecated
-- $attributes_http_deprecated

http_method,
http_statusCode,
http_scheme,
http_url,
http_target,
http_requestContentLength,
http_responseContentLength,
http_flavor,
http_userAgent,
-- * attributes.system.deprecated
-- $attributes_system_deprecated

system_processes_status,
-- * attributes.container.deprecated
-- $attributes_container_deprecated

container_labels,
-- * attributes.k8s.deprecated
-- $attributes_k8s_deprecated

k8s_pod_labels,
-- * os
-- $os

-- * deployment
-- $deployment

deployment_environment,
-- * android
-- $android

android_os_apiLevel,
-- * service_experimental
-- $serviceExperimental

service_namespace,
service_instance_id,
-- * telemetry
-- $telemetry

telemetry_sdk_name,
telemetry_sdk_language,
telemetry_sdk_version,
-- * webengine_resource
-- $webengineResource

webengine_name,
webengine_version,
webengine_description,
-- * browser
-- $browser

-- * device
-- $device

-- * process
-- $process

-- * process.runtime
-- $process_runtime

-- * service
-- $service

service_name,
service_version,
-- * telemetry_experimental
-- $telemetryExperimental

telemetry_distro_name,
telemetry_distro_version,
-- * faas_resource
-- $faasResource

faas_name,
faas_version,
faas_instance,
faas_maxMemory,
-- * container
-- $container

-- * cloud
-- $cloud

-- * host
-- $host

-- * host.cpu
-- $host_cpu

-- * k8s.cluster
-- $k8s_cluster

-- * k8s.node
-- $k8s_node

-- * k8s.namespace
-- $k8s_namespace

-- * k8s.pod
-- $k8s_pod

-- * k8s.container
-- $k8s_container

-- * k8s.replicaset
-- $k8s_replicaset

-- * k8s.deployment
-- $k8s_deployment

-- * k8s.statefulset
-- $k8s_statefulset

-- * k8s.daemonset
-- $k8s_daemonset

-- * k8s.job
-- $k8s_job

-- * k8s.cronjob
-- $k8s_cronjob

-- * heroku
-- $heroku

heroku_release_creationTimestamp,
heroku_release_commit,
heroku_app_id,
-- * aws.ecs
-- $aws_ecs

aws_ecs_container_arn,
aws_ecs_cluster_arn,
aws_ecs_launchtype,
aws_ecs_task_arn,
aws_ecs_task_family,
aws_ecs_task_id,
aws_ecs_task_revision,
-- * aws.eks
-- $aws_eks

aws_eks_cluster_arn,
-- * aws.log
-- $aws_log

aws_log_group_names,
aws_log_group_arns,
aws_log_stream_names,
aws_log_stream_arns,
-- * gcp.cloud_run
-- $gcp_cloudRun

gcp_cloudRun_job_execution,
gcp_cloudRun_job_taskIndex,
-- * gcp.gce
-- $gcp_gce

gcp_gce_instance_name,
gcp_gce_instance_hostname,
-- * event
-- $event

event_name,
-- * log-exception
-- $log-exception

-- * attributes.log
-- $attributes_log

log_iostream,
-- * attributes.log.file
-- $attributes_log_file

log_file_name,
log_file_path,
log_file_nameResolved,
log_file_pathResolved,
-- * log-feature_flag
-- $log-featureFlag

-- * log.record
-- $log_record

log_record_uid,
-- * ios.lifecycle.events
-- $ios_lifecycle_events

ios_state,
-- * android.lifecycle.events
-- $android_lifecycle_events

android_state,
-- * attributes.http.common
-- $attributes_http_common

-- * attributes.http.client
-- $attributes_http_client

-- * attributes.http.server
-- $attributes_http_server

-- * messaging.attributes.common
-- $messaging_attributes_common

-- * network-core
-- $network-core

-- * network-connection-and-carrier
-- $network-connection-and-carrier

) where
import Data.Text (Text)
import Data.Int (Int64)
import OpenTelemetry.Attributes.Key (AttributeKey (AttributeKey))
{-# ANN module ("HLint: ignore Use camelCase" :: String) #-}
-- $general_client
-- General client attributes.
--
-- === Attributes
-- - 'client_address'
--
-- - 'client_port'
--



-- $general_server
-- General server attributes.
--
-- === Attributes
-- - 'server_address'
--
-- - 'server_port'
--



-- $general_source
-- General source attributes.
--
-- === Attributes
-- - 'source_address'
--
-- - 'source_port'
--



-- $general_destination
-- General destination attributes.
--
-- === Attributes
-- - 'destination_address'
--
-- - 'destination_port'
--



-- $peer
-- Operations that access some remote service.
--
-- === Attributes
-- - 'peer_service'
--

-- |
-- The [@service.name@](\/docs\/resource\/README.md#service) of the remote service. SHOULD be equal to the actual @service.name@ resource attribute of the remote service if any.
peer_service :: AttributeKey Text
peer_service = AttributeKey "peer.service"

-- $identity
-- These attributes may be used for any operation with an authenticated and\/or authorized enduser.
--
-- === Attributes
-- - 'enduser_id'
--
-- - 'enduser_role'
--
-- - 'enduser_scope'
--

-- |
-- Username or client_id extracted from the access token or [Authorization](https:\/\/tools.ietf.org\/html\/rfc7235#section-4.2) header in the inbound request from outside the system.
enduser_id :: AttributeKey Text
enduser_id = AttributeKey "enduser.id"

-- |
-- Actual\/assumed role the client is making the request under extracted from token or application security context.
enduser_role :: AttributeKey Text
enduser_role = AttributeKey "enduser.role"

-- |
-- Scopes or granted authorities the client currently possesses extracted from token or application security context. The value would come from the scope associated with an [OAuth 2.0 Access Token](https:\/\/tools.ietf.org\/html\/rfc6749#section-3.3) or an attribute value in a [SAML 2.0 Assertion](http:\/\/docs.oasis-open.org\/security\/saml\/Post2.0\/sstc-saml-tech-overview-2.0.html).
enduser_scope :: AttributeKey Text
enduser_scope = AttributeKey "enduser.scope"

-- $thread
-- These attributes may be used for any operation to store information about a thread that started a span.
--
-- === Attributes
-- - 'thread_id'
--
-- - 'thread_name'
--



-- $code
-- These attributes allow to report this unit of code and therefore to provide more context about the span.
--
-- === Attributes
-- - 'code_function'
--
-- - 'code_namespace'
--
-- - 'code_filepath'
--
-- - 'code_lineno'
--
-- - 'code_column'
--
-- - 'code_stacktrace'
--
--     Requirement level: opt-in
--







-- $metric_jvm_memory_init
-- Measure of initial memory requested.
--

-- $metric_jvm_system_cpu_utilization
-- Recent CPU utilization for the whole system as reported by the JVM.
--
-- ==== Note
-- The value range is [0.0,1.0]. This utilization is not defined as being for the specific interval since last measurement (unlike @system.cpu.utilization@). [Reference](https:\/\/docs.oracle.com\/en\/java\/javase\/17\/docs\/api\/jdk.management\/com\/sun\/management\/OperatingSystemMXBean.html#getCpuLoad()).
--

-- $metric_jvm_system_cpu_load1m
-- Average CPU load of the whole system for the last minute as reported by the JVM.
--
-- ==== Note
-- The value range is [0,n], where n is the number of CPU cores - or a negative number if the value is not available. This utilization is not defined as being for the specific interval since last measurement (unlike @system.cpu.utilization@). [Reference](https:\/\/docs.oracle.com\/en\/java\/javase\/17\/docs\/api\/java.management\/java\/lang\/management\/OperatingSystemMXBean.html#getSystemLoadAverage()).
--

-- $attributes_jvm_buffer
-- Describes JVM buffer metric attributes.
--
-- === Attributes
-- - 'jvm_buffer_pool_name'
--
--     Requirement level: recommended
--

-- |
-- Name of the buffer pool.

-- ==== Note
-- Pool names are generally obtained via [BufferPoolMXBean#getName()](https:\/\/docs.oracle.com\/en\/java\/javase\/11\/docs\/api\/java.management\/java\/lang\/management\/BufferPoolMXBean.html#getName()).
jvm_buffer_pool_name :: AttributeKey Text
jvm_buffer_pool_name = AttributeKey "jvm.buffer.pool.name"

-- $metric_jvm_buffer_memory_usage
-- Measure of memory used by buffers.
--

-- $metric_jvm_buffer_memory_limit
-- Measure of total memory capacity of buffers.
--

-- $metric_jvm_buffer_count
-- Number of buffers in the pool.
--

-- $metric_faas_invokeDuration
-- Measures the duration of the function\'s logic execution
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_initDuration
-- Measures the duration of the function\'s initialization, such as a cold start
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_coldstarts
-- Number of invocation cold starts
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_errors
-- Number of invocation errors
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_invocations
-- Number of successful invocations
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_timeouts
-- Number of invocation timeouts
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_memUsage
-- Distribution of max memory usage per invocation
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_cpuUsage
-- Distribution of CPU usage per invocation
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_netIo
-- Distribution of net I\/O usage per invocation
--
-- === Attributes
-- - 'faas_trigger'
--


-- $attributes_metrics_rpc
-- Describes RPC metric attributes.
--
-- === Attributes
-- - 'rpc_system'
--
--     Requirement level: required
--
-- - 'rpc_service'
--
-- - 'rpc_method'
--
-- - 'network_transport'
--
-- - 'network_type'
--
-- - 'server_address'
--
-- - 'server_port'
--








-- $metric_rpc_server_duration
-- Measures the duration of inbound RPC.
--
-- ==== Note
-- While streaming RPCs may record this metric as start-of-batch
-- to end-of-batch, it\'s hard to interpret in practice.
-- 
-- __Streaming__: N\/A.
--

-- $metric_rpc_server_request_size
-- Measures the size of RPC request messages (uncompressed).
--
-- ==== Note
-- __Streaming__: Recorded per message in a streaming batch
--

-- $metric_rpc_server_response_size
-- Measures the size of RPC response messages (uncompressed).
--
-- ==== Note
-- __Streaming__: Recorded per response in a streaming batch
--

-- $metric_rpc_server_requestsPerRpc
-- Measures the number of messages received per RPC.
--
-- ==== Note
-- Should be 1 for all non-streaming RPCs.
-- 
-- __Streaming__ : This metric is required for server and client streaming RPCs
--

-- $metric_rpc_server_responsesPerRpc
-- Measures the number of messages sent per RPC.
--
-- ==== Note
-- Should be 1 for all non-streaming RPCs.
-- 
-- __Streaming__: This metric is required for server and client streaming RPCs
--

-- $metric_rpc_client_duration
-- Measures the duration of outbound RPC.
--
-- ==== Note
-- While streaming RPCs may record this metric as start-of-batch
-- to end-of-batch, it\'s hard to interpret in practice.
-- 
-- __Streaming__: N\/A.
--

-- $metric_rpc_client_request_size
-- Measures the size of RPC request messages (uncompressed).
--
-- ==== Note
-- __Streaming__: Recorded per message in a streaming batch
--

-- $metric_rpc_client_response_size
-- Measures the size of RPC response messages (uncompressed).
--
-- ==== Note
-- __Streaming__: Recorded per response in a streaming batch
--

-- $metric_rpc_client_requestsPerRpc
-- Measures the number of messages received per RPC.
--
-- ==== Note
-- Should be 1 for all non-streaming RPCs.
-- 
-- __Streaming__: This metric is required for server and client streaming RPCs
--

-- $metric_rpc_client_responsesPerRpc
-- Measures the number of messages sent per RPC.
--
-- ==== Note
-- Should be 1 for all non-streaming RPCs.
-- 
-- __Streaming__: This metric is required for server and client streaming RPCs
--

-- $attributes_process_cpu
-- Attributes for process CPU metrics.
--
-- === Attributes
-- - 'process_cpu_state'
--

-- |
-- The CPU state for this data point. A process SHOULD be characterized _either_ by data points with no @state@ labels, _or only_ data points with @state@ labels.
process_cpu_state :: AttributeKey Text
process_cpu_state = AttributeKey "process.cpu.state"

-- $metric_process_cpu_time
-- Total CPU seconds broken down by different states.
--
-- === Attributes
-- - 'process_cpu_state'
--


-- $metric_process_cpu_utilization
-- Difference in process.cpu.time since the last measurement, divided by the elapsed time and number of CPUs available to the process.
--
-- === Attributes
-- - 'process_cpu_state'
--


-- $metric_process_memory_usage
-- The amount of physical memory in use.
--

-- $metric_process_memory_virtual
-- The amount of committed virtual memory.
--

-- $metric_process_disk_io
-- Disk bytes transferred.
--
-- === Attributes
-- - 'disk_io_direction'
--


-- $metric_process_network_io
-- Network bytes transferred.
--
-- === Attributes
-- - 'network_io_direction'
--


-- $metric_process_thread_count
-- Process threads count.
--

-- $metric_process_openFileDescriptor_count
-- Number of file descriptors in use by the process.
--

-- $metric_process_contextSwitches
-- Number of times the process has been context switched.
--
-- === Attributes
-- - 'process_contextSwitchType'
--

-- |
-- Specifies whether the context switches for this data point were voluntary or involuntary.
process_contextSwitchType :: AttributeKey Text
process_contextSwitchType = AttributeKey "process.context_switch_type"

-- $metric_process_paging_faults
-- Number of page faults the process has made.
--
-- === Attributes
-- - 'process_paging_faultType'
--

-- |
-- The type of page fault for this data point. Type @major@ is for major\/hard page faults, and @minor@ is for minor\/soft page faults.
process_paging_faultType :: AttributeKey Text
process_paging_faultType = AttributeKey "process.paging.fault_type"

-- $attributes_db
-- Describes Database attributes
--
-- === Attributes
-- - 'state'
--
--     Requirement level: required
--
-- - 'pool_name'
--
--     Requirement level: required
--

-- |
-- The state of a connection in the pool
state :: AttributeKey Text
state = AttributeKey "state"

-- |
-- The name of the connection pool; unique within the instrumented application. In case the connection pool implementation doesn\'t provide a name, then the [db.connection_string](\/docs\/database\/database-spans.md#common-attributes) should be used
pool_name :: AttributeKey Text
pool_name = AttributeKey "pool.name"

-- $metric_db_client_connections_usage
-- The number of connections that are currently in state described by the @state@ attribute
--
-- === Attributes
-- - 'state'
--
-- - 'pool_name'
--



-- $metric_db_client_connections_idle_max
-- The maximum number of idle open connections allowed
--
-- === Attributes
-- - 'pool_name'
--


-- $metric_db_client_connections_idle_min
-- The minimum number of idle open connections allowed
--
-- === Attributes
-- - 'pool_name'
--


-- $metric_db_client_connections_max
-- The maximum number of open connections allowed
--
-- === Attributes
-- - 'pool_name'
--


-- $metric_db_client_connections_pendingRequests
-- The number of pending requests for an open connection, cumulative for the entire pool
--
-- === Attributes
-- - 'pool_name'
--


-- $metric_db_client_connections_timeouts
-- The number of connection timeouts that have occurred trying to obtain a connection from the pool
--
-- === Attributes
-- - 'pool_name'
--


-- $metric_db_client_connections_createTime
-- The time it took to create a new connection
--
-- === Attributes
-- - 'pool_name'
--


-- $metric_db_client_connections_waitTime
-- The time it took to obtain an open connection from the pool
--
-- === Attributes
-- - 'pool_name'
--


-- $metric_db_client_connections_useTime
-- The time between borrowing a connection and returning it to the pool
--
-- === Attributes
-- - 'pool_name'
--


-- $attributes_system
-- Describes System metric attributes
--
-- === Attributes
-- - 'system_device'
--

-- |
-- The device identifier
system_device :: AttributeKey Text
system_device = AttributeKey "system.device"

-- $attributes_system_cpu
-- Describes System CPU metric attributes
--
-- === Attributes
-- - 'system_cpu_state'
--
-- - 'system_cpu_logicalNumber'
--

-- |
-- The state of the CPU
system_cpu_state :: AttributeKey Text
system_cpu_state = AttributeKey "system.cpu.state"

-- |
-- The logical CPU number [0..n-1]
system_cpu_logicalNumber :: AttributeKey Int64
system_cpu_logicalNumber = AttributeKey "system.cpu.logical_number"

-- $metric_system_cpu_time
-- Seconds each logical CPU spent on each mode
--
-- === Attributes
-- - 'system_cpu_state'
--
-- - 'system_cpu_logicalNumber'
--



-- $metric_system_cpu_utilization
-- Difference in system.cpu.time since the last measurement, divided by the elapsed time and number of logical CPUs
--
-- === Attributes
-- - 'system_cpu_state'
--
-- - 'system_cpu_logicalNumber'
--



-- $metric_system_cpu_frequency
-- Reports the current frequency of the CPU in Hz
--
-- === Attributes
-- - 'system_cpu_logicalNumber'
--


-- $metric_system_cpu_physical_count
-- Reports the number of actual physical processor cores on the hardware
--

-- $metric_system_cpu_logical_count
-- Reports the number of logical (virtual) processor cores created by the operating system to manage multitasking
--

-- $attributes_system_memory
-- Describes System Memory metric attributes
--
-- === Attributes
-- - 'system_memory_state'
--

-- |
-- The memory state
system_memory_state :: AttributeKey Text
system_memory_state = AttributeKey "system.memory.state"

-- $metric_system_memory_usage
-- Reports memory in use by state.
--
-- ==== Note
-- The sum over all @system.memory.state@ values SHOULD equal the total memory
-- available on the system, that is @system.memory.limit@.
--
-- === Attributes
-- - 'system_memory_state'
--


-- $metric_system_memory_limit
-- Total memory available in the system.
--
-- ==== Note
-- Its value SHOULD equal the sum of @system.memory.state@ over all states.
--

-- $metric_system_memory_utilization
--
-- === Attributes
-- - 'system_memory_state'
--


-- $attributes_system_paging
-- Describes System Memory Paging metric attributes
--
-- === Attributes
-- - 'system_paging_state'
--
-- - 'system_paging_type'
--
-- - 'system_paging_direction'
--

-- |
-- The memory paging state
system_paging_state :: AttributeKey Text
system_paging_state = AttributeKey "system.paging.state"

-- |
-- The memory paging type
system_paging_type :: AttributeKey Text
system_paging_type = AttributeKey "system.paging.type"

-- |
-- The paging access direction
system_paging_direction :: AttributeKey Text
system_paging_direction = AttributeKey "system.paging.direction"

-- $metric_system_paging_usage
-- Unix swap or windows pagefile usage
--
-- === Attributes
-- - 'system_paging_state'
--


-- $metric_system_paging_utilization
--
-- === Attributes
-- - 'system_paging_state'
--


-- $metric_system_paging_faults
--
-- === Attributes
-- - 'system_paging_type'
--


-- $metric_system_paging_operations
--
-- === Attributes
-- - 'system_paging_type'
--
-- - 'system_paging_direction'
--



-- $metric_system_disk_io
--
-- === Attributes
-- - 'system_device'
--
-- - 'disk_io_direction'
--



-- $metric_system_disk_operations
--
-- === Attributes
-- - 'system_device'
--
-- - 'disk_io_direction'
--



-- $metric_system_disk_ioTime
-- Time disk spent activated
--
-- ==== Note
-- The real elapsed time ("wall clock") used in the I\/O path (time from operations running in parallel are not counted). Measured as:
-- 
-- - Linux: Field 13 from [procfs-diskstats](https:\/\/www.kernel.org\/doc\/Documentation\/ABI\/testing\/procfs-diskstats)
-- - Windows: The complement of
--   ["Disk\% Idle Time"](https:\/\/learn.microsoft.com\/archive\/blogs\/askcore\/windows-performance-monitor-disk-counters-explained#windows-performance-monitor-disk-counters-explained)
--   performance counter: @uptime * (100 - "Disk\% Idle Time") \/ 100@
--
-- === Attributes
-- - 'system_device'
--


-- $metric_system_disk_operationTime
-- Sum of the time each operation took to complete
--
-- ==== Note
-- Because it is the sum of time each request took, parallel-issued requests each contribute to make the count grow. Measured as:
-- 
-- - Linux: Fields 7 & 11 from [procfs-diskstats](https:\/\/www.kernel.org\/doc\/Documentation\/ABI\/testing\/procfs-diskstats)
-- - Windows: "Avg. Disk sec\/Read" perf counter multiplied by "Disk Reads\/sec" perf counter (similar for Writes)
--
-- === Attributes
-- - 'system_device'
--
-- - 'disk_io_direction'
--



-- $metric_system_disk_merged
--
-- === Attributes
-- - 'system_device'
--
-- - 'disk_io_direction'
--



-- $attributes_system_filesystem
-- Describes Filesystem metric attributes
--
-- === Attributes
-- - 'system_filesystem_state'
--
-- - 'system_filesystem_type'
--
-- - 'system_filesystem_mode'
--
-- - 'system_filesystem_mountpoint'
--

-- |
-- The filesystem state
system_filesystem_state :: AttributeKey Text
system_filesystem_state = AttributeKey "system.filesystem.state"

-- |
-- The filesystem type
system_filesystem_type :: AttributeKey Text
system_filesystem_type = AttributeKey "system.filesystem.type"

-- |
-- The filesystem mode
system_filesystem_mode :: AttributeKey Text
system_filesystem_mode = AttributeKey "system.filesystem.mode"

-- |
-- The filesystem mount path
system_filesystem_mountpoint :: AttributeKey Text
system_filesystem_mountpoint = AttributeKey "system.filesystem.mountpoint"

-- $metric_system_filesystem_usage
--
-- === Attributes
-- - 'system_device'
--
-- - 'system_filesystem_state'
--
-- - 'system_filesystem_type'
--
-- - 'system_filesystem_mode'
--
-- - 'system_filesystem_mountpoint'
--






-- $metric_system_filesystem_utilization
--
-- === Attributes
-- - 'system_device'
--
-- - 'system_filesystem_state'
--
-- - 'system_filesystem_type'
--
-- - 'system_filesystem_mode'
--
-- - 'system_filesystem_mountpoint'
--






-- $attributes_system_network
-- Describes Network metric attributes
--
-- === Attributes
-- - 'system_network_state'
--

-- |
-- A stateless protocol MUST NOT set this attribute
system_network_state :: AttributeKey Text
system_network_state = AttributeKey "system.network.state"

-- $metric_system_network_dropped
-- Count of packets that are dropped or discarded even though there was no error
--
-- ==== Note
-- Measured as:
-- 
-- - Linux: the @drop@ column in @\/proc\/dev\/net@ ([source](https:\/\/web.archive.org\/web\/20180321091318\/http:\/\/www.onlamp.com\/pub\/a\/linux\/2000\/11\/16\/LinuxAdmin.html))
-- - Windows: [@InDiscards@\/@OutDiscards@](https:\/\/docs.microsoft.com\/windows\/win32\/api\/netioapi\/ns-netioapi-mib_if_row2)
--   from [@GetIfEntry2@](https:\/\/docs.microsoft.com\/windows\/win32\/api\/netioapi\/nf-netioapi-getifentry2)
--
-- === Attributes
-- - 'system_device'
--
-- - 'network_io_direction'
--



-- $metric_system_network_packets
--
-- === Attributes
-- - 'system_device'
--
-- - 'network_io_direction'
--



-- $metric_system_network_errors
-- Count of network errors detected
--
-- ==== Note
-- Measured as:
-- 
-- - Linux: the @errs@ column in @\/proc\/dev\/net@ ([source](https:\/\/web.archive.org\/web\/20180321091318\/http:\/\/www.onlamp.com\/pub\/a\/linux\/2000\/11\/16\/LinuxAdmin.html)).
-- - Windows: [@InErrors@\/@OutErrors@](https:\/\/docs.microsoft.com\/windows\/win32\/api\/netioapi\/ns-netioapi-mib_if_row2)
--   from [@GetIfEntry2@](https:\/\/docs.microsoft.com\/windows\/win32\/api\/netioapi\/nf-netioapi-getifentry2).
--
-- === Attributes
-- - 'system_device'
--
-- - 'network_io_direction'
--



-- $metric_system_network_io
--
-- === Attributes
-- - 'system_device'
--
-- - 'network_io_direction'
--



-- $metric_system_network_connections
--
-- === Attributes
-- - 'system_device'
--
-- - 'system_network_state'
--
-- - 'network_transport'
--




-- $attributes_system_process
-- Describes System Process metric attributes
--
-- === Attributes
-- - 'system_process_status'
--

-- |
-- The process state, e.g., [Linux Process State Codes](https:\/\/man7.org\/linux\/man-pages\/man1\/ps.1.html#PROCESS_STATE_CODES)
system_process_status :: AttributeKey Text
system_process_status = AttributeKey "system.process.status"

-- $metric_system_process_count
-- Total number of processes in each state
--
-- === Attributes
-- - 'system_process_status'
--


-- $metric_system_process_created
-- Total number of processes created over uptime of the host
--

-- $metric_system_linux_memory_available
-- An estimate of how much memory is available for starting new applications, without causing swapping
--
-- ==== Note
-- This is an alternative to @system.memory.usage@ metric with @state=free@.
-- Linux starting from 3.14 exports "available" memory. It takes "free" memory as a baseline, and then factors in kernel-specific values.
-- This is supposed to be more accurate than just "free" memory.
-- For reference, see the calculations [here](https:\/\/superuser.com\/a\/980821).
-- See also @MemAvailable@ in [\/proc\/meminfo](https:\/\/man7.org\/linux\/man-pages\/man5\/proc.5.html).
--

-- $metricAttributes_http_server
-- HTTP server attributes
--
-- === Attributes
-- - 'server_address'
--
--     Requirement level: opt-in
--
--     ==== Note
--     See [Setting @server.address@ and @server.port@ attributes](\/docs\/http\/http-spans.md#setting-serveraddress-and-serverport-attributes).
--     \> __Warning__
--     \> Since this attribute is based on HTTP headers, opting in to it may allow an attacker
--     \> to trigger cardinality limits, degrading the usefulness of the metric.
--
-- - 'server_port'
--
--     Requirement level: opt-in
--
--     ==== Note
--     See [Setting @server.address@ and @server.port@ attributes](\/docs\/http\/http-spans.md#setting-serveraddress-and-serverport-attributes).
--     \> __Warning__
--     \> Since this attribute is based on HTTP headers, opting in to it may allow an attacker
--     \> to trigger cardinality limits, degrading the usefulness of the metric.
--



-- $metricAttributes_http_client
-- HTTP client attributes
--

-- $metric_http_server_request_duration
-- Duration of HTTP server requests.
--
-- Stability: stable
--

-- $metric_http_server_activeRequests
-- Number of active HTTP server requests.
--
-- === Attributes
-- - 'http_request_method'
--
--     Requirement level: required
--
-- - 'url_scheme'
--
--     Requirement level: required
--
-- - 'server_address'
--
--     Name of the local HTTP server that received the request.
--
--     Requirement level: opt-in
--
--     ==== Note
--     See [Setting @server.address@ and @server.port@ attributes](\/docs\/http\/http-spans.md#setting-serveraddress-and-serverport-attributes).
--     \> __Warning__
--     \> Since this attribute is based on HTTP headers, opting in to it may allow an attacker
--     \> to trigger cardinality limits, degrading the usefulness of the metric.
--
-- - 'server_port'
--
--     Port of the local HTTP server that received the request.
--
--     Requirement level: opt-in
--
--     ==== Note
--     See [Setting @server.address@ and @server.port@ attributes](\/docs\/http\/http-spans.md#setting-serveraddress-and-serverport-attributes).
--     \> __Warning__
--     \> Since this attribute is based on HTTP headers, opting in to it may allow an attacker
--     \> to trigger cardinality limits, degrading the usefulness of the metric.
--





-- $metric_http_server_request_body_size
-- Size of HTTP server request bodies.
--
-- ==== Note
-- The size of the request payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.
--

-- $metric_http_server_response_body_size
-- Size of HTTP server response bodies.
--
-- ==== Note
-- The size of the response payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.
--

-- $metric_http_client_request_duration
-- Duration of HTTP client requests.
--
-- Stability: stable
--

-- $metric_http_client_request_body_size
-- Size of HTTP client request bodies.
--
-- ==== Note
-- The size of the request payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.
--

-- $metric_http_client_response_body_size
-- Size of HTTP client response bodies.
--
-- ==== Note
-- The size of the response payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.
--

-- $metric_messaging_attributes
-- Common messaging metrics attributes.
--
-- === Attributes
-- - 'messaging_destination_name'
--
--     Requirement level: conditionally required: if and only if @messaging.destination.name@ is known to have low cardinality. Otherwise, @messaging.destination.template@ MAY be populated.
--
-- - 'messaging_destination_template'
--
--     Requirement level: conditionally required: if available.
--



-- $metric_messaging_publish_duration
-- Measures the duration of publish operation.
--

-- $metric_messaging_receive_duration
-- Measures the duration of receive operation.
--

-- $metric_messaging_deliver_duration
-- Measures the duration of deliver operation.
--

-- $metric_messaging_publish_messages
-- Measures the number of published messages.
--

-- $metric_messaging_receive_messages
-- Measures the number of received messages.
--

-- $metric_messaging_deliver_messages
-- Measures the number of delivered messages.
--

-- $attributes_jvm_memory
-- Describes JVM memory metric attributes.
--
-- === Attributes
-- - 'jvm_memory_type'
--
--     Stability: stable
--
--     Requirement level: recommended
--
-- - 'jvm_memory_pool_name'
--
--     Stability: stable
--
--     Requirement level: recommended
--

-- |
-- The type of memory.
jvm_memory_type :: AttributeKey Text
jvm_memory_type = AttributeKey "jvm.memory.type"

-- |
-- Name of the memory pool.

-- ==== Note
-- Pool names are generally obtained via [MemoryPoolMXBean#getName()](https:\/\/docs.oracle.com\/en\/java\/javase\/11\/docs\/api\/java.management\/java\/lang\/management\/MemoryPoolMXBean.html#getName()).
jvm_memory_pool_name :: AttributeKey Text
jvm_memory_pool_name = AttributeKey "jvm.memory.pool.name"

-- $metric_jvm_memory_used
-- Measure of memory used.
--
-- Stability: stable
--

-- $metric_jvm_memory_committed
-- Measure of memory committed.
--
-- Stability: stable
--

-- $metric_jvm_memory_limit
-- Measure of max obtainable memory.
--
-- Stability: stable
--

-- $metric_jvm_memory_usedAfterLastGc
-- Measure of memory used, as measured after the most recent garbage collection event on this pool.
--
-- Stability: stable
--

-- $metric_jvm_gc_duration
-- Duration of JVM garbage collection actions.
--
-- Stability: stable
--
-- === Attributes
-- - 'jvm_gc_name'
--
--     Stability: stable
--
--     Requirement level: recommended
--
-- - 'jvm_gc_action'
--
--     Stability: stable
--
--     Requirement level: recommended
--

-- |
-- Name of the garbage collector.

-- ==== Note
-- Garbage collector name is generally obtained via [GarbageCollectionNotificationInfo#getGcName()](https:\/\/docs.oracle.com\/en\/java\/javase\/11\/docs\/api\/jdk.management\/com\/sun\/management\/GarbageCollectionNotificationInfo.html#getGcName()).
jvm_gc_name :: AttributeKey Text
jvm_gc_name = AttributeKey "jvm.gc.name"

-- |
-- Name of the garbage collector action.

-- ==== Note
-- Garbage collector action is generally obtained via [GarbageCollectionNotificationInfo#getGcAction()](https:\/\/docs.oracle.com\/en\/java\/javase\/11\/docs\/api\/jdk.management\/com\/sun\/management\/GarbageCollectionNotificationInfo.html#getGcAction()).
jvm_gc_action :: AttributeKey Text
jvm_gc_action = AttributeKey "jvm.gc.action"

-- $metric_jvm_thread_count
-- Number of executing platform threads.
--
-- Stability: stable
--
-- === Attributes
-- - 'jvm_thread_daemon'
--
--     Stability: stable
--
--     Requirement level: recommended
--
-- - 'jvm_thread_state'
--
--     Stability: stable
--
--     Requirement level: recommended
--

-- |
-- Whether the thread is daemon or not.
jvm_thread_daemon :: AttributeKey Bool
jvm_thread_daemon = AttributeKey "jvm.thread.daemon"

-- |
-- State of the thread.
jvm_thread_state :: AttributeKey Text
jvm_thread_state = AttributeKey "jvm.thread.state"

-- $metric_jvm_class_loaded
-- Number of classes loaded since JVM start.
--
-- Stability: stable
--

-- $metric_jvm_class_unloaded
-- Number of classes unloaded since JVM start.
--
-- Stability: stable
--

-- $metric_jvm_class_count
-- Number of classes currently loaded.
--
-- Stability: stable
--

-- $metric_jvm_cpu_count
-- Number of processors available to the Java virtual machine.
--
-- Stability: stable
--

-- $metric_jvm_cpu_time
-- CPU time used by the process as reported by the JVM.
--
-- Stability: stable
--

-- $metric_jvm_cpu_recentUtilization
-- Recent CPU utilization for the process as reported by the JVM.
--
-- Stability: stable
--
-- ==== Note
-- The value range is [0.0,1.0]. This utilization is not defined as being for the specific interval since last measurement (unlike @system.cpu.utilization@). [Reference](https:\/\/docs.oracle.com\/en\/java\/javase\/17\/docs\/api\/jdk.management\/com\/sun\/management\/OperatingSystemMXBean.html#getProcessCpuLoad()).
--

-- $common_kestrel_attributes
-- Common kestrel attributes
--
-- === Attributes
-- - 'server_address'
--
-- - 'server_port'
--
-- - 'network_type'
--
--     Requirement level: recommended: if the transport is @tcp@ or @udp@
--
-- - 'network_transport'
--





-- $metric_kestrel_activeConnections
-- Number of connections that are currently active on the server.
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Server.Kestrel@; Added in: ASP.NET Core 8.0
--

-- $metric_kestrel_connection_duration
-- The duration of connections on the server.
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Server.Kestrel@; Added in: ASP.NET Core 8.0
--
-- === Attributes
-- - 'network_protocol_name'
--
-- - 'network_protocol_version'
--
-- - 'tls_protocol_version'
--
-- - 'error_type'
--
--     The full name of exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     Captures the exception type when a connection fails.
--





-- $metric_kestrel_rejectedConnections
-- Number of connections rejected by the server.
--
-- ==== Note
-- Connections are rejected when the currently active count exceeds the value configured with @MaxConcurrentConnections@.
-- Meter name: @Microsoft.AspNetCore.Server.Kestrel@; Added in: ASP.NET Core 8.0
--

-- $metric_kestrel_queuedConnections
-- Number of connections that are currently queued and are waiting to start.
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Server.Kestrel@; Added in: ASP.NET Core 8.0
--

-- $metric_kestrel_queuedRequests
-- Number of HTTP requests on multiplexed connections (HTTP\/2 and HTTP\/3) that are currently queued and are waiting to start.
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Server.Kestrel@; Added in: ASP.NET Core 8.0
--
-- === Attributes
-- - 'network_protocol_name'
--
-- - 'network_protocol_version'
--



-- $metric_kestrel_upgradedConnections
-- Number of connections that are currently upgraded (WebSockets). .
--
-- ==== Note
-- The counter only tracks HTTP\/1.1 connections.
-- 
-- Meter name: @Microsoft.AspNetCore.Server.Kestrel@; Added in: ASP.NET Core 8.0
--

-- $metric_kestrel_tlsHandshake_duration
-- The duration of TLS handshakes on the server.
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Server.Kestrel@; Added in: ASP.NET Core 8.0
--
-- === Attributes
-- - 'tls_protocol_version'
--
-- - 'error_type'
--
--     The full name of exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     Captures the exception type when a TLS handshake fails.
--



-- $metric_kestrel_activeTlsHandshakes
-- Number of TLS handshakes that are currently in progress on the server.
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Server.Kestrel@; Added in: ASP.NET Core 8.0
--

-- $metric_dotnet_dns_lookup_duration
-- Measures the time taken to perform a DNS lookup.
--
-- ==== Note
-- Meter name: @System.Net.NameResolution@; Added in: .NET 8.0
--
-- === Attributes
-- - 'dns_question_name'
--
--     Requirement level: required
--
-- - 'error_type'
--
--     One of the resolution errors or the full name of exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     The following errors codes are reported:
--     
--     - "host_not_found"
--     - "try_again"
--     - "address_family_not_supported"
--     - "no_recovery"
--     
--     See [SocketError](https:\/\/learn.microsoft.com\/dotnet\/api\/system.net.sockets.socketerror)
--     for more details.
--

-- |
-- The name being queried.

-- ==== Note
-- The name being queried.
-- If the name field contains non-printable characters (below 32 or above 126), those characters should be represented as escaped base 10 integers (\DDD). Back slashes and quotes should be escaped. Tabs, carriage returns, and line feeds should be converted to \t, \r, and \n respectively.
dns_question_name :: AttributeKey Text
dns_question_name = AttributeKey "dns.question.name"


-- $dotnet_http_client_common_attributes
-- Common HTTP client attributes
--
-- === Attributes
-- - 'url_scheme'
--
-- - 'server_address'
--
--     Host identifier of the ["URI origin"](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#name-uri-origin) HTTP request is sent to.
--
--     Requirement level: required
--
--     ==== Note
--     If an HTTP client request is explicitly made to an IP address, e.g. @http:\/\/x.x.x.x:8080@, then @server.address@ SHOULD be the IP address @x.x.x.x@. A DNS lookup SHOULD NOT be used.
--
-- - 'server_port'
--
--     Port identifier of the ["URI origin"](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#name-uri-origin) HTTP request is sent to.
--
--     Requirement level: conditionally required: If not the default (@80@ for @http@ scheme, @443@ for @https@).
--




-- $dotnet_http_client_connection_attributes
-- Common HTTP client attributes
--
-- === Attributes
-- - 'network_protocol_version'
--
--     HTTP protocol version of the connection in the connection pool.
--
--     ==== Note
--     HTTP 1.0 and 1.1 requests share connections in the connection pool and are both reported as version @1.1@. So, the @network.protocol.version@ value reported on connection metrics is different than the one reported on request-level metrics or spans for HTTP 1.0 requests.
--


-- $dotnet_http_client_request_attributes
-- Common HTTP client attributes
--
-- === Attributes
-- - 'http_request_method'
--
--     ==== Note
--     HTTP request method value is one of the "known" methods listed in [RFC9110](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#name-methods) and the PATCH method defined in [RFC5789](https:\/\/www.rfc-editor.org\/rfc\/rfc5789.html).
--     If the HTTP request method isn\'t known, it sets the @http.request.method@ attribute to @_OTHER@. It\'s not possible at the moment to override the list of known HTTP methods.
--


-- $metric_dotnet_http_client_openConnections
-- Number of outbound HTTP connections that are currently active or idle on the client.
--
-- ==== Note
-- Meter name: @System.Net.Http@; Added in: .NET 8.0
--
-- === Attributes
-- - 'http_connection_state'
--
--     Requirement level: required
--
-- - 'network_peer_address'
--
--     Remote IP address of the socket connection.
--

-- |
-- State of the HTTP connection in the HTTP connection pool.
http_connection_state :: AttributeKey Text
http_connection_state = AttributeKey "http.connection.state"


-- $metric_dotnet_http_client_connection_duration
-- The duration of the successfully established outbound HTTP connections.
--
-- ==== Note
-- Meter name: @System.Net.Http@; Added in: .NET 8.0
--
-- === Attributes
-- - 'network_peer_address'
--


-- $metric_dotnet_http_client_activeRequests
-- Number of active HTTP requests.
--
-- ==== Note
-- Meter name: @System.Net.Http@; Added in: .NET 8.0
--

-- $metric_dotnet_http_client_request_timeInQueue
-- The amount of time requests spent on a queue waiting for an available connection.
--
-- ==== Note
-- Meter name: @System.Net.Http@; Added in: .NET 8.0
--
-- === Attributes
-- - 'http_request_method'
--
--     ==== Note
--     HTTP request method value is one of the "known" methods listed in [RFC9110](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#name-methods) and the PATCH method defined in [RFC5789](https:\/\/www.rfc-editor.org\/rfc\/rfc5789.html).
--     If the HTTP request method isn\'t known, it sets the @http.request.method@ attribute to @_OTHER@. It\'s not possible at the moment to override the list of known HTTP methods.
--


-- $signalr_commonAttributes
-- SignalR attributes
--
-- === Attributes
-- - 'signalr_connection_status'
--
-- - 'signalr_transport'
--

-- |
-- SignalR HTTP connection closure status.
signalr_connection_status :: AttributeKey Text
signalr_connection_status = AttributeKey "signalr.connection.status"

-- |
-- [SignalR transport type](https:\/\/github.com\/dotnet\/aspnetcore\/blob\/main\/src\/SignalR\/docs\/specs\/TransportProtocols.md)
signalr_transport :: AttributeKey Text
signalr_transport = AttributeKey "signalr.transport"

-- $metric_signalr_server_connection_duration
-- The duration of connections on the server.
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Http.Connections@; Added in: ASP.NET Core 8.0
--
-- === Attributes
-- - 'signalr_connection_status'
--
-- - 'signalr_transport'
--



-- $metric_signalr_server_activeConnections
-- Number of connections that are currently active on the server.
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Http.Connections@; Added in: ASP.NET Core 8.0
--
-- === Attributes
-- - 'signalr_connection_status'
--
-- - 'signalr_transport'
--



-- $aspnetcore
-- ASP.NET Core attributes
--
-- === Attributes
-- - 'aspnetcore_rateLimiting_policy'
--
--     Requirement level: conditionally required: if the matched endpoint for the request had a rate-limiting policy.
--
-- - 'aspnetcore_rateLimiting_result'
--
--     Requirement level: required
--
-- - 'aspnetcore_routing_isFallback'
--
--     Requirement level: conditionally required: If and only if a route was successfully matched.
--
-- - 'aspnetcore_diagnostics_handler_type'
--
--     Requirement level: conditionally required: if and only if the exception was handled by this handler.
--
-- - 'aspnetcore_request_isUnhandled'
--
--     Requirement level: conditionally required: if and only if the request was not handled.
--

-- |
-- Rate limiting policy name.
aspnetcore_rateLimiting_policy :: AttributeKey Text
aspnetcore_rateLimiting_policy = AttributeKey "aspnetcore.rate_limiting.policy"

-- |
-- Rate-limiting result, shows whether the lease was acquired or contains a rejection reason
aspnetcore_rateLimiting_result :: AttributeKey Text
aspnetcore_rateLimiting_result = AttributeKey "aspnetcore.rate_limiting.result"

-- |
-- A value that indicates whether the matched route is a fallback route.
aspnetcore_routing_isFallback :: AttributeKey Bool
aspnetcore_routing_isFallback = AttributeKey "aspnetcore.routing.is_fallback"

-- |
-- Full type name of the [@IExceptionHandler@](https:\/\/learn.microsoft.com\/dotnet\/api\/microsoft.aspnetcore.diagnostics.iexceptionhandler) implementation that handled the exception.
aspnetcore_diagnostics_handler_type :: AttributeKey Text
aspnetcore_diagnostics_handler_type = AttributeKey "aspnetcore.diagnostics.handler.type"

-- |
-- Flag indicating if request was handled by the application pipeline.
aspnetcore_request_isUnhandled :: AttributeKey Bool
aspnetcore_request_isUnhandled = AttributeKey "aspnetcore.request.is_unhandled"

-- $metric_aspnetcore_routing_matchAttempts
-- Number of requests that were attempted to be matched to an endpoint.
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Routing@; Added in: ASP.NET Core 8.0
--
-- === Attributes
-- - 'http_route'
--
--     Requirement level: conditionally required: if and only if a route was successfully matched.
--
-- - 'aspnetcore_routing_isFallback'
--
--     Requirement level: conditionally required: if and only if a route was successfully matched.
--
-- - 'aspnetcore_routing_matchStatus'
--
--     Requirement level: required
--



-- |
-- Match result - success or failure
aspnetcore_routing_matchStatus :: AttributeKey Text
aspnetcore_routing_matchStatus = AttributeKey "aspnetcore.routing.match_status"

-- $metric_aspnetcore_diagnostics_exceptions
-- Number of exceptions caught by exception handling middleware.
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Diagnostics@; Added in: ASP.NET Core 8.0
--
-- === Attributes
-- - 'error_type'
--
--     The full name of exception type.
--
--     Requirement level: required
--
-- - 'aspnetcore_diagnostics_handler_type'
--
-- - 'aspnetcore_diagnostics_exception_result'
--
--     Requirement level: required
--



-- |
-- ASP.NET Core exception middleware handling result
aspnetcore_diagnostics_exception_result :: AttributeKey Text
aspnetcore_diagnostics_exception_result = AttributeKey "aspnetcore.diagnostics.exception.result"

-- $metric_aspnetcore_rateLimiting_activeRequestLeases
-- Number of requests that are currently active on the server that hold a rate limiting lease.
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.RateLimiting@; Added in: ASP.NET Core 8.0
--
-- === Attributes
-- - 'aspnetcore_rateLimiting_policy'
--


-- $metric_aspnetcore_rateLimiting_requestLease_duration
-- The duration of rate limiting lease held by requests on the server.
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.RateLimiting@; Added in: ASP.NET Core 8.0
--
-- === Attributes
-- - 'aspnetcore_rateLimiting_policy'
--


-- $metric_aspnetcore_rateLimiting_request_timeInQueue
-- The time the request spent in a queue waiting to acquire a rate limiting lease.
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.RateLimiting@; Added in: ASP.NET Core 8.0
--
-- === Attributes
-- - 'aspnetcore_rateLimiting_policy'
--
-- - 'aspnetcore_rateLimiting_result'
--



-- $metric_aspnetcore_rateLimiting_queuedRequests
-- Number of requests that are currently queued, waiting to acquire a rate limiting lease.
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.RateLimiting@; Added in: ASP.NET Core 8.0
--
-- === Attributes
-- - 'aspnetcore_rateLimiting_policy'
--


-- $metric_aspnetcore_rateLimiting_requests
-- Number of requests that tried to acquire a rate limiting lease.
--
-- ==== Note
-- Requests could be:
-- 
-- * Rejected by global or endpoint rate limiting policies
-- * Canceled while waiting for the lease.
-- 
-- Meter name: @Microsoft.AspNetCore.RateLimiting@; Added in: ASP.NET Core 8.0
--
-- === Attributes
-- - 'aspnetcore_rateLimiting_policy'
--
-- - 'aspnetcore_rateLimiting_result'
--



-- $otel_scope
-- Attributes used by non-OTLP exporters to represent OpenTelemetry Scope\'s concepts.
--
-- === Attributes
-- - 'otel_scope_name'
--
--     Stability: stable
--
-- - 'otel_scope_version'
--
--     Stability: stable
--

-- |
-- The name of the instrumentation scope - (@InstrumentationScope.Name@ in OTLP).
otel_scope_name :: AttributeKey Text
otel_scope_name = AttributeKey "otel.scope.name"

-- |
-- The version of the instrumentation scope - (@InstrumentationScope.Version@ in OTLP).
otel_scope_version :: AttributeKey Text
otel_scope_version = AttributeKey "otel.scope.version"

-- $otel_library
-- Span attributes used by non-OTLP exporters to represent OpenTelemetry Scope\'s concepts.
--
-- === Attributes
-- - 'otel_library_name'
--
--     Stability: deprecated
--
-- - 'otel_library_version'
--
--     Stability: deprecated
--

-- |
-- Deprecated, use the @otel.scope.name@ attribute.
otel_library_name :: AttributeKey Text
otel_library_name = AttributeKey "otel.library.name"

-- |
-- Deprecated, use the @otel.scope.version@ attribute.
otel_library_version :: AttributeKey Text
otel_library_version = AttributeKey "otel.library.version"

-- $attributes_faas_common
-- Describes FaaS attributes.
--
-- === Attributes
-- - 'faas_trigger'
--
-- - 'faas_invokedName'
--
--     Requirement level: required
--
-- - 'faas_invokedProvider'
--
--     Requirement level: required
--
-- - 'faas_invokedRegion'
--
--     Requirement level: conditionally required: For some cloud providers, like AWS or GCP, the region in which a function is hosted is essential to uniquely identify the function and also part of its endpoint. Since it\'s part of the endpoint being called, the region is always known to clients. In these cases, @faas.invoked_region@ MUST be set accordingly. If the region is unknown to the client or not required for identifying the invoked function, setting @faas.invoked_region@ is optional.
--

-- |
-- Type of the trigger which caused this function invocation.
faas_trigger :: AttributeKey Text
faas_trigger = AttributeKey "faas.trigger"

-- |
-- The name of the invoked function.

-- ==== Note
-- SHOULD be equal to the @faas.name@ resource attribute of the invoked function.
faas_invokedName :: AttributeKey Text
faas_invokedName = AttributeKey "faas.invoked_name"

-- |
-- The cloud provider of the invoked function.

-- ==== Note
-- SHOULD be equal to the @cloud.provider@ resource attribute of the invoked function.
faas_invokedProvider :: AttributeKey Text
faas_invokedProvider = AttributeKey "faas.invoked_provider"

-- |
-- The cloud region of the invoked function.

-- ==== Note
-- SHOULD be equal to the @cloud.region@ resource attribute of the invoked function.
faas_invokedRegion :: AttributeKey Text
faas_invokedRegion = AttributeKey "faas.invoked_region"

-- $trace-exception
-- This document defines the attributes used to report a single exception associated with a span.
--
-- === Attributes
-- - 'exception_type'
--
-- - 'exception_message'
--
-- - 'exception_stacktrace'
--
-- - 'exception_escaped'
--





-- $featureFlag
-- This semantic convention defines the attributes used to represent a feature flag evaluation as an event.
--
-- === Attributes
-- - 'featureFlag_key'
--
--     Requirement level: required
--
-- - 'featureFlag_providerName'
--
--     Requirement level: recommended
--
-- - 'featureFlag_variant'
--
--     Requirement level: recommended
--

-- |
-- The unique identifier of the feature flag.
featureFlag_key :: AttributeKey Text
featureFlag_key = AttributeKey "feature_flag.key"

-- |
-- The name of the service provider that performs the flag evaluation.
featureFlag_providerName :: AttributeKey Text
featureFlag_providerName = AttributeKey "feature_flag.provider_name"

-- |
-- SHOULD be a semantic identifier for a value. If one is unavailable, a stringified version of the value can be used.

-- ==== Note
-- A semantic identifier, commonly referred to as a variant, provides a means
-- for referring to a value without including the value itself. This can
-- provide additional context for understanding the meaning behind a value.
-- For example, the variant @red@ maybe be used for the value @#c05543@.
-- 
-- A stringified version of the value can be used in situations where a
-- semantic identifier is unavailable. String representation of the value
-- should be determined by the implementer.
featureFlag_variant :: AttributeKey Text
featureFlag_variant = AttributeKey "feature_flag.variant"

-- $cloudevents
-- This document defines attributes for CloudEvents. CloudEvents is a specification on how to define event data in a standard way. These attributes can be attached to spans when performing operations with CloudEvents, regardless of the protocol being used.
--
-- === Attributes
-- - 'cloudevents_eventId'
--
--     Requirement level: required
--
-- - 'cloudevents_eventSource'
--
--     Requirement level: required
--
-- - 'cloudevents_eventSpecVersion'
--
-- - 'cloudevents_eventType'
--
-- - 'cloudevents_eventSubject'
--

-- |
-- The [event_id](https:\/\/github.com\/cloudevents\/spec\/blob\/v1.0.2\/cloudevents\/spec.md#id) uniquely identifies the event.
cloudevents_eventId :: AttributeKey Text
cloudevents_eventId = AttributeKey "cloudevents.event_id"

-- |
-- The [source](https:\/\/github.com\/cloudevents\/spec\/blob\/v1.0.2\/cloudevents\/spec.md#source-1) identifies the context in which an event happened.
cloudevents_eventSource :: AttributeKey Text
cloudevents_eventSource = AttributeKey "cloudevents.event_source"

-- |
-- The [version of the CloudEvents specification](https:\/\/github.com\/cloudevents\/spec\/blob\/v1.0.2\/cloudevents\/spec.md#specversion) which the event uses.
cloudevents_eventSpecVersion :: AttributeKey Text
cloudevents_eventSpecVersion = AttributeKey "cloudevents.event_spec_version"

-- |
-- The [event_type](https:\/\/github.com\/cloudevents\/spec\/blob\/v1.0.2\/cloudevents\/spec.md#type) contains a value describing the type of event related to the originating occurrence.
cloudevents_eventType :: AttributeKey Text
cloudevents_eventType = AttributeKey "cloudevents.event_type"

-- |
-- The [subject](https:\/\/github.com\/cloudevents\/spec\/blob\/v1.0.2\/cloudevents\/spec.md#subject) of the event in the context of the event producer (identified by source).
cloudevents_eventSubject :: AttributeKey Text
cloudevents_eventSubject = AttributeKey "cloudevents.event_subject"

-- $rpc
-- This document defines semantic conventions for remote procedure calls.
--
-- === Attributes
-- - 'rpc_system'
--
--     Requirement level: required
--
-- - 'rpc_service'
--
-- - 'rpc_method'
--
-- - 'network_transport'
--
-- - 'network_type'
--
-- - 'server_address'
--
--     RPC server [host name](https:\/\/grpc.github.io\/grpc\/core\/md_doc_naming.html).
--
--     Requirement level: required
--
--     ==== Note
--     May contain server IP address, DNS name, or local socket name. When host component is an IP address, instrumentations SHOULD NOT do a reverse proxy lookup to obtain DNS name and SHOULD set @server.address@ to the IP address provided in the host component.
--
-- - 'server_port'
--
--     Requirement level: conditionally required: if the port is supported by the network transport used for communication.
--








-- $rpc_client
-- This document defines semantic conventions for remote procedure call client spans.
--
-- === Attributes
-- - 'network_peer_address'
--
-- - 'network_peer_port'
--
--     Requirement level: recommended: If @network.peer.address@ is set.
--



-- $rpc_server
-- Semantic Convention for RPC server spans
--
-- === Attributes
-- - 'client_address'
--
-- - 'client_port'
--
-- - 'network_peer_address'
--
-- - 'network_peer_port'
--
--     Requirement level: recommended: If @network.peer.address@ is set.
--
-- - 'network_transport'
--
-- - 'network_type'
--







-- $rpc_grpc
-- Tech-specific attributes for gRPC.
--
-- === Attributes
-- - 'rpc_grpc_statusCode'
--
--     Requirement level: required
--
-- - 'rpc_grpc_request_metadata'
--
--     Requirement level: opt-in
--
-- - 'rpc_grpc_response_metadata'
--
--     Requirement level: opt-in
--




-- $rpc_jsonrpc
-- Tech-specific attributes for [JSON RPC](https:\/\/www.jsonrpc.org\/).
--
-- === Attributes
-- - 'rpc_jsonrpc_version'
--
--     Requirement level: conditionally required: If other than the default version (@1.0@)
--
-- - 'rpc_jsonrpc_requestId'
--
-- - 'rpc_jsonrpc_errorCode'
--
--     Requirement level: conditionally required: If response is not successful.
--
-- - 'rpc_jsonrpc_errorMessage'
--
-- - 'rpc_method'
--
--     Requirement level: required
--
--     ==== Note
--     This is always required for jsonrpc. See the note in the general RPC conventions for more information.
--






-- $rpc_message
-- RPC received\/sent message.
--
-- === Attributes
-- - 'message_type'
--
-- - 'message_id'
--
-- - 'message_compressedSize'
--
-- - 'message_uncompressedSize'
--

-- |
-- Whether this is a received or sent message.
message_type :: AttributeKey Text
message_type = AttributeKey "message.type"

-- |
-- MUST be calculated as two different counters starting from @1@ one for sent messages and one for received message.

-- ==== Note
-- This way we guarantee that the values will be consistent between different implementations.
message_id :: AttributeKey Int64
message_id = AttributeKey "message.id"

-- |
-- Compressed size of the message in bytes.
message_compressedSize :: AttributeKey Int64
message_compressedSize = AttributeKey "message.compressed_size"

-- |
-- Uncompressed size of the message in bytes.
message_uncompressedSize :: AttributeKey Int64
message_uncompressedSize = AttributeKey "message.uncompressed_size"

-- $rpc_connectRpc
-- Tech-specific attributes for Connect RPC.
--
-- === Attributes
-- - 'rpc_connectRpc_errorCode'
--
--     Requirement level: conditionally required: If response is not successful and if error code available.
--
-- - 'rpc_connectRpc_request_metadata'
--
--     Requirement level: opt-in
--
-- - 'rpc_connectRpc_response_metadata'
--
--     Requirement level: opt-in
--




-- $trace_http_common
-- This document defines semantic conventions for HTTP client and server Spans.
--
-- ==== Note
-- These conventions can be used for http and https schemes and various HTTP versions like 1.1, 2 and SPDY.
--
-- === Attributes
-- - 'http_request_methodOriginal'
--
--     Requirement level: conditionally required: If and only if it\'s different than @http.request.method@.
--
-- - 'http_response_header'
--
--     Requirement level: opt-in
--
-- - 'http_request_method'
--
--     Requirement level: required
--
-- - 'network_peer_address'
--
-- - 'network_peer_port'
--
--     Requirement level: recommended: If @network.peer.address@ is set.
--
-- - 'network_transport'
--
--     Requirement level: opt-in
--
--     ==== Note
--     Generally @tcp@ for @HTTP\/1.0@, @HTTP\/1.1@, and @HTTP\/2@. Generally @udp@ for @HTTP\/3@. Other obscure implementations are possible.
--







-- $trace_http_client
-- Semantic Convention for HTTP Client
--
-- === Attributes
-- - 'http_request_resendCount'
--
--     Requirement level: recommended: if and only if request was retried.
--
-- - 'http_request_header'
--
--     Requirement level: opt-in
--
-- - 'server_address'
--
-- - 'server_port'
--
-- - 'url_full'
--
--     Requirement level: required
--
-- - 'userAgent_original'
--
--     Requirement level: opt-in
--
-- - 'url_scheme'
--








-- $trace_http_server
-- Semantic Convention for HTTP Server
--
-- === Attributes
-- - 'http_route'
--
-- - 'http_request_header'
--
--     Requirement level: opt-in
--
-- - 'server_address'
--
-- - 'server_port'
--
-- - 'network_local_address'
--
--     Local socket address. Useful in case of a multi-IP host.
--
--     Requirement level: opt-in
--
-- - 'network_local_port'
--
--     Local socket port. Useful in case of a multi-port host.
--
--     Requirement level: opt-in
--
-- - 'client_address'
--
--     ==== Note
--     The IP address of the original client behind all proxies, if known (e.g. from [Forwarded#for](https:\/\/developer.mozilla.org\/docs\/Web\/HTTP\/Headers\/Forwarded#for), [X-Forwarded-For](https:\/\/developer.mozilla.org\/docs\/Web\/HTTP\/Headers\/X-Forwarded-For), or a similar header). Otherwise, the immediate client peer address.
--
-- - 'client_port'
--
--     The port of whichever client was captured in @client.address@.
--
--     Requirement level: opt-in
--
-- - 'url_path'
--
--     Requirement level: required
--
-- - 'url_query'
--
--     Requirement level: conditionally required: If and only if one was received\/sent.
--
-- - 'url_scheme'
--
-- - 'userAgent_original'
--













-- $opentracing
-- This document defines semantic conventions for the OpenTracing Shim
--
-- ==== Note
-- These conventions are used by the OpenTracing Shim layer.
--
-- === Attributes
-- - 'opentracing_refType'
--

-- |
-- Parent-child Reference type

-- ==== Note
-- The causal relationship between a child Span and a parent Span.
opentracing_refType :: AttributeKey Text
opentracing_refType = AttributeKey "opentracing.ref_type"

-- $faasSpan
-- This semantic convention describes an instance of a function that runs without provisioning or managing of servers (also known as serverless functions or Function as a Service (FaaS)) with spans.
--
-- === Attributes
-- - 'faas_trigger'
--
--     ==== Note
--     For the server\/consumer span on the incoming side,
--     @faas.trigger@ MUST be set.
--     
--     Clients invoking FaaS instances usually cannot set @faas.trigger@,
--     since they would typically need to look in the payload to determine
--     the event type. If clients set it, it should be the same as the
--     trigger that corresponding incoming would have (i.e., this has
--     nothing to do with the underlying transport used to make the API
--     call to invoke the lambda, which is often HTTP).
--
-- - 'faas_invocationId'
--
-- - 'cloud_resourceId'
--


-- |
-- The invocation ID of the current function invocation.
faas_invocationId :: AttributeKey Text
faas_invocationId = AttributeKey "faas.invocation_id"


-- $faasSpan_datasource
-- Semantic Convention for FaaS triggered as a response to some data source operation such as a database or filesystem read\/write.
--
-- === Attributes
-- - 'faas_document_collection'
--
--     Requirement level: required
--
-- - 'faas_document_operation'
--
--     Requirement level: required
--
-- - 'faas_document_time'
--
-- - 'faas_document_name'
--

-- |
-- The name of the source on which the triggering operation was performed. For example, in Cloud Storage or S3 corresponds to the bucket name, and in Cosmos DB to the database name.
faas_document_collection :: AttributeKey Text
faas_document_collection = AttributeKey "faas.document.collection"

-- |
-- Describes the type of the operation that was performed on the data.
faas_document_operation :: AttributeKey Text
faas_document_operation = AttributeKey "faas.document.operation"

-- |
-- A string containing the time when the data was accessed in the [ISO 8601](https:\/\/www.iso.org\/iso-8601-date-and-time-format.html) format expressed in [UTC](https:\/\/www.w3.org\/TR\/NOTE-datetime).
faas_document_time :: AttributeKey Text
faas_document_time = AttributeKey "faas.document.time"

-- |
-- The document name\/table subjected to the operation. For example, in Cloud Storage or S3 is the name of the file, and in Cosmos DB the table name.
faas_document_name :: AttributeKey Text
faas_document_name = AttributeKey "faas.document.name"

-- $faasSpan_http
-- Semantic Convention for FaaS triggered as a response to some data source operation such as a database or filesystem read\/write.
--

-- $faasSpan_pubsub
-- Semantic Convention for FaaS set to be executed when messages are sent to a messaging system.
--

-- $faasSpan_timer
-- Semantic Convention for FaaS scheduled to be executed regularly.
--
-- === Attributes
-- - 'faas_time'
--
-- - 'faas_cron'
--

-- |
-- A string containing the function invocation time in the [ISO 8601](https:\/\/www.iso.org\/iso-8601-date-and-time-format.html) format expressed in [UTC](https:\/\/www.w3.org\/TR\/NOTE-datetime).
faas_time :: AttributeKey Text
faas_time = AttributeKey "faas.time"

-- |
-- A string containing the schedule period as [Cron Expression](https:\/\/docs.oracle.com\/cd\/E12058_01\/doc\/doc.1014\/e12030\/cron_expressions.htm).
faas_cron :: AttributeKey Text
faas_cron = AttributeKey "faas.cron"

-- $faasSpan_in
-- Contains additional attributes for incoming FaaS spans.
--
-- === Attributes
-- - 'faas_coldstart'
--
-- - 'faas_trigger'
--
--     Requirement level: required
--
--     ==== Note
--     For the server\/consumer span on the incoming side,
--     @faas.trigger@ MUST be set.
--     
--     Clients invoking FaaS instances usually cannot set @faas.trigger@,
--     since they would typically need to look in the payload to determine
--     the event type. If clients set it, it should be the same as the
--     trigger that corresponding incoming would have (i.e., this has
--     nothing to do with the underlying transport used to make the API
--     call to invoke the lambda, which is often HTTP).
--

-- |
-- A boolean that is true if the serverless function is executed for the first time (aka cold-start).
faas_coldstart :: AttributeKey Bool
faas_coldstart = AttributeKey "faas.coldstart"


-- $faasSpan_out
-- Contains additional attributes for outgoing FaaS spans.
--
-- === Attributes
-- - 'faas_invokedName'
--
-- - 'faas_invokedProvider'
--
-- - 'faas_invokedRegion'
--




-- $messaging_message
-- Semantic convention describing per-message attributes populated on messaging spans or links.
--
-- === Attributes
-- - 'messaging_destination_name'
--
-- - 'messaging_message_id'
--
-- - 'messaging_message_conversationId'
--
-- - 'messaging_message_envelope_size'
--
-- - 'messaging_message_body_size'
--






-- $messaging_destination
-- Semantic convention for attributes that describe messaging destination on broker
--
-- ==== Note
-- Destination attributes should be set on publish, receive, or other spans
-- describing messaging operations.
-- 
-- Destination attributes should be set when the messaging operation handles
-- single messages. When the operation handles a batch of messages,
-- the destination attributes should only be applied when the attribute value
-- applies to all messages in the batch.
-- In other cases, destination attributes may be set on links.
--
-- === Attributes
-- - 'messaging_destination_name'
--
-- - 'messaging_destination_template'
--
-- - 'messaging_destination_temporary'
--
-- - 'messaging_destination_anonymous'
--





-- $messaging_destinationPublish
-- Semantic convention for attributes that describe the publish messaging destination on broker. The term Publish Destination refers to the destination the message was originally published to. These attributes should be used on the consumer side when information about the publish destination is available and different than the destination message are consumed from.
--
-- ==== Note
-- Publish destination attributes should be set on publish, receive,
-- or other spans describing messaging operations.
-- Destination attributes should be set when the messaging operation handles
-- single messages. When the operation handles a batch of messages,
-- the destination attributes should only be applied when the attribute value
-- applies to all messages in the batch.
-- In other cases, destination attributes may be set on links.
--
-- === Attributes
-- - 'messaging_destinationPublish_name'
--
-- - 'messaging_destinationPublish_anonymous'
--



-- $messaging
-- This document defines general attributes used in messaging systems.
--
-- === Attributes
-- - 'messaging_operation'
--
--     Requirement level: required
--
-- - 'messaging_batch_messageCount'
--
--     Requirement level: conditionally required: If the span describes an operation on a batch of messages.
--
-- - 'messaging_clientId'
--
--     Requirement level: recommended: If a client id is available
--
-- - 'messaging_destination_name'
--
--     Requirement level: conditionally required: If span describes operation on a single message or if the value applies to all messages in the batch.
--
-- - 'messaging_destination_template'
--
--     Requirement level: conditionally required: If available. Instrumentations MUST NOT use @messaging.destination.name@ as template unless low-cardinality of destination name is guaranteed.
--
-- - 'messaging_destination_temporary'
--
--     Requirement level: conditionally required: If value is @true@. When missing, the value is assumed to be @false@.
--
-- - 'messaging_destination_anonymous'
--
--     Requirement level: conditionally required: If value is @true@. When missing, the value is assumed to be @false@.
--
-- - 'messaging_message_id'
--
-- - 'messaging_message_conversationId'
--
-- - 'messaging_message_envelope_size'
--
-- - 'messaging_message_body_size'
--
-- - 'server_address'
--
-- - 'network_peer_address'
--
-- - 'network_peer_port'
--
--     Requirement level: recommended: If @network.peer.address@ is set.
--
-- - 'network_transport'
--
-- - 'network_type'
--

















-- $messaging_rabbitmq
-- Attributes for RabbitMQ
--
-- === Attributes
-- - 'messaging_rabbitmq_destination_routingKey'
--
--     Requirement level: conditionally required: If not empty.
--
-- - 'messaging_rabbitmq_message_deliveryTag'
--
--     Requirement level: conditionally required: When available.
--



-- $messaging_kafka
-- Attributes for Apache Kafka
--
-- === Attributes
-- - 'messaging_kafka_message_key'
--
-- - 'messaging_kafka_consumer_group'
--
-- - 'messaging_kafka_destination_partition'
--
-- - 'messaging_kafka_message_offset'
--
-- - 'messaging_kafka_message_tombstone'
--
--     Requirement level: conditionally required: If value is @true@. When missing, the value is assumed to be @false@.
--






-- $messaging_rocketmq
-- Attributes for Apache RocketMQ
--
-- === Attributes
-- - 'messaging_rocketmq_namespace'
--
--     Requirement level: required
--
-- - 'messaging_rocketmq_clientGroup'
--
--     Requirement level: required
--
-- - 'messaging_rocketmq_message_deliveryTimestamp'
--
--     Requirement level: conditionally required: If the message type is delay and delay time level is not specified.
--
-- - 'messaging_rocketmq_message_delayTimeLevel'
--
--     Requirement level: conditionally required: If the message type is delay and delivery timestamp is not specified.
--
-- - 'messaging_rocketmq_message_group'
--
--     Requirement level: conditionally required: If the message type is FIFO.
--
-- - 'messaging_rocketmq_message_type'
--
-- - 'messaging_rocketmq_message_tag'
--
-- - 'messaging_rocketmq_message_keys'
--
-- - 'messaging_rocketmq_consumptionModel'
--










-- $messaging_gcpPubsub
-- Attributes for Google Cloud Pub\/Sub
--
-- === Attributes
-- - 'messaging_gcpPubsub_message_orderingKey'
--
--     Requirement level: conditionally required: If the message type has an ordering key set.
--


-- $messaging_servicebus
-- Attributes for Azure Service Bus
--
-- === Attributes
-- - 'messaging_servicebus_message_deliveryCount'
--
--     Requirement level: conditionally required: If delivery count is available and is bigger than 0.
--
-- - 'messaging_servicebus_message_enqueuedTime'
--
-- - 'messaging_servicebus_destination_subscriptionName'
--
--     Requirement level: conditionally required: If messages are received from the subscription.
--
-- - 'messaging_servicebus_dispositionStatus'
--
--     Requirement level: conditionally required: if and only if @messaging.operation@ is @settle@.
--





-- $messaging_eventhubs
-- Attributes for Azure Event Hubs
--
-- === Attributes
-- - 'messaging_eventhubs_message_enqueuedTime'
--
-- - 'messaging_eventhubs_destination_partition_id'
--
--     Requirement level: conditionally required: If available.
--
-- - 'messaging_eventhubs_consumer_group'
--
--     Requirement level: conditionally required: If not default ("$Default").
--




-- $db
-- This document defines the attributes used to perform database client calls.
--
-- === Attributes
-- - 'db_system'
--
--     Requirement level: required
--
-- - 'db_connectionString'
--
-- - 'db_user'
--
-- - 'db_name'
--
--     Requirement level: conditionally required: If applicable.
--
-- - 'db_statement'
--
--     Requirement level: recommended: Should be collected by default only if there is sanitization that excludes sensitive information.
--
-- - 'db_operation'
--
--     Requirement level: conditionally required: If @db.statement@ is not applicable.
--
-- - 'server_address'
--
--     Name of the database host.
--
-- - 'server_port'
--
--     Requirement level: conditionally required: If using a port other than the default port for this DBMS and if @server.address@ is set.
--
-- - 'network_peer_address'
--
-- - 'network_peer_port'
--
--     Requirement level: recommended: If @network.peer.address@ is set.
--
-- - 'network_transport'
--
-- - 'network_type'
--
-- - 'db_instance_id'
--
--     Requirement level: recommended: If different from the @server.address@
--














-- $db_mssql
-- Attributes for Microsoft SQL Server
--
-- === Attributes
-- - 'db_mssql_instanceName'
--


-- $db_cassandra
-- Attributes for Cassandra
--
-- === Attributes
-- - 'db_name'
--
--     The keyspace name in Cassandra.
--
--     ==== Note
--     For Cassandra the @db.name@ should be set to the Cassandra keyspace name.
--
-- - 'db_cassandra_pageSize'
--
-- - 'db_cassandra_consistencyLevel'
--
-- - 'db_cassandra_table'
--
-- - 'db_cassandra_idempotence'
--
-- - 'db_cassandra_speculativeExecutionCount'
--
-- - 'db_cassandra_coordinator_id'
--
-- - 'db_cassandra_coordinator_dc'
--









-- $db_hbase
-- Attributes for HBase
--
-- === Attributes
-- - 'db_name'
--
--     The HBase namespace.
--
--     ==== Note
--     For HBase the @db.name@ should be set to the HBase namespace.
--


-- $db_couchdb
-- Attributes for CouchDB
--
-- === Attributes
-- - 'db_operation'
--
--     The HTTP method + the target REST route.
--
--     ==== Note
--     In __CouchDB__, @db.operation@ should be set to the HTTP method + the target REST route according to the API reference documentation. For example, when retrieving a document, @db.operation@ would be set to (literally, i.e., without replacing the placeholders with concrete values): [@GET \/{db}\/{docid}@](https:\/\/docs.couchdb.org\/en\/stable\/api\/document\/common.html#get--db-docid).
--


-- $db_redis
-- Attributes for Redis
--
-- === Attributes
-- - 'db_redis_databaseIndex'
--
--     Requirement level: conditionally required: If other than the default database (@0@).
--
-- - 'db_statement'
--
--     The full syntax of the Redis CLI command.
--
--     ==== Note
--     For __Redis__, the value provided for @db.statement@ SHOULD correspond to the syntax of the Redis CLI. If, for example, the [@HMSET@ command](https:\/\/redis.io\/commands\/hmset) is invoked, @"HMSET myhash field1 \'Hello\' field2 \'World\'"@ would be a suitable value for @db.statement@.
--



-- $db_mongodb
-- Attributes for MongoDB
--
-- === Attributes
-- - 'db_mongodb_collection'
--
--     Requirement level: required
--


-- $db_elasticsearch
-- Attributes for Elasticsearch
--
-- === Attributes
-- - 'http_request_method'
--
--     Requirement level: required
--
-- - 'db_operation'
--
--     The endpoint identifier for the request.
--
--     Requirement level: required
--
-- - 'url_full'
--
--     Requirement level: required
--
-- - 'db_statement'
--
--     The request body for a [search-type query](https:\/\/www.elastic.co\/guide\/en\/elasticsearch\/reference\/current\/search.html), as a json string.
--
--     Requirement level: recommended: Should be collected by default for search-type queries and only if there is sanitization that excludes sensitive information.
--
-- - 'server_address'
--
-- - 'server_port'
--
-- - 'db_elasticsearch_cluster_name'
--
--     Requirement level: recommended: When communicating with an Elastic Cloud deployment, this should be collected from the "X-Found-Handling-Cluster" HTTP response header.
--
-- - 'db_elasticsearch_node_name'
--
--     Requirement level: recommended: When communicating with an Elastic Cloud deployment, this should be collected from the "X-Found-Handling-Instance" HTTP response header.
--
-- - 'db_elasticsearch_pathParts'
--
--     Requirement level: conditionally required: when the url has dynamic values
--










-- $db_sql
-- Attributes for SQL databases
--
-- === Attributes
-- - 'db_sql_table'
--
-- - 'db_jdbc_driverClassname'
--



-- $db_cosmosdb
-- Attributes for Cosmos DB.
--
-- === Attributes
-- - 'db_cosmosdb_clientId'
--
-- - 'db_cosmosdb_operationType'
--
--     Requirement level: conditionally required: when performing one of the operations in this list
--
-- - 'userAgent_original'
--
--     Full user-agent string is generated by Cosmos DB SDK
--
--     ==== Note
--     The user-agent value is generated by SDK which is a combination of\<br\> @sdk_version@ : Current version of SDK. e.g. \'cosmos-netstandard-sdk\/3.23.0\'\<br\> @direct_pkg_version@ : Direct package version used by Cosmos DB SDK. e.g. \'3.23.1\'\<br\> @number_of_client_instances@ : Number of cosmos client instances created by the application. e.g. \'1\'\<br\> @type_of_machine_architecture@ : Machine architecture. e.g. \'X64\'\<br\> @operating_system@ : Operating System. e.g. \'Linux 5.4.0-1098-azure 104 18\'\<br\> @runtime_framework@ : Runtime Framework. e.g. \'.NET Core 3.1.32\'\<br\> @failover_information@ : Generated key to determine if region failover enabled.
--        Format Reg-{D (Disabled discovery)}-S(application region)|L(List of preferred regions)|N(None, user did not configure it).
--        Default value is "NS".
--
-- - 'db_cosmosdb_connectionMode'
--
--     Requirement level: conditionally required: if not @direct@ (or pick gw as default)
--
-- - 'db_cosmosdb_container'
--
--     Requirement level: conditionally required: if available
--
-- - 'db_cosmosdb_requestContentLength'
--
-- - 'db_cosmosdb_statusCode'
--
--     Requirement level: conditionally required: if response was received
--
-- - 'db_cosmosdb_subStatusCode'
--
--     Requirement level: conditionally required: when response was received and contained sub-code.
--
-- - 'db_cosmosdb_requestCharge'
--
--     Requirement level: conditionally required: when available
--










-- $aws_lambda
-- Span attributes used by AWS Lambda (in addition to general @faas@ attributes).
--
-- === Attributes
-- - 'aws_lambda_invokedArn'
--

-- |
-- The full invoked ARN as provided on the @Context@ passed to the function (@Lambda-Runtime-Invoked-Function-Arn@ header on the @\/runtime\/invocation\/next@ applicable).

-- ==== Note
-- This may be different from @cloud.resource_id@ if an alias is involved.
aws_lambda_invokedArn :: AttributeKey Text
aws_lambda_invokedArn = AttributeKey "aws.lambda.invoked_arn"

-- $otelSpan
-- Span attributes used by non-OTLP exporters to represent OpenTelemetry Span\'s concepts.
--
-- === Attributes
-- - 'otel_statusCode'
--
--     Stability: stable
--
-- - 'otel_statusDescription'
--
--     Stability: stable
--

-- |
-- Name of the code, either "OK" or "ERROR". MUST NOT be set if the status code is UNSET.
otel_statusCode :: AttributeKey Text
otel_statusCode = AttributeKey "otel.status_code"

-- |
-- Description of the Status if it has a value, otherwise not set.
otel_statusDescription :: AttributeKey Text
otel_statusDescription = AttributeKey "otel.status_description"

-- $aws
-- The @aws@ conventions apply to operations using the AWS SDK. They map request or response parameters in AWS SDK API calls to attributes on a Span. The conventions have been collected over time based on feedback from AWS users of tracing and will continue to evolve as new interesting conventions are found.
-- Some descriptions are also provided for populating general OpenTelemetry semantic conventions based on these APIs.
--
-- === Attributes
-- - 'rpc_system'
--
--     The value @aws-api@.
--
--     Requirement level: required
--
-- - 'rpc_service'
--
--     The name of the service to which a request is made, as returned by the AWS SDK.
--
-- - 'rpc_method'
--
--     The name of the operation corresponding to the request, as returned by the AWS SDK
--
-- - 'aws_requestId'
--




-- |
-- The AWS request ID as returned in the response headers @x-amz-request-id@ or @x-amz-requestid@.
aws_requestId :: AttributeKey Text
aws_requestId = AttributeKey "aws.request_id"

-- $dynamodb_all
-- Attributes always filled for all DynamoDB request types.
--
-- === Attributes
-- - 'db_system'
--
--     The value @dynamodb@.
--
--     Requirement level: required
--


-- $dynamodb_shared
-- Attributes that exist for multiple DynamoDB request types.
--
-- === Attributes
-- - 'db_operation'
--
--     The same value as @rpc.method@.
--
-- - 'aws_dynamodb_tableNames'
--
-- - 'aws_dynamodb_consumedCapacity'
--
-- - 'aws_dynamodb_itemCollectionMetrics'
--
-- - 'aws_dynamodb_provisionedReadCapacity'
--
-- - 'aws_dynamodb_provisionedWriteCapacity'
--
-- - 'aws_dynamodb_consistentRead'
--
-- - 'aws_dynamodb_projection'
--
-- - 'aws_dynamodb_limit'
--
-- - 'aws_dynamodb_attributesToGet'
--
-- - 'aws_dynamodb_indexName'
--
-- - 'aws_dynamodb_select'
--


-- |
-- The keys in the @RequestItems@ object field.
aws_dynamodb_tableNames :: AttributeKey [Text]
aws_dynamodb_tableNames = AttributeKey "aws.dynamodb.table_names"

-- |
-- The JSON-serialized value of each item in the @ConsumedCapacity@ response field.
aws_dynamodb_consumedCapacity :: AttributeKey [Text]
aws_dynamodb_consumedCapacity = AttributeKey "aws.dynamodb.consumed_capacity"

-- |
-- The JSON-serialized value of the @ItemCollectionMetrics@ response field.
aws_dynamodb_itemCollectionMetrics :: AttributeKey Text
aws_dynamodb_itemCollectionMetrics = AttributeKey "aws.dynamodb.item_collection_metrics"

-- |
-- The value of the @ProvisionedThroughput.ReadCapacityUnits@ request parameter.
aws_dynamodb_provisionedReadCapacity :: AttributeKey Double
aws_dynamodb_provisionedReadCapacity = AttributeKey "aws.dynamodb.provisioned_read_capacity"

-- |
-- The value of the @ProvisionedThroughput.WriteCapacityUnits@ request parameter.
aws_dynamodb_provisionedWriteCapacity :: AttributeKey Double
aws_dynamodb_provisionedWriteCapacity = AttributeKey "aws.dynamodb.provisioned_write_capacity"

-- |
-- The value of the @ConsistentRead@ request parameter.
aws_dynamodb_consistentRead :: AttributeKey Bool
aws_dynamodb_consistentRead = AttributeKey "aws.dynamodb.consistent_read"

-- |
-- The value of the @ProjectionExpression@ request parameter.
aws_dynamodb_projection :: AttributeKey Text
aws_dynamodb_projection = AttributeKey "aws.dynamodb.projection"

-- |
-- The value of the @Limit@ request parameter.
aws_dynamodb_limit :: AttributeKey Int64
aws_dynamodb_limit = AttributeKey "aws.dynamodb.limit"

-- |
-- The value of the @AttributesToGet@ request parameter.
aws_dynamodb_attributesToGet :: AttributeKey [Text]
aws_dynamodb_attributesToGet = AttributeKey "aws.dynamodb.attributes_to_get"

-- |
-- The value of the @IndexName@ request parameter.
aws_dynamodb_indexName :: AttributeKey Text
aws_dynamodb_indexName = AttributeKey "aws.dynamodb.index_name"

-- |
-- The value of the @Select@ request parameter.
aws_dynamodb_select :: AttributeKey Text
aws_dynamodb_select = AttributeKey "aws.dynamodb.select"

-- $dynamodb_batchgetitem
-- DynamoDB.BatchGetItem
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
-- - 'aws_dynamodb_consumedCapacity'
--



-- $dynamodb_batchwriteitem
-- DynamoDB.BatchWriteItem
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
-- - 'aws_dynamodb_consumedCapacity'
--
-- - 'aws_dynamodb_itemCollectionMetrics'
--




-- $dynamodb_createtable
-- DynamoDB.CreateTable
--
-- === Attributes
-- - 'aws_dynamodb_globalSecondaryIndexes'
--
-- - 'aws_dynamodb_localSecondaryIndexes'
--
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
-- - 'aws_dynamodb_consumedCapacity'
--
-- - 'aws_dynamodb_itemCollectionMetrics'
--
-- - 'aws_dynamodb_provisionedReadCapacity'
--
-- - 'aws_dynamodb_provisionedWriteCapacity'
--

-- |
-- The JSON-serialized value of each item of the @GlobalSecondaryIndexes@ request field
aws_dynamodb_globalSecondaryIndexes :: AttributeKey [Text]
aws_dynamodb_globalSecondaryIndexes = AttributeKey "aws.dynamodb.global_secondary_indexes"

-- |
-- The JSON-serialized value of each item of the @LocalSecondaryIndexes@ request field.
aws_dynamodb_localSecondaryIndexes :: AttributeKey [Text]
aws_dynamodb_localSecondaryIndexes = AttributeKey "aws.dynamodb.local_secondary_indexes"






-- $dynamodb_deleteitem
-- DynamoDB.DeleteItem
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
-- - 'aws_dynamodb_consumedCapacity'
--
-- - 'aws_dynamodb_itemCollectionMetrics'
--




-- $dynamodb_deletetable
-- DynamoDB.DeleteTable
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--


-- $dynamodb_describetable
-- DynamoDB.DescribeTable
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--


-- $dynamodb_getitem
-- DynamoDB.GetItem
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
-- - 'aws_dynamodb_consumedCapacity'
--
-- - 'aws_dynamodb_consistentRead'
--
-- - 'aws_dynamodb_projection'
--





-- $dynamodb_listtables
-- DynamoDB.ListTables
--
-- === Attributes
-- - 'aws_dynamodb_exclusiveStartTable'
--
-- - 'aws_dynamodb_tableCount'
--
-- - 'aws_dynamodb_limit'
--

-- |
-- The value of the @ExclusiveStartTableName@ request parameter.
aws_dynamodb_exclusiveStartTable :: AttributeKey Text
aws_dynamodb_exclusiveStartTable = AttributeKey "aws.dynamodb.exclusive_start_table"

-- |
-- The the number of items in the @TableNames@ response parameter.
aws_dynamodb_tableCount :: AttributeKey Int64
aws_dynamodb_tableCount = AttributeKey "aws.dynamodb.table_count"


-- $dynamodb_putitem
-- DynamoDB.PutItem
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
-- - 'aws_dynamodb_consumedCapacity'
--
-- - 'aws_dynamodb_itemCollectionMetrics'
--




-- $dynamodb_query
-- DynamoDB.Query
--
-- === Attributes
-- - 'aws_dynamodb_scanForward'
--
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
-- - 'aws_dynamodb_consumedCapacity'
--
-- - 'aws_dynamodb_consistentRead'
--
-- - 'aws_dynamodb_limit'
--
-- - 'aws_dynamodb_projection'
--
-- - 'aws_dynamodb_attributesToGet'
--
-- - 'aws_dynamodb_indexName'
--
-- - 'aws_dynamodb_select'
--

-- |
-- The value of the @ScanIndexForward@ request parameter.
aws_dynamodb_scanForward :: AttributeKey Bool
aws_dynamodb_scanForward = AttributeKey "aws.dynamodb.scan_forward"









-- $dynamodb_scan
-- DynamoDB.Scan
--
-- === Attributes
-- - 'aws_dynamodb_segment'
--
-- - 'aws_dynamodb_totalSegments'
--
-- - 'aws_dynamodb_count'
--
-- - 'aws_dynamodb_scannedCount'
--
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
-- - 'aws_dynamodb_consumedCapacity'
--
-- - 'aws_dynamodb_consistentRead'
--
-- - 'aws_dynamodb_limit'
--
-- - 'aws_dynamodb_projection'
--
-- - 'aws_dynamodb_attributesToGet'
--
-- - 'aws_dynamodb_indexName'
--
-- - 'aws_dynamodb_select'
--

-- |
-- The value of the @Segment@ request parameter.
aws_dynamodb_segment :: AttributeKey Int64
aws_dynamodb_segment = AttributeKey "aws.dynamodb.segment"

-- |
-- The value of the @TotalSegments@ request parameter.
aws_dynamodb_totalSegments :: AttributeKey Int64
aws_dynamodb_totalSegments = AttributeKey "aws.dynamodb.total_segments"

-- |
-- The value of the @Count@ response parameter.
aws_dynamodb_count :: AttributeKey Int64
aws_dynamodb_count = AttributeKey "aws.dynamodb.count"

-- |
-- The value of the @ScannedCount@ response parameter.
aws_dynamodb_scannedCount :: AttributeKey Int64
aws_dynamodb_scannedCount = AttributeKey "aws.dynamodb.scanned_count"









-- $dynamodb_updateitem
-- DynamoDB.UpdateItem
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
-- - 'aws_dynamodb_consumedCapacity'
--
-- - 'aws_dynamodb_itemCollectionMetrics'
--




-- $dynamodb_updatetable
-- DynamoDB.UpdateTable
--
-- === Attributes
-- - 'aws_dynamodb_attributeDefinitions'
--
-- - 'aws_dynamodb_globalSecondaryIndexUpdates'
--
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
-- - 'aws_dynamodb_consumedCapacity'
--
-- - 'aws_dynamodb_provisionedReadCapacity'
--
-- - 'aws_dynamodb_provisionedWriteCapacity'
--

-- |
-- The JSON-serialized value of each item in the @AttributeDefinitions@ request field.
aws_dynamodb_attributeDefinitions :: AttributeKey [Text]
aws_dynamodb_attributeDefinitions = AttributeKey "aws.dynamodb.attribute_definitions"

-- |
-- The JSON-serialized value of each item in the the @GlobalSecondaryIndexUpdates@ request field.
aws_dynamodb_globalSecondaryIndexUpdates :: AttributeKey [Text]
aws_dynamodb_globalSecondaryIndexUpdates = AttributeKey "aws.dynamodb.global_secondary_index_updates"





-- $aws_s3
-- Attributes that exist for S3 request types.
--
-- === Attributes
-- - 'aws_s3_bucket'
--
-- - 'aws_s3_key'
--
-- - 'aws_s3_copySource'
--
-- - 'aws_s3_uploadId'
--
-- - 'aws_s3_delete'
--
-- - 'aws_s3_partNumber'
--

-- |
-- The S3 bucket name the request refers to. Corresponds to the @--bucket@ parameter of the [S3 API](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/index.html) operations.

-- ==== Note
-- The @bucket@ attribute is applicable to all S3 operations that reference a bucket, i.e. that require the bucket name as a mandatory parameter.
-- This applies to almost all S3 operations except @list-buckets@.
aws_s3_bucket :: AttributeKey Text
aws_s3_bucket = AttributeKey "aws.s3.bucket"

-- |
-- The S3 object key the request refers to. Corresponds to the @--key@ parameter of the [S3 API](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/index.html) operations.

-- ==== Note
-- The @key@ attribute is applicable to all object-related S3 operations, i.e. that require the object key as a mandatory parameter.
-- This applies in particular to the following operations:
-- 
-- - [copy-object](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/copy-object.html)
-- - [delete-object](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/delete-object.html)
-- - [get-object](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/get-object.html)
-- - [head-object](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/head-object.html)
-- - [put-object](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/put-object.html)
-- - [restore-object](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/restore-object.html)
-- - [select-object-content](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/select-object-content.html)
-- - [abort-multipart-upload](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/abort-multipart-upload.html)
-- - [complete-multipart-upload](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/complete-multipart-upload.html)
-- - [create-multipart-upload](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/create-multipart-upload.html)
-- - [list-parts](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/list-parts.html)
-- - [upload-part](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/upload-part.html)
-- - [upload-part-copy](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/upload-part-copy.html)
aws_s3_key :: AttributeKey Text
aws_s3_key = AttributeKey "aws.s3.key"

-- |
-- The source object (in the form @bucket@\/@key@) for the copy operation.

-- ==== Note
-- The @copy_source@ attribute applies to S3 copy operations and corresponds to the @--copy-source@ parameter
-- of the [copy-object operation within the S3 API](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/copy-object.html).
-- This applies in particular to the following operations:
-- 
-- - [copy-object](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/copy-object.html)
-- - [upload-part-copy](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/upload-part-copy.html)
aws_s3_copySource :: AttributeKey Text
aws_s3_copySource = AttributeKey "aws.s3.copy_source"

-- |
-- Upload ID that identifies the multipart upload.

-- ==== Note
-- The @upload_id@ attribute applies to S3 multipart-upload operations and corresponds to the @--upload-id@ parameter
-- of the [S3 API](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/index.html) multipart operations.
-- This applies in particular to the following operations:
-- 
-- - [abort-multipart-upload](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/abort-multipart-upload.html)
-- - [complete-multipart-upload](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/complete-multipart-upload.html)
-- - [list-parts](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/list-parts.html)
-- - [upload-part](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/upload-part.html)
-- - [upload-part-copy](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/upload-part-copy.html)
aws_s3_uploadId :: AttributeKey Text
aws_s3_uploadId = AttributeKey "aws.s3.upload_id"

-- |
-- The delete request container that specifies the objects to be deleted.

-- ==== Note
-- The @delete@ attribute is only applicable to the [delete-object](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/delete-object.html) operation.
-- The @delete@ attribute corresponds to the @--delete@ parameter of the
-- [delete-objects operation within the S3 API](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/delete-objects.html).
aws_s3_delete :: AttributeKey Text
aws_s3_delete = AttributeKey "aws.s3.delete"

-- |
-- The part number of the part being uploaded in a multipart-upload operation. This is a positive integer between 1 and 10,000.

-- ==== Note
-- The @part_number@ attribute is only applicable to the [upload-part](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/upload-part.html)
-- and [upload-part-copy](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/upload-part-copy.html) operations.
-- The @part_number@ attribute corresponds to the @--part-number@ parameter of the
-- [upload-part operation within the S3 API](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/s3api\/upload-part.html).
aws_s3_partNumber :: AttributeKey Int64
aws_s3_partNumber = AttributeKey "aws.s3.part_number"

-- $graphql
-- This document defines semantic conventions to apply when instrumenting the GraphQL implementation. They map GraphQL operations to attributes on a Span.
--
-- === Attributes
-- - 'graphql_operation_name'
--
-- - 'graphql_operation_type'
--
-- - 'graphql_document'
--

-- |
-- The name of the operation being executed.
graphql_operation_name :: AttributeKey Text
graphql_operation_name = AttributeKey "graphql.operation.name"

-- |
-- The type of the operation being executed.
graphql_operation_type :: AttributeKey Text
graphql_operation_type = AttributeKey "graphql.operation.type"

-- |
-- The GraphQL document being executed.

-- ==== Note
-- The value may be sanitized to exclude sensitive information.
graphql_document :: AttributeKey Text
graphql_document = AttributeKey "graphql.document"

-- $url
-- Attributes describing URL.
--
-- === Attributes
-- - 'url_scheme'
--
-- - 'url_full'
--
-- - 'url_path'
--
-- - 'url_query'
--
-- - 'url_fragment'
--






-- $session-id
-- Session is defined as the period of time encompassing all activities performed by the application and the actions executed by the end user.
-- Consequently, a Session is represented as a collection of Logs, Events, and Spans emitted by the Client Application throughout the Session\'s duration. Each Session is assigned a unique identifier, which is included as an attribute in the Logs, Events, and Spans generated during the Session\'s lifecycle.
-- When a session reaches end of life, typically due to user inactivity or session timeout, a new session identifier will be assigned. The previous session identifier may be provided by the instrumentation so that telemetry backends can link the two sessions.
--
-- === Attributes
-- - 'session_id'
--
--     Requirement level: opt-in
--
-- - 'session_previousId'
--
--     Requirement level: opt-in
--

-- |
-- A unique id to identify a session.
session_id :: AttributeKey Text
session_id = AttributeKey "session.id"

-- |
-- The previous @session.id@ for this user, when known.
session_previousId :: AttributeKey Text
session_previousId = AttributeKey "session.previous_id"

-- $registry_os
-- The operating system (OS) on which the process represented by this resource is running.
--
-- ==== Note
-- In case of virtualized environments, this is the operating system as it is observed by the process, i.e., the virtualized guest rather than the underlying host.
--
-- === Attributes
-- - 'os_type'
--
-- - 'os_description'
--
-- - 'os_name'
--
-- - 'os_version'
--
-- - 'os_buildId'
--

-- |
-- The operating system type.
os_type :: AttributeKey Text
os_type = AttributeKey "os.type"

-- |
-- Human readable (not intended to be parsed) OS version information, like e.g. reported by @ver@ or @lsb_release -a@ commands.
os_description :: AttributeKey Text
os_description = AttributeKey "os.description"

-- |
-- Human readable operating system name.
os_name :: AttributeKey Text
os_name = AttributeKey "os.name"

-- |
-- The version string of the operating system as defined in [Version Attributes](\/docs\/resource\/README.md#version-attributes).
os_version :: AttributeKey Text
os_version = AttributeKey "os.version"

-- |
-- Unique identifier for a particular build or compilation of the operating system.
os_buildId :: AttributeKey Text
os_buildId = AttributeKey "os.build_id"

-- $registry_network
-- These attributes may be used for any network related operation.
--
-- === Attributes
-- - 'network_carrier_icc'
--
-- - 'network_carrier_mcc'
--
-- - 'network_carrier_mnc'
--
-- - 'network_carrier_name'
--
-- - 'network_connection_subtype'
--
-- - 'network_connection_type'
--
-- - 'network_local_address'
--
--     Stability: stable
--
-- - 'network_local_port'
--
--     Stability: stable
--
-- - 'network_peer_address'
--
--     Stability: stable
--
-- - 'network_peer_port'
--
--     Stability: stable
--
-- - 'network_protocol_name'
--
--     Stability: stable
--
-- - 'network_protocol_version'
--
--     Stability: stable
--
-- - 'network_transport'
--
--     Stability: stable
--
-- - 'network_type'
--
--     Stability: stable
--
-- - 'network_io_direction'
--

-- |
-- The ISO 3166-1 alpha-2 2-character country code associated with the mobile carrier network.
network_carrier_icc :: AttributeKey Text
network_carrier_icc = AttributeKey "network.carrier.icc"

-- |
-- The mobile carrier country code.
network_carrier_mcc :: AttributeKey Text
network_carrier_mcc = AttributeKey "network.carrier.mcc"

-- |
-- The mobile carrier network code.
network_carrier_mnc :: AttributeKey Text
network_carrier_mnc = AttributeKey "network.carrier.mnc"

-- |
-- The name of the mobile carrier.
network_carrier_name :: AttributeKey Text
network_carrier_name = AttributeKey "network.carrier.name"

-- |
-- This describes more details regarding the connection.type. It may be the type of cell technology connection, but it could be used for describing details about a wifi connection.
network_connection_subtype :: AttributeKey Text
network_connection_subtype = AttributeKey "network.connection.subtype"

-- |
-- The internet connection type.
network_connection_type :: AttributeKey Text
network_connection_type = AttributeKey "network.connection.type"

-- |
-- Local address of the network connection - IP address or Unix domain socket name.
network_local_address :: AttributeKey Text
network_local_address = AttributeKey "network.local.address"

-- |
-- Local port number of the network connection.
network_local_port :: AttributeKey Int64
network_local_port = AttributeKey "network.local.port"

-- |
-- Peer address of the network connection - IP address or Unix domain socket name.
network_peer_address :: AttributeKey Text
network_peer_address = AttributeKey "network.peer.address"

-- |
-- Peer port number of the network connection.
network_peer_port :: AttributeKey Int64
network_peer_port = AttributeKey "network.peer.port"

-- |
-- [OSI application layer](https:\/\/osi-model.com\/application-layer\/) or non-OSI equivalent.

-- ==== Note
-- The value SHOULD be normalized to lowercase.
network_protocol_name :: AttributeKey Text
network_protocol_name = AttributeKey "network.protocol.name"

-- |
-- Version of the protocol specified in @network.protocol.name@.

-- ==== Note
-- @network.protocol.version@ refers to the version of the protocol used and might be different from the protocol client\'s version. If the HTTP client has a version of @0.27.2@, but sends HTTP version @1.1@, this attribute should be set to @1.1@.
network_protocol_version :: AttributeKey Text
network_protocol_version = AttributeKey "network.protocol.version"

-- |
-- [OSI transport layer](https:\/\/osi-model.com\/transport-layer\/) or [inter-process communication method](https:\/\/wikipedia.org\/wiki\/Inter-process_communication).

-- ==== Note
-- The value SHOULD be normalized to lowercase.
-- 
-- Consider always setting the transport when setting a port number, since
-- a port number is ambiguous without knowing the transport. For example
-- different processes could be listening on TCP port 12345 and UDP port 12345.
network_transport :: AttributeKey Text
network_transport = AttributeKey "network.transport"

-- |
-- [OSI network layer](https:\/\/osi-model.com\/network-layer\/) or non-OSI equivalent.

-- ==== Note
-- The value SHOULD be normalized to lowercase.
network_type :: AttributeKey Text
network_type = AttributeKey "network.type"

-- |
-- The network IO operation direction.
network_io_direction :: AttributeKey Text
network_io_direction = AttributeKey "network.io.direction"

-- $registry_exception
-- This document defines the shared attributes used to report a single exception associated with a span or log.
--
-- === Attributes
-- - 'exception_type'
--
--     Stability: stable
--
-- - 'exception_message'
--
--     Stability: stable
--
-- - 'exception_stacktrace'
--
--     Stability: stable
--
-- - 'exception_escaped'
--
--     Stability: stable
--

-- |
-- The type of the exception (its fully-qualified class name, if applicable). The dynamic type of the exception should be preferred over the static type in languages that support it.
exception_type :: AttributeKey Text
exception_type = AttributeKey "exception.type"

-- |
-- The exception message.
exception_message :: AttributeKey Text
exception_message = AttributeKey "exception.message"

-- |
-- A stacktrace as a string in the natural representation for the language runtime. The representation is to be determined and documented by each language SIG.
exception_stacktrace :: AttributeKey Text
exception_stacktrace = AttributeKey "exception.stacktrace"

-- |
-- SHOULD be set to true if the exception event is recorded at a point where it is known that the exception is escaping the scope of the span.

-- ==== Note
-- An exception is considered to have escaped (or left) the scope of a span,
-- if that span is ended while the exception is still logically "in flight".
-- This may be actually "in flight" in some languages (e.g. if the exception
-- is passed to a Context manager\'s @__exit__@ method in Python) but will
-- usually be caught at the point of recording the exception in most languages.
-- 
-- It is usually not possible to determine at the point where an exception is thrown
-- whether it will escape the scope of a span.
-- However, it is trivial to know that an exception
-- will escape, if one checks for an active exception just before ending the span,
-- as done in the [example for recording span exceptions](#recording-an-exception).
-- 
-- It follows that an exception may still escape the scope of the span
-- even if the @exception.escaped@ attribute was not set or set to false,
-- since the event might have been recorded at a time where it was not
-- clear whether the exception will escape.
exception_escaped :: AttributeKey Bool
exception_escaped = AttributeKey "exception.escaped"

-- $registry_browser
-- The web browser attributes
--
-- === Attributes
-- - 'browser_brands'
--
-- - 'browser_platform'
--
-- - 'browser_mobile'
--
-- - 'browser_language'
--

-- |
-- Array of brand name and version separated by a space

-- ==== Note
-- This value is intended to be taken from the [UA client hints API](https:\/\/wicg.github.io\/ua-client-hints\/#interface) (@navigator.userAgentData.brands@).
browser_brands :: AttributeKey [Text]
browser_brands = AttributeKey "browser.brands"

-- |
-- The platform on which the browser is running

-- ==== Note
-- This value is intended to be taken from the [UA client hints API](https:\/\/wicg.github.io\/ua-client-hints\/#interface) (@navigator.userAgentData.platform@). If unavailable, the legacy @navigator.platform@ API SHOULD NOT be used instead and this attribute SHOULD be left unset in order for the values to be consistent.
-- The list of possible values is defined in the [W3C User-Agent Client Hints specification](https:\/\/wicg.github.io\/ua-client-hints\/#sec-ch-ua-platform). Note that some (but not all) of these values can overlap with values in the [@os.type@ and @os.name@ attributes](.\/os.md). However, for consistency, the values in the @browser.platform@ attribute should capture the exact value that the user agent provides.
browser_platform :: AttributeKey Text
browser_platform = AttributeKey "browser.platform"

-- |
-- A boolean that is true if the browser is running on a mobile device

-- ==== Note
-- This value is intended to be taken from the [UA client hints API](https:\/\/wicg.github.io\/ua-client-hints\/#interface) (@navigator.userAgentData.mobile@). If unavailable, this attribute SHOULD be left unset.
browser_mobile :: AttributeKey Bool
browser_mobile = AttributeKey "browser.mobile"

-- |
-- Preferred language of the user using the browser

-- ==== Note
-- This value is intended to be taken from the Navigator API @navigator.language@.
browser_language :: AttributeKey Text
browser_language = AttributeKey "browser.language"

-- $registry_userAgent
-- Describes user-agent attributes.
--
-- === Attributes
-- - 'userAgent_original'
--
--     Stability: stable
--
-- - 'userAgent_name'
--
-- - 'userAgent_version'
--

-- |
-- Value of the [HTTP User-Agent](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#field.user-agent) header sent by the client.
userAgent_original :: AttributeKey Text
userAgent_original = AttributeKey "user_agent.original"

-- |
-- Name of the user-agent extracted from original. Usually refers to the browser\'s name.

-- ==== Note
-- [Example](https:\/\/www.whatsmyua.info) of extracting browser\'s name from original string. In the case of using a user-agent for non-browser products, such as microservices with multiple names\/versions inside the @user_agent.original@, the most significant name SHOULD be selected. In such a scenario it should align with @user_agent.version@
userAgent_name :: AttributeKey Text
userAgent_name = AttributeKey "user_agent.name"

-- |
-- Version of the user-agent extracted from original. Usually refers to the browser\'s version

-- ==== Note
-- [Example](https:\/\/www.whatsmyua.info) of extracting browser\'s version from original string. In the case of using a user-agent for non-browser products, such as microservices with multiple names\/versions inside the @user_agent.original@, the most significant version SHOULD be selected. In such a scenario it should align with @user_agent.name@
userAgent_version :: AttributeKey Text
userAgent_version = AttributeKey "user_agent.version"

-- $server
-- These attributes may be used to describe the server in a connection-based network interaction where there is one side that initiates the connection (the client is the side that initiates the connection). This covers all TCP network interactions since TCP is connection-based and one side initiates the connection (an exception is made for peer-to-peer communication over TCP where the "user-facing" surface of the protocol \/ API doesn\'t expose a clear notion of client and server). This also covers UDP network interactions where one side initiates the interaction, e.g. QUIC (HTTP\/3) and DNS.
--
-- === Attributes
-- - 'server_address'
--
--     Stability: stable
--
-- - 'server_port'
--
--     Stability: stable
--

-- |
-- Server domain name if available without reverse DNS lookup; otherwise, IP address or Unix domain socket name.

-- ==== Note
-- When observed from the client side, and when communicating through an intermediary, @server.address@ SHOULD represent the server address behind any intermediaries, for example proxies, if it\'s available.
server_address :: AttributeKey Text
server_address = AttributeKey "server.address"

-- |
-- Server port number.

-- ==== Note
-- When observed from the client side, and when communicating through an intermediary, @server.port@ SHOULD represent the server port behind any intermediaries, for example proxies, if it\'s available.
server_port :: AttributeKey Int64
server_port = AttributeKey "server.port"

-- $registry_device
-- Describes device attributes.
--
-- === Attributes
-- - 'device_id'
--
-- - 'device_manufacturer'
--
-- - 'device_model_identifier'
--
-- - 'device_model_name'
--

-- |
-- A unique identifier representing the device

-- ==== Note
-- The device identifier MUST only be defined using the values outlined below. This value is not an advertising identifier and MUST NOT be used as such. On iOS (Swift or Objective-C), this value MUST be equal to the [vendor identifier](https:\/\/developer.apple.com\/documentation\/uikit\/uidevice\/1620059-identifierforvendor). On Android (Java or Kotlin), this value MUST be equal to the Firebase Installation ID or a globally unique UUID which is persisted across sessions in your application. More information can be found [here](https:\/\/developer.android.com\/training\/articles\/user-data-ids) on best practices and exact implementation details. Caution should be taken when storing personal data or anything which can identify a user. GDPR and data protection laws may apply, ensure you do your own due diligence.
device_id :: AttributeKey Text
device_id = AttributeKey "device.id"

-- |
-- The name of the device manufacturer

-- ==== Note
-- The Android OS provides this field via [Build](https:\/\/developer.android.com\/reference\/android\/os\/Build#MANUFACTURER). iOS apps SHOULD hardcode the value @Apple@.
device_manufacturer :: AttributeKey Text
device_manufacturer = AttributeKey "device.manufacturer"

-- |
-- The model identifier for the device

-- ==== Note
-- It\'s recommended this value represents a machine-readable version of the model identifier rather than the market or consumer-friendly name of the device.
device_model_identifier :: AttributeKey Text
device_model_identifier = AttributeKey "device.model.identifier"

-- |
-- The marketing name for the device model

-- ==== Note
-- It\'s recommended this value represents a human-readable version of the device model rather than a machine-readable alternative.
device_model_name :: AttributeKey Text
device_model_name = AttributeKey "device.model.name"

-- $client
-- These attributes may be used to describe the client in a connection-based network interaction where there is one side that initiates the connection (the client is the side that initiates the connection). This covers all TCP network interactions since TCP is connection-based and one side initiates the connection (an exception is made for peer-to-peer communication over TCP where the "user-facing" surface of the protocol \/ API doesn\'t expose a clear notion of client and server). This also covers UDP network interactions where one side initiates the interaction, e.g. QUIC (HTTP\/3) and DNS.
--
-- === Attributes
-- - 'client_address'
--
--     Stability: stable
--
-- - 'client_port'
--
--     Stability: stable
--

-- |
-- Client address - domain name if available without reverse DNS lookup; otherwise, IP address or Unix domain socket name.

-- ==== Note
-- When observed from the server side, and when communicating through an intermediary, @client.address@ SHOULD represent the client address behind any intermediaries,  for example proxies, if it\'s available.
client_address :: AttributeKey Text
client_address = AttributeKey "client.address"

-- |
-- Client port number.

-- ==== Note
-- When observed from the server side, and when communicating through an intermediary, @client.port@ SHOULD represent the client port behind any intermediaries,  for example proxies, if it\'s available.
client_port :: AttributeKey Int64
client_port = AttributeKey "client.port"

-- $registry_process
-- An operating system process.
--
-- === Attributes
-- - 'process_pid'
--
-- - 'process_parentPid'
--
-- - 'process_executable_name'
--
-- - 'process_executable_path'
--
-- - 'process_command'
--
-- - 'process_commandLine'
--
-- - 'process_commandArgs'
--
-- - 'process_owner'
--
-- - 'process_runtime_name'
--
-- - 'process_runtime_version'
--
-- - 'process_runtime_description'
--

-- |
-- Process identifier (PID).
process_pid :: AttributeKey Int64
process_pid = AttributeKey "process.pid"

-- |
-- Parent Process identifier (PPID).
process_parentPid :: AttributeKey Int64
process_parentPid = AttributeKey "process.parent_pid"

-- |
-- The name of the process executable. On Linux based systems, can be set to the @Name@ in @proc\/[pid]\/status@. On Windows, can be set to the base name of @GetProcessImageFileNameW@.
process_executable_name :: AttributeKey Text
process_executable_name = AttributeKey "process.executable.name"

-- |
-- The full path to the process executable. On Linux based systems, can be set to the target of @proc\/[pid]\/exe@. On Windows, can be set to the result of @GetProcessImageFileNameW@.
process_executable_path :: AttributeKey Text
process_executable_path = AttributeKey "process.executable.path"

-- |
-- The command used to launch the process (i.e. the command name). On Linux based systems, can be set to the zeroth string in @proc\/[pid]\/cmdline@. On Windows, can be set to the first parameter extracted from @GetCommandLineW@.
process_command :: AttributeKey Text
process_command = AttributeKey "process.command"

-- |
-- The full command used to launch the process as a single string representing the full command. On Windows, can be set to the result of @GetCommandLineW@. Do not set this if you have to assemble it just for monitoring; use @process.command_args@ instead.
process_commandLine :: AttributeKey Text
process_commandLine = AttributeKey "process.command_line"

-- |
-- All the command arguments (including the command\/executable itself) as received by the process. On Linux-based systems (and some other Unixoid systems supporting procfs), can be set according to the list of null-delimited strings extracted from @proc\/[pid]\/cmdline@. For libc-based executables, this would be the full argv vector passed to @main@.
process_commandArgs :: AttributeKey [Text]
process_commandArgs = AttributeKey "process.command_args"

-- |
-- The username of the user that owns the process.
process_owner :: AttributeKey Text
process_owner = AttributeKey "process.owner"

-- |
-- The name of the runtime of this process. For compiled native binaries, this SHOULD be the name of the compiler.
process_runtime_name :: AttributeKey Text
process_runtime_name = AttributeKey "process.runtime.name"

-- |
-- The version of the runtime of this process, as returned by the runtime without modification.
process_runtime_version :: AttributeKey Text
process_runtime_version = AttributeKey "process.runtime.version"

-- |
-- An additional description about the runtime of the process, for example a specific vendor customization of the runtime environment.
process_runtime_description :: AttributeKey Text
process_runtime_description = AttributeKey "process.runtime.description"

-- $registry_rpc
-- This document defines attributes for remote procedure calls.
--
-- === Attributes
-- - 'rpc_connectRpc_errorCode'
--
-- - 'rpc_connectRpc_request_metadata'
--
-- - 'rpc_connectRpc_response_metadata'
--
-- - 'rpc_grpc_statusCode'
--
-- - 'rpc_grpc_request_metadata'
--
-- - 'rpc_grpc_response_metadata'
--
-- - 'rpc_jsonrpc_errorCode'
--
-- - 'rpc_jsonrpc_errorMessage'
--
-- - 'rpc_jsonrpc_requestId'
--
-- - 'rpc_jsonrpc_version'
--
-- - 'rpc_method'
--
-- - 'rpc_service'
--
-- - 'rpc_system'
--

-- |
-- The [error codes](https:\/\/connect.build\/docs\/protocol\/#error-codes) of the Connect request. Error codes are always string values.
rpc_connectRpc_errorCode :: AttributeKey Text
rpc_connectRpc_errorCode = AttributeKey "rpc.connect_rpc.error_code"

-- |
-- Connect request metadata, @\<key\>@ being the normalized Connect Metadata key (lowercase), the value being the metadata values.

-- ==== Note
-- Instrumentations SHOULD require an explicit configuration of which metadata values are to be captured. Including all request metadata values can be a security risk - explicit configuration helps avoid leaking sensitive information.
rpc_connectRpc_request_metadata :: Text -> AttributeKey [Text]
rpc_connectRpc_request_metadata = \k -> AttributeKey $ "rpc.connect_rpc.request.metadata." <> k

-- |
-- Connect response metadata, @\<key\>@ being the normalized Connect Metadata key (lowercase), the value being the metadata values.

-- ==== Note
-- Instrumentations SHOULD require an explicit configuration of which metadata values are to be captured. Including all response metadata values can be a security risk - explicit configuration helps avoid leaking sensitive information.
rpc_connectRpc_response_metadata :: Text -> AttributeKey [Text]
rpc_connectRpc_response_metadata = \k -> AttributeKey $ "rpc.connect_rpc.response.metadata." <> k

-- |
-- The [numeric status code](https:\/\/github.com\/grpc\/grpc\/blob\/v1.33.2\/doc\/statuscodes.md) of the gRPC request.
rpc_grpc_statusCode :: AttributeKey Text
rpc_grpc_statusCode = AttributeKey "rpc.grpc.status_code"

-- |
-- gRPC request metadata, @\<key\>@ being the normalized gRPC Metadata key (lowercase), the value being the metadata values.

-- ==== Note
-- Instrumentations SHOULD require an explicit configuration of which metadata values are to be captured. Including all request metadata values can be a security risk - explicit configuration helps avoid leaking sensitive information.
rpc_grpc_request_metadata :: Text -> AttributeKey [Text]
rpc_grpc_request_metadata = \k -> AttributeKey $ "rpc.grpc.request.metadata." <> k

-- |
-- gRPC response metadata, @\<key\>@ being the normalized gRPC Metadata key (lowercase), the value being the metadata values.

-- ==== Note
-- Instrumentations SHOULD require an explicit configuration of which metadata values are to be captured. Including all response metadata values can be a security risk - explicit configuration helps avoid leaking sensitive information.
rpc_grpc_response_metadata :: Text -> AttributeKey [Text]
rpc_grpc_response_metadata = \k -> AttributeKey $ "rpc.grpc.response.metadata." <> k

-- |
-- @error.code@ property of response if it is an error response.
rpc_jsonrpc_errorCode :: AttributeKey Int64
rpc_jsonrpc_errorCode = AttributeKey "rpc.jsonrpc.error_code"

-- |
-- @error.message@ property of response if it is an error response.
rpc_jsonrpc_errorMessage :: AttributeKey Text
rpc_jsonrpc_errorMessage = AttributeKey "rpc.jsonrpc.error_message"

-- |
-- @id@ property of request or response. Since protocol allows id to be int, string, @null@ or missing (for notifications), value is expected to be cast to string for simplicity. Use empty string in case of @null@ value. Omit entirely if this is a notification.
rpc_jsonrpc_requestId :: AttributeKey Text
rpc_jsonrpc_requestId = AttributeKey "rpc.jsonrpc.request_id"

-- |
-- Protocol version as in @jsonrpc@ property of request\/response. Since JSON-RPC 1.0 doesn\'t specify this, the value can be omitted.
rpc_jsonrpc_version :: AttributeKey Text
rpc_jsonrpc_version = AttributeKey "rpc.jsonrpc.version"

-- |
-- The name of the (logical) method being called, must be equal to the $method part in the span name.

-- ==== Note
-- This is the logical name of the method from the RPC interface perspective, which can be different from the name of any implementing method\/function. The @code.function@ attribute may be used to store the latter (e.g., method actually executing the call on the server side, RPC client stub method on the client side).
rpc_method :: AttributeKey Text
rpc_method = AttributeKey "rpc.method"

-- |
-- The full (logical) name of the service being called, including its package name, if applicable.

-- ==== Note
-- This is the logical name of the service from the RPC interface perspective, which can be different from the name of any implementing class. The @code.namespace@ attribute may be used to store the latter (despite the attribute name, it may include a class name; e.g., class with method actually executing the call on the server side, RPC client stub class on the client side).
rpc_service :: AttributeKey Text
rpc_service = AttributeKey "rpc.service"

-- |
-- A string identifying the remoting system. See below for a list of well-known identifiers.
rpc_system :: AttributeKey Text
rpc_system = AttributeKey "rpc.system"

-- $destination
-- These attributes may be used to describe the receiver of a network exchange\/packet. These should be used when there is no client\/server relationship between the two sides, or when that relationship is unknown. This covers low-level network interactions (e.g. packet tracing) where you don\'t know if there was a connection or which side initiated it. This also covers unidirectional UDP flows and peer-to-peer communication where the "user-facing" surface of the protocol \/ API doesn\'t expose a clear notion of client and server.
--
-- === Attributes
-- - 'destination_address'
--
-- - 'destination_port'
--

-- |
-- Destination address - domain name if available without reverse DNS lookup; otherwise, IP address or Unix domain socket name.

-- ==== Note
-- When observed from the source side, and when communicating through an intermediary, @destination.address@ SHOULD represent the destination address behind any intermediaries, for example proxies, if it\'s available.
destination_address :: AttributeKey Text
destination_address = AttributeKey "destination.address"

-- |
-- Destination port number
destination_port :: AttributeKey Int64
destination_port = AttributeKey "destination.port"

-- $registry_disk
-- These attributes may be used for any disk related operation.
--
-- === Attributes
-- - 'disk_io_direction'
--

-- |
-- The disk IO operation direction.
disk_io_direction :: AttributeKey Text
disk_io_direction = AttributeKey "disk.io.direction"

-- $registry_thread
-- These attributes may be used for any operation to store information about a thread that started a span.
--
-- === Attributes
-- - 'thread_id'
--
-- - 'thread_name'
--

-- |
-- Current "managed" thread ID (as opposed to OS thread ID).
thread_id :: AttributeKey Int64
thread_id = AttributeKey "thread.id"

-- |
-- Current thread name.
thread_name :: AttributeKey Text
thread_name = AttributeKey "thread.name"

-- $registry_http
-- This document defines semantic convention attributes in the HTTP namespace.
--
-- === Attributes
-- - 'http_request_body_size'
--
--     Stability: experimental
--
-- - 'http_request_header'
--
--     Stability: stable
--
-- - 'http_request_method'
--
--     Stability: stable
--
-- - 'http_request_methodOriginal'
--
--     Stability: stable
--
-- - 'http_request_resendCount'
--
--     Stability: stable
--
-- - 'http_response_body_size'
--
--     Stability: experimental
--
-- - 'http_response_header'
--
--     Stability: stable
--
-- - 'http_response_statusCode'
--
--     Stability: stable
--
-- - 'http_route'
--
--     Stability: stable
--

-- |
-- The size of the request payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.
http_request_body_size :: AttributeKey Int64
http_request_body_size = AttributeKey "http.request.body.size"

-- |
-- HTTP request headers, @\<key\>@ being the normalized HTTP Header name (lowercase), the value being the header values.

-- ==== Note
-- Instrumentations SHOULD require an explicit configuration of which headers are to be captured. Including all request headers can be a security risk - explicit configuration helps avoid leaking sensitive information.
-- The @User-Agent@ header is already captured in the @user_agent.original@ attribute. Users MAY explicitly configure instrumentations to capture them even though it is not recommended.
-- The attribute value MUST consist of either multiple header values as an array of strings or a single-item array containing a possibly comma-concatenated string, depending on the way the HTTP library provides access to headers.
http_request_header :: Text -> AttributeKey [Text]
http_request_header = \k -> AttributeKey $ "http.request.header." <> k

-- |
-- HTTP request method.

-- ==== Note
-- HTTP request method value SHOULD be "known" to the instrumentation.
-- By default, this convention defines "known" methods as the ones listed in [RFC9110](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#name-methods)
-- and the PATCH method defined in [RFC5789](https:\/\/www.rfc-editor.org\/rfc\/rfc5789.html).
-- 
-- If the HTTP request method is not known to instrumentation, it MUST set the @http.request.method@ attribute to @_OTHER@.
-- 
-- If the HTTP instrumentation could end up converting valid HTTP request methods to @_OTHER@, then it MUST provide a way to override
-- the list of known HTTP methods. If this override is done via environment variable, then the environment variable MUST be named
-- OTEL_INSTRUMENTATION_HTTP_KNOWN_METHODS and support a comma-separated list of case-sensitive known HTTP methods
-- (this list MUST be a full override of the default known method, it is not a list of known methods in addition to the defaults).
-- 
-- HTTP method names are case-sensitive and @http.request.method@ attribute value MUST match a known HTTP method name exactly.
-- Instrumentations for specific web frameworks that consider HTTP methods to be case insensitive, SHOULD populate a canonical equivalent.
-- Tracing instrumentations that do so, MUST also set @http.request.method_original@ to the original value.
http_request_method :: AttributeKey Text
http_request_method = AttributeKey "http.request.method"

-- |
-- Original HTTP method sent by the client in the request line.
http_request_methodOriginal :: AttributeKey Text
http_request_methodOriginal = AttributeKey "http.request.method_original"

-- |
-- The ordinal number of request resending attempt (for any reason, including redirects).

-- ==== Note
-- The resend count SHOULD be updated each time an HTTP request gets resent by the client, regardless of what was the cause of the resending (e.g. redirection, authorization failure, 503 Server Unavailable, network issues, or any other).
http_request_resendCount :: AttributeKey Int64
http_request_resendCount = AttributeKey "http.request.resend_count"

-- |
-- The size of the response payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.
http_response_body_size :: AttributeKey Int64
http_response_body_size = AttributeKey "http.response.body.size"

-- |
-- HTTP response headers, @\<key\>@ being the normalized HTTP Header name (lowercase), the value being the header values.

-- ==== Note
-- Instrumentations SHOULD require an explicit configuration of which headers are to be captured. Including all response headers can be a security risk - explicit configuration helps avoid leaking sensitive information.
-- Users MAY explicitly configure instrumentations to capture them even though it is not recommended.
-- The attribute value MUST consist of either multiple header values as an array of strings or a single-item array containing a possibly comma-concatenated string, depending on the way the HTTP library provides access to headers.
http_response_header :: Text -> AttributeKey [Text]
http_response_header = \k -> AttributeKey $ "http.response.header." <> k

-- |
-- [HTTP response status code](https:\/\/tools.ietf.org\/html\/rfc7231#section-6).
http_response_statusCode :: AttributeKey Int64
http_response_statusCode = AttributeKey "http.response.status_code"

-- |
-- The matched route, that is, the path template in the format used by the respective server framework.

-- ==== Note
-- MUST NOT be populated when this is not supported by the HTTP server framework as the route attribute should have low-cardinality and the URI path can NOT substitute it.
-- SHOULD include the [application root](\/docs\/http\/http-spans.md#http-server-definitions) if there is one.
http_route :: AttributeKey Text
http_route = AttributeKey "http.route"

-- $registry_error
-- This document defines the shared attributes used to report an error.
--
-- === Attributes
-- - 'error_type'
--
--     Stability: stable
--

-- |
-- Describes a class of error the operation ended with.

-- ==== Note
-- The @error.type@ SHOULD be predictable and SHOULD have low cardinality.
-- Instrumentations SHOULD document the list of errors they report.
-- 
-- The cardinality of @error.type@ within one instrumentation library SHOULD be low.
-- Telemetry consumers that aggregate data from multiple instrumentation libraries and applications
-- should be prepared for @error.type@ to have high cardinality at query time when no
-- additional filters are applied.
-- 
-- If the operation has completed successfully, instrumentations SHOULD NOT set @error.type@.
-- 
-- If a specific domain defines its own set of error identifiers (such as HTTP or gRPC status codes),
-- it\'s RECOMMENDED to:
-- 
-- * Use a domain-specific attribute
-- * Set @error.type@ to capture all errors, regardless of whether they are defined within the domain-specific set or not.
error_type :: AttributeKey Text
error_type = AttributeKey "error.type"

-- $registry_url
-- Attributes describing URL.
--
-- === Attributes
-- - 'url_domain'
--
-- - 'url_extension'
--
-- - 'url_fragment'
--
--     Stability: stable
--
-- - 'url_full'
--
--     Stability: stable
--
-- - 'url_original'
--
-- - 'url_path'
--
--     Stability: stable
--
-- - 'url_port'
--
-- - 'url_query'
--
--     Stability: stable
--
-- - 'url_registeredDomain'
--
-- - 'url_scheme'
--
--     Stability: stable
--
-- - 'url_subdomain'
--
-- - 'url_topLevelDomain'
--

-- |
-- Domain extracted from the @url.full@, such as "opentelemetry.io".

-- ==== Note
-- In some cases a URL may refer to an IP and\/or port directly, without a domain name. In this case, the IP address would go to the domain field. If the URL contains a [literal IPv6 address](https:\/\/www.rfc-editor.org\/rfc\/rfc2732#section-2) enclosed by @[@ and @]@, the @[@ and @]@ characters should also be captured in the domain field.
url_domain :: AttributeKey Text
url_domain = AttributeKey "url.domain"

-- |
-- The file extension extracted from the @url.full@, excluding the leading dot.

-- ==== Note
-- The file extension is only set if it exists, as not every url has a file extension. When the file name has multiple extensions @example.tar.gz@, only the last one should be captured @gz@, not @tar.gz@.
url_extension :: AttributeKey Text
url_extension = AttributeKey "url.extension"

-- |
-- The [URI fragment](https:\/\/www.rfc-editor.org\/rfc\/rfc3986#section-3.5) component
url_fragment :: AttributeKey Text
url_fragment = AttributeKey "url.fragment"

-- |
-- Absolute URL describing a network resource according to [RFC3986](https:\/\/www.rfc-editor.org\/rfc\/rfc3986)

-- ==== Note
-- For network calls, URL usually has @scheme:\/\/host[:port][path][?query][#fragment]@ format, where the fragment is not transmitted over HTTP, but if it is known, it SHOULD be included nevertheless.
-- @url.full@ MUST NOT contain credentials passed via URL in form of @https:\/\/username:password\@www.example.com\/@. In such case username and password SHOULD be redacted and attribute\'s value SHOULD be @https:\/\/REDACTED:REDACTED\@www.example.com\/@.
-- @url.full@ SHOULD capture the absolute URL when it is available (or can be reconstructed). Sensitive content provided in @url.full@ SHOULD be scrubbed when instrumentations can identify it.
url_full :: AttributeKey Text
url_full = AttributeKey "url.full"

-- |
-- Unmodified original URL as seen in the event source.

-- ==== Note
-- In network monitoring, the observed URL may be a full URL, whereas in access logs, the URL is often just represented as a path. This field is meant to represent the URL as it was observed, complete or not.
-- @url.original@ might contain credentials passed via URL in form of @https:\/\/username:password\@www.example.com\/@. In such case password and username SHOULD NOT be redacted and attribute\'s value SHOULD remain the same.
url_original :: AttributeKey Text
url_original = AttributeKey "url.original"

-- |
-- The [URI path](https:\/\/www.rfc-editor.org\/rfc\/rfc3986#section-3.3) component

-- ==== Note
-- Sensitive content provided in @url.path@ SHOULD be scrubbed when instrumentations can identify it.
url_path :: AttributeKey Text
url_path = AttributeKey "url.path"

-- |
-- Port extracted from the @url.full@
url_port :: AttributeKey Int64
url_port = AttributeKey "url.port"

-- |
-- The [URI query](https:\/\/www.rfc-editor.org\/rfc\/rfc3986#section-3.4) component

-- ==== Note
-- Sensitive content provided in @url.query@ SHOULD be scrubbed when instrumentations can identify it.
url_query :: AttributeKey Text
url_query = AttributeKey "url.query"

-- |
-- The highest registered url domain, stripped of the subdomain.

-- ==== Note
-- This value can be determined precisely with the [public suffix list](http:\/\/publicsuffix.org). For example, the registered domain for @foo.example.com@ is @example.com@. Trying to approximate this by simply taking the last two labels will not work well for TLDs such as @co.uk@.
url_registeredDomain :: AttributeKey Text
url_registeredDomain = AttributeKey "url.registered_domain"

-- |
-- The [URI scheme](https:\/\/www.rfc-editor.org\/rfc\/rfc3986#section-3.1) component identifying the used protocol.
url_scheme :: AttributeKey Text
url_scheme = AttributeKey "url.scheme"

-- |
-- The subdomain portion of a fully qualified domain name includes all of the names except the host name under the registered_domain. In a partially qualified domain, or if the the qualification level of the full name cannot be determined, subdomain contains all of the names below the registered domain.

-- ==== Note
-- The subdomain portion of @www.east.mydomain.co.uk@ is @east@. If the domain has multiple levels of subdomain, such as @sub2.sub1.example.com@, the subdomain field should contain @sub2.sub1@, with no trailing period.
url_subdomain :: AttributeKey Text
url_subdomain = AttributeKey "url.subdomain"

-- |
-- The effective top level domain (eTLD), also known as the domain suffix, is the last part of the domain name. For example, the top level domain for example.com is @com@.

-- ==== Note
-- This value can be determined precisely with the [public suffix list](http:\/\/publicsuffix.org).
url_topLevelDomain :: AttributeKey Text
url_topLevelDomain = AttributeKey "url.top_level_domain"

-- $registry_container
-- A container instance.
--
-- === Attributes
-- - 'container_name'
--
-- - 'container_id'
--
-- - 'container_runtime'
--
-- - 'container_image_name'
--
-- - 'container_image_tags'
--
-- - 'container_image_id'
--
-- - 'container_image_repoDigests'
--
-- - 'container_command'
--
-- - 'container_commandLine'
--
-- - 'container_commandArgs'
--
-- - 'container_label'
--

-- |
-- Container name used by container runtime.
container_name :: AttributeKey Text
container_name = AttributeKey "container.name"

-- |
-- Container ID. Usually a UUID, as for example used to [identify Docker containers](https:\/\/docs.docker.com\/engine\/reference\/run\/#container-identification). The UUID might be abbreviated.
container_id :: AttributeKey Text
container_id = AttributeKey "container.id"

-- |
-- The container runtime managing this container.
container_runtime :: AttributeKey Text
container_runtime = AttributeKey "container.runtime"

-- |
-- Name of the image the container was built on.
container_image_name :: AttributeKey Text
container_image_name = AttributeKey "container.image.name"

-- |
-- Container image tags. An example can be found in [Docker Image Inspect](https:\/\/docs.docker.com\/engine\/api\/v1.43\/#tag\/Image\/operation\/ImageInspect). Should be only the @\<tag\>@ section of the full name for example from @registry.example.com\/my-org\/my-image:\<tag\>@.
container_image_tags :: AttributeKey [Text]
container_image_tags = AttributeKey "container.image.tags"

-- |
-- Runtime specific image identifier. Usually a hash algorithm followed by a UUID.

-- ==== Note
-- Docker defines a sha256 of the image id; @container.image.id@ corresponds to the @Image@ field from the Docker container inspect [API](https:\/\/docs.docker.com\/engine\/api\/v1.43\/#tag\/Container\/operation\/ContainerInspect) endpoint.
-- K8s defines a link to the container registry repository with digest @"imageID": "registry.azurecr.io \/namespace\/service\/dockerfile\@sha256:bdeabd40c3a8a492eaf9e8e44d0ebbb84bac7ee25ac0cf8a7159d25f62555625"@.
-- The ID is assinged by the container runtime and can vary in different environments. Consider using @oci.manifest.digest@ if it is important to identify the same image in different environments\/runtimes.
container_image_id :: AttributeKey Text
container_image_id = AttributeKey "container.image.id"

-- |
-- Repo digests of the container image as provided by the container runtime.

-- ==== Note
-- [Docker](https:\/\/docs.docker.com\/engine\/api\/v1.43\/#tag\/Image\/operation\/ImageInspect) and [CRI](https:\/\/github.com\/kubernetes\/cri-api\/blob\/c75ef5b473bbe2d0a4fc92f82235efd665ea8e9f\/pkg\/apis\/runtime\/v1\/api.proto#L1237-L1238) report those under the @RepoDigests@ field.
container_image_repoDigests :: AttributeKey [Text]
container_image_repoDigests = AttributeKey "container.image.repo_digests"

-- |
-- The command used to run the container (i.e. the command name).

-- ==== Note
-- If using embedded credentials or sensitive data, it is recommended to remove them to prevent potential leakage.
container_command :: AttributeKey Text
container_command = AttributeKey "container.command"

-- |
-- The full command run by the container as a single string representing the full command. [2]
container_commandLine :: AttributeKey Text
container_commandLine = AttributeKey "container.command_line"

-- |
-- All the command arguments (including the command\/executable itself) run by the container. [2]
container_commandArgs :: AttributeKey [Text]
container_commandArgs = AttributeKey "container.command_args"

-- |
-- Container labels, @\<key\>@ being the label name, the value being the label value.
container_label :: Text -> AttributeKey Text
container_label = \k -> AttributeKey $ "container.label." <> k

-- $registry_tls
-- This document defines semantic convention attributes in the TLS namespace.
--
-- === Attributes
-- - 'tls_cipher'
--
-- - 'tls_client_certificate'
--
-- - 'tls_client_certificateChain'
--
-- - 'tls_client_hash_md5'
--
-- - 'tls_client_hash_sha1'
--
-- - 'tls_client_hash_sha256'
--
-- - 'tls_client_issuer'
--
-- - 'tls_client_ja3'
--
-- - 'tls_client_notAfter'
--
-- - 'tls_client_notBefore'
--
-- - 'tls_client_serverName'
--
-- - 'tls_client_subject'
--
-- - 'tls_client_supportedCiphers'
--
-- - 'tls_curve'
--
-- - 'tls_established'
--
-- - 'tls_nextProtocol'
--
-- - 'tls_protocol_name'
--
-- - 'tls_protocol_version'
--
-- - 'tls_resumed'
--
-- - 'tls_server_certificate'
--
-- - 'tls_server_certificateChain'
--
-- - 'tls_server_hash_md5'
--
-- - 'tls_server_hash_sha1'
--
-- - 'tls_server_hash_sha256'
--
-- - 'tls_server_issuer'
--
-- - 'tls_server_ja3s'
--
-- - 'tls_server_notAfter'
--
-- - 'tls_server_notBefore'
--
-- - 'tls_server_subject'
--

-- |
-- String indicating the [cipher](https:\/\/datatracker.ietf.org\/doc\/html\/rfc5246#appendix-A.5) used during the current connection.

-- ==== Note
-- The values allowed for @tls.cipher@ MUST be one of the @Descriptions@ of the [registered TLS Cipher Suits](https:\/\/www.iana.org\/assignments\/tls-parameters\/tls-parameters.xhtml#table-tls-parameters-4).
tls_cipher :: AttributeKey Text
tls_cipher = AttributeKey "tls.cipher"

-- |
-- PEM-encoded stand-alone certificate offered by the client. This is usually mutually-exclusive of @client.certificate_chain@ since this value also exists in that list.
tls_client_certificate :: AttributeKey Text
tls_client_certificate = AttributeKey "tls.client.certificate"

-- |
-- Array of PEM-encoded certificates that make up the certificate chain offered by the client. This is usually mutually-exclusive of @client.certificate@ since that value should be the first certificate in the chain.
tls_client_certificateChain :: AttributeKey [Text]
tls_client_certificateChain = AttributeKey "tls.client.certificate_chain"

-- |
-- Certificate fingerprint using the MD5 digest of DER-encoded version of certificate offered by the client. For consistency with other hash values, this value should be formatted as an uppercase hash.
tls_client_hash_md5 :: AttributeKey Text
tls_client_hash_md5 = AttributeKey "tls.client.hash.md5"

-- |
-- Certificate fingerprint using the SHA1 digest of DER-encoded version of certificate offered by the client. For consistency with other hash values, this value should be formatted as an uppercase hash.
tls_client_hash_sha1 :: AttributeKey Text
tls_client_hash_sha1 = AttributeKey "tls.client.hash.sha1"

-- |
-- Certificate fingerprint using the SHA256 digest of DER-encoded version of certificate offered by the client. For consistency with other hash values, this value should be formatted as an uppercase hash.
tls_client_hash_sha256 :: AttributeKey Text
tls_client_hash_sha256 = AttributeKey "tls.client.hash.sha256"

-- |
-- Distinguished name of [subject](https:\/\/datatracker.ietf.org\/doc\/html\/rfc5280#section-4.1.2.6) of the issuer of the x.509 certificate presented by the client.
tls_client_issuer :: AttributeKey Text
tls_client_issuer = AttributeKey "tls.client.issuer"

-- |
-- A hash that identifies clients based on how they perform an SSL\/TLS handshake.
tls_client_ja3 :: AttributeKey Text
tls_client_ja3 = AttributeKey "tls.client.ja3"

-- |
-- Date\/Time indicating when client certificate is no longer considered valid.
tls_client_notAfter :: AttributeKey Text
tls_client_notAfter = AttributeKey "tls.client.not_after"

-- |
-- Date\/Time indicating when client certificate is first considered valid.
tls_client_notBefore :: AttributeKey Text
tls_client_notBefore = AttributeKey "tls.client.not_before"

-- |
-- Also called an SNI, this tells the server which hostname to which the client is attempting to connect to.
tls_client_serverName :: AttributeKey Text
tls_client_serverName = AttributeKey "tls.client.server_name"

-- |
-- Distinguished name of subject of the x.509 certificate presented by the client.
tls_client_subject :: AttributeKey Text
tls_client_subject = AttributeKey "tls.client.subject"

-- |
-- Array of ciphers offered by the client during the client hello.
tls_client_supportedCiphers :: AttributeKey [Text]
tls_client_supportedCiphers = AttributeKey "tls.client.supported_ciphers"

-- |
-- String indicating the curve used for the given cipher, when applicable
tls_curve :: AttributeKey Text
tls_curve = AttributeKey "tls.curve"

-- |
-- Boolean flag indicating if the TLS negotiation was successful and transitioned to an encrypted tunnel.
tls_established :: AttributeKey Bool
tls_established = AttributeKey "tls.established"

-- |
-- String indicating the protocol being tunneled. Per the values in the [IANA registry](https:\/\/www.iana.org\/assignments\/tls-extensiontype-values\/tls-extensiontype-values.xhtml#alpn-protocol-ids), this string should be lower case.
tls_nextProtocol :: AttributeKey Text
tls_nextProtocol = AttributeKey "tls.next_protocol"

-- |
-- Normalized lowercase protocol name parsed from original string of the negotiated [SSL\/TLS protocol version](https:\/\/www.openssl.org\/docs\/man1.1.1\/man3\/SSL_get_version.html#RETURN-VALUES)
tls_protocol_name :: AttributeKey Text
tls_protocol_name = AttributeKey "tls.protocol.name"

-- |
-- Numeric part of the version parsed from the original string of the negotiated [SSL\/TLS protocol version](https:\/\/www.openssl.org\/docs\/man1.1.1\/man3\/SSL_get_version.html#RETURN-VALUES)
tls_protocol_version :: AttributeKey Text
tls_protocol_version = AttributeKey "tls.protocol.version"

-- |
-- Boolean flag indicating if this TLS connection was resumed from an existing TLS negotiation.
tls_resumed :: AttributeKey Bool
tls_resumed = AttributeKey "tls.resumed"

-- |
-- PEM-encoded stand-alone certificate offered by the server. This is usually mutually-exclusive of @server.certificate_chain@ since this value also exists in that list.
tls_server_certificate :: AttributeKey Text
tls_server_certificate = AttributeKey "tls.server.certificate"

-- |
-- Array of PEM-encoded certificates that make up the certificate chain offered by the server. This is usually mutually-exclusive of @server.certificate@ since that value should be the first certificate in the chain.
tls_server_certificateChain :: AttributeKey [Text]
tls_server_certificateChain = AttributeKey "tls.server.certificate_chain"

-- |
-- Certificate fingerprint using the MD5 digest of DER-encoded version of certificate offered by the server. For consistency with other hash values, this value should be formatted as an uppercase hash.
tls_server_hash_md5 :: AttributeKey Text
tls_server_hash_md5 = AttributeKey "tls.server.hash.md5"

-- |
-- Certificate fingerprint using the SHA1 digest of DER-encoded version of certificate offered by the server. For consistency with other hash values, this value should be formatted as an uppercase hash.
tls_server_hash_sha1 :: AttributeKey Text
tls_server_hash_sha1 = AttributeKey "tls.server.hash.sha1"

-- |
-- Certificate fingerprint using the SHA256 digest of DER-encoded version of certificate offered by the server. For consistency with other hash values, this value should be formatted as an uppercase hash.
tls_server_hash_sha256 :: AttributeKey Text
tls_server_hash_sha256 = AttributeKey "tls.server.hash.sha256"

-- |
-- Distinguished name of [subject](https:\/\/datatracker.ietf.org\/doc\/html\/rfc5280#section-4.1.2.6) of the issuer of the x.509 certificate presented by the client.
tls_server_issuer :: AttributeKey Text
tls_server_issuer = AttributeKey "tls.server.issuer"

-- |
-- A hash that identifies servers based on how they perform an SSL\/TLS handshake.
tls_server_ja3s :: AttributeKey Text
tls_server_ja3s = AttributeKey "tls.server.ja3s"

-- |
-- Date\/Time indicating when server certificate is no longer considered valid.
tls_server_notAfter :: AttributeKey Text
tls_server_notAfter = AttributeKey "tls.server.not_after"

-- |
-- Date\/Time indicating when server certificate is first considered valid.
tls_server_notBefore :: AttributeKey Text
tls_server_notBefore = AttributeKey "tls.server.not_before"

-- |
-- Distinguished name of subject of the x.509 certificate presented by the server.
tls_server_subject :: AttributeKey Text
tls_server_subject = AttributeKey "tls.server.subject"

-- $registry_messaging
-- Attributes describing telemetry around messaging systems and messaging activities.
--
-- === Attributes
-- - 'messaging_batch_messageCount'
--
-- - 'messaging_clientId'
--
-- - 'messaging_destination_name'
--
-- - 'messaging_destination_template'
--
-- - 'messaging_destination_anonymous'
--
-- - 'messaging_destination_temporary'
--
-- - 'messaging_destinationPublish_anonymous'
--
-- - 'messaging_destinationPublish_name'
--
-- - 'messaging_kafka_consumer_group'
--
-- - 'messaging_kafka_destination_partition'
--
-- - 'messaging_kafka_message_key'
--
-- - 'messaging_kafka_message_offset'
--
-- - 'messaging_kafka_message_tombstone'
--
-- - 'messaging_message_conversationId'
--
-- - 'messaging_message_envelope_size'
--
-- - 'messaging_message_id'
--
-- - 'messaging_message_body_size'
--
-- - 'messaging_operation'
--
-- - 'messaging_rabbitmq_destination_routingKey'
--
-- - 'messaging_rabbitmq_message_deliveryTag'
--
-- - 'messaging_rocketmq_clientGroup'
--
-- - 'messaging_rocketmq_consumptionModel'
--
-- - 'messaging_rocketmq_message_delayTimeLevel'
--
-- - 'messaging_rocketmq_message_deliveryTimestamp'
--
-- - 'messaging_rocketmq_message_group'
--
-- - 'messaging_rocketmq_message_keys'
--
-- - 'messaging_rocketmq_message_tag'
--
-- - 'messaging_rocketmq_message_type'
--
-- - 'messaging_rocketmq_namespace'
--
-- - 'messaging_gcpPubsub_message_orderingKey'
--
-- - 'messaging_system'
--
-- - 'messaging_servicebus_message_deliveryCount'
--
-- - 'messaging_servicebus_message_enqueuedTime'
--
-- - 'messaging_servicebus_destination_subscriptionName'
--
-- - 'messaging_servicebus_dispositionStatus'
--
--     Stability: experimental
--
-- - 'messaging_eventhubs_message_enqueuedTime'
--
-- - 'messaging_eventhubs_destination_partition_id'
--
-- - 'messaging_eventhubs_consumer_group'
--

-- |
-- The number of messages sent, received, or processed in the scope of the batching operation.

-- ==== Note
-- Instrumentations SHOULD NOT set @messaging.batch.message_count@ on spans that operate with a single message. When a messaging client library supports both batch and single-message API for the same operation, instrumentations SHOULD use @messaging.batch.message_count@ for batching APIs and SHOULD NOT use it for single-message APIs.
messaging_batch_messageCount :: AttributeKey Int64
messaging_batch_messageCount = AttributeKey "messaging.batch.message_count"

-- |
-- A unique identifier for the client that consumes or produces a message.
messaging_clientId :: AttributeKey Text
messaging_clientId = AttributeKey "messaging.client_id"

-- |
-- The message destination name

-- ==== Note
-- Destination name SHOULD uniquely identify a specific queue, topic or other entity within the broker. If
-- the broker doesn\'t have such notion, the destination name SHOULD uniquely identify the broker.
messaging_destination_name :: AttributeKey Text
messaging_destination_name = AttributeKey "messaging.destination.name"

-- |
-- Low cardinality representation of the messaging destination name

-- ==== Note
-- Destination names could be constructed from templates. An example would be a destination name involving a user name or product id. Although the destination name in this case is of high cardinality, the underlying template is of low cardinality and can be effectively used for grouping and aggregation.
messaging_destination_template :: AttributeKey Text
messaging_destination_template = AttributeKey "messaging.destination.template"

-- |
-- A boolean that is true if the message destination is anonymous (could be unnamed or have auto-generated name).
messaging_destination_anonymous :: AttributeKey Bool
messaging_destination_anonymous = AttributeKey "messaging.destination.anonymous"

-- |
-- A boolean that is true if the message destination is temporary and might not exist anymore after messages are processed.
messaging_destination_temporary :: AttributeKey Bool
messaging_destination_temporary = AttributeKey "messaging.destination.temporary"

-- |
-- A boolean that is true if the publish message destination is anonymous (could be unnamed or have auto-generated name).
messaging_destinationPublish_anonymous :: AttributeKey Bool
messaging_destinationPublish_anonymous = AttributeKey "messaging.destination_publish.anonymous"

-- |
-- The name of the original destination the message was published to

-- ==== Note
-- The name SHOULD uniquely identify a specific queue, topic, or other entity within the broker. If
-- the broker doesn\'t have such notion, the original destination name SHOULD uniquely identify the broker.
messaging_destinationPublish_name :: AttributeKey Text
messaging_destinationPublish_name = AttributeKey "messaging.destination_publish.name"

-- |
-- Name of the Kafka Consumer Group that is handling the message. Only applies to consumers, not producers.
messaging_kafka_consumer_group :: AttributeKey Text
messaging_kafka_consumer_group = AttributeKey "messaging.kafka.consumer.group"

-- |
-- Partition the message is sent to.
messaging_kafka_destination_partition :: AttributeKey Int64
messaging_kafka_destination_partition = AttributeKey "messaging.kafka.destination.partition"

-- |
-- Message keys in Kafka are used for grouping alike messages to ensure they\'re processed on the same partition. They differ from @messaging.message.id@ in that they\'re not unique. If the key is @null@, the attribute MUST NOT be set.

-- ==== Note
-- If the key type is not string, it\'s string representation has to be supplied for the attribute. If the key has no unambiguous, canonical string form, don\'t include its value.
messaging_kafka_message_key :: AttributeKey Text
messaging_kafka_message_key = AttributeKey "messaging.kafka.message.key"

-- |
-- The offset of a record in the corresponding Kafka partition.
messaging_kafka_message_offset :: AttributeKey Int64
messaging_kafka_message_offset = AttributeKey "messaging.kafka.message.offset"

-- |
-- A boolean that is true if the message is a tombstone.
messaging_kafka_message_tombstone :: AttributeKey Bool
messaging_kafka_message_tombstone = AttributeKey "messaging.kafka.message.tombstone"

-- |
-- The conversation ID identifying the conversation to which the message belongs, represented as a string. Sometimes called "Correlation ID".
messaging_message_conversationId :: AttributeKey Text
messaging_message_conversationId = AttributeKey "messaging.message.conversation_id"

-- |
-- The size of the message body and metadata in bytes.

-- ==== Note
-- This can refer to both the compressed or uncompressed size. If both sizes are known, the uncompressed
-- size should be used.
messaging_message_envelope_size :: AttributeKey Int64
messaging_message_envelope_size = AttributeKey "messaging.message.envelope.size"

-- |
-- A value used by the messaging system as an identifier for the message, represented as a string.
messaging_message_id :: AttributeKey Text
messaging_message_id = AttributeKey "messaging.message.id"

-- |
-- The size of the message body in bytes.

-- ==== Note
-- This can refer to both the compressed or uncompressed body size. If both sizes are known, the uncompressed
-- body size should be used.
messaging_message_body_size :: AttributeKey Int64
messaging_message_body_size = AttributeKey "messaging.message.body.size"

-- |
-- A string identifying the kind of messaging operation.

-- ==== Note
-- If a custom value is used, it MUST be of low cardinality.
messaging_operation :: AttributeKey Text
messaging_operation = AttributeKey "messaging.operation"

-- |
-- RabbitMQ message routing key.
messaging_rabbitmq_destination_routingKey :: AttributeKey Text
messaging_rabbitmq_destination_routingKey = AttributeKey "messaging.rabbitmq.destination.routing_key"

-- |
-- RabbitMQ message delivery tag
messaging_rabbitmq_message_deliveryTag :: AttributeKey Int64
messaging_rabbitmq_message_deliveryTag = AttributeKey "messaging.rabbitmq.message.delivery_tag"

-- |
-- Name of the RocketMQ producer\/consumer group that is handling the message. The client type is identified by the SpanKind.
messaging_rocketmq_clientGroup :: AttributeKey Text
messaging_rocketmq_clientGroup = AttributeKey "messaging.rocketmq.client_group"

-- |
-- Model of message consumption. This only applies to consumer spans.
messaging_rocketmq_consumptionModel :: AttributeKey Text
messaging_rocketmq_consumptionModel = AttributeKey "messaging.rocketmq.consumption_model"

-- |
-- The delay time level for delay message, which determines the message delay time.
messaging_rocketmq_message_delayTimeLevel :: AttributeKey Int64
messaging_rocketmq_message_delayTimeLevel = AttributeKey "messaging.rocketmq.message.delay_time_level"

-- |
-- The timestamp in milliseconds that the delay message is expected to be delivered to consumer.
messaging_rocketmq_message_deliveryTimestamp :: AttributeKey Int64
messaging_rocketmq_message_deliveryTimestamp = AttributeKey "messaging.rocketmq.message.delivery_timestamp"

-- |
-- It is essential for FIFO message. Messages that belong to the same message group are always processed one by one within the same consumer group.
messaging_rocketmq_message_group :: AttributeKey Text
messaging_rocketmq_message_group = AttributeKey "messaging.rocketmq.message.group"

-- |
-- Key(s) of message, another way to mark message besides message id.
messaging_rocketmq_message_keys :: AttributeKey [Text]
messaging_rocketmq_message_keys = AttributeKey "messaging.rocketmq.message.keys"

-- |
-- The secondary classifier of message besides topic.
messaging_rocketmq_message_tag :: AttributeKey Text
messaging_rocketmq_message_tag = AttributeKey "messaging.rocketmq.message.tag"

-- |
-- Type of message.
messaging_rocketmq_message_type :: AttributeKey Text
messaging_rocketmq_message_type = AttributeKey "messaging.rocketmq.message.type"

-- |
-- Namespace of RocketMQ resources, resources in different namespaces are individual.
messaging_rocketmq_namespace :: AttributeKey Text
messaging_rocketmq_namespace = AttributeKey "messaging.rocketmq.namespace"

-- |
-- The ordering key for a given message. If the attribute is not present, the message does not have an ordering key.
messaging_gcpPubsub_message_orderingKey :: AttributeKey Text
messaging_gcpPubsub_message_orderingKey = AttributeKey "messaging.gcp_pubsub.message.ordering_key"

-- |
-- An identifier for the messaging system being used. See below for a list of well-known identifiers.
messaging_system :: AttributeKey Text
messaging_system = AttributeKey "messaging.system"

-- |
-- Number of deliveries that have been attempted for this message.
messaging_servicebus_message_deliveryCount :: AttributeKey Int64
messaging_servicebus_message_deliveryCount = AttributeKey "messaging.servicebus.message.delivery_count"

-- |
-- The UTC epoch seconds at which the message has been accepted and stored in the entity.
messaging_servicebus_message_enqueuedTime :: AttributeKey Int64
messaging_servicebus_message_enqueuedTime = AttributeKey "messaging.servicebus.message.enqueued_time"

-- |
-- The name of the subscription in the topic messages are received from.
messaging_servicebus_destination_subscriptionName :: AttributeKey Text
messaging_servicebus_destination_subscriptionName = AttributeKey "messaging.servicebus.destination.subscription_name"

-- |
-- Describes the [settlement type](https:\/\/learn.microsoft.com\/azure\/service-bus-messaging\/message-transfers-locks-settlement#peeklock).
messaging_servicebus_dispositionStatus :: AttributeKey Text
messaging_servicebus_dispositionStatus = AttributeKey "messaging.servicebus.disposition_status"

-- |
-- The UTC epoch seconds at which the message has been accepted and stored in the entity.
messaging_eventhubs_message_enqueuedTime :: AttributeKey Int64
messaging_eventhubs_message_enqueuedTime = AttributeKey "messaging.eventhubs.message.enqueued_time"

-- |
-- The identifier of the partition messages are sent to or received from, unique to the Event Hub which contains it.
messaging_eventhubs_destination_partition_id :: AttributeKey Text
messaging_eventhubs_destination_partition_id = AttributeKey "messaging.eventhubs.destination.partition.id"

-- |
-- The name of the consumer group the event consumer is associated with.
messaging_eventhubs_consumer_group :: AttributeKey Text
messaging_eventhubs_consumer_group = AttributeKey "messaging.eventhubs.consumer.group"

-- $registry_cloud
-- A cloud environment (e.g. GCP, Azure, AWS).
--
-- === Attributes
-- - 'cloud_provider'
--
-- - 'cloud_account_id'
--
-- - 'cloud_region'
--
-- - 'cloud_resourceId'
--
-- - 'cloud_availabilityZone'
--
-- - 'cloud_platform'
--

-- |
-- Name of the cloud provider.
cloud_provider :: AttributeKey Text
cloud_provider = AttributeKey "cloud.provider"

-- |
-- The cloud account ID the resource is assigned to.
cloud_account_id :: AttributeKey Text
cloud_account_id = AttributeKey "cloud.account.id"

-- |
-- The geographical region the resource is running.

-- ==== Note
-- Refer to your provider\'s docs to see the available regions, for example [Alibaba Cloud regions](https:\/\/www.alibabacloud.com\/help\/doc-detail\/40654.htm), [AWS regions](https:\/\/aws.amazon.com\/about-aws\/global-infrastructure\/regions_az\/), [Azure regions](https:\/\/azure.microsoft.com\/global-infrastructure\/geographies\/), [Google Cloud regions](https:\/\/cloud.google.com\/about\/locations), or [Tencent Cloud regions](https:\/\/www.tencentcloud.com\/document\/product\/213\/6091).
cloud_region :: AttributeKey Text
cloud_region = AttributeKey "cloud.region"

-- |
-- Cloud provider-specific native identifier of the monitored cloud resource (e.g. an [ARN](https:\/\/docs.aws.amazon.com\/general\/latest\/gr\/aws-arns-and-namespaces.html) on AWS, a [fully qualified resource ID](https:\/\/learn.microsoft.com\/rest\/api\/resources\/resources\/get-by-id) on Azure, a [full resource name](https:\/\/cloud.google.com\/apis\/design\/resource_names#full_resource_name) on GCP)

-- ==== Note
-- On some cloud providers, it may not be possible to determine the full ID at startup,
-- so it may be necessary to set @cloud.resource_id@ as a span attribute instead.
-- 
-- The exact value to use for @cloud.resource_id@ depends on the cloud provider.
-- The following well-known definitions MUST be used if you set this attribute and they apply:
-- 
-- * __AWS Lambda:__ The function [ARN](https:\/\/docs.aws.amazon.com\/general\/latest\/gr\/aws-arns-and-namespaces.html).
--   Take care not to use the "invoked ARN" directly but replace any
--   [alias suffix](https:\/\/docs.aws.amazon.com\/lambda\/latest\/dg\/configuration-aliases.html)
--   with the resolved function version, as the same runtime instance may be invokable with
--   multiple different aliases.
-- * __GCP:__ The [URI of the resource](https:\/\/cloud.google.com\/iam\/docs\/full-resource-names)
-- * __Azure:__ The [Fully Qualified Resource ID](https:\/\/docs.microsoft.com\/rest\/api\/resources\/resources\/get-by-id) of the invoked function,
--   *not* the function app, having the form
--   @\/subscriptions\/\<SUBSCIPTION_GUID\>\/resourceGroups\/\<RG\>\/providers\/Microsoft.Web\/sites\/\<FUNCAPP\>\/functions\/\<FUNC\>@.
--   This means that a span attribute MUST be used, as an Azure function app can host multiple functions that would usually share
--   a TracerProvider.
cloud_resourceId :: AttributeKey Text
cloud_resourceId = AttributeKey "cloud.resource_id"

-- |
-- Cloud regions often have multiple, isolated locations known as zones to increase availability. Availability zone represents the zone where the resource is running.

-- ==== Note
-- Availability zones are called "zones" on Alibaba Cloud and Google Cloud.
cloud_availabilityZone :: AttributeKey Text
cloud_availabilityZone = AttributeKey "cloud.availability_zone"

-- |
-- The cloud platform in use.

-- ==== Note
-- The prefix of the service SHOULD match the one specified in @cloud.provider@.
cloud_platform :: AttributeKey Text
cloud_platform = AttributeKey "cloud.platform"

-- $registry_db
-- This document defines the attributes used to describe telemetry in the context of databases.
--
-- === Attributes
-- - 'db_cassandra_coordinator_dc'
--
-- - 'db_cassandra_coordinator_id'
--
-- - 'db_cassandra_consistencyLevel'
--
-- - 'db_cassandra_idempotence'
--
-- - 'db_cassandra_pageSize'
--
-- - 'db_cassandra_speculativeExecutionCount'
--
-- - 'db_cassandra_table'
--
-- - 'db_connectionString'
--
-- - 'db_cosmosdb_clientId'
--
-- - 'db_cosmosdb_connectionMode'
--
-- - 'db_cosmosdb_container'
--
-- - 'db_cosmosdb_operationType'
--
-- - 'db_cosmosdb_requestCharge'
--
-- - 'db_cosmosdb_requestContentLength'
--
-- - 'db_cosmosdb_statusCode'
--
-- - 'db_cosmosdb_subStatusCode'
--
-- - 'db_elasticsearch_cluster_name'
--
-- - 'db_elasticsearch_node_name'
--
-- - 'db_elasticsearch_pathParts'
--
-- - 'db_jdbc_driverClassname'
--
-- - 'db_mongodb_collection'
--
-- - 'db_mssql_instanceName'
--
-- - 'db_name'
--
-- - 'db_operation'
--
-- - 'db_redis_databaseIndex'
--
-- - 'db_sql_table'
--
-- - 'db_statement'
--
-- - 'db_system'
--
-- - 'db_user'
--
-- - 'db_instance_id'
--

-- |
-- The data center of the coordinating node for a query.
db_cassandra_coordinator_dc :: AttributeKey Text
db_cassandra_coordinator_dc = AttributeKey "db.cassandra.coordinator.dc"

-- |
-- The ID of the coordinating node for a query.
db_cassandra_coordinator_id :: AttributeKey Text
db_cassandra_coordinator_id = AttributeKey "db.cassandra.coordinator.id"

-- |
-- The consistency level of the query. Based on consistency values from [CQL](https:\/\/docs.datastax.com\/en\/cassandra-oss\/3.0\/cassandra\/dml\/dmlConfigConsistency.html).
db_cassandra_consistencyLevel :: AttributeKey Text
db_cassandra_consistencyLevel = AttributeKey "db.cassandra.consistency_level"

-- |
-- Whether or not the query is idempotent.
db_cassandra_idempotence :: AttributeKey Bool
db_cassandra_idempotence = AttributeKey "db.cassandra.idempotence"

-- |
-- The fetch size used for paging, i.e. how many rows will be returned at once.
db_cassandra_pageSize :: AttributeKey Int64
db_cassandra_pageSize = AttributeKey "db.cassandra.page_size"

-- |
-- The number of times a query was speculatively executed. Not set or @0@ if the query was not executed speculatively.
db_cassandra_speculativeExecutionCount :: AttributeKey Int64
db_cassandra_speculativeExecutionCount = AttributeKey "db.cassandra.speculative_execution_count"

-- |
-- The name of the primary Cassandra table that the operation is acting upon, including the keyspace name (if applicable).

-- ==== Note
-- This mirrors the db.sql.table attribute but references cassandra rather than sql. It is not recommended to attempt any client-side parsing of @db.statement@ just to get this property, but it should be set if it is provided by the library being instrumented. If the operation is acting upon an anonymous table, or more than one table, this value MUST NOT be set.
db_cassandra_table :: AttributeKey Text
db_cassandra_table = AttributeKey "db.cassandra.table"

-- |
-- The connection string used to connect to the database. It is recommended to remove embedded credentials.
db_connectionString :: AttributeKey Text
db_connectionString = AttributeKey "db.connection_string"

-- |
-- Unique Cosmos client instance id.
db_cosmosdb_clientId :: AttributeKey Text
db_cosmosdb_clientId = AttributeKey "db.cosmosdb.client_id"

-- |
-- Cosmos client connection mode.
db_cosmosdb_connectionMode :: AttributeKey Text
db_cosmosdb_connectionMode = AttributeKey "db.cosmosdb.connection_mode"

-- |
-- Cosmos DB container name.
db_cosmosdb_container :: AttributeKey Text
db_cosmosdb_container = AttributeKey "db.cosmosdb.container"

-- |
-- CosmosDB Operation Type.
db_cosmosdb_operationType :: AttributeKey Text
db_cosmosdb_operationType = AttributeKey "db.cosmosdb.operation_type"

-- |
-- RU consumed for that operation
db_cosmosdb_requestCharge :: AttributeKey Double
db_cosmosdb_requestCharge = AttributeKey "db.cosmosdb.request_charge"

-- |
-- Request payload size in bytes
db_cosmosdb_requestContentLength :: AttributeKey Int64
db_cosmosdb_requestContentLength = AttributeKey "db.cosmosdb.request_content_length"

-- |
-- Cosmos DB status code.
db_cosmosdb_statusCode :: AttributeKey Int64
db_cosmosdb_statusCode = AttributeKey "db.cosmosdb.status_code"

-- |
-- Cosmos DB sub status code.
db_cosmosdb_subStatusCode :: AttributeKey Int64
db_cosmosdb_subStatusCode = AttributeKey "db.cosmosdb.sub_status_code"

-- |
-- Represents the identifier of an Elasticsearch cluster.
db_elasticsearch_cluster_name :: AttributeKey Text
db_elasticsearch_cluster_name = AttributeKey "db.elasticsearch.cluster.name"

-- |
-- Represents the human-readable identifier of the node\/instance to which a request was routed.
db_elasticsearch_node_name :: AttributeKey Text
db_elasticsearch_node_name = AttributeKey "db.elasticsearch.node.name"

-- |
-- A dynamic value in the url path.

-- ==== Note
-- Many Elasticsearch url paths allow dynamic values. These SHOULD be recorded in span attributes in the format @db.elasticsearch.path_parts.\<key\>@, where @\<key\>@ is the url path part name. The implementation SHOULD reference the [elasticsearch schema](https:\/\/raw.githubusercontent.com\/elastic\/elasticsearch-specification\/main\/output\/schema\/schema.json) in order to map the path part values to their names.
db_elasticsearch_pathParts :: Text -> AttributeKey Text
db_elasticsearch_pathParts = \k -> AttributeKey $ "db.elasticsearch.path_parts." <> k

-- |
-- The fully-qualified class name of the [Java Database Connectivity (JDBC)](https:\/\/docs.oracle.com\/javase\/8\/docs\/technotes\/guides\/jdbc\/) driver used to connect.
db_jdbc_driverClassname :: AttributeKey Text
db_jdbc_driverClassname = AttributeKey "db.jdbc.driver_classname"

-- |
-- The MongoDB collection being accessed within the database stated in @db.name@.
db_mongodb_collection :: AttributeKey Text
db_mongodb_collection = AttributeKey "db.mongodb.collection"

-- |
-- The Microsoft SQL Server [instance name](https:\/\/docs.microsoft.com\/sql\/connect\/jdbc\/building-the-connection-url?view=sql-server-ver15) connecting to. This name is used to determine the port of a named instance.

-- ==== Note
-- If setting a @db.mssql.instance_name@, @server.port@ is no longer required (but still recommended if non-standard).
db_mssql_instanceName :: AttributeKey Text
db_mssql_instanceName = AttributeKey "db.mssql.instance_name"

-- |
-- This attribute is used to report the name of the database being accessed. For commands that switch the database, this should be set to the target database (even if the command fails).

-- ==== Note
-- In some SQL databases, the database name to be used is called "schema name". In case there are multiple layers that could be considered for database name (e.g. Oracle instance name and schema name), the database name to be used is the more specific layer (e.g. Oracle schema name).
db_name :: AttributeKey Text
db_name = AttributeKey "db.name"

-- |
-- The name of the operation being executed, e.g. the [MongoDB command name](https:\/\/docs.mongodb.com\/manual\/reference\/command\/#database-operations) such as @findAndModify@, or the SQL keyword.

-- ==== Note
-- When setting this to an SQL keyword, it is not recommended to attempt any client-side parsing of @db.statement@ just to get this property, but it should be set if the operation name is provided by the library being instrumented. If the SQL statement has an ambiguous operation, or performs more than one operation, this value may be omitted.
db_operation :: AttributeKey Text
db_operation = AttributeKey "db.operation"

-- |
-- The index of the database being accessed as used in the [@SELECT@ command](https:\/\/redis.io\/commands\/select), provided as an integer. To be used instead of the generic @db.name@ attribute.
db_redis_databaseIndex :: AttributeKey Int64
db_redis_databaseIndex = AttributeKey "db.redis.database_index"

-- |
-- The name of the primary table that the operation is acting upon, including the database name (if applicable).

-- ==== Note
-- It is not recommended to attempt any client-side parsing of @db.statement@ just to get this property, but it should be set if it is provided by the library being instrumented. If the operation is acting upon an anonymous table, or more than one table, this value MUST NOT be set.
db_sql_table :: AttributeKey Text
db_sql_table = AttributeKey "db.sql.table"

-- |
-- The database statement being executed.
db_statement :: AttributeKey Text
db_statement = AttributeKey "db.statement"

-- |
-- An identifier for the database management system (DBMS) product being used. See below for a list of well-known identifiers.
db_system :: AttributeKey Text
db_system = AttributeKey "db.system"

-- |
-- Username for accessing the database.
db_user :: AttributeKey Text
db_user = AttributeKey "db.user"

-- |
-- An identifier (address, unique name, or any other identifier) of the database instance that is executing queries or mutations on the current connection. This is useful in cases where the database is running in a clustered environment and the instrumentation is able to record the node executing the query. The client may obtain this value in databases like MySQL using queries like @select \@\@hostname@.
db_instance_id :: AttributeKey Text
db_instance_id = AttributeKey "db.instance.id"

-- $registry_code
-- These attributes allow to report this unit of code and therefore to provide more context about the span.
--
-- === Attributes
-- - 'code_function'
--
-- - 'code_namespace'
--
-- - 'code_filepath'
--
-- - 'code_lineno'
--
-- - 'code_column'
--
-- - 'code_stacktrace'
--

-- |
-- The method or function name, or equivalent (usually rightmost part of the code unit\'s name).
code_function :: AttributeKey Text
code_function = AttributeKey "code.function"

-- |
-- The "namespace" within which @code.function@ is defined. Usually the qualified class or module name, such that @code.namespace@ + some separator + @code.function@ form a unique identifier for the code unit.
code_namespace :: AttributeKey Text
code_namespace = AttributeKey "code.namespace"

-- |
-- The source code file name that identifies the code unit as uniquely as possible (preferably an absolute file path).
code_filepath :: AttributeKey Text
code_filepath = AttributeKey "code.filepath"

-- |
-- The line number in @code.filepath@ best representing the operation. It SHOULD point within the code unit named in @code.function@.
code_lineno :: AttributeKey Int64
code_lineno = AttributeKey "code.lineno"

-- |
-- The column number in @code.filepath@ best representing the operation. It SHOULD point within the code unit named in @code.function@.
code_column :: AttributeKey Int64
code_column = AttributeKey "code.column"

-- |
-- A stacktrace as a string in the natural representation for the language runtime. The representation is to be determined and documented by each language SIG.
code_stacktrace :: AttributeKey Text
code_stacktrace = AttributeKey "code.stacktrace"

-- $registry_host
-- A host is defined as a computing instance. For example, physical servers, virtual machines, switches or disk array.
--
-- === Attributes
-- - 'host_id'
--
-- - 'host_name'
--
-- - 'host_type'
--
-- - 'host_arch'
--
-- - 'host_image_name'
--
-- - 'host_image_id'
--
-- - 'host_image_version'
--
-- - 'host_ip'
--
-- - 'host_mac'
--
-- - 'host_cpu_vendor_id'
--
-- - 'host_cpu_family'
--
-- - 'host_cpu_model_id'
--
-- - 'host_cpu_model_name'
--
-- - 'host_cpu_stepping'
--
-- - 'host_cpu_cache_l2_size'
--

-- |
-- Unique host ID. For Cloud, this must be the instance_id assigned by the cloud provider. For non-containerized systems, this should be the @machine-id@. See the table below for the sources to use to determine the @machine-id@ based on operating system.
host_id :: AttributeKey Text
host_id = AttributeKey "host.id"

-- |
-- Name of the host. On Unix systems, it may contain what the hostname command returns, or the fully qualified hostname, or another name specified by the user.
host_name :: AttributeKey Text
host_name = AttributeKey "host.name"

-- |
-- Type of host. For Cloud, this must be the machine type.
host_type :: AttributeKey Text
host_type = AttributeKey "host.type"

-- |
-- The CPU architecture the host system is running on.
host_arch :: AttributeKey Text
host_arch = AttributeKey "host.arch"

-- |
-- Name of the VM image or OS install the host was instantiated from.
host_image_name :: AttributeKey Text
host_image_name = AttributeKey "host.image.name"

-- |
-- VM image ID or host OS image ID. For Cloud, this value is from the provider.
host_image_id :: AttributeKey Text
host_image_id = AttributeKey "host.image.id"

-- |
-- The version string of the VM image or host OS as defined in [Version Attributes](\/docs\/resource\/README.md#version-attributes).
host_image_version :: AttributeKey Text
host_image_version = AttributeKey "host.image.version"

-- |
-- Available IP addresses of the host, excluding loopback interfaces.

-- ==== Note
-- IPv4 Addresses MUST be specified in dotted-quad notation. IPv6 addresses MUST be specified in the [RFC 5952](https:\/\/www.rfc-editor.org\/rfc\/rfc5952.html) format.
host_ip :: AttributeKey [Text]
host_ip = AttributeKey "host.ip"

-- |
-- Available MAC addresses of the host, excluding loopback interfaces.

-- ==== Note
-- MAC Addresses MUST be represented in [IEEE RA hexadecimal form](https:\/\/standards.ieee.org\/wp-content\/uploads\/import\/documents\/tutorials\/eui.pdf): as hyphen-separated octets in uppercase hexadecimal form from most to least significant.
host_mac :: AttributeKey [Text]
host_mac = AttributeKey "host.mac"

-- |
-- Processor manufacturer identifier. A maximum 12-character string.

-- ==== Note
-- [CPUID](https:\/\/wiki.osdev.org\/CPUID) command returns the vendor ID string in EBX, EDX and ECX registers. Writing these to memory in this order results in a 12-character string.
host_cpu_vendor_id :: AttributeKey Text
host_cpu_vendor_id = AttributeKey "host.cpu.vendor.id"

-- |
-- Family or generation of the CPU.
host_cpu_family :: AttributeKey Text
host_cpu_family = AttributeKey "host.cpu.family"

-- |
-- Model identifier. It provides more granular information about the CPU, distinguishing it from other CPUs within the same family.
host_cpu_model_id :: AttributeKey Text
host_cpu_model_id = AttributeKey "host.cpu.model.id"

-- |
-- Model designation of the processor.
host_cpu_model_name :: AttributeKey Text
host_cpu_model_name = AttributeKey "host.cpu.model.name"

-- |
-- Stepping or core revisions.
host_cpu_stepping :: AttributeKey Text
host_cpu_stepping = AttributeKey "host.cpu.stepping"

-- |
-- The amount of level 2 memory cache available to the processor (in Bytes).
host_cpu_cache_l2_size :: AttributeKey Int64
host_cpu_cache_l2_size = AttributeKey "host.cpu.cache.l2.size"

-- $registry_k8s
-- Kubernetes resource attributes.
--
-- === Attributes
-- - 'k8s_cluster_name'
--
-- - 'k8s_cluster_uid'
--
-- - 'k8s_node_name'
--
-- - 'k8s_node_uid'
--
-- - 'k8s_namespace_name'
--
-- - 'k8s_pod_uid'
--
-- - 'k8s_pod_name'
--
-- - 'k8s_pod_label'
--
-- - 'k8s_pod_annotation'
--
-- - 'k8s_container_name'
--
-- - 'k8s_container_restartCount'
--
-- - 'k8s_replicaset_uid'
--
-- - 'k8s_replicaset_name'
--
-- - 'k8s_deployment_uid'
--
-- - 'k8s_deployment_name'
--
-- - 'k8s_statefulset_uid'
--
-- - 'k8s_statefulset_name'
--
-- - 'k8s_daemonset_uid'
--
-- - 'k8s_daemonset_name'
--
-- - 'k8s_job_uid'
--
-- - 'k8s_job_name'
--
-- - 'k8s_cronjob_uid'
--
-- - 'k8s_cronjob_name'
--

-- |
-- The name of the cluster.
k8s_cluster_name :: AttributeKey Text
k8s_cluster_name = AttributeKey "k8s.cluster.name"

-- |
-- A pseudo-ID for the cluster, set to the UID of the @kube-system@ namespace.

-- ==== Note
-- K8s doesn\'t have support for obtaining a cluster ID. If this is ever
-- added, we will recommend collecting the @k8s.cluster.uid@ through the
-- official APIs. In the meantime, we are able to use the @uid@ of the
-- @kube-system@ namespace as a proxy for cluster ID. Read on for the
-- rationale.
-- 
-- Every object created in a K8s cluster is assigned a distinct UID. The
-- @kube-system@ namespace is used by Kubernetes itself and will exist
-- for the lifetime of the cluster. Using the @uid@ of the @kube-system@
-- namespace is a reasonable proxy for the K8s ClusterID as it will only
-- change if the cluster is rebuilt. Furthermore, Kubernetes UIDs are
-- UUIDs as standardized by
-- [ISO\/IEC 9834-8 and ITU-T X.667](https:\/\/www.itu.int\/ITU-T\/studygroups\/com17\/oid.html).
-- Which states:
-- 
-- \> If generated according to one of the mechanisms defined in Rec.
--   ITU-T X.667 | ISO\/IEC 9834-8, a UUID is either guaranteed to be
--   different from all other UUIDs generated before 3603 A.D., or is
--   extremely likely to be different (depending on the mechanism chosen).
-- 
-- Therefore, UIDs between clusters should be extremely unlikely to
-- conflict.
k8s_cluster_uid :: AttributeKey Text
k8s_cluster_uid = AttributeKey "k8s.cluster.uid"

-- |
-- The name of the Node.
k8s_node_name :: AttributeKey Text
k8s_node_name = AttributeKey "k8s.node.name"

-- |
-- The UID of the Node.
k8s_node_uid :: AttributeKey Text
k8s_node_uid = AttributeKey "k8s.node.uid"

-- |
-- The name of the namespace that the pod is running in.
k8s_namespace_name :: AttributeKey Text
k8s_namespace_name = AttributeKey "k8s.namespace.name"

-- |
-- The UID of the Pod.
k8s_pod_uid :: AttributeKey Text
k8s_pod_uid = AttributeKey "k8s.pod.uid"

-- |
-- The name of the Pod.
k8s_pod_name :: AttributeKey Text
k8s_pod_name = AttributeKey "k8s.pod.name"

-- |
-- The label key-value pairs placed on the Pod, the @\<key\>@ being the label name, the value being the label value.
k8s_pod_label :: Text -> AttributeKey Text
k8s_pod_label = \k -> AttributeKey $ "k8s.pod.label." <> k

-- |
-- The annotation key-value pairs placed on the Pod, the @\<key\>@ being the annotation name, the value being the annotation value.
k8s_pod_annotation :: Text -> AttributeKey Text
k8s_pod_annotation = \k -> AttributeKey $ "k8s.pod.annotation." <> k

-- |
-- The name of the Container from Pod specification, must be unique within a Pod. Container runtime usually uses different globally unique name (@container.name@).
k8s_container_name :: AttributeKey Text
k8s_container_name = AttributeKey "k8s.container.name"

-- |
-- Number of times the container was restarted. This attribute can be used to identify a particular container (running or stopped) within a container spec.
k8s_container_restartCount :: AttributeKey Int64
k8s_container_restartCount = AttributeKey "k8s.container.restart_count"

-- |
-- The UID of the ReplicaSet.
k8s_replicaset_uid :: AttributeKey Text
k8s_replicaset_uid = AttributeKey "k8s.replicaset.uid"

-- |
-- The name of the ReplicaSet.
k8s_replicaset_name :: AttributeKey Text
k8s_replicaset_name = AttributeKey "k8s.replicaset.name"

-- |
-- The UID of the Deployment.
k8s_deployment_uid :: AttributeKey Text
k8s_deployment_uid = AttributeKey "k8s.deployment.uid"

-- |
-- The name of the Deployment.
k8s_deployment_name :: AttributeKey Text
k8s_deployment_name = AttributeKey "k8s.deployment.name"

-- |
-- The UID of the StatefulSet.
k8s_statefulset_uid :: AttributeKey Text
k8s_statefulset_uid = AttributeKey "k8s.statefulset.uid"

-- |
-- The name of the StatefulSet.
k8s_statefulset_name :: AttributeKey Text
k8s_statefulset_name = AttributeKey "k8s.statefulset.name"

-- |
-- The UID of the DaemonSet.
k8s_daemonset_uid :: AttributeKey Text
k8s_daemonset_uid = AttributeKey "k8s.daemonset.uid"

-- |
-- The name of the DaemonSet.
k8s_daemonset_name :: AttributeKey Text
k8s_daemonset_name = AttributeKey "k8s.daemonset.name"

-- |
-- The UID of the Job.
k8s_job_uid :: AttributeKey Text
k8s_job_uid = AttributeKey "k8s.job.uid"

-- |
-- The name of the Job.
k8s_job_name :: AttributeKey Text
k8s_job_name = AttributeKey "k8s.job.name"

-- |
-- The UID of the CronJob.
k8s_cronjob_uid :: AttributeKey Text
k8s_cronjob_uid = AttributeKey "k8s.cronjob.uid"

-- |
-- The name of the CronJob.
k8s_cronjob_name :: AttributeKey Text
k8s_cronjob_name = AttributeKey "k8s.cronjob.name"

-- $registry_oci_manifest
-- An OCI image manifest.
--
-- === Attributes
-- - 'oci_manifest_digest'
--

-- |
-- The digest of the OCI image manifest. For container images specifically is the digest by which the container image is known.

-- ==== Note
-- Follows [OCI Image Manifest Specification](https:\/\/github.com\/opencontainers\/image-spec\/blob\/main\/manifest.md), and specifically the [Digest property](https:\/\/github.com\/opencontainers\/image-spec\/blob\/main\/descriptor.md#digests).
-- An example can be found in [Example Image Manifest](https:\/\/docs.docker.com\/registry\/spec\/manifest-v2-2\/#example-image-manifest).
oci_manifest_digest :: AttributeKey Text
oci_manifest_digest = AttributeKey "oci.manifest.digest"

-- $source
-- These attributes may be used to describe the sender of a network exchange\/packet. These should be used when there is no client\/server relationship between the two sides, or when that relationship is unknown. This covers low-level network interactions (e.g. packet tracing) where you don\'t know if there was a connection or which side initiated it. This also covers unidirectional UDP flows and peer-to-peer communication where the "user-facing" surface of the protocol \/ API doesn\'t expose a clear notion of client and server.
--
-- === Attributes
-- - 'source_address'
--
-- - 'source_port'
--

-- |
-- Source address - domain name if available without reverse DNS lookup; otherwise, IP address or Unix domain socket name.

-- ==== Note
-- When observed from the destination side, and when communicating through an intermediary, @source.address@ SHOULD represent the source address behind any intermediaries, for example proxies, if it\'s available.
source_address :: AttributeKey Text
source_address = AttributeKey "source.address"

-- |
-- Source port number
source_port :: AttributeKey Int64
source_port = AttributeKey "source.port"

-- $attributes_network_deprecated
-- These attributes may be used for any network related operation.
--
-- === Attributes
-- - 'net_sock_peer_name'
--
--     Deprecated: Removed.
--
-- - 'net_sock_peer_addr'
--
--     Deprecated: Replaced by `network.peer.address`.
--
-- - 'net_sock_peer_port'
--
--     Deprecated: Replaced by `network.peer.port`.
--
-- - 'net_peer_name'
--
--     Deprecated: Replaced by `server.address` on client spans and `client.address` on server spans.
--
-- - 'net_peer_port'
--
--     Deprecated: Replaced by `server.port` on client spans and `client.port` on server spans.
--
-- - 'net_host_name'
--
--     Deprecated: Replaced by `server.address`.
--
-- - 'net_host_port'
--
--     Deprecated: Replaced by `server.port`.
--
-- - 'net_sock_host_addr'
--
--     Deprecated: Replaced by `network.local.address`.
--
-- - 'net_sock_host_port'
--
--     Deprecated: Replaced by `network.local.port`.
--
-- - 'net_transport'
--
--     Deprecated: Replaced by `network.transport`.
--
-- - 'net_protocol_name'
--
--     Deprecated: Replaced by `network.protocol.name`.
--
-- - 'net_protocol_version'
--
--     Deprecated: Replaced by `network.protocol.version`.
--
-- - 'net_sock_family'
--
--     Deprecated: Split to `network.transport` and `network.type`.
--

-- |
-- Deprecated, no replacement at this time.
net_sock_peer_name :: AttributeKey Text
net_sock_peer_name = AttributeKey "net.sock.peer.name"

-- |
-- Deprecated, use @network.peer.address@.
net_sock_peer_addr :: AttributeKey Text
net_sock_peer_addr = AttributeKey "net.sock.peer.addr"

-- |
-- Deprecated, use @network.peer.port@.
net_sock_peer_port :: AttributeKey Int64
net_sock_peer_port = AttributeKey "net.sock.peer.port"

-- |
-- Deprecated, use @server.address@ on client spans and @client.address@ on server spans.
net_peer_name :: AttributeKey Text
net_peer_name = AttributeKey "net.peer.name"

-- |
-- Deprecated, use @server.port@ on client spans and @client.port@ on server spans.
net_peer_port :: AttributeKey Int64
net_peer_port = AttributeKey "net.peer.port"

-- |
-- Deprecated, use @server.address@.
net_host_name :: AttributeKey Text
net_host_name = AttributeKey "net.host.name"

-- |
-- Deprecated, use @server.port@.
net_host_port :: AttributeKey Int64
net_host_port = AttributeKey "net.host.port"

-- |
-- Deprecated, use @network.local.address@.
net_sock_host_addr :: AttributeKey Text
net_sock_host_addr = AttributeKey "net.sock.host.addr"

-- |
-- Deprecated, use @network.local.port@.
net_sock_host_port :: AttributeKey Int64
net_sock_host_port = AttributeKey "net.sock.host.port"

-- |
-- Deprecated, use @network.transport@.
net_transport :: AttributeKey Text
net_transport = AttributeKey "net.transport"

-- |
-- Deprecated, use @network.protocol.name@.
net_protocol_name :: AttributeKey Text
net_protocol_name = AttributeKey "net.protocol.name"

-- |
-- Deprecated, use @network.protocol.version@.
net_protocol_version :: AttributeKey Text
net_protocol_version = AttributeKey "net.protocol.version"

-- |
-- Deprecated, use @network.transport@ and @network.type@.
net_sock_family :: AttributeKey Text
net_sock_family = AttributeKey "net.sock.family"

-- $attributes_http_deprecated
-- Describes deprecated HTTP attributes.
--
-- === Attributes
-- - 'http_method'
--
--     Deprecated: Replaced by `http.request.method`.
--
-- - 'http_statusCode'
--
--     Deprecated: Replaced by `http.response.status_code`.
--
-- - 'http_scheme'
--
--     Deprecated: Replaced by `url.scheme` instead.
--
-- - 'http_url'
--
--     Deprecated: Replaced by `url.full`.
--
-- - 'http_target'
--
--     Deprecated: Split to `url.path` and `url.query.
--
-- - 'http_requestContentLength'
--
--     Deprecated: Replaced by `http.request.header.content-length`.
--
-- - 'http_responseContentLength'
--
--     Deprecated: Replaced by `http.response.header.content-length`.
--
-- - 'http_flavor'
--
--     Deprecated: Replaced by `network.protocol.name`.
--
-- - 'http_userAgent'
--
--     Deprecated: Replaced by `user_agent.original`.
--

-- |
-- Deprecated, use @http.request.method@ instead.
http_method :: AttributeKey Text
http_method = AttributeKey "http.method"

-- |
-- Deprecated, use @http.response.status_code@ instead.
http_statusCode :: AttributeKey Int64
http_statusCode = AttributeKey "http.status_code"

-- |
-- Deprecated, use @url.scheme@ instead.
http_scheme :: AttributeKey Text
http_scheme = AttributeKey "http.scheme"

-- |
-- Deprecated, use @url.full@ instead.
http_url :: AttributeKey Text
http_url = AttributeKey "http.url"

-- |
-- Deprecated, use @url.path@ and @url.query@ instead.
http_target :: AttributeKey Text
http_target = AttributeKey "http.target"

-- |
-- Deprecated, use @http.request.header.content-length@ instead.
http_requestContentLength :: AttributeKey Int64
http_requestContentLength = AttributeKey "http.request_content_length"

-- |
-- Deprecated, use @http.response.header.content-length@ instead.
http_responseContentLength :: AttributeKey Int64
http_responseContentLength = AttributeKey "http.response_content_length"

-- |
-- Deprecated, use @network.protocol.name@ instead.
http_flavor :: AttributeKey Text
http_flavor = AttributeKey "http.flavor"

-- |
-- Deprecated, use @user_agent.original@ instead.
http_userAgent :: AttributeKey Text
http_userAgent = AttributeKey "http.user_agent"

-- $attributes_system_deprecated
-- Deprecated system attributes.
--
-- === Attributes
-- - 'system_processes_status'
--
--     Deprecated: Replaced by `system.process.status`.
--

-- |
-- Deprecated, use @system.process.status@ instead.
system_processes_status :: AttributeKey Text
system_processes_status = AttributeKey "system.processes.status"

-- $attributes_container_deprecated
-- Describes deprecated container attributes.
--
-- === Attributes
-- - 'container_labels'
--
--     Deprecated: Replaced by `container.label`.
--

-- |
-- Deprecated, use @container.label@ instead.
container_labels :: Text -> AttributeKey Text
container_labels = \k -> AttributeKey $ "container.labels." <> k

-- $attributes_k8s_deprecated
-- Describes deprecated k8s attributes.
--
-- === Attributes
-- - 'k8s_pod_labels'
--
--     Deprecated: Replaced by `k8s.pod.label`.
--

-- |
-- Deprecated, use @k8s.pod.label@ instead.
k8s_pod_labels :: Text -> AttributeKey Text
k8s_pod_labels = \k -> AttributeKey $ "k8s.pod.labels." <> k

-- $os
-- The operating system (OS) on which the process represented by this resource is running.
--
-- ==== Note
-- In case of virtualized environments, this is the operating system as it is observed by the process, i.e., the virtualized guest rather than the underlying host.
--
-- === Attributes
-- - 'os_type'
--
--     Requirement level: required
--
-- - 'os_description'
--
-- - 'os_name'
--
-- - 'os_version'
--
-- - 'os_buildId'
--






-- $deployment
-- The software deployment.
--
-- === Attributes
-- - 'deployment_environment'
--

-- |
-- Name of the [deployment environment](https:\/\/wikipedia.org\/wiki\/Deployment_environment) (aka deployment tier).

-- ==== Note
-- @deployment.environment@ does not affect the uniqueness constraints defined through
-- the @service.namespace@, @service.name@ and @service.instance.id@ resource attributes.
-- This implies that resources carrying the following attribute combinations MUST be
-- considered to be identifying the same service:
-- 
-- * @service.name=frontend@, @deployment.environment=production@
-- * @service.name=frontend@, @deployment.environment=staging@.
deployment_environment :: AttributeKey Text
deployment_environment = AttributeKey "deployment.environment"

-- $android
-- The Android platform on which the Android application is running.
--
-- === Attributes
-- - 'android_os_apiLevel'
--

-- |
-- Uniquely identifies the framework API revision offered by a version (@os.version@) of the android operating system. More information can be found [here](https:\/\/developer.android.com\/guide\/topics\/manifest\/uses-sdk-element#ApiLevels).
android_os_apiLevel :: AttributeKey Text
android_os_apiLevel = AttributeKey "android.os.api_level"

-- $serviceExperimental
-- A service instance.
--
-- === Attributes
-- - 'service_namespace'
--
-- - 'service_instance_id'
--

-- |
-- A namespace for @service.name@.

-- ==== Note
-- A string value having a meaning that helps to distinguish a group of services, for example the team name that owns a group of services. @service.name@ is expected to be unique within the same namespace. If @service.namespace@ is not specified in the Resource then @service.name@ is expected to be unique for all services that have no explicit namespace defined (so the empty\/unspecified namespace is simply one more valid namespace). Zero-length namespace string is assumed equal to unspecified namespace.
service_namespace :: AttributeKey Text
service_namespace = AttributeKey "service.namespace"

-- |
-- The string ID of the service instance.

-- ==== Note
-- MUST be unique for each instance of the same @service.namespace,service.name@ pair (in other words
-- @service.namespace,service.name,service.instance.id@ triplet MUST be globally unique). The ID helps to
-- distinguish instances of the same service that exist at the same time (e.g. instances of a horizontally scaled
-- service).
-- 
-- Implementations, such as SDKs, are recommended to generate a random Version 1 or Version 4 [RFC
-- 4122](https:\/\/www.ietf.org\/rfc\/rfc4122.txt) UUID, but are free to use an inherent unique ID as the source of
-- this value if stability is desirable. In that case, the ID SHOULD be used as source of a UUID Version 5 and
-- SHOULD use the following UUID as the namespace: @4d63009a-8d0f-11ee-aad7-4c796ed8e320@.
-- 
-- UUIDs are typically recommended, as only an opaque value for the purposes of identifying a service instance is
-- needed. Similar to what can be seen in the man page for the
-- [@\/etc\/machine-id@](https:\/\/www.freedesktop.org\/software\/systemd\/man\/machine-id.html) file, the underlying
-- data, such as pod name and namespace should be treated as confidential, being the user\'s choice to expose it
-- or not via another resource attribute.
-- 
-- For applications running behind an application server (like unicorn), we do not recommend using one identifier
-- for all processes participating in the application. Instead, it\'s recommended each division (e.g. a worker
-- thread in unicorn) to have its own instance.id.
-- 
-- It\'s not recommended for a Collector to set @service.instance.id@ if it can\'t unambiguously determine the
-- service instance that is generating that telemetry. For instance, creating an UUID based on @pod.name@ will
-- likely be wrong, as the Collector might not know from which container within that pod the telemetry originated.
-- However, Collectors can set the @service.instance.id@ if they can unambiguously determine the service instance
-- for that telemetry. This is typically the case for scraping receivers, as they know the target address and
-- port.
service_instance_id :: AttributeKey Text
service_instance_id = AttributeKey "service.instance.id"

-- $telemetry
-- The telemetry SDK used to capture data recorded by the instrumentation libraries.
--
-- === Attributes
-- - 'telemetry_sdk_name'
--
--     Stability: stable
--
--     Requirement level: required
--
-- - 'telemetry_sdk_language'
--
--     Stability: stable
--
--     Requirement level: required
--
-- - 'telemetry_sdk_version'
--
--     Stability: stable
--
--     Requirement level: required
--

-- |
-- The name of the telemetry SDK as defined above.

-- ==== Note
-- The OpenTelemetry SDK MUST set the @telemetry.sdk.name@ attribute to @opentelemetry@.
-- If another SDK, like a fork or a vendor-provided implementation, is used, this SDK MUST set the
-- @telemetry.sdk.name@ attribute to the fully-qualified class or module name of this SDK\'s main entry point
-- or another suitable identifier depending on the language.
-- The identifier @opentelemetry@ is reserved and MUST NOT be used in this case.
-- All custom identifiers SHOULD be stable across different versions of an implementation.
telemetry_sdk_name :: AttributeKey Text
telemetry_sdk_name = AttributeKey "telemetry.sdk.name"

-- |
-- The language of the telemetry SDK.
telemetry_sdk_language :: AttributeKey Text
telemetry_sdk_language = AttributeKey "telemetry.sdk.language"

-- |
-- The version string of the telemetry SDK.
telemetry_sdk_version :: AttributeKey Text
telemetry_sdk_version = AttributeKey "telemetry.sdk.version"

-- $webengineResource
-- Resource describing the packaged software running the application code. Web engines are typically executed using process.runtime.
--
-- === Attributes
-- - 'webengine_name'
--
--     Requirement level: required
--
-- - 'webengine_version'
--
-- - 'webengine_description'
--

-- |
-- The name of the web engine.
webengine_name :: AttributeKey Text
webengine_name = AttributeKey "webengine.name"

-- |
-- The version of the web engine.
webengine_version :: AttributeKey Text
webengine_version = AttributeKey "webengine.version"

-- |
-- Additional description of the web engine (e.g. detailed version and edition information).
webengine_description :: AttributeKey Text
webengine_description = AttributeKey "webengine.description"

-- $browser
-- The web browser in which the application represented by the resource is running. The @browser.*@ attributes MUST be used only for resources that represent applications running in a web browser (regardless of whether running on a mobile or desktop device).
--
-- === Attributes
-- - 'browser_brands'
--
-- - 'browser_platform'
--
-- - 'browser_mobile'
--
-- - 'browser_language'
--
-- - 'userAgent_original'
--
--     Full user-agent string provided by the browser
--
--     ==== Note
--     The user-agent value SHOULD be provided only from browsers that do not have a mechanism to retrieve brands and platform individually from the User-Agent Client Hints API. To retrieve the value, the legacy @navigator.userAgent@ API can be used.
--






-- $device
-- The device on which the process represented by this resource is running.
--
-- === Attributes
-- - 'device_id'
--
-- - 'device_manufacturer'
--
-- - 'device_model_identifier'
--
-- - 'device_model_name'
--





-- $process
-- An operating system process.
--
-- === Attributes
-- - 'process_pid'
--
-- - 'process_parentPid'
--
-- - 'process_executable_name'
--
--     Requirement level: conditionally required: See alternative attributes below.
--
-- - 'process_executable_path'
--
--     Requirement level: conditionally required: See alternative attributes below.
--
-- - 'process_command'
--
--     Requirement level: conditionally required: See alternative attributes below.
--
-- - 'process_commandLine'
--
--     Requirement level: conditionally required: See alternative attributes below.
--
-- - 'process_commandArgs'
--
--     Requirement level: conditionally required: See alternative attributes below.
--
-- - 'process_owner'
--









-- $process_runtime
-- The single (language) runtime instance which is monitored.
--
-- === Attributes
-- - 'process_runtime_name'
--
-- - 'process_runtime_version'
--
-- - 'process_runtime_description'
--




-- $service
-- A service instance.
--
-- === Attributes
-- - 'service_name'
--
--     Stability: stable
--
--     Requirement level: required
--
-- - 'service_version'
--
--     Stability: stable
--

-- |
-- Logical name of the service.

-- ==== Note
-- MUST be the same for all instances of horizontally scaled services. If the value was not specified, SDKs MUST fallback to @unknown_service:@ concatenated with [@process.executable.name@](process.md#process), e.g. @unknown_service:bash@. If @process.executable.name@ is not available, the value MUST be set to @unknown_service@.
service_name :: AttributeKey Text
service_name = AttributeKey "service.name"

-- |
-- The version string of the service API or implementation. The format is not defined by these conventions.
service_version :: AttributeKey Text
service_version = AttributeKey "service.version"

-- $telemetryExperimental
-- The telemetry SDK used to capture data recorded by the instrumentation libraries.
--
-- === Attributes
-- - 'telemetry_distro_name'
--
-- - 'telemetry_distro_version'
--

-- |
-- The name of the auto instrumentation agent or distribution, if used.

-- ==== Note
-- Official auto instrumentation agents and distributions SHOULD set the @telemetry.distro.name@ attribute to
-- a string starting with @opentelemetry-@, e.g. @opentelemetry-java-instrumentation@.
telemetry_distro_name :: AttributeKey Text
telemetry_distro_name = AttributeKey "telemetry.distro.name"

-- |
-- The version string of the auto instrumentation agent or distribution, if used.
telemetry_distro_version :: AttributeKey Text
telemetry_distro_version = AttributeKey "telemetry.distro.version"

-- $faasResource
-- A serverless instance.
--
-- === Attributes
-- - 'faas_name'
--
--     Requirement level: required
--
-- - 'faas_version'
--
-- - 'faas_instance'
--
-- - 'faas_maxMemory'
--
-- - 'cloud_resourceId'
--

-- |
-- The name of the single function that this runtime instance executes.

-- ==== Note
-- This is the name of the function as configured\/deployed on the FaaS
-- platform and is usually different from the name of the callback
-- function (which may be stored in the
-- [@code.namespace@\/@code.function@](\/docs\/general\/attributes.md#source-code-attributes)
-- span attributes).
-- 
-- For some cloud providers, the above definition is ambiguous. The following
-- definition of function name MUST be used for this attribute
-- (and consequently the span name) for the listed cloud providers\/products:
-- 
-- * __Azure:__  The full name @\<FUNCAPP\>\/\<FUNC\>@, i.e., function app name
--   followed by a forward slash followed by the function name (this form
--   can also be seen in the resource JSON for the function).
--   This means that a span attribute MUST be used, as an Azure function
--   app can host multiple functions that would usually share
--   a TracerProvider (see also the @cloud.resource_id@ attribute).
faas_name :: AttributeKey Text
faas_name = AttributeKey "faas.name"

-- |
-- The immutable version of the function being executed.

-- ==== Note
-- Depending on the cloud provider and platform, use:
-- 
-- * __AWS Lambda:__ The [function version](https:\/\/docs.aws.amazon.com\/lambda\/latest\/dg\/configuration-versions.html)
--   (an integer represented as a decimal string).
-- * __Google Cloud Run (Services):__ The [revision](https:\/\/cloud.google.com\/run\/docs\/managing\/revisions)
--   (i.e., the function name plus the revision suffix).
-- * __Google Cloud Functions:__ The value of the
--   [@K_REVISION@ environment variable](https:\/\/cloud.google.com\/functions\/docs\/env-var#runtime_environment_variables_set_automatically).
-- * __Azure Functions:__ Not applicable. Do not set this attribute.
faas_version :: AttributeKey Text
faas_version = AttributeKey "faas.version"

-- |
-- The execution environment ID as a string, that will be potentially reused for other invocations to the same function\/function version.

-- ==== Note
-- * __AWS Lambda:__ Use the (full) log stream name.
faas_instance :: AttributeKey Text
faas_instance = AttributeKey "faas.instance"

-- |
-- The amount of memory available to the serverless function converted to Bytes.

-- ==== Note
-- It\'s recommended to set this attribute since e.g. too little memory can easily stop a Java AWS Lambda function from working correctly. On AWS Lambda, the environment variable @AWS_LAMBDA_FUNCTION_MEMORY_SIZE@ provides this information (which must be multiplied by 1,048,576).
faas_maxMemory :: AttributeKey Int64
faas_maxMemory = AttributeKey "faas.max_memory"


-- $container
-- A container instance.
--
-- === Attributes
-- - 'container_name'
--
-- - 'container_id'
--
-- - 'container_runtime'
--
-- - 'container_image_name'
--
-- - 'container_image_tags'
--
-- - 'container_image_id'
--
-- - 'container_image_repoDigests'
--
-- - 'container_command'
--
--     Requirement level: opt-in
--
-- - 'container_commandLine'
--
--     Requirement level: opt-in
--
-- - 'container_commandArgs'
--
--     Requirement level: opt-in
--
-- - 'container_label'
--
-- - 'oci_manifest_digest'
--













-- $cloud
-- A cloud environment (e.g. GCP, Azure, AWS)
--
-- === Attributes
-- - 'cloud_provider'
--
-- - 'cloud_account_id'
--
-- - 'cloud_region'
--
-- - 'cloud_resourceId'
--
-- - 'cloud_availabilityZone'
--
-- - 'cloud_platform'
--







-- $host
-- A host is defined as a computing instance. For example, physical servers, virtual machines, switches or disk array.
--
-- === Attributes
-- - 'host_id'
--
-- - 'host_name'
--
-- - 'host_type'
--
-- - 'host_arch'
--
-- - 'host_image_name'
--
-- - 'host_image_id'
--
-- - 'host_image_version'
--
-- - 'host_ip'
--
--     Requirement level: opt-in
--
-- - 'host_mac'
--
--     Requirement level: opt-in
--










-- $host_cpu
-- A host\'s CPU information
--
-- === Attributes
-- - 'host_cpu_vendor_id'
--
--     Requirement level: opt-in
--
-- - 'host_cpu_family'
--
--     Requirement level: opt-in
--
-- - 'host_cpu_model_id'
--
--     Requirement level: opt-in
--
-- - 'host_cpu_model_name'
--
--     Requirement level: opt-in
--
-- - 'host_cpu_stepping'
--
--     Requirement level: opt-in
--
-- - 'host_cpu_cache_l2_size'
--
--     Requirement level: opt-in
--







-- $k8s_cluster
-- A Kubernetes Cluster.
--
-- === Attributes
-- - 'k8s_cluster_name'
--
-- - 'k8s_cluster_uid'
--



-- $k8s_node
-- A Kubernetes Node object.
--
-- === Attributes
-- - 'k8s_node_name'
--
-- - 'k8s_node_uid'
--



-- $k8s_namespace
-- A Kubernetes Namespace.
--
-- === Attributes
-- - 'k8s_namespace_name'
--


-- $k8s_pod
-- A Kubernetes Pod object.
--
-- === Attributes
-- - 'k8s_pod_uid'
--
-- - 'k8s_pod_name'
--
-- - 'k8s_pod_label'
--
-- - 'k8s_pod_annotation'
--
--     Requirement level: opt-in
--





-- $k8s_container
-- A container in a [PodTemplate](https:\/\/kubernetes.io\/docs\/concepts\/workloads\/pods\/#pod-templates).
--
-- === Attributes
-- - 'k8s_container_name'
--
-- - 'k8s_container_restartCount'
--



-- $k8s_replicaset
-- A Kubernetes ReplicaSet object.
--
-- === Attributes
-- - 'k8s_replicaset_uid'
--
-- - 'k8s_replicaset_name'
--



-- $k8s_deployment
-- A Kubernetes Deployment object.
--
-- === Attributes
-- - 'k8s_deployment_uid'
--
-- - 'k8s_deployment_name'
--



-- $k8s_statefulset
-- A Kubernetes StatefulSet object.
--
-- === Attributes
-- - 'k8s_statefulset_uid'
--
-- - 'k8s_statefulset_name'
--



-- $k8s_daemonset
-- A Kubernetes DaemonSet object.
--
-- === Attributes
-- - 'k8s_daemonset_uid'
--
-- - 'k8s_daemonset_name'
--



-- $k8s_job
-- A Kubernetes Job object.
--
-- === Attributes
-- - 'k8s_job_uid'
--
-- - 'k8s_job_name'
--



-- $k8s_cronjob
-- A Kubernetes CronJob object.
--
-- === Attributes
-- - 'k8s_cronjob_uid'
--
-- - 'k8s_cronjob_name'
--



-- $heroku
-- Heroku dyno metadata
--
-- === Attributes
-- - 'heroku_release_creationTimestamp'
--
--     Requirement level: opt-in
--
-- - 'heroku_release_commit'
--
--     Requirement level: opt-in
--
-- - 'heroku_app_id'
--
--     Requirement level: opt-in
--

-- |
-- Time and date the release was created
heroku_release_creationTimestamp :: AttributeKey Text
heroku_release_creationTimestamp = AttributeKey "heroku.release.creation_timestamp"

-- |
-- Commit hash for the current release
heroku_release_commit :: AttributeKey Text
heroku_release_commit = AttributeKey "heroku.release.commit"

-- |
-- Unique identifier for the application
heroku_app_id :: AttributeKey Text
heroku_app_id = AttributeKey "heroku.app.id"

-- $aws_ecs
-- Resources used by AWS Elastic Container Service (ECS).
--
-- === Attributes
-- - 'aws_ecs_container_arn'
--
-- - 'aws_ecs_cluster_arn'
--
-- - 'aws_ecs_launchtype'
--
-- - 'aws_ecs_task_arn'
--
-- - 'aws_ecs_task_family'
--
-- - 'aws_ecs_task_id'
--
--     Requirement level: conditionally required: If and only if @task.arn@ is populated.
--
-- - 'aws_ecs_task_revision'
--

-- |
-- The Amazon Resource Name (ARN) of an [ECS container instance](https:\/\/docs.aws.amazon.com\/AmazonECS\/latest\/developerguide\/ECS_instances.html).
aws_ecs_container_arn :: AttributeKey Text
aws_ecs_container_arn = AttributeKey "aws.ecs.container.arn"

-- |
-- The ARN of an [ECS cluster](https:\/\/docs.aws.amazon.com\/AmazonECS\/latest\/developerguide\/clusters.html).
aws_ecs_cluster_arn :: AttributeKey Text
aws_ecs_cluster_arn = AttributeKey "aws.ecs.cluster.arn"

-- |
-- The [launch type](https:\/\/docs.aws.amazon.com\/AmazonECS\/latest\/developerguide\/launch_types.html) for an ECS task.
aws_ecs_launchtype :: AttributeKey Text
aws_ecs_launchtype = AttributeKey "aws.ecs.launchtype"

-- |
-- The ARN of a running [ECS task](https:\/\/docs.aws.amazon.com\/AmazonECS\/latest\/developerguide\/ecs-account-settings.html#ecs-resource-ids).
aws_ecs_task_arn :: AttributeKey Text
aws_ecs_task_arn = AttributeKey "aws.ecs.task.arn"

-- |
-- The family name of the [ECS task definition](https:\/\/docs.aws.amazon.com\/AmazonECS\/latest\/developerguide\/task_definitions.html) used to create the ECS task.
aws_ecs_task_family :: AttributeKey Text
aws_ecs_task_family = AttributeKey "aws.ecs.task.family"

-- |
-- The ID of a running ECS task. The ID MUST be extracted from @task.arn@.
aws_ecs_task_id :: AttributeKey Text
aws_ecs_task_id = AttributeKey "aws.ecs.task.id"

-- |
-- The revision for the task definition used to create the ECS task.
aws_ecs_task_revision :: AttributeKey Text
aws_ecs_task_revision = AttributeKey "aws.ecs.task.revision"

-- $aws_eks
-- Resources used by AWS Elastic Kubernetes Service (EKS).
--
-- === Attributes
-- - 'aws_eks_cluster_arn'
--

-- |
-- The ARN of an EKS cluster.
aws_eks_cluster_arn :: AttributeKey Text
aws_eks_cluster_arn = AttributeKey "aws.eks.cluster.arn"

-- $aws_log
-- Resources specific to Amazon Web Services.
--
-- === Attributes
-- - 'aws_log_group_names'
--
-- - 'aws_log_group_arns'
--
-- - 'aws_log_stream_names'
--
-- - 'aws_log_stream_arns'
--

-- |
-- The name(s) of the AWS log group(s) an application is writing to.

-- ==== Note
-- Multiple log groups must be supported for cases like multi-container applications, where a single application has sidecar containers, and each write to their own log group.
aws_log_group_names :: AttributeKey [Text]
aws_log_group_names = AttributeKey "aws.log.group.names"

-- |
-- The Amazon Resource Name(s) (ARN) of the AWS log group(s).

-- ==== Note
-- See the [log group ARN format documentation](https:\/\/docs.aws.amazon.com\/AmazonCloudWatch\/latest\/logs\/iam-access-control-overview-cwl.html#CWL_ARN_Format).
aws_log_group_arns :: AttributeKey [Text]
aws_log_group_arns = AttributeKey "aws.log.group.arns"

-- |
-- The name(s) of the AWS log stream(s) an application is writing to.
aws_log_stream_names :: AttributeKey [Text]
aws_log_stream_names = AttributeKey "aws.log.stream.names"

-- |
-- The ARN(s) of the AWS log stream(s).

-- ==== Note
-- See the [log stream ARN format documentation](https:\/\/docs.aws.amazon.com\/AmazonCloudWatch\/latest\/logs\/iam-access-control-overview-cwl.html#CWL_ARN_Format). One log group can contain several log streams, so these ARNs necessarily identify both a log group and a log stream.
aws_log_stream_arns :: AttributeKey [Text]
aws_log_stream_arns = AttributeKey "aws.log.stream.arns"

-- $gcp_cloudRun
-- Resource used by Google Cloud Run.
--
-- === Attributes
-- - 'gcp_cloudRun_job_execution'
--
-- - 'gcp_cloudRun_job_taskIndex'
--

-- |
-- The name of the Cloud Run [execution](https:\/\/cloud.google.com\/run\/docs\/managing\/job-executions) being run for the Job, as set by the [@CLOUD_RUN_EXECUTION@](https:\/\/cloud.google.com\/run\/docs\/container-contract#jobs-env-vars) environment variable.
gcp_cloudRun_job_execution :: AttributeKey Text
gcp_cloudRun_job_execution = AttributeKey "gcp.cloud_run.job.execution"

-- |
-- The index for a task within an execution as provided by the [@CLOUD_RUN_TASK_INDEX@](https:\/\/cloud.google.com\/run\/docs\/container-contract#jobs-env-vars) environment variable.
gcp_cloudRun_job_taskIndex :: AttributeKey Int64
gcp_cloudRun_job_taskIndex = AttributeKey "gcp.cloud_run.job.task_index"

-- $gcp_gce
-- Resources used by Google Compute Engine (GCE).
--
-- === Attributes
-- - 'gcp_gce_instance_name'
--
-- - 'gcp_gce_instance_hostname'
--

-- |
-- The instance name of a GCE instance. This is the value provided by @host.name@, the visible name of the instance in the Cloud Console UI, and the prefix for the default hostname of the instance as defined by the [default internal DNS name](https:\/\/cloud.google.com\/compute\/docs\/internal-dns#instance-fully-qualified-domain-names).
gcp_gce_instance_name :: AttributeKey Text
gcp_gce_instance_name = AttributeKey "gcp.gce.instance.name"

-- |
-- The hostname of a GCE instance. This is the full value of the default or [custom hostname](https:\/\/cloud.google.com\/compute\/docs\/instances\/custom-hostname-vm).
gcp_gce_instance_hostname :: AttributeKey Text
gcp_gce_instance_hostname = AttributeKey "gcp.gce.instance.hostname"

-- $event
-- This document defines attributes for Events represented using Log Records.
--
-- === Attributes
-- - 'event_name'
--
--     Requirement level: required
--

-- |
-- Identifies the class \/ type of event.

-- ==== Note
-- Event names are subject to the same rules as [attribute names](https:\/\/github.com\/open-telemetry\/opentelemetry-specification\/tree\/v1.26.0\/specification\/common\/attribute-naming.md). Notably, event names are namespaced to avoid collisions and provide a clean separation of semantics for events in separate domains like browser, mobile, and kubernetes.
event_name :: AttributeKey Text
event_name = AttributeKey "event.name"

-- $log-exception
-- This document defines attributes for exceptions represented using Log Records.
--
-- === Attributes
-- - 'exception_type'
--
-- - 'exception_message'
--
-- - 'exception_stacktrace'
--




-- $attributes_log
-- Describes Log attributes
--
-- === Attributes
-- - 'log_iostream'
--
--     Requirement level: opt-in
--

-- |
-- The stream associated with the log. See below for a list of well-known values.
log_iostream :: AttributeKey Text
log_iostream = AttributeKey "log.iostream"

-- $attributes_log_file
-- A file to which log was emitted.
--
-- === Attributes
-- - 'log_file_name'
--
--     Requirement level: recommended
--
-- - 'log_file_path'
--
--     Requirement level: opt-in
--
-- - 'log_file_nameResolved'
--
--     Requirement level: opt-in
--
-- - 'log_file_pathResolved'
--
--     Requirement level: opt-in
--

-- |
-- The basename of the file.
log_file_name :: AttributeKey Text
log_file_name = AttributeKey "log.file.name"

-- |
-- The full path to the file.
log_file_path :: AttributeKey Text
log_file_path = AttributeKey "log.file.path"

-- |
-- The basename of the file, with symlinks resolved.
log_file_nameResolved :: AttributeKey Text
log_file_nameResolved = AttributeKey "log.file.name_resolved"

-- |
-- The full path to the file, with symlinks resolved.
log_file_pathResolved :: AttributeKey Text
log_file_pathResolved = AttributeKey "log.file.path_resolved"

-- $log-featureFlag
-- This document defines attributes for feature flag evaluations represented using Log Records.
--
-- === Attributes
-- - 'featureFlag_key'
--
-- - 'featureFlag_providerName'
--
-- - 'featureFlag_variant'
--




-- $log_record
-- The attributes described in this section are rather generic. They may be used in any Log Record they apply to.
--
-- === Attributes
-- - 'log_record_uid'
--
--     Requirement level: opt-in
--

-- |
-- A unique identifier for the Log Record.

-- ==== Note
-- If an id is provided, other log records with the same id will be considered duplicates and can be removed safely. This means, that two distinguishable log records MUST have different values.
-- The id MAY be an [Universally Unique Lexicographically Sortable Identifier (ULID)](https:\/\/github.com\/ulid\/spec), but other identifiers (e.g. UUID) may be used as needed.
log_record_uid :: AttributeKey Text
log_record_uid = AttributeKey "log.record.uid"

-- $ios_lifecycle_events
-- This event represents an occurrence of a lifecycle transition on the iOS platform.
--
-- === Attributes
-- - 'ios_state'
--
--     Requirement level: required
--

-- |
-- This attribute represents the state the application has transitioned into at the occurrence of the event.

-- ==== Note
-- The iOS lifecycle states are defined in the [UIApplicationDelegate documentation](https:\/\/developer.apple.com\/documentation\/uikit\/uiapplicationdelegate#1656902), and from which the @OS terminology@ column values are derived.
ios_state :: AttributeKey Text
ios_state = AttributeKey "ios.state"

-- $android_lifecycle_events
-- This event represents an occurrence of a lifecycle transition on the Android platform.
--
-- === Attributes
-- - 'android_state'
--
--     Requirement level: required
--

-- |
-- This attribute represents the state the application has transitioned into at the occurrence of the event.

-- ==== Note
-- The Android lifecycle states are defined in [Activity lifecycle callbacks](https:\/\/developer.android.com\/guide\/components\/activities\/activity-lifecycle#lc), and from which the @OS identifiers@ are derived.
android_state :: AttributeKey Text
android_state = AttributeKey "android.state"

-- $attributes_http_common
-- Describes HTTP attributes.
--
-- === Attributes
-- - 'http_request_method'
--
--     Requirement level: required
--
-- - 'http_response_statusCode'
--
--     Requirement level: conditionally required: If and only if one was received\/sent.
--
-- - 'error_type'
--
--     Requirement level: conditionally required: If request has ended with an error.
--
--     ==== Note
--     If the request fails with an error before response status code was sent or received,
--     @error.type@ SHOULD be set to exception type (its fully-qualified class name, if applicable)
--     or a component-specific low cardinality error identifier.
--     
--     If response status code was sent or received and status indicates an error according to [HTTP span status definition](\/docs\/http\/http-spans.md),
--     @error.type@ SHOULD be set to the status code number (represented as a string), an exception type (if thrown) or a component-specific error identifier.
--     
--     The @error.type@ value SHOULD be predictable and SHOULD have low cardinality.
--     Instrumentations SHOULD document the list of errors they report.
--     
--     The cardinality of @error.type@ within one instrumentation library SHOULD be low, but
--     telemetry consumers that aggregate data from multiple instrumentation libraries and applications
--     should be prepared for @error.type@ to have high cardinality at query time, when no
--     additional filters are applied.
--     
--     If the request has completed successfully, instrumentations SHOULD NOT set @error.type@.
--
-- - 'network_protocol_name'
--
--     Requirement level: conditionally required: If not @http@ and @network.protocol.version@ is set.
--
-- - 'network_protocol_version'
--






-- $attributes_http_client
-- HTTP Client attributes
--
-- === Attributes
-- - 'server_address'
--
--     Host identifier of the ["URI origin"](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#name-uri-origin) HTTP request is sent to.
--
--     Requirement level: required
--
--     ==== Note
--     If an HTTP client request is explicitly made to an IP address, e.g. @http:\/\/x.x.x.x:8080@, then @server.address@ SHOULD be the IP address @x.x.x.x@. A DNS lookup SHOULD NOT be used.
--
-- - 'server_port'
--
--     Port identifier of the ["URI origin"](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#name-uri-origin) HTTP request is sent to.
--
--     Requirement level: required
--
-- - 'url_scheme'
--
--     Requirement level: opt-in
--




-- $attributes_http_server
-- HTTP Server attributes
--
-- === Attributes
-- - 'http_route'
--
--     Requirement level: conditionally required: If and only if it\'s available
--
-- - 'server_address'
--
--     Name of the local HTTP server that received the request.
--
--     ==== Note
--     See [Setting @server.address@ and @server.port@ attributes](\/docs\/http\/http-spans.md#setting-serveraddress-and-serverport-attributes).
--
-- - 'server_port'
--
--     Port of the local HTTP server that received the request.
--
--     Requirement level: conditionally required: If @server.address@ is set.
--
--     ==== Note
--     See [Setting @server.address@ and @server.port@ attributes](\/docs\/http\/http-spans.md#setting-serveraddress-and-serverport-attributes).
--
-- - 'url_scheme'
--
--     Requirement level: required
--
--     ==== Note
--     The scheme of the original client request, if known (e.g. from [Forwarded#proto](https:\/\/developer.mozilla.org\/docs\/Web\/HTTP\/Headers\/Forwarded#proto), [X-Forwarded-Proto](https:\/\/developer.mozilla.org\/docs\/Web\/HTTP\/Headers\/X-Forwarded-Proto), or a similar header). Otherwise, the scheme of the immediate peer request.
--





-- $messaging_attributes_common
-- Common messaging attributes.
--
-- === Attributes
-- - 'messaging_system'
--
--     Requirement level: required
--
-- - 'error_type'
--
--     Requirement level: conditionally required: If and only if the messaging operation has failed.
--
-- - 'server_address'
--
--     Requirement level: conditionally required: If available.
--
--     ==== Note
--     This should be the IP\/hostname of the broker (or other network-level peer) this specific message is sent to\/received from.
--
-- - 'server_port'
--
-- - 'network_protocol_name'
--
--     Requirement level: conditionally required: Only for messaging systems and frameworks that support more than one protocol.
--
-- - 'network_protocol_version'
--







-- $network-core
-- These attributes may be used for any network related operation.
--
-- === Attributes
-- - 'network_transport'
--
-- - 'network_type'
--
-- - 'network_protocol_name'
--
-- - 'network_protocol_version'
--
-- - 'network_peer_address'
--
-- - 'network_peer_port'
--
-- - 'network_local_address'
--
-- - 'network_local_port'
--









-- $network-connection-and-carrier
-- These attributes may be used for any network related operation.
--
-- === Attributes
-- - 'network_connection_type'
--
-- - 'network_connection_subtype'
--
-- - 'network_carrier_name'
--
-- - 'network_carrier_mcc'
--
-- - 'network_carrier_mnc'
--
-- - 'network_carrier_icc'
--







