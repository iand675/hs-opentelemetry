------------------------------------------
-- DO NOT EDIT. THIS FILE IS GENERATED. --
------------------------------------------

{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
-- | This module is OpenTelemetry Semantic Conventions for Haskell.
-- This is automatically generated
-- based on [semantic-conventions](https://github.com/open-telemetry/semantic-conventions/) v1.40.
module OpenTelemetry.SemanticConventions (
-- * entity.webengine
-- $entity_webengine

-- * registry.webengine
-- $registry_webengine

webengine_name,
webengine_version,
webengine_description,
-- * registry.oracle_cloud
-- $registry_oracleCloud

oracleCloud_realm,
-- * opentracing
-- $opentracing

-- * registry.opentracing
-- $registry_opentracing

opentracing_refType,
-- * registry.aspnetcore
-- $registry_aspnetcore

aspnetcore_rateLimiting_policy,
aspnetcore_rateLimiting_result,
aspnetcore_routing_isFallback,
aspnetcore_diagnostics_handler_type,
aspnetcore_request_isUnhandled,
aspnetcore_routing_matchStatus,
aspnetcore_diagnostics_exception_result,
aspnetcore_memoryPool_owner,
aspnetcore_identity_userType,
aspnetcore_authentication_result,
aspnetcore_authentication_scheme,
aspnetcore_user_isAuthenticated,
aspnetcore_authorization_policy,
aspnetcore_authorization_result,
aspnetcore_identity_result,
aspnetcore_identity_errorCode,
aspnetcore_identity_user_updateType,
aspnetcore_identity_passwordCheckResult,
aspnetcore_identity_tokenPurpose,
aspnetcore_identity_tokenVerified,
aspnetcore_identity_signIn_type,
aspnetcore_signIn_isPersistent,
aspnetcore_identity_signIn_result,
-- * aspnetcore.common.rate_limiting.metrics.attributes
-- $aspnetcore_common_rateLimiting_metrics_attributes

-- * aspnetcore.common.authentication.metrics.attributes
-- $aspnetcore_common_authentication_metrics_attributes

-- * aspnetcore.common.identity.metrics.attributes
-- $aspnetcore_common_identity_metrics_attributes

-- * aspnetcore.common.memory_pool.metrics.attributes
-- $aspnetcore_common_memoryPool_metrics_attributes

-- * metric.aspnetcore.routing.match_attempts
-- $metric_aspnetcore_routing_matchAttempts

-- * metric.aspnetcore.diagnostics.exceptions
-- $metric_aspnetcore_diagnostics_exceptions

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

-- * metric.aspnetcore.memory_pool.pooled
-- $metric_aspnetcore_memoryPool_pooled

-- * metric.aspnetcore.memory_pool.allocated
-- $metric_aspnetcore_memoryPool_allocated

-- * metric.aspnetcore.memory_pool.evicted
-- $metric_aspnetcore_memoryPool_evicted

-- * metric.aspnetcore.memory_pool.rented
-- $metric_aspnetcore_memoryPool_rented

-- * metric.aspnetcore.authentication.authenticate.duration
-- $metric_aspnetcore_authentication_authenticate_duration

-- * metric.aspnetcore.authentication.challenges
-- $metric_aspnetcore_authentication_challenges

-- * metric.aspnetcore.authentication.forbids
-- $metric_aspnetcore_authentication_forbids

-- * metric.aspnetcore.authentication.sign_ins
-- $metric_aspnetcore_authentication_signIns

-- * metric.aspnetcore.authentication.sign_outs
-- $metric_aspnetcore_authentication_signOuts

-- * metric.aspnetcore.authorization.attempts
-- $metric_aspnetcore_authorization_attempts

-- * metric.aspnetcore.identity.user.create.duration
-- $metric_aspnetcore_identity_user_create_duration

-- * metric.aspnetcore.identity.user.update.duration
-- $metric_aspnetcore_identity_user_update_duration

-- * metric.aspnetcore.identity.user.delete.duration
-- $metric_aspnetcore_identity_user_delete_duration

-- * metric.aspnetcore.identity.user.check_password_attempts
-- $metric_aspnetcore_identity_user_checkPasswordAttempts

-- * metric.aspnetcore.identity.user.verify_token_attempts
-- $metric_aspnetcore_identity_user_verifyTokenAttempts

-- * metric.aspnetcore.identity.user.generated_tokens
-- $metric_aspnetcore_identity_user_generatedTokens

-- * metric.aspnetcore.identity.sign_in.authenticate.duration
-- $metric_aspnetcore_identity_signIn_authenticate_duration

-- * metric.aspnetcore.identity.sign_in.two_factor_clients_remembered
-- $metric_aspnetcore_identity_signIn_twoFactorClientsRemembered

-- * metric.aspnetcore.identity.sign_in.two_factor_clients_forgotten
-- $metric_aspnetcore_identity_signIn_twoFactorClientsForgotten

-- * metric.aspnetcore.identity.sign_in.check_password_attempts
-- $metric_aspnetcore_identity_signIn_checkPasswordAttempts

-- * metric.aspnetcore.identity.sign_in.sign_ins
-- $metric_aspnetcore_identity_signIn_signIns

-- * metric.aspnetcore.identity.sign_in.sign_outs
-- $metric_aspnetcore_identity_signIn_signOuts

-- * registry.nodejs
-- $registry_nodejs

nodejs_eventloop_state,
-- * metric.nodejs.eventloop.delay.min
-- $metric_nodejs_eventloop_delay_min

-- * metric.nodejs.eventloop.delay.max
-- $metric_nodejs_eventloop_delay_max

-- * metric.nodejs.eventloop.delay.mean
-- $metric_nodejs_eventloop_delay_mean

-- * metric.nodejs.eventloop.delay.stddev
-- $metric_nodejs_eventloop_delay_stddev

-- * metric.nodejs.eventloop.delay.p50
-- $metric_nodejs_eventloop_delay_p50

-- * metric.nodejs.eventloop.delay.p90
-- $metric_nodejs_eventloop_delay_p90

-- * metric.nodejs.eventloop.delay.p99
-- $metric_nodejs_eventloop_delay_p99

-- * metric.nodejs.eventloop.utilization
-- $metric_nodejs_eventloop_utilization

-- * metric.nodejs.eventloop.time
-- $metric_nodejs_eventloop_time

-- * cloudevents
-- $cloudevents

-- * registry.cloudevents
-- $registry_cloudevents

cloudevents_eventId,
cloudevents_eventSource,
cloudevents_eventSpecVersion,
cloudevents_eventType,
cloudevents_eventSubject,
-- * metric_attributes.hw.network
-- $metricAttributes_hw_network

-- * metric.hw.network.bandwidth.limit
-- $metric_hw_network_bandwidth_limit

-- * metric.hw.network.bandwidth.utilization
-- $metric_hw_network_bandwidth_utilization

-- * metric.hw.network.io
-- $metric_hw_network_io

-- * metric.hw.network.packets
-- $metric_hw_network_packets

-- * metric.hw.network.up
-- $metric_hw_network_up

-- * metric_attributes.hw.logical_disk
-- $metricAttributes_hw_logicalDisk

-- * metric.hw.logical_disk.limit
-- $metric_hw_logicalDisk_limit

-- * metric.hw.logical_disk.usage
-- $metric_hw_logicalDisk_usage

-- * metric.hw.logical_disk.utilization
-- $metric_hw_logicalDisk_utilization

-- * metric_attributes.hw.fan
-- $metricAttributes_hw_fan

-- * metric.hw.fan.speed
-- $metric_hw_fan_speed

-- * metric.hw.fan.speed.limit
-- $metric_hw_fan_speed_limit

-- * metric.hw.fan.speed_ratio
-- $metric_hw_fan_speedRatio

-- * metric_attributes.hw.battery
-- $metricAttributes_hw_battery

-- * metric.hw.battery.charge
-- $metric_hw_battery_charge

-- * metric.hw.battery.charge.limit
-- $metric_hw_battery_charge_limit

-- * metric.hw.battery.time_left
-- $metric_hw_battery_timeLeft

-- * metric_attributes.hw.memory
-- $metricAttributes_hw_memory

-- * metric.hw.memory.size
-- $metric_hw_memory_size

-- * metric_attributes.hw.disk_controller
-- $metricAttributes_hw_diskController

-- * metric.hw.host.ambient_temperature
-- $metric_hw_host_ambientTemperature

-- * metric.hw.host.energy
-- $metric_hw_host_energy

-- * metric.hw.host.heating_margin
-- $metric_hw_host_heatingMargin

-- * metric.hw.host.power
-- $metric_hw_host_power

-- * metric_attributes.hw.cpu
-- $metricAttributes_hw_cpu

-- * metric.hw.cpu.speed
-- $metric_hw_cpu_speed

-- * metric.hw.cpu.speed.limit
-- $metric_hw_cpu_speed_limit

-- * metric_attributes.hw.voltage.common
-- $metricAttributes_hw_voltage_common

-- * metric.hw.voltage
-- $metric_hw_voltage

-- * metric.hw.voltage.limit
-- $metric_hw_voltage_limit

-- * metric.hw.voltage.nominal
-- $metric_hw_voltage_nominal

-- * metric_attributes.hw.temperature.common
-- $metricAttributes_hw_temperature_common

-- * metric.hw.temperature
-- $metric_hw_temperature

-- * metric.hw.temperature.limit
-- $metric_hw_temperature_limit

-- * hardware.attributes.common
-- $hardware_attributes_common

-- * metric_attributes.hw.gpu
-- $metricAttributes_hw_gpu

-- * metric.hw.gpu.io
-- $metric_hw_gpu_io

-- * metric.hw.gpu.memory.limit
-- $metric_hw_gpu_memory_limit

-- * metric.hw.gpu.memory.utilization
-- $metric_hw_gpu_memory_utilization

-- * metric.hw.gpu.memory.usage
-- $metric_hw_gpu_memory_usage

-- * metric.hw.gpu.utilization
-- $metric_hw_gpu_utilization

-- * registry.hardware
-- $registry_hardware

hw_id,
hw_name,
hw_parent,
hw_type,
hw_state,
hw_battery_state,
hw_limitType,
hw_biosVersion,
hw_driverVersion,
hw_firmwareVersion,
hw_model,
hw_serialNumber,
hw_vendor,
hw_sensorLocation,
hw_battery_chemistry,
hw_battery_capacity,
hw_enclosure_type,
hw_gpu_task,
hw_logicalDisk_raidLevel,
hw_logicalDisk_state,
hw_memory_type,
hw_network_logicalAddresses,
hw_network_physicalAddress,
hw_physicalDisk_type,
hw_physicalDisk_state,
hw_physicalDisk_smartAttribute,
hw_tapeDrive_operationType,
-- * metric_attributes.hw.power_supply
-- $metricAttributes_hw_powerSupply

-- * metric.hw.power_supply.limit
-- $metric_hw_powerSupply_limit

-- * metric.hw.power_supply.utilization
-- $metric_hw_powerSupply_utilization

-- * metric.hw.power_supply.usage
-- $metric_hw_powerSupply_usage

-- * metric_attributes.hw.attributes
-- $metricAttributes_hw_attributes

-- * metric.hw.energy
-- $metric_hw_energy

-- * metric.hw.errors
-- $metric_hw_errors

-- * metric.hw.power
-- $metric_hw_power

-- * metric.hw.status
-- $metric_hw_status

-- * metric_attributes.hw.tape_drive
-- $metricAttributes_hw_tapeDrive

-- * metric.hw.tape_drive.operations
-- $metric_hw_tapeDrive_operations

-- * metric_attributes.hw.enclosure
-- $metricAttributes_hw_enclosure

-- * metric_attributes.hw.physical_disk
-- $metricAttributes_hw_physicalDisk

-- * metric.hw.physical_disk.endurance_utilization
-- $metric_hw_physicalDisk_enduranceUtilization

-- * metric.hw.physical_disk.size
-- $metric_hw_physicalDisk_size

-- * metric.hw.physical_disk.smart
-- $metric_hw_physicalDisk_smart

-- * registry.go
-- $registry_go

go_memory_type,
-- * metric.go.memory.used
-- $metric_go_memory_used

-- * metric.go.memory.limit
-- $metric_go_memory_limit

-- * metric.go.memory.allocated
-- $metric_go_memory_allocated

-- * metric.go.memory.allocations
-- $metric_go_memory_allocations

-- * metric.go.memory.gc.goal
-- $metric_go_memory_gc_goal

-- * metric.go.goroutine.count
-- $metric_go_goroutine_count

-- * metric.go.processor.limit
-- $metric_go_processor_limit

-- * metric.go.schedule.duration
-- $metric_go_schedule_duration

-- * metric.go.config.gogc
-- $metric_go_config_gogc

-- * entity.host
-- $entity_host

-- * entity.host.cpu
-- $entity_host_cpu

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
-- * entity.app
-- $entity_app

-- * registry.app
-- $registry_app

app_installation_id,
app_jank_frameCount,
app_jank_threshold,
app_jank_period,
app_screen_coordinate_x,
app_screen_coordinate_y,
app_screen_id,
app_screen_name,
app_widget_id,
app_widget_name,
app_buildId,
-- * event.app.screen.click
-- $event_app_screen_click

-- * event.app.widget.click
-- $event_app_widget_click

-- * event.app.jank
-- $event_app_jank

-- * entity.heroku
-- $entity_heroku

-- * registry.heroku
-- $registry_heroku

heroku_release_creationTimestamp,
heroku_release_commit,
heroku_app_id,
-- * registry.test
-- $registry_test

test_suite_name,
test_suite_run_status,
test_case_name,
test_case_result_status,
-- * registry.nfs
-- $registry_nfs

nfs_server_repcache_status,
nfs_operation_name,
-- * metric.nfs.client.net.count
-- $metric_nfs_client_net_count

-- * metric.nfs.client.net.tcp.connection.accepted
-- $metric_nfs_client_net_tcp_connection_accepted

-- * metric.nfs.client.rpc.count
-- $metric_nfs_client_rpc_count

-- * metric.nfs.client.rpc.retransmit.count
-- $metric_nfs_client_rpc_retransmit_count

-- * metric.nfs.client.rpc.authrefresh.count
-- $metric_nfs_client_rpc_authrefresh_count

-- * metric.nfs.client.operation.count
-- $metric_nfs_client_operation_count

-- * metric.nfs.client.procedure.count
-- $metric_nfs_client_procedure_count

-- * metric.nfs.server.repcache.requests
-- $metric_nfs_server_repcache_requests

-- * metric.nfs.server.fh.stale.count
-- $metric_nfs_server_fh_stale_count

-- * metric.nfs.server.io
-- $metric_nfs_server_io

-- * metric.nfs.server.thread.count
-- $metric_nfs_server_thread_count

-- * metric.nfs.server.net.count
-- $metric_nfs_server_net_count

-- * metric.nfs.server.net.tcp.connection.accepted
-- $metric_nfs_server_net_tcp_connection_accepted

-- * metric.nfs.server.rpc.count
-- $metric_nfs_server_rpc_count

-- * metric.nfs.server.operation.count
-- $metric_nfs_server_operation_count

-- * metric.nfs.server.procedure.count
-- $metric_nfs_server_procedure_count

-- * pprof
-- $pprof

-- * registry.pprof
-- $registry_pprof

pprof_mapping_hasFunctions,
pprof_mapping_hasFilenames,
pprof_mapping_hasLineNumbers,
pprof_mapping_hasInlineFrames,
pprof_location_isFolded,
pprof_profile_comment,
pprof_profile_dropFrames,
pprof_profile_keepFrames,
pprof_profile_docUrl,
pprof_scope_defaultSampleType,
pprof_scope_sampleTypeOrder,
-- * registry.file
-- $registry_file

file_accessed,
file_attributes,
file_created,
file_changed,
file_directory,
file_extension,
file_forkName,
file_group_id,
file_group_name,
file_inode,
file_mode,
file_modified,
file_name,
file_owner_id,
file_owner_name,
file_path,
file_size,
file_symbolicLink_targetPath,
-- * metric.cpu.time
-- $metric_cpu_time

-- * metric.cpu.utilization
-- $metric_cpu_utilization

-- * metric.cpu.frequency
-- $metric_cpu_frequency

-- * registry.cpu
-- $registry_cpu

cpu_mode,
cpu_logicalNumber,
-- * registry.azure.client.sdk
-- $registry_azure_client_sdk

azure_service_request_id,
azure_resourceProvider_namespace,
azure_client_id,
-- * registry.azure.cosmosdb
-- $registry_azure_cosmosdb

azure_cosmosdb_connection_mode,
azure_cosmosdb_operation_requestCharge,
azure_cosmosdb_request_body_size,
azure_cosmosdb_operation_contactedRegions,
azure_cosmosdb_response_subStatusCode,
azure_cosmosdb_consistency_level,
-- * metric.azure.cosmosdb.client.operation.request_charge
-- $metric_azure_cosmosdb_client_operation_requestCharge

-- * metric.azure.cosmosdb.client.active_instance.count
-- $metric_azure_cosmosdb_client_activeInstance_count

-- * event.azure.resource.log
-- $event_azure_resource_log

-- * registry.azure.deprecated
-- $registry_azure_deprecated

az_serviceRequestId,
az_namespace,
-- * event.az.resource.log
-- $event_az_resource_log

-- * registry.signalr
-- $registry_signalr

signalr_connection_status,
signalr_transport,
-- * metric.signalr.server.connection.duration
-- $metric_signalr_server_connection_duration

-- * metric.signalr.server.active_connections
-- $metric_signalr_server_activeConnections

-- * entity.cloudfoundry.system
-- $entity_cloudfoundry_system

-- * entity.cloudfoundry.app
-- $entity_cloudfoundry_app

-- * entity.cloudfoundry.space
-- $entity_cloudfoundry_space

-- * entity.cloudfoundry.org
-- $entity_cloudfoundry_org

-- * entity.cloudfoundry.process
-- $entity_cloudfoundry_process

-- * registry.cloudfoundry
-- $registry_cloudfoundry

cloudfoundry_system_id,
cloudfoundry_system_instance_id,
cloudfoundry_app_name,
cloudfoundry_app_id,
cloudfoundry_app_instance_id,
cloudfoundry_space_name,
cloudfoundry_space_id,
cloudfoundry_org_name,
cloudfoundry_org_id,
cloudfoundry_process_id,
cloudfoundry_process_type,
-- * registry.user_agent
-- $registry_userAgent

userAgent_original,
userAgent_name,
userAgent_version,
-- * registry.user_agent.os
-- $registry_userAgent_os

userAgent_os_name,
userAgent_os_version,
userAgent_synthetic_type,
-- * entity.k8s.cluster
-- $entity_k8s_cluster

-- * entity.k8s.node
-- $entity_k8s_node

-- * entity.k8s.namespace
-- $entity_k8s_namespace

-- * entity.k8s.pod
-- $entity_k8s_pod

-- * entity.k8s.container
-- $entity_k8s_container

-- * entity.k8s.replicaset
-- $entity_k8s_replicaset

-- * entity.k8s.deployment
-- $entity_k8s_deployment

-- * entity.k8s.statefulset
-- $entity_k8s_statefulset

-- * entity.k8s.daemonset
-- $entity_k8s_daemonset

-- * entity.k8s.job
-- $entity_k8s_job

-- * entity.k8s.cronjob
-- $entity_k8s_cronjob

-- * entity.k8s.replicationcontroller
-- $entity_k8s_replicationcontroller

-- * entity.k8s.hpa
-- $entity_k8s_hpa

-- * entity.k8s.resourcequota
-- $entity_k8s_resourcequota

-- * entity.k8s.service
-- $entity_k8s_service

-- * registry.k8s
-- $registry_k8s

k8s_cluster_name,
k8s_cluster_uid,
k8s_node_name,
k8s_node_uid,
k8s_node_label,
k8s_node_annotation,
k8s_namespace_name,
k8s_namespace_label,
k8s_namespace_annotation,
k8s_pod_uid,
k8s_pod_name,
k8s_pod_ip,
k8s_pod_hostname,
k8s_pod_startTime,
k8s_pod_label,
k8s_pod_annotation,
k8s_container_name,
k8s_container_restartCount,
k8s_container_status_lastTerminatedReason,
k8s_replicaset_uid,
k8s_replicaset_name,
k8s_replicaset_label,
k8s_replicaset_annotation,
k8s_replicationcontroller_uid,
k8s_replicationcontroller_name,
k8s_resourcequota_uid,
k8s_resourcequota_name,
k8s_deployment_uid,
k8s_deployment_name,
k8s_deployment_label,
k8s_deployment_annotation,
k8s_statefulset_uid,
k8s_statefulset_name,
k8s_statefulset_label,
k8s_statefulset_annotation,
k8s_daemonset_uid,
k8s_daemonset_name,
k8s_daemonset_label,
k8s_daemonset_annotation,
k8s_hpa_uid,
k8s_hpa_name,
k8s_hpa_scaletargetref_kind,
k8s_hpa_scaletargetref_name,
k8s_hpa_scaletargetref_apiVersion,
k8s_hpa_metric_type,
k8s_job_uid,
k8s_job_name,
k8s_job_label,
k8s_job_annotation,
k8s_cronjob_uid,
k8s_cronjob_name,
k8s_cronjob_label,
k8s_cronjob_annotation,
k8s_volume_name,
k8s_volume_type,
k8s_namespace_phase,
k8s_node_condition_type,
k8s_node_condition_status,
k8s_container_status_state,
k8s_container_status_reason,
k8s_hugepage_size,
k8s_storageclass_name,
k8s_resourcequota_resourceName,
k8s_pod_status_reason,
k8s_pod_status_phase,
k8s_service_uid,
k8s_service_name,
k8s_service_type,
k8s_service_trafficDistribution,
k8s_service_selector,
k8s_service_label,
k8s_service_annotation,
k8s_service_publishNotReadyAddresses,
k8s_service_endpoint_condition,
k8s_service_endpoint_addressType,
k8s_service_endpoint_zone,
-- * metric.k8s.pod.uptime
-- $metric_k8s_pod_uptime

-- * metric.k8s.pod.status.reason
-- $metric_k8s_pod_status_reason

-- * metric.k8s.pod.status.phase
-- $metric_k8s_pod_status_phase

-- * metric.k8s.pod.cpu.time
-- $metric_k8s_pod_cpu_time

-- * metric.k8s.pod.cpu.usage
-- $metric_k8s_pod_cpu_usage

-- * metric.k8s.pod.memory.usage
-- $metric_k8s_pod_memory_usage

-- * metric.k8s.pod.memory.available
-- $metric_k8s_pod_memory_available

-- * metric.k8s.pod.memory.rss
-- $metric_k8s_pod_memory_rss

-- * metric.k8s.pod.memory.working_set
-- $metric_k8s_pod_memory_workingSet

-- * metric.k8s.pod.memory.paging.faults
-- $metric_k8s_pod_memory_paging_faults

-- * metric.k8s.pod.network.io
-- $metric_k8s_pod_network_io

-- * metric.k8s.pod.network.errors
-- $metric_k8s_pod_network_errors

-- * metric.k8s.pod.filesystem.available
-- $metric_k8s_pod_filesystem_available

-- * metric.k8s.pod.filesystem.capacity
-- $metric_k8s_pod_filesystem_capacity

-- * metric.k8s.pod.filesystem.usage
-- $metric_k8s_pod_filesystem_usage

-- * metric.k8s.pod.volume.available
-- $metric_k8s_pod_volume_available

-- * metric.k8s.pod.volume.capacity
-- $metric_k8s_pod_volume_capacity

-- * metric.k8s.pod.volume.usage
-- $metric_k8s_pod_volume_usage

-- * metric.k8s.pod.volume.inode.count
-- $metric_k8s_pod_volume_inode_count

-- * metric.k8s.pod.volume.inode.used
-- $metric_k8s_pod_volume_inode_used

-- * metric.k8s.pod.volume.inode.free
-- $metric_k8s_pod_volume_inode_free

-- * metric.k8s.container.status.state
-- $metric_k8s_container_status_state

-- * metric.k8s.container.status.reason
-- $metric_k8s_container_status_reason

-- * metric.k8s.node.uptime
-- $metric_k8s_node_uptime

-- * metric.k8s.node.cpu.allocatable
-- $metric_k8s_node_cpu_allocatable

-- * metric.k8s.node.ephemeral_storage.allocatable
-- $metric_k8s_node_ephemeralStorage_allocatable

-- * metric.k8s.node.memory.allocatable
-- $metric_k8s_node_memory_allocatable

-- * metric.k8s.node.pod.allocatable
-- $metric_k8s_node_pod_allocatable

-- * metric.k8s.node.condition.status
-- $metric_k8s_node_condition_status

-- * metric.k8s.node.cpu.time
-- $metric_k8s_node_cpu_time

-- * metric.k8s.node.cpu.usage
-- $metric_k8s_node_cpu_usage

-- * metric.k8s.node.filesystem.available
-- $metric_k8s_node_filesystem_available

-- * metric.k8s.node.filesystem.capacity
-- $metric_k8s_node_filesystem_capacity

-- * metric.k8s.node.filesystem.usage
-- $metric_k8s_node_filesystem_usage

-- * metric.k8s.node.memory.usage
-- $metric_k8s_node_memory_usage

-- * metric.k8s.node.memory.available
-- $metric_k8s_node_memory_available

-- * metric.k8s.node.memory.rss
-- $metric_k8s_node_memory_rss

-- * metric.k8s.node.memory.working_set
-- $metric_k8s_node_memory_workingSet

-- * metric.k8s.node.memory.paging.faults
-- $metric_k8s_node_memory_paging_faults

-- * metric.k8s.node.network.io
-- $metric_k8s_node_network_io

-- * metric.k8s.node.network.errors
-- $metric_k8s_node_network_errors

-- * metric.k8s.deployment.pod.desired
-- $metric_k8s_deployment_pod_desired

-- * metric.k8s.deployment.pod.available
-- $metric_k8s_deployment_pod_available

-- * metric.k8s.replicaset.pod.desired
-- $metric_k8s_replicaset_pod_desired

-- * metric.k8s.replicaset.pod.available
-- $metric_k8s_replicaset_pod_available

-- * metric.k8s.replicationcontroller.pod.desired
-- $metric_k8s_replicationcontroller_pod_desired

-- * metric.k8s.replicationcontroller.pod.available
-- $metric_k8s_replicationcontroller_pod_available

-- * metric.k8s.statefulset.pod.desired
-- $metric_k8s_statefulset_pod_desired

-- * metric.k8s.statefulset.pod.ready
-- $metric_k8s_statefulset_pod_ready

-- * metric.k8s.statefulset.pod.current
-- $metric_k8s_statefulset_pod_current

-- * metric.k8s.statefulset.pod.updated
-- $metric_k8s_statefulset_pod_updated

-- * metric.k8s.hpa.pod.desired
-- $metric_k8s_hpa_pod_desired

-- * metric.k8s.hpa.pod.current
-- $metric_k8s_hpa_pod_current

-- * metric.k8s.hpa.pod.max
-- $metric_k8s_hpa_pod_max

-- * metric.k8s.hpa.pod.min
-- $metric_k8s_hpa_pod_min

-- * metric.k8s.hpa.metric.target.cpu.value
-- $metric_k8s_hpa_metric_target_cpu_value

-- * metric.k8s.hpa.metric.target.cpu.average_value
-- $metric_k8s_hpa_metric_target_cpu_averageValue

-- * metric.k8s.hpa.metric.target.cpu.average_utilization
-- $metric_k8s_hpa_metric_target_cpu_averageUtilization

-- * metric.k8s.daemonset.node.current_scheduled
-- $metric_k8s_daemonset_node_currentScheduled

-- * metric.k8s.daemonset.node.desired_scheduled
-- $metric_k8s_daemonset_node_desiredScheduled

-- * metric.k8s.daemonset.node.misscheduled
-- $metric_k8s_daemonset_node_misscheduled

-- * metric.k8s.daemonset.node.ready
-- $metric_k8s_daemonset_node_ready

-- * metric.k8s.job.pod.active
-- $metric_k8s_job_pod_active

-- * metric.k8s.job.pod.failed
-- $metric_k8s_job_pod_failed

-- * metric.k8s.job.pod.successful
-- $metric_k8s_job_pod_successful

-- * metric.k8s.job.pod.desired_successful
-- $metric_k8s_job_pod_desiredSuccessful

-- * metric.k8s.job.pod.max_parallel
-- $metric_k8s_job_pod_maxParallel

-- * metric.k8s.cronjob.job.active
-- $metric_k8s_cronjob_job_active

-- * metric.k8s.namespace.phase
-- $metric_k8s_namespace_phase

-- * metric.k8s.container.cpu.limit
-- $metric_k8s_container_cpu_limit

-- * metric.k8s.container.cpu.request
-- $metric_k8s_container_cpu_request

-- * metric.k8s.container.memory.limit
-- $metric_k8s_container_memory_limit

-- * metric.k8s.container.memory.request
-- $metric_k8s_container_memory_request

-- * metric.k8s.container.storage.limit
-- $metric_k8s_container_storage_limit

-- * metric.k8s.container.storage.request
-- $metric_k8s_container_storage_request

-- * metric.k8s.container.ephemeral_storage.limit
-- $metric_k8s_container_ephemeralStorage_limit

-- * metric.k8s.container.ephemeral_storage.request
-- $metric_k8s_container_ephemeralStorage_request

-- * metric.k8s.container.restart.count
-- $metric_k8s_container_restart_count

-- * metric.k8s.container.ready
-- $metric_k8s_container_ready

-- * metric.k8s.container.cpu.limit_utilization
-- $metric_k8s_container_cpu_limitUtilization

-- * metric.k8s.container.cpu.request_utilization
-- $metric_k8s_container_cpu_requestUtilization

-- * metric.k8s.resourcequota.cpu.limit.hard
-- $metric_k8s_resourcequota_cpu_limit_hard

-- * metric.k8s.resourcequota.cpu.limit.used
-- $metric_k8s_resourcequota_cpu_limit_used

-- * metric.k8s.resourcequota.cpu.request.hard
-- $metric_k8s_resourcequota_cpu_request_hard

-- * metric.k8s.resourcequota.cpu.request.used
-- $metric_k8s_resourcequota_cpu_request_used

-- * metric.k8s.resourcequota.memory.limit.hard
-- $metric_k8s_resourcequota_memory_limit_hard

-- * metric.k8s.resourcequota.memory.limit.used
-- $metric_k8s_resourcequota_memory_limit_used

-- * metric.k8s.resourcequota.memory.request.hard
-- $metric_k8s_resourcequota_memory_request_hard

-- * metric.k8s.resourcequota.memory.request.used
-- $metric_k8s_resourcequota_memory_request_used

-- * metric.k8s.resourcequota.hugepage_count.request.hard
-- $metric_k8s_resourcequota_hugepageCount_request_hard

-- * metric.k8s.resourcequota.hugepage_count.request.used
-- $metric_k8s_resourcequota_hugepageCount_request_used

-- * metric.k8s.resourcequota.storage.request.hard
-- $metric_k8s_resourcequota_storage_request_hard

-- * metric.k8s.resourcequota.storage.request.used
-- $metric_k8s_resourcequota_storage_request_used

-- * metric.k8s.resourcequota.persistentvolumeclaim_count.hard
-- $metric_k8s_resourcequota_persistentvolumeclaimCount_hard

-- * metric.k8s.resourcequota.persistentvolumeclaim_count.used
-- $metric_k8s_resourcequota_persistentvolumeclaimCount_used

-- * metric.k8s.resourcequota.ephemeral_storage.request.hard
-- $metric_k8s_resourcequota_ephemeralStorage_request_hard

-- * metric.k8s.resourcequota.ephemeral_storage.request.used
-- $metric_k8s_resourcequota_ephemeralStorage_request_used

-- * metric.k8s.resourcequota.ephemeral_storage.limit.hard
-- $metric_k8s_resourcequota_ephemeralStorage_limit_hard

-- * metric.k8s.resourcequota.ephemeral_storage.limit.used
-- $metric_k8s_resourcequota_ephemeralStorage_limit_used

-- * metric.k8s.resourcequota.object_count.hard
-- $metric_k8s_resourcequota_objectCount_hard

-- * metric.k8s.resourcequota.object_count.used
-- $metric_k8s_resourcequota_objectCount_used

-- * metric.k8s.service.endpoint.count
-- $metric_k8s_service_endpoint_count

-- * metric.k8s.service.load_balancer.ingress.count
-- $metric_k8s_service_loadBalancer_ingress_count

-- * registry.k8s.deprecated
-- $registry_k8s_deprecated

k8s_pod_labels,
-- * metric.k8s.replication_controller.desired_pods
-- $metric_k8s_replicationController_desiredPods

-- * metric.k8s.replication_controller.available_pods
-- $metric_k8s_replicationController_availablePods

-- * metric.k8s.replicationcontroller.desired_pods
-- $metric_k8s_replicationcontroller_desiredPods

-- * metric.k8s.daemonset.current_scheduled_nodes
-- $metric_k8s_daemonset_currentScheduledNodes

-- * metric.k8s.daemonset.desired_scheduled_nodes
-- $metric_k8s_daemonset_desiredScheduledNodes

-- * metric.k8s.daemonset.misscheduled_nodes
-- $metric_k8s_daemonset_misscheduledNodes

-- * metric.k8s.daemonset.ready_nodes
-- $metric_k8s_daemonset_readyNodes

-- * metric.k8s.job.active_pods
-- $metric_k8s_job_activePods

-- * metric.k8s.job.failed_pods
-- $metric_k8s_job_failedPods

-- * metric.k8s.job.successful_pods
-- $metric_k8s_job_successfulPods

-- * metric.k8s.job.desired_successful_pods
-- $metric_k8s_job_desiredSuccessfulPods

-- * metric.k8s.job.max_parallel_pods
-- $metric_k8s_job_maxParallelPods

-- * metric.k8s.cronjob.active_jobs
-- $metric_k8s_cronjob_activeJobs

-- * metric.k8s.replicationcontroller.available_pods
-- $metric_k8s_replicationcontroller_availablePods

-- * metric.k8s.node.allocatable.pods
-- $metric_k8s_node_allocatable_pods

-- * metric.k8s.deployment.desired_pods
-- $metric_k8s_deployment_desiredPods

-- * metric.k8s.deployment.available_pods
-- $metric_k8s_deployment_availablePods

-- * metric.k8s.replicaset.desired_pods
-- $metric_k8s_replicaset_desiredPods

-- * metric.k8s.replicaset.available_pods
-- $metric_k8s_replicaset_availablePods

-- * metric.k8s.statefulset.desired_pods
-- $metric_k8s_statefulset_desiredPods

-- * metric.k8s.statefulset.ready_pods
-- $metric_k8s_statefulset_readyPods

-- * metric.k8s.statefulset.current_pods
-- $metric_k8s_statefulset_currentPods

-- * metric.k8s.statefulset.updated_pods
-- $metric_k8s_statefulset_updatedPods

-- * metric.k8s.hpa.desired_pods
-- $metric_k8s_hpa_desiredPods

-- * metric.k8s.hpa.current_pods
-- $metric_k8s_hpa_currentPods

-- * metric.k8s.hpa.max_pods
-- $metric_k8s_hpa_maxPods

-- * metric.k8s.hpa.min_pods
-- $metric_k8s_hpa_minPods

-- * metric.k8s.node.allocatable.cpu
-- $metric_k8s_node_allocatable_cpu

-- * metric.k8s.node.allocatable.ephemeral_storage
-- $metric_k8s_node_allocatable_ephemeralStorage

-- * metric.k8s.node.allocatable.memory
-- $metric_k8s_node_allocatable_memory

-- * registry.enduser
-- $registry_enduser

enduser_id,
enduser_pseudo_id,
-- * registry.enduser.deprecated
-- $registry_enduser_deprecated

enduser_role,
enduser_scope,
-- * registry.v8js
-- $registry_v8js

v8js_gc_type,
v8js_heap_space_name,
-- * metric.v8js.gc.duration
-- $metric_v8js_gc_duration

-- * metric.v8js.memory.heap.limit
-- $metric_v8js_memory_heap_limit

-- * metric.v8js.memory.heap.used
-- $metric_v8js_memory_heap_used

-- * metric.v8js.memory.heap.space.available_size
-- $metric_v8js_memory_heap_space_availableSize

-- * metric.v8js.memory.heap.space.physical_size
-- $metric_v8js_memory_heap_space_physicalSize

-- * metric.v8js.heap.space.available_size
-- $metric_v8js_heap_space_availableSize

-- * metric.v8js.heap.space.physical_size
-- $metric_v8js_heap_space_physicalSize

-- * registry.feature_flag
-- $registry_featureFlag

featureFlag_key,
featureFlag_provider_name,
featureFlag_result_variant,
featureFlag_context_id,
featureFlag_version,
featureFlag_set_id,
featureFlag_result_reason,
featureFlag_result_value,
featureFlag_error_message,
-- * event.feature_flag.evaluation
-- $event_featureFlag_evaluation

-- * registry.feature_flag.deprecated
-- $registry_featureFlag_deprecated

featureFlag_providerName,
featureFlag_evaluation_reason,
featureFlag_variant,
featureFlag_evaluation_error_message,
-- * registry.jsonrpc
-- $registry_jsonrpc

jsonrpc_request_id,
jsonrpc_protocol_version,
-- * source
-- $source

-- * registry.source
-- $registry_source

source_address,
source_port,
-- * network-core
-- $network-core

-- * network-connection-and-carrier
-- $network-connection-and-carrier

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
network_interface_name,
network_connection_state,
-- * registry.network.deprecated
-- $registry_network_deprecated

net_sock_peer_name,
net_sock_peer_addr,
net_sock_peer_port,
net_peer_name,
net_peer_port,
net_peer_ip,
net_host_name,
net_host_ip,
net_host_port,
net_sock_host_addr,
net_sock_host_port,
net_transport,
net_protocol_name,
net_protocol_version,
net_sock_family,
-- * entity.faas
-- $entity_faas

-- * faas.attributes
-- $faas_attributes

-- * span.faas.datasource.server
-- $span_faas_datasource_server

-- * span.faas.timer.server
-- $span_faas_timer_server

-- * span.faas.server
-- $span_faas_server

-- * span.faas.client
-- $span_faas_client

-- * attributes.faas.common
-- $attributes_faas_common

-- * registry.faas
-- $registry_faas

faas_name,
faas_version,
faas_instance,
faas_maxMemory,
faas_trigger,
faas_invokedName,
faas_invokedProvider,
faas_invokedRegion,
faas_invocationId,
faas_time,
faas_cron,
faas_coldstart,
faas_document_collection,
faas_document_operation,
faas_document_time,
faas_document_name,
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

-- * registry.geo
-- $registry_geo

geo_locality_name,
geo_continent_code,
geo_country_isoCode,
geo_location_lon,
geo_location_lat,
geo_postalCode,
geo_region_isoCode,
-- * registry.security_rule
-- $registry_securityRule

securityRule_category,
securityRule_description,
securityRule_license,
securityRule_name,
securityRule_reference,
securityRule_ruleset_name,
securityRule_uuid,
securityRule_version,
-- * registry.code.deprecated
-- $registry_code_deprecated

code_function,
code_filepath,
code_lineno,
code_column,
code_namespace,
-- * code
-- $code

-- * registry.code
-- $registry_code

code_function_name,
code_file_path,
code_line_number,
code_column_number,
code_stacktrace,
-- * metric.jvm.memory.init
-- $metric_jvm_memory_init

-- * metric.jvm.system.cpu.utilization
-- $metric_jvm_system_cpu_utilization

-- * metric.jvm.system.cpu.load_1m
-- $metric_jvm_system_cpu_load1m

-- * attributes.jvm.buffer
-- $attributes_jvm_buffer

-- * metric.jvm.buffer.memory.used
-- $metric_jvm_buffer_memory_used

-- * metric.jvm.buffer.memory.limit
-- $metric_jvm_buffer_memory_limit

-- * metric.jvm.buffer.count
-- $metric_jvm_buffer_count

-- * metric.jvm.file_descriptor.count
-- $metric_jvm_fileDescriptor_count

-- * metric.jvm.file_descriptor.limit
-- $metric_jvm_fileDescriptor_limit

-- * registry.jvm
-- $registry_jvm

jvm_gc_action,
jvm_gc_cause,
jvm_gc_name,
jvm_memory_type,
jvm_memory_pool_name,
jvm_thread_daemon,
jvm_thread_state,
jvm_buffer_pool_name,
-- * attributes.jvm.memory
-- $attributes_jvm_memory

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

-- * metric.jvm.thread.count
-- $metric_jvm_thread_count

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

-- * metric.jvm.buffer.memory.usage
-- $metric_jvm_buffer_memory_usage

-- * registry.oci.manifest
-- $registry_oci_manifest

oci_manifest_digest,
-- * server
-- $server

-- * registry.server
-- $registry_server

server_address,
server_port,
-- * registry.user
-- $registry_user

user_email,
user_fullName,
user_hash,
user_id,
user_name,
user_roles,
-- * trace.mcp.common.attributes
-- $trace_mcp_common_attributes

-- * span.mcp.client
-- $span_mcp_client

-- * span.mcp.server
-- $span_mcp_server

-- * mcp.common.attributes
-- $mcp_common_attributes

-- * registry.mcp
-- $registry_mcp

mcp_method_name,
mcp_session_id,
mcp_resource_uri,
mcp_protocol_version,
-- * mcp.operation.metrics.attributes
-- $mcp_operation_metrics_attributes

-- * mcp.session.metrics.attributes
-- $mcp_session_metrics_attributes

-- * metric.mcp.client.operation.duration
-- $metric_mcp_client_operation_duration

-- * metric.mcp.server.operation.duration
-- $metric_mcp_server_operation_duration

-- * metric.mcp.client.session.duration
-- $metric_mcp_client_session_duration

-- * metric.mcp.server.session.duration
-- $metric_mcp_server_session_duration

-- * destination
-- $destination

-- * registry.destination
-- $registry_destination

destination_address,
destination_port,
-- * otel_span
-- $otelSpan

-- * registry.otel
-- $registry_otel

otel_statusCode,
otel_statusDescription,
otel_span_samplingResult,
otel_span_parent_origin,
-- * registry.otel.scope
-- $registry_otel_scope

otel_scope_name,
otel_scope_version,
otel_scope_schemaUrl,
-- * registry.otel.event
-- $registry_otel_event

otel_event_name,
-- * registry.otel.component
-- $registry_otel_component

otel_component_type,
otel_component_name,
-- * metric.otel.sdk.span.live
-- $metric_otel_sdk_span_live

-- * metric.otel.sdk.span.started
-- $metric_otel_sdk_span_started

-- * metric.otel.sdk.processor.span.queue.size
-- $metric_otel_sdk_processor_span_queue_size

-- * metric.otel.sdk.processor.span.queue.capacity
-- $metric_otel_sdk_processor_span_queue_capacity

-- * metric.otel.sdk.processor.span.processed
-- $metric_otel_sdk_processor_span_processed

-- * metric.otel.sdk.exporter.span.inflight
-- $metric_otel_sdk_exporter_span_inflight

-- * metric.otel.sdk.exporter.span.exported
-- $metric_otel_sdk_exporter_span_exported

-- * metric.otel.sdk.log.created
-- $metric_otel_sdk_log_created

-- * metric.otel.sdk.processor.log.queue.size
-- $metric_otel_sdk_processor_log_queue_size

-- * metric.otel.sdk.processor.log.queue.capacity
-- $metric_otel_sdk_processor_log_queue_capacity

-- * metric.otel.sdk.processor.log.processed
-- $metric_otel_sdk_processor_log_processed

-- * metric.otel.sdk.exporter.log.inflight
-- $metric_otel_sdk_exporter_log_inflight

-- * metric.otel.sdk.exporter.log.exported
-- $metric_otel_sdk_exporter_log_exported

-- * metric.otel.sdk.exporter.metric_data_point.inflight
-- $metric_otel_sdk_exporter_metricDataPoint_inflight

-- * metric.otel.sdk.exporter.metric_data_point.exported
-- $metric_otel_sdk_exporter_metricDataPoint_exported

-- * metric.otel.sdk.metric_reader.collection.duration
-- $metric_otel_sdk_metricReader_collection_duration

-- * metric.otel.sdk.exporter.operation.duration
-- $metric_otel_sdk_exporter_operation_duration

-- * registry.otel.library.deprecated
-- $registry_otel_library_deprecated

otel_library_name,
otel_library_version,
-- * entity.otel.scope
-- $entity_otel_scope

-- * metric.otel.sdk.span.live.count
-- $metric_otel_sdk_span_live_count

-- * metric.otel.sdk.span.ended.count
-- $metric_otel_sdk_span_ended_count

-- * metric.otel.sdk.processor.span.processed.count
-- $metric_otel_sdk_processor_span_processed_count

-- * metric.otel.sdk.exporter.span.inflight.count
-- $metric_otel_sdk_exporter_span_inflight_count

-- * metric.otel.sdk.exporter.span.exported.count
-- $metric_otel_sdk_exporter_span_exported_count

-- * metric.otel.sdk.span.ended
-- $metric_otel_sdk_span_ended

-- * attributes.cli.common
-- $attributes_cli_common

-- * span.cli.internal
-- $span_cli_internal

-- * span.cli.client
-- $span_cli_client

-- * entity.gcp.gce
-- $entity_gcp_gce

-- * entity.gcp.gce.instance_group_manager
-- $entity_gcp_gce_instanceGroupManager

-- * entity.gcp.cloud_run
-- $entity_gcp_cloudRun

-- * entity.gcp.apphub.application
-- $entity_gcp_apphub_application

-- * entity.gcp.apphub.service
-- $entity_gcp_apphub_service

-- * entity.gcp.apphub.workload
-- $entity_gcp_apphub_workload

-- * registry.gcp.client
-- $registry_gcp_client

gcp_client_service,
-- * registry.gcp.cloud_run
-- $registry_gcp_cloudRun

gcp_cloudRun_job_execution,
gcp_cloudRun_job_taskIndex,
-- * registry.gcp.apphub
-- $registry_gcp_apphub

gcp_apphub_application_container,
gcp_apphub_application_location,
gcp_apphub_application_id,
gcp_apphub_service_id,
gcp_apphub_service_environmentType,
gcp_apphub_service_criticalityType,
gcp_apphub_workload_id,
gcp_apphub_workload_environmentType,
gcp_apphub_workload_criticalityType,
-- * registry.gcp.apphub_destination
-- $registry_gcp_apphubDestination

gcp_apphubDestination_application_container,
gcp_apphubDestination_application_location,
gcp_apphubDestination_application_id,
gcp_apphubDestination_service_id,
gcp_apphubDestination_service_environmentType,
gcp_apphubDestination_service_criticalityType,
gcp_apphubDestination_workload_id,
gcp_apphubDestination_workload_environmentType,
gcp_apphubDestination_workload_criticalityType,
-- * registry.gcp.gce
-- $registry_gcp_gce

gcp_gce_instance_name,
gcp_gce_instance_hostname,
gcp_gce_instanceGroupManager_name,
gcp_gce_instanceGroupManager_zone,
gcp_gce_instanceGroupManager_region,
-- * gcp.client.attributes
-- $gcp_client_attributes

-- * registry.peer
-- $registry_peer

peer_service,
-- * registry.exception
-- $registry_exception

exception_type,
exception_message,
exception_stacktrace,
-- * log-exception
-- $log-exception

-- * event.exception
-- $event_exception

-- * registry.exception.deprecated
-- $registry_exception_deprecated

exception_escaped,
-- * registry.ios
-- $registry_ios

ios_app_state,
-- * registry.ios.deprecated
-- $registry_ios_deprecated

ios_state,
-- * url
-- $url

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
url_template,
url_topLevelDomain,
-- * span.dotnet.http.request.wait_for_connection.internal
-- $span_dotnet_http_request_waitForConnection_internal

-- * span.dotnet.http.connection_setup.internal
-- $span_dotnet_http_connectionSetup_internal

-- * span.dotnet.socket.connect.internal
-- $span_dotnet_socket_connect_internal

-- * span.dotnet.dns.lookup.internal
-- $span_dotnet_dns_lookup_internal

-- * span.dotnet.tls.handshake.internal
-- $span_dotnet_tls_handshake_internal

-- * registry.dotnet
-- $registry_dotnet

dotnet_gc_heap_generation,
-- * metric.dotnet.process.cpu.count
-- $metric_dotnet_process_cpu_count

-- * metric.dotnet.process.cpu.time
-- $metric_dotnet_process_cpu_time

-- * metric.dotnet.process.memory.working_set
-- $metric_dotnet_process_memory_workingSet

-- * metric.dotnet.gc.collections
-- $metric_dotnet_gc_collections

-- * metric.dotnet.gc.heap.total_allocated
-- $metric_dotnet_gc_heap_totalAllocated

-- * metric.dotnet.gc.last_collection.memory.committed_size
-- $metric_dotnet_gc_lastCollection_memory_committedSize

-- * metric.dotnet.gc.last_collection.heap.size
-- $metric_dotnet_gc_lastCollection_heap_size

-- * metric.dotnet.gc.last_collection.heap.fragmentation.size
-- $metric_dotnet_gc_lastCollection_heap_fragmentation_size

-- * metric.dotnet.gc.pause.time
-- $metric_dotnet_gc_pause_time

-- * metric.dotnet.jit.compiled_il.size
-- $metric_dotnet_jit_compiledIl_size

-- * metric.dotnet.jit.compiled_methods
-- $metric_dotnet_jit_compiledMethods

-- * metric.dotnet.jit.compilation.time
-- $metric_dotnet_jit_compilation_time

-- * metric.dotnet.monitor.lock_contentions
-- $metric_dotnet_monitor_lockContentions

-- * metric.dotnet.thread_pool.thread.count
-- $metric_dotnet_threadPool_thread_count

-- * metric.dotnet.thread_pool.work_item.count
-- $metric_dotnet_threadPool_workItem_count

-- * metric.dotnet.thread_pool.queue.length
-- $metric_dotnet_threadPool_queue_length

-- * metric.dotnet.timer.count
-- $metric_dotnet_timer_count

-- * metric.dotnet.assembly.count
-- $metric_dotnet_assembly_count

-- * metric.dotnet.exceptions
-- $metric_dotnet_exceptions

-- * entity.cicd.pipeline
-- $entity_cicd_pipeline

-- * entity.cicd.pipeline.run
-- $entity_cicd_pipeline_run

-- * entity.cicd.worker
-- $entity_cicd_worker

-- * span.cicd.pipeline.run.server
-- $span_cicd_pipeline_run_server

-- * span.cicd.pipeline.task.internal
-- $span_cicd_pipeline_task_internal

-- * registry.cicd.pipeline
-- $registry_cicd_pipeline

cicd_pipeline_name,
cicd_pipeline_run_id,
cicd_pipeline_run_url_full,
cicd_pipeline_run_state,
cicd_pipeline_task_name,
cicd_pipeline_task_run_id,
cicd_pipeline_task_run_url_full,
cicd_pipeline_task_run_result,
cicd_pipeline_task_type,
cicd_pipeline_result,
cicd_pipeline_action_name,
cicd_worker_id,
cicd_worker_name,
cicd_worker_url_full,
cicd_worker_state,
cicd_system_component,
-- * metric.cicd.pipeline.run.duration
-- $metric_cicd_pipeline_run_duration

-- * metric.cicd.pipeline.run.active
-- $metric_cicd_pipeline_run_active

-- * metric.cicd.worker.count
-- $metric_cicd_worker_count

-- * metric.cicd.pipeline.run.errors
-- $metric_cicd_pipeline_run_errors

-- * metric.cicd.system.errors
-- $metric_cicd_system_errors

-- * entity.container
-- $entity_container

-- * entity.container.image
-- $entity_container_image

-- * entity.container.runtime
-- $entity_container_runtime

-- * registry.container
-- $registry_container

container_name,
container_id,
container_runtime_name,
container_runtime_version,
container_runtime_description,
container_image_name,
container_image_tags,
container_image_id,
container_image_repoDigests,
container_command,
container_commandLine,
container_commandArgs,
container_label,
container_csi_plugin_name,
container_csi_volume_id,
-- * metric.container.uptime
-- $metric_container_uptime

-- * metric.container.cpu.time
-- $metric_container_cpu_time

-- * metric.container.cpu.usage
-- $metric_container_cpu_usage

-- * metric.container.memory.usage
-- $metric_container_memory_usage

-- * metric.container.memory.available
-- $metric_container_memory_available

-- * metric.container.memory.rss
-- $metric_container_memory_rss

-- * metric.container.memory.working_set
-- $metric_container_memory_workingSet

-- * metric.container.memory.paging.faults
-- $metric_container_memory_paging_faults

-- * metric.container.disk.io
-- $metric_container_disk_io

-- * metric.container.network.io
-- $metric_container_network_io

-- * metric.container.filesystem.available
-- $metric_container_filesystem_available

-- * metric.container.filesystem.capacity
-- $metric_container_filesystem_capacity

-- * metric.container.filesystem.usage
-- $metric_container_filesystem_usage

-- * registry.container.deprecated
-- $registry_container_deprecated

container_labels,
container_cpu_state,
container_runtime,
-- * registry.system
-- $registry_system

system_device,
-- * registry.system.memory
-- $registry_system_memory

system_memory_state,
system_memory_linux_slab_state,
-- * registry.system.paging
-- $registry_system_paging

system_paging_state,
system_paging_fault_type,
system_paging_direction,
-- * registry.system.filesystem
-- $registry_system_filesystem

system_filesystem_state,
system_filesystem_type,
system_filesystem_mode,
system_filesystem_mountpoint,
-- * metric.system.uptime
-- $metric_system_uptime

-- * metric.system.cpu.physical.count
-- $metric_system_cpu_physical_count

-- * metric.system.cpu.logical.count
-- $metric_system_cpu_logical_count

-- * metric.system.cpu.time
-- $metric_system_cpu_time

-- * metric.system.cpu.utilization
-- $metric_system_cpu_utilization

-- * metric.system.cpu.frequency
-- $metric_system_cpu_frequency

-- * metric.system.memory.usage
-- $metric_system_memory_usage

-- * metric.system.memory.limit
-- $metric_system_memory_limit

-- * metric.system.memory.utilization
-- $metric_system_memory_utilization

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

-- * metric.system.disk.limit
-- $metric_system_disk_limit

-- * metric.system.filesystem.usage
-- $metric_system_filesystem_usage

-- * metric.system.filesystem.utilization
-- $metric_system_filesystem_utilization

-- * metric.system.filesystem.limit
-- $metric_system_filesystem_limit

-- * metric.system.network.packet.dropped
-- $metric_system_network_packet_dropped

-- * metric.system.network.packet.count
-- $metric_system_network_packet_count

-- * metric.system.network.errors
-- $metric_system_network_errors

-- * metric.system.network.io
-- $metric_system_network_io

-- * metric.system.network.connection.count
-- $metric_system_network_connection_count

-- * metric.system.process.count
-- $metric_system_process_count

-- * metric.system.process.created
-- $metric_system_process_created

-- * metric.system.memory.linux.available
-- $metric_system_memory_linux_available

-- * metric.system.memory.linux.shared
-- $metric_system_memory_linux_shared

-- * metric.system.memory.linux.slab.usage
-- $metric_system_memory_linux_slab_usage

-- * registry.system.deprecated
-- $registry_system_deprecated

system_processes_status,
system_cpu_state,
system_network_state,
system_cpu_logicalNumber,
system_paging_type,
system_process_status,
-- * metric.system.memory.shared
-- $metric_system_memory_shared

-- * metric.system.network.connections
-- $metric_system_network_connections

-- * metric.system.network.dropped
-- $metric_system_network_dropped

-- * metric.system.network.packets
-- $metric_system_network_packets

-- * metric.system.linux.memory.available
-- $metric_system_linux_memory_available

-- * metric.system.linux.memory.slab.usage
-- $metric_system_linux_memory_slab_usage

-- * entity.browser
-- $entity_browser

-- * registry.browser
-- $registry_browser

browser_brands,
browser_platform,
browser_mobile,
browser_language,
-- * event.browser.web_vital
-- $event_browser_webVital

-- * entity.zos.software
-- $entity_zos_software

-- * service.zos.software
-- $service_zos_software

-- * process.zos
-- $process_zos

-- * os.zos
-- $os_zos

-- * host.zos
-- $host_zos

-- * registry.zos
-- $registry_zos

zos_smf_id,
zos_sysplex_name,
-- * registry.cpython
-- $registry_cpython

cpython_gc_generation,
-- * metric.cpython.gc.collections
-- $metric_cpython_gc_collections

-- * metric.cpython.gc.collected_objects
-- $metric_cpython_gc_collectedObjects

-- * metric.cpython.gc.uncollectable_objects
-- $metric_cpython_gc_uncollectableObjects

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
-- * registry.tls.deprecated
-- $registry_tls_deprecated

tls_client_serverName,
-- * entity.openshift.clusterquota
-- $entity_openshift_clusterquota

-- * registry.openshift
-- $registry_openshift

openshift_clusterquota_uid,
openshift_clusterquota_name,
-- * metric.openshift.clusterquota.cpu.limit.hard
-- $metric_openshift_clusterquota_cpu_limit_hard

-- * metric.openshift.clusterquota.cpu.limit.used
-- $metric_openshift_clusterquota_cpu_limit_used

-- * metric.openshift.clusterquota.cpu.request.hard
-- $metric_openshift_clusterquota_cpu_request_hard

-- * metric.openshift.clusterquota.cpu.request.used
-- $metric_openshift_clusterquota_cpu_request_used

-- * metric.openshift.clusterquota.memory.limit.hard
-- $metric_openshift_clusterquota_memory_limit_hard

-- * metric.openshift.clusterquota.memory.limit.used
-- $metric_openshift_clusterquota_memory_limit_used

-- * metric.openshift.clusterquota.memory.request.hard
-- $metric_openshift_clusterquota_memory_request_hard

-- * metric.openshift.clusterquota.memory.request.used
-- $metric_openshift_clusterquota_memory_request_used

-- * metric.openshift.clusterquota.hugepage_count.request.hard
-- $metric_openshift_clusterquota_hugepageCount_request_hard

-- * metric.openshift.clusterquota.hugepage_count.request.used
-- $metric_openshift_clusterquota_hugepageCount_request_used

-- * metric.openshift.clusterquota.storage.request.hard
-- $metric_openshift_clusterquota_storage_request_hard

-- * metric.openshift.clusterquota.storage.request.used
-- $metric_openshift_clusterquota_storage_request_used

-- * metric.openshift.clusterquota.persistentvolumeclaim_count.hard
-- $metric_openshift_clusterquota_persistentvolumeclaimCount_hard

-- * metric.openshift.clusterquota.persistentvolumeclaim_count.used
-- $metric_openshift_clusterquota_persistentvolumeclaimCount_used

-- * metric.openshift.clusterquota.ephemeral_storage.request.hard
-- $metric_openshift_clusterquota_ephemeralStorage_request_hard

-- * metric.openshift.clusterquota.ephemeral_storage.request.used
-- $metric_openshift_clusterquota_ephemeralStorage_request_used

-- * metric.openshift.clusterquota.ephemeral_storage.limit.hard
-- $metric_openshift_clusterquota_ephemeralStorage_limit_hard

-- * metric.openshift.clusterquota.ephemeral_storage.limit.used
-- $metric_openshift_clusterquota_ephemeralStorage_limit_used

-- * metric.openshift.clusterquota.object_count.hard
-- $metric_openshift_clusterquota_objectCount_hard

-- * metric.openshift.clusterquota.object_count.used
-- $metric_openshift_clusterquota_objectCount_used

-- * profile.frame
-- $profile_frame

-- * registry.profile.frame
-- $registry_profile_frame

profile_frame_type,
-- * entity.vcs.repo
-- $entity_vcs_repo

-- * entity.vcs.ref
-- $entity_vcs_ref

-- * registry.vcs.repository
-- $registry_vcs_repository

vcs_repository_url_full,
vcs_repository_name,
vcs_ref_base_name,
vcs_ref_base_type,
vcs_ref_base_revision,
vcs_ref_head_name,
vcs_ref_head_type,
vcs_ref_head_revision,
vcs_ref_type,
vcs_revisionDelta_direction,
vcs_lineChange_type,
vcs_change_title,
vcs_change_id,
vcs_change_state,
vcs_owner_name,
vcs_provider_name,
-- * metric.vcs.change.count
-- $metric_vcs_change_count

-- * metric.vcs.change.duration
-- $metric_vcs_change_duration

-- * metric.vcs.change.time_to_approval
-- $metric_vcs_change_timeToApproval

-- * metric.vcs.change.time_to_merge
-- $metric_vcs_change_timeToMerge

-- * metric.vcs.repository.count
-- $metric_vcs_repository_count

-- * metric.vcs.ref.count
-- $metric_vcs_ref_count

-- * metric.vcs.ref.lines_delta
-- $metric_vcs_ref_linesDelta

-- * metric.vcs.ref.revisions_delta
-- $metric_vcs_ref_revisionsDelta

-- * metric.vcs.ref.time
-- $metric_vcs_ref_time

-- * metric.vcs.contributor.count
-- $metric_vcs_contributor_count

-- * registry.vcs.deprecated
-- $registry_vcs_deprecated

vcs_repository_ref_name,
vcs_repository_ref_type,
vcs_repository_ref_revision,
vcs_repository_change_title,
vcs_repository_change_id,
-- * span.http.client
-- $span_http_client

-- * span.http.server
-- $span_http_server

-- * attributes.http.common
-- $attributes_http_common

-- * attributes.http.client
-- $attributes_http_client

-- * attributes.http.server
-- $attributes_http_server

-- * registry.http
-- $registry_http

http_request_body_size,
http_request_header,
http_request_method,
http_request_methodOriginal,
http_request_resendCount,
http_request_size,
http_response_body_size,
http_response_header,
http_response_size,
http_response_statusCode,
http_route,
http_connection_state,
-- * metric_attributes.http.server
-- $metricAttributes_http_server

-- * metric_attributes.http.client
-- $metricAttributes_http_client

-- * metric_attributes.http.client.experimental
-- $metricAttributes_http_client_experimental

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

-- * metric.http.client.open_connections
-- $metric_http_client_openConnections

-- * metric.http.client.connection.duration
-- $metric_http_client_connection_duration

-- * metric.http.client.active_requests
-- $metric_http_client_activeRequests

-- * event.http.client.request.exception
-- $event_http_client_request_exception

-- * event.http.server.request.exception
-- $event_http_server_request_exception

-- * registry.http.deprecated
-- $registry_http_deprecated

http_method,
http_statusCode,
http_scheme,
http_url,
http_target,
http_requestContentLength,
http_responseContentLength,
http_clientIp,
http_host,
http_requestContentLengthUncompressed,
http_responseContentLengthUncompressed,
http_serverName,
http_flavor,
http_userAgent,
-- * registry.cassandra
-- $registry_cassandra

cassandra_coordinator_dc,
cassandra_coordinator_id,
cassandra_consistency_level,
cassandra_query_idempotent,
cassandra_page_size,
cassandra_speculativeExecution_count,
-- * span.graphql.server
-- $span_graphql_server

-- * registry.graphql
-- $registry_graphql

graphql_operation_name,
graphql_operation_type,
graphql_document,
-- * entity.deployment
-- $entity_deployment

-- * registry.deployment
-- $registry_deployment

deployment_name,
deployment_id,
deployment_status,
deployment_environment_name,
-- * registry.deployment.deprecated
-- $registry_deployment_deprecated

deployment_environment,
-- * registry.linux.deprecated
-- $registry_linux_deprecated

linux_memory_slab_state,
-- * entity.android
-- $entity_android

-- * registry.android
-- $registry_android

android_os_apiLevel,
android_app_state,
-- * registry.android.deprecated
-- $registry_android_deprecated

android_state,
-- * entity.cloud
-- $entity_cloud

-- * registry.cloud
-- $registry_cloud

cloud_provider,
cloud_account_id,
cloud_region,
cloud_resourceId,
cloud_availabilityZone,
cloud_platform,
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

-- * trace.db.common.minimal
-- $trace_db_common_minimal

-- * trace.db.common.query
-- $trace_db_common_query

-- * trace.db.common.query_and_collection
-- $trace_db_common_queryAndCollection

-- * trace.db.common.full
-- $trace_db_common_full

-- * span.db.client
-- $span_db_client

-- * span.db.sql_server.client
-- $span_db_sqlServer_client

-- * span.db.postgresql.client
-- $span_db_postgresql_client

-- * span.db.mysql.client
-- $span_db_mysql_client

-- * span.db.mariadb.client
-- $span_db_mariadb_client

-- * span.db.cassandra.client
-- $span_db_cassandra_client

-- * span.db.hbase.client
-- $span_db_hbase_client

-- * span.db.couchdb.client
-- $span_db_couchdb_client

-- * span.db.redis.client
-- $span_db_redis_client

-- * span.db.mongodb.client
-- $span_db_mongodb_client

-- * span.db.elasticsearch.client
-- $span_db_elasticsearch_client

-- * span.db.sql.client
-- $span_db_sql_client

-- * span.azure.cosmosdb.client
-- $span_azure_cosmosdb_client

-- * span.db.oracledb.client
-- $span_db_oracledb_client

-- * attributes.db.client.minimal
-- $attributes_db_client_minimal

-- * attributes.azure.cosmosdb.minimal
-- $attributes_azure_cosmosdb_minimal

-- * attributes.db.client.with_query
-- $attributes_db_client_withQuery

-- * attributes.db.client.with_query_and_collection
-- $attributes_db_client_withQueryAndCollection

-- * registry.db
-- $registry_db

db_collection_name,
db_namespace,
db_operation_name,
db_query_text,
db_query_parameter,
db_query_summary,
db_storedProcedure_name,
db_operation_parameter,
db_operation_batch_size,
db_response_statusCode,
db_response_returnedRows,
db_system_name,
db_client_connection_state,
db_client_connection_pool_name,
-- * metric.db.client.operation.duration
-- $metric_db_client_operation_duration

-- * metric.db.client.connection.count
-- $metric_db_client_connection_count

-- * metric.db.client.connection.idle.max
-- $metric_db_client_connection_idle_max

-- * metric.db.client.connection.idle.min
-- $metric_db_client_connection_idle_min

-- * metric.db.client.connection.max
-- $metric_db_client_connection_max

-- * metric.db.client.connection.pending_requests
-- $metric_db_client_connection_pendingRequests

-- * metric.db.client.connection.timeouts
-- $metric_db_client_connection_timeouts

-- * metric.db.client.connection.create_time
-- $metric_db_client_connection_createTime

-- * metric.db.client.connection.wait_time
-- $metric_db_client_connection_waitTime

-- * metric.db.client.connection.use_time
-- $metric_db_client_connection_useTime

-- * metric.db.client.response.returned_rows
-- $metric_db_client_response_returnedRows

-- * event.db.client.operation.exception
-- $event_db_client_operation_exception

-- * registry.db.deprecated
-- $registry_db_deprecated

db_connectionString,
db_jdbc_driverClassname,
db_operation,
db_user,
db_statement,
db_cassandra_table,
db_cosmosdb_container,
db_mongodb_collection,
db_sql_table,
db_redis_databaseIndex,
db_name,
db_mssql_instanceName,
db_instance_id,
db_elasticsearch_cluster_name,
db_cosmosdb_statusCode,
db_cosmosdb_operationType,
db_cassandra_coordinator_dc,
db_cassandra_coordinator_id,
db_cassandra_consistencyLevel,
db_cassandra_idempotence,
db_cassandra_pageSize,
db_cassandra_speculativeExecutionCount,
db_cosmosdb_clientId,
db_cosmosdb_connectionMode,
db_cosmosdb_requestCharge,
db_cosmosdb_requestContentLength,
db_cosmosdb_subStatusCode,
db_cosmosdb_consistencyLevel,
db_cosmosdb_regionsContacted,
db_elasticsearch_node_name,
db_elasticsearch_pathParts,
db_system,
-- * registry.db.metrics.deprecated
-- $registry_db_metrics_deprecated

state,
pool_name,
db_client_connections_state,
db_client_connections_pool_name,
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

-- * metric.db.client.cosmosdb.operation.request_charge
-- $metric_db_client_cosmosdb_operation_requestCharge

-- * metric.db.client.cosmosdb.active_instance.count
-- $metric_db_client_cosmosdb_activeInstance_count

-- * log.record
-- $log_record

-- * attributes.log
-- $attributes_log

-- * attributes.log.file
-- $attributes_log_file

-- * registry.log
-- $registry_log

log_iostream,
-- * registry.log.file
-- $registry_log_file

log_file_name,
log_file_path,
log_file_nameResolved,
log_file_pathResolved,
-- * registry.log.record
-- $registry_log_record

log_record_uid,
log_record_original,
-- * registry.disk
-- $registry_disk

disk_io_direction,
-- * registry.artifact
-- $registry_artifact

artifact_filename,
artifact_version,
artifact_purl,
artifact_hash,
artifact_attestation_id,
artifact_attestation_filename,
artifact_attestation_hash,
-- * entity.device
-- $entity_device

-- * registry.device
-- $registry_device

device_id,
device_manufacturer,
device_model_identifier,
device_model_name,
-- * event.device.app.lifecycle
-- $event_device_app_lifecycle

-- * entity.os
-- $entity_os

-- * registry.os
-- $registry_os

os_type,
os_description,
os_name,
os_version,
os_buildId,
-- * entity.aws.log
-- $entity_aws_log

-- * span.aws.client
-- $span_aws_client

-- * span.dynamodb.batchgetitem.client
-- $span_dynamodb_batchgetitem_client

-- * span.dynamodb.batchwriteitem.client
-- $span_dynamodb_batchwriteitem_client

-- * span.dynamodb.createtable.client
-- $span_dynamodb_createtable_client

-- * span.dynamodb.deleteitem.client
-- $span_dynamodb_deleteitem_client

-- * span.dynamodb.deletetable.client
-- $span_dynamodb_deletetable_client

-- * span.dynamodb.describetable.client
-- $span_dynamodb_describetable_client

-- * span.dynamodb.getitem.client
-- $span_dynamodb_getitem_client

-- * span.dynamodb.listtables.client
-- $span_dynamodb_listtables_client

-- * span.dynamodb.putitem.client
-- $span_dynamodb_putitem_client

-- * span.dynamodb.query.client
-- $span_dynamodb_query_client

-- * span.dynamodb.scan.client
-- $span_dynamodb_scan_client

-- * span.dynamodb.updateitem.client
-- $span_dynamodb_updateitem_client

-- * span.dynamodb.updatetable.client
-- $span_dynamodb_updatetable_client

-- * span.aws.s3.client
-- $span_aws_s3_client

-- * entity.aws.ecs
-- $entity_aws_ecs

-- * registry.aws
-- $registry_aws

aws_requestId,
aws_extendedRequestId,
-- * registry.aws.dynamodb
-- $registry_aws_dynamodb

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
aws_dynamodb_globalSecondaryIndexes,
aws_dynamodb_localSecondaryIndexes,
aws_dynamodb_exclusiveStartTable,
aws_dynamodb_tableCount,
aws_dynamodb_scanForward,
aws_dynamodb_segment,
aws_dynamodb_totalSegments,
aws_dynamodb_count,
aws_dynamodb_scannedCount,
aws_dynamodb_attributeDefinitions,
aws_dynamodb_globalSecondaryIndexUpdates,
-- * registry.aws.ecs
-- $registry_aws_ecs

aws_ecs_container_arn,
aws_ecs_cluster_arn,
aws_ecs_launchtype,
aws_ecs_task_arn,
aws_ecs_task_family,
aws_ecs_task_id,
aws_ecs_task_revision,
-- * registry.aws.eks
-- $registry_aws_eks

aws_eks_cluster_arn,
-- * registry.aws.log
-- $registry_aws_log

aws_log_group_names,
aws_log_group_arns,
aws_log_stream_names,
aws_log_stream_arns,
-- * registry.aws.lambda
-- $registry_aws_lambda

aws_lambda_invokedArn,
aws_lambda_resourceMapping_id,
-- * registry.aws.s3
-- $registry_aws_s3

aws_s3_bucket,
aws_s3_key,
aws_s3_copySource,
aws_s3_uploadId,
aws_s3_delete,
aws_s3_partNumber,
-- * registry.aws.sqs
-- $registry_aws_sqs

aws_sqs_queue_url,
-- * registry.aws.sns
-- $registry_aws_sns

aws_sns_topic_arn,
-- * registry.aws.kinesis
-- $registry_aws_kinesis

aws_kinesis_streamName,
-- * registry.aws.step_functions
-- $registry_aws_stepFunctions

aws_stepFunctions_activity_arn,
aws_stepFunctions_stateMachine_arn,
-- * registry.aws.secretsmanager
-- $registry_aws_secretsmanager

aws_secretsmanager_secret_arn,
-- * registry.aws.bedrock
-- $registry_aws_bedrock

aws_bedrock_guardrail_id,
aws_bedrock_knowledgeBase_id,
-- * entity.aws.eks
-- $entity_aws_eks

-- * span.aws.lambda.server
-- $span_aws_lambda_server

-- * attributes.gen_ai.common.client
-- $attributes_genAi_common_client

-- * attributes.gen_ai.inference.client
-- $attributes_genAi_inference_client

-- * span.gen_ai.inference.client
-- $span_genAi_inference_client

-- * attributes.gen_ai.inference.openai_based
-- $attributes_genAi_inference_openaiBased

-- * span.openai.inference.client
-- $span_openai_inference_client

-- * span.azure.ai.inference.client
-- $span_azure_ai_inference_client

-- * span.gen_ai.embeddings.client
-- $span_genAi_embeddings_client

-- * span.gen_ai.retrieval.client
-- $span_genAi_retrieval_client

-- * span.gen_ai.create_agent.client
-- $span_genAi_createAgent_client

-- * span.gen_ai.invoke_agent.client
-- $span_genAi_invokeAgent_client

-- * span.gen_ai.execute_tool.internal
-- $span_genAi_executeTool_internal

-- * span.aws.bedrock.client
-- $span_aws_bedrock_client

-- * span.anthropic.inference.client
-- $span_anthropic_inference_client

-- * registry.gen_ai
-- $registry_genAi

genAi_provider_name,
genAi_request_model,
genAi_request_maxTokens,
genAi_request_choice_count,
genAi_request_temperature,
genAi_request_topP,
genAi_request_topK,
genAi_request_stopSequences,
genAi_request_frequencyPenalty,
genAi_request_presencePenalty,
genAi_request_encodingFormats,
genAi_request_seed,
genAi_response_id,
genAi_response_model,
genAi_response_finishReasons,
genAi_usage_inputTokens,
genAi_usage_cacheRead_inputTokens,
genAi_usage_cacheCreation_inputTokens,
genAi_usage_outputTokens,
genAi_token_type,
genAi_conversation_id,
genAi_agent_id,
genAi_agent_name,
genAi_agent_description,
genAi_agent_version,
genAi_tool_name,
genAi_tool_call_id,
genAi_tool_description,
genAi_tool_type,
genAi_tool_call_arguments,
genAi_tool_call_result,
genAi_tool_definitions,
genAi_dataSource_id,
genAi_operation_name,
genAi_output_type,
genAi_embeddings_dimension_count,
genAi_retrieval_documents,
genAi_retrieval_query_text,
genAi_systemInstructions,
genAi_input_messages,
genAi_output_messages,
genAi_evaluation_name,
genAi_evaluation_score_value,
genAi_evaluation_score_label,
genAi_evaluation_explanation,
genAi_prompt_name,
-- * metric_attributes.gen_ai
-- $metricAttributes_genAi

-- * metric_attributes.gen_ai.server
-- $metricAttributes_genAi_server

-- * metric_attributes.openai
-- $metricAttributes_openai

-- * metric.gen_ai.client.token.usage
-- $metric_genAi_client_token_usage

-- * metric.gen_ai.client.operation.duration
-- $metric_genAi_client_operation_duration

-- * metric.gen_ai.server.request.duration
-- $metric_genAi_server_request_duration

-- * metric.gen_ai.server.time_per_output_token
-- $metric_genAi_server_timePerOutputToken

-- * metric.gen_ai.server.time_to_first_token
-- $metric_genAi_server_timeToFirstToken

-- * event.gen_ai.client.inference.operation.details
-- $event_genAi_client_inference_operation_details

-- * event.gen_ai.evaluation.result
-- $event_genAi_evaluation_result

-- * gen_ai.common.event.attributes
-- $genAi_common_event_attributes

-- * registry.gen_ai.deprecated
-- $registry_genAi_deprecated

genAi_usage_promptTokens,
genAi_usage_completionTokens,
genAi_prompt,
genAi_completion,
genAi_system,
-- * registry.gen_ai.openai.deprecated
-- $registry_genAi_openai_deprecated

genAi_openai_request_seed,
genAi_openai_request_responseFormat,
genAi_openai_request_serviceTier,
genAi_openai_response_serviceTier,
genAi_openai_response_systemFingerprint,
-- * gen_ai.deprecated.event.attributes
-- $genAi_deprecated_event_attributes

-- * event.gen_ai.system.message
-- $event_genAi_system_message

-- * event.gen_ai.user.message
-- $event_genAi_user_message

-- * event.gen_ai.assistant.message
-- $event_genAi_assistant_message

-- * event.gen_ai.tool.message
-- $event_genAi_tool_message

-- * event.gen_ai.choice
-- $event_genAi_choice

-- * entity.telemetry.sdk
-- $entity_telemetry_sdk

-- * entity.telemetry.distro
-- $entity_telemetry_distro

-- * registry.telemetry
-- $registry_telemetry

telemetry_sdk_name,
telemetry_sdk_language,
telemetry_sdk_version,
telemetry_distro_name,
telemetry_distro_version,
-- * registry.mainframe.lpar
-- $registry_mainframe_lpar

mainframe_lpar_name,
-- * registry.onc_rpc
-- $registry_oncRpc

oncRpc_version,
oncRpc_procedure_number,
oncRpc_procedure_name,
oncRpc_program_name,
-- * entity.service
-- $entity_service

-- * entity.service.instance
-- $entity_service_instance

-- * entity.service.namespace
-- $entity_service_namespace

-- * service.peer
-- $service_peer

-- * registry.service
-- $registry_service

service_name,
service_version,
service_namespace,
service_instance_id,
service_criticality,
-- * registry.service.peer
-- $registry_service_peer

service_peer_name,
service_peer_namespace,
-- * rpc
-- $rpc

-- * rpc.server
-- $rpc_server

-- * span.rpc.call.client
-- $span_rpc_call_client

-- * span.rpc.call.server
-- $span_rpc_call_server

-- * span.rpc.connect_rpc.call.client
-- $span_rpc_connectRpc_call_client

-- * span.rpc.connect_rpc.call.server
-- $span_rpc_connectRpc_call_server

-- * span.rpc.grpc.call.client
-- $span_rpc_grpc_call_client

-- * span.rpc.grpc.call.server
-- $span_rpc_grpc_call_server

-- * span.rpc.jsonrpc.call.client
-- $span_rpc_jsonrpc_call_client

-- * span.rpc.jsonrpc.call.server
-- $span_rpc_jsonrpc_call_server

-- * span.rpc.dubbo.call.client
-- $span_rpc_dubbo_call_client

-- * span.rpc.dubbo.call.server
-- $span_rpc_dubbo_call_server

-- * common.rpc.attributes
-- $common_rpc_attributes

-- * registry.rpc
-- $registry_rpc

rpc_response_statusCode,
rpc_request_metadata,
rpc_response_metadata,
rpc_method,
rpc_methodOriginal,
rpc_system_name,
-- * attributes.metrics.rpc.client
-- $attributes_metrics_rpc_client

-- * attributes.metrics.rpc.server
-- $attributes_metrics_rpc_server

-- * metric.rpc.server.call.duration
-- $metric_rpc_server_call_duration

-- * metric.rpc.client.call.duration
-- $metric_rpc_client_call_duration

-- * event.rpc.client.call.exception
-- $event_rpc_client_call_exception

-- * event.rpc.server.call.exception
-- $event_rpc_server_call_exception

-- * registry.rpc.deprecated
-- $registry_rpc_deprecated

message_type,
message_id,
message_compressedSize,
message_uncompressedSize,
rpc_connectRpc_request_metadata,
rpc_connectRpc_response_metadata,
rpc_grpc_request_metadata,
rpc_grpc_response_metadata,
rpc_grpc_statusCode,
rpc_connectRpc_errorCode,
rpc_jsonrpc_errorCode,
rpc_jsonrpc_errorMessage,
rpc_system,
rpc_jsonrpc_requestId,
rpc_jsonrpc_version,
rpc_service,
rpc_message_type,
rpc_message_id,
rpc_message_compressedSize,
rpc_message_uncompressedSize,
-- * event.rpc.message
-- $event_rpc_message

-- * metric.rpc.client.requests_per_rpc
-- $metric_rpc_client_requestsPerRpc

-- * metric.rpc.client.responses_per_rpc
-- $metric_rpc_client_responsesPerRpc

-- * metric.rpc.server.requests_per_rpc
-- $metric_rpc_server_requestsPerRpc

-- * metric.rpc.server.responses_per_rpc
-- $metric_rpc_server_responsesPerRpc

-- * metric.rpc.server.duration
-- $metric_rpc_server_duration

-- * metric.rpc.client.duration
-- $metric_rpc_client_duration

-- * metric.rpc.server.request.size
-- $metric_rpc_server_request_size

-- * metric.rpc.server.response.size
-- $metric_rpc_server_response_size

-- * metric.rpc.client.request.size
-- $metric_rpc_client_request_size

-- * metric.rpc.client.response.size
-- $metric_rpc_client_response_size

-- * registry.dns
-- $registry_dns

dns_question_name,
dns_answers,
-- * metric.dns.lookup.duration
-- $metric_dns_lookup_duration

-- * thread
-- $thread

-- * registry.thread
-- $registry_thread

thread_id,
thread_name,
-- * registry.error
-- $registry_error

error_type,
-- * registry.error.deprecated
-- $registry_error_deprecated

error_message,
-- * attributes.messaging.trace.minimal
-- $attributes_messaging_trace_minimal

-- * messaging.attributes
-- $messaging_attributes

-- * messaging.network.attributes
-- $messaging_network_attributes

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

-- * messaging.aws.sqs
-- $messaging_aws_sqs

-- * messaging.aws.sns
-- $messaging_aws_sns

-- * attributes.messaging.common.minimal
-- $attributes_messaging_common_minimal

-- * registry.messaging
-- $registry_messaging

messaging_batch_messageCount,
messaging_client_id,
messaging_consumer_group_name,
messaging_destination_name,
messaging_destination_subscription_name,
messaging_destination_template,
messaging_destination_anonymous,
messaging_destination_temporary,
messaging_destination_partition_id,
messaging_message_conversationId,
messaging_message_envelope_size,
messaging_message_id,
messaging_message_body_size,
messaging_operation_type,
messaging_operation_name,
messaging_system,
-- * registry.messaging.kafka
-- $registry_messaging_kafka

messaging_kafka_message_key,
messaging_kafka_offset,
messaging_kafka_message_tombstone,
-- * registry.messaging.rabbitmq
-- $registry_messaging_rabbitmq

messaging_rabbitmq_destination_routingKey,
messaging_rabbitmq_message_deliveryTag,
-- * registry.messaging.rocketmq
-- $registry_messaging_rocketmq

messaging_rocketmq_consumptionModel,
messaging_rocketmq_message_delayTimeLevel,
messaging_rocketmq_message_deliveryTimestamp,
messaging_rocketmq_message_group,
messaging_rocketmq_message_keys,
messaging_rocketmq_message_tag,
messaging_rocketmq_message_type,
messaging_rocketmq_namespace,
-- * registry.messaging.gcp_pubsub
-- $registry_messaging_gcpPubsub

messaging_gcpPubsub_message_orderingKey,
messaging_gcpPubsub_message_ackId,
messaging_gcpPubsub_message_ackDeadline,
messaging_gcpPubsub_message_deliveryAttempt,
-- * registry.messaging.servicebus
-- $registry_messaging_servicebus

messaging_servicebus_message_deliveryCount,
messaging_servicebus_message_enqueuedTime,
messaging_servicebus_dispositionStatus,
-- * registry.messaging.eventhubs
-- $registry_messaging_eventhubs

messaging_eventhubs_message_enqueuedTime,
-- * metric.messaging.attributes
-- $metric_messaging_attributes

-- * metric.messaging.consumer.attributes
-- $metric_messaging_consumer_attributes

-- * metric.messaging.client.operation.duration
-- $metric_messaging_client_operation_duration

-- * metric.messaging.process.duration
-- $metric_messaging_process_duration

-- * metric.messaging.client.sent.messages
-- $metric_messaging_client_sent_messages

-- * metric.messaging.client.consumed.messages
-- $metric_messaging_client_consumed_messages

-- * registry.messaging.deprecated
-- $registry_messaging_deprecated

messaging_kafka_destination_partition,
messaging_operation,
messaging_clientId,
messaging_kafka_consumer_group,
messaging_rocketmq_clientGroup,
messaging_eventhubs_consumer_group,
messaging_servicebus_destination_subscriptionName,
messaging_kafka_message_offset,
messaging_destinationPublish_anonymous,
messaging_destinationPublish_name,
-- * metric.messaging.publish.duration
-- $metric_messaging_publish_duration

-- * metric.messaging.receive.duration
-- $metric_messaging_receive_duration

-- * metric.messaging.process.messages
-- $metric_messaging_process_messages

-- * metric.messaging.publish.messages
-- $metric_messaging_publish_messages

-- * metric.messaging.receive.messages
-- $metric_messaging_receive_messages

-- * metric.messaging.client.published.messages
-- $metric_messaging_client_published_messages

-- * registry.event.deprecated
-- $registry_event_deprecated

event_name,
-- * client
-- $client

-- * registry.client
-- $registry_client

client_address,
client_port,
-- * registry.oracledb
-- $registry_oracledb

oracle_db_name,
oracle_db_domain,
oracle_db_instance_name,
oracle_db_pdb,
oracle_db_service,
-- * registry.elasticsearch
-- $registry_elasticsearch

elasticsearch_node_name,
-- * registry.openai
-- $registry_openai

openai_request_serviceTier,
openai_api_type,
openai_response_serviceTier,
openai_response_systemFingerprint,
-- * entity.process
-- $entity_process

-- * entity.process.runtime
-- $entity_process_runtime

-- * registry.process
-- $registry_process

process_pid,
process_parentPid,
process_vpid,
process_sessionLeader_pid,
process_groupLeader_pid,
process_executable_buildId_gnu,
process_executable_buildId_go,
process_executable_buildId_htlhash,
process_executable_name,
process_executable_path,
process_command,
process_commandLine,
process_commandArgs,
process_argsCount,
process_owner,
process_user_id,
process_user_name,
process_realUser_id,
process_realUser_name,
process_savedUser_id,
process_savedUser_name,
process_runtime_name,
process_runtime_version,
process_runtime_description,
process_title,
process_creation_time,
process_exit_time,
process_exit_code,
process_interactive,
process_workingDirectory,
process_contextSwitch_type,
process_environmentVariable,
process_state,
-- * registry.process.linux
-- $registry_process_linux

process_linux_cgroup,
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

-- * metric.process.unix.file_descriptor.count
-- $metric_process_unix_fileDescriptor_count

-- * metric.process.windows.handle.count
-- $metric_process_windows_handle_count

-- * metric.process.context_switches
-- $metric_process_contextSwitches

-- * metric.process.paging.faults
-- $metric_process_paging_faults

-- * metric.process.uptime
-- $metric_process_uptime

-- * registry.process.deprecated
-- $registry_process_deprecated

process_cpu_state,
process_executable_buildId_profiling,
process_contextSwitchType,
process_paging_faultType,
-- * metric.process.open_file_descriptor.count
-- $metric_process_openFileDescriptor_count

-- * session-id
-- $session-id

-- * registry.session
-- $registry_session

session_id,
session_previousId,
-- * event.session.start
-- $event_session_start

-- * event.session.end
-- $event_session_end

) where
import Data.Text (Text)
import Data.Int (Int64)
import OpenTelemetry.Attributes.Key (AttributeKey (AttributeKey))
{-# ANN module ("HLint: ignore Use camelCase" :: String) #-}
-- $entity_webengine
-- Resource describing the packaged software running the application code. Web engines are typically executed using process.runtime.
--
-- Stability: development
--
-- === Attributes
-- - 'webengine_name'
--
--     Requirement level: required
--
-- - 'webengine_version'
--
--     Requirement level: recommended
--
-- - 'webengine_description'
--
--     Requirement level: recommended
--




-- $registry_webengine
-- This document defines the attributes used to describe the packaged software running the application code.
--
-- Stability: development
--
-- === Attributes
-- - 'webengine_name'
--
--     Stability: development
--
-- - 'webengine_version'
--
--     Stability: development
--
-- - 'webengine_description'
--
--     Stability: development
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

-- $registry_oracleCloud
-- This section defines generic attributes for Oracle Cloud Infrastructure (OCI).
--
-- === Attributes
-- - 'oracleCloud_realm'
--
--     Stability: development
--

-- |
-- The OCI realm identifier that indicates the isolated partition in which the tenancy and its resources reside.

-- ==== Note
-- See [OCI documentation on realms](https:\/\/docs.oracle.com\/iaas\/Content\/General\/Concepts\/regions.htm)
oracleCloud_realm :: AttributeKey Text
oracleCloud_realm = AttributeKey "oracle_cloud.realm"

-- $opentracing
-- This document defines semantic conventions for the OpenTracing Shim
--
-- ==== Note
-- These conventions are used by the OpenTracing Shim layer.
--
-- === Attributes
-- - 'opentracing_refType'
--
--     Requirement level: recommended
--


-- $registry_opentracing
-- Attributes used by the OpenTracing Shim layer.
--
-- === Attributes
-- - 'opentracing_refType'
--
--     Stability: development
--

-- |
-- Parent-child Reference type

-- ==== Note
-- The causal relationship between a child Span and a parent Span.
opentracing_refType :: AttributeKey Text
opentracing_refType = AttributeKey "opentracing.ref_type"

-- $registry_aspnetcore
-- ASP.NET Core attributes
--
-- === Attributes
-- - 'aspnetcore_rateLimiting_policy'
--
--     Stability: stable
--
-- - 'aspnetcore_rateLimiting_result'
--
--     Stability: stable
--
-- - 'aspnetcore_routing_isFallback'
--
--     Stability: stable
--
-- - 'aspnetcore_diagnostics_handler_type'
--
--     Stability: stable
--
-- - 'aspnetcore_request_isUnhandled'
--
--     Stability: stable
--
-- - 'aspnetcore_routing_matchStatus'
--
--     Stability: stable
--
-- - 'aspnetcore_diagnostics_exception_result'
--
--     Stability: stable
--
-- - 'aspnetcore_memoryPool_owner'
--
--     Stability: development
--
-- - 'aspnetcore_identity_userType'
--
--     Stability: development
--
-- - 'aspnetcore_authentication_result'
--
--     Stability: development
--
-- - 'aspnetcore_authentication_scheme'
--
--     Stability: development
--
-- - 'aspnetcore_user_isAuthenticated'
--
--     Stability: stable
--
-- - 'aspnetcore_authorization_policy'
--
--     Stability: development
--
-- - 'aspnetcore_authorization_result'
--
--     Stability: development
--
-- - 'aspnetcore_identity_result'
--
--     Stability: development
--
-- - 'aspnetcore_identity_errorCode'
--
--     Stability: development
--
-- - 'aspnetcore_identity_user_updateType'
--
--     Stability: development
--
-- - 'aspnetcore_identity_passwordCheckResult'
--
--     Stability: development
--
-- - 'aspnetcore_identity_tokenPurpose'
--
--     Stability: development
--
-- - 'aspnetcore_identity_tokenVerified'
--
--     Stability: development
--
-- - 'aspnetcore_identity_signIn_type'
--
--     Stability: development
--
-- - 'aspnetcore_signIn_isPersistent'
--
--     Stability: development
--
-- - 'aspnetcore_identity_signIn_result'
--
--     Stability: development
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

-- |
-- Match result - success or failure
aspnetcore_routing_matchStatus :: AttributeKey Text
aspnetcore_routing_matchStatus = AttributeKey "aspnetcore.routing.match_status"

-- |
-- ASP.NET Core exception middleware handling result.
aspnetcore_diagnostics_exception_result :: AttributeKey Text
aspnetcore_diagnostics_exception_result = AttributeKey "aspnetcore.diagnostics.exception.result"

-- |
-- The name of the library or subsystem using the memory pool instance.
aspnetcore_memoryPool_owner :: AttributeKey Text
aspnetcore_memoryPool_owner = AttributeKey "aspnetcore.memory_pool.owner"

-- |
-- The full name of the identity user type.
aspnetcore_identity_userType :: AttributeKey Text
aspnetcore_identity_userType = AttributeKey "aspnetcore.identity.user_type"

-- |
-- The result of the authentication operation.
aspnetcore_authentication_result :: AttributeKey Text
aspnetcore_authentication_result = AttributeKey "aspnetcore.authentication.result"

-- |
-- The identifier that names a particular authentication handler.
aspnetcore_authentication_scheme :: AttributeKey Text
aspnetcore_authentication_scheme = AttributeKey "aspnetcore.authentication.scheme"

-- |
-- A value that indicates whether the user is authenticated.
aspnetcore_user_isAuthenticated :: AttributeKey Bool
aspnetcore_user_isAuthenticated = AttributeKey "aspnetcore.user.is_authenticated"

-- |
-- The name of the authorization policy.
aspnetcore_authorization_policy :: AttributeKey Text
aspnetcore_authorization_policy = AttributeKey "aspnetcore.authorization.policy"

-- |
-- The result of calling the authorization service.
aspnetcore_authorization_result :: AttributeKey Text
aspnetcore_authorization_result = AttributeKey "aspnetcore.authorization.result"

-- |
-- The result of the identity operation.
aspnetcore_identity_result :: AttributeKey Text
aspnetcore_identity_result = AttributeKey "aspnetcore.identity.result"

-- |
-- The error code for a failed identity operation.
aspnetcore_identity_errorCode :: AttributeKey Text
aspnetcore_identity_errorCode = AttributeKey "aspnetcore.identity.error_code"

-- |
-- The user update type.
aspnetcore_identity_user_updateType :: AttributeKey Text
aspnetcore_identity_user_updateType = AttributeKey "aspnetcore.identity.user.update_type"

-- |
-- The result from checking the password.
aspnetcore_identity_passwordCheckResult :: AttributeKey Text
aspnetcore_identity_passwordCheckResult = AttributeKey "aspnetcore.identity.password_check_result"

-- |
-- What the token will be used for.
aspnetcore_identity_tokenPurpose :: AttributeKey Text
aspnetcore_identity_tokenPurpose = AttributeKey "aspnetcore.identity.token_purpose"

-- |
-- The result of token verification.
aspnetcore_identity_tokenVerified :: AttributeKey Text
aspnetcore_identity_tokenVerified = AttributeKey "aspnetcore.identity.token_verified"

-- |
-- The authentication type.
aspnetcore_identity_signIn_type :: AttributeKey Text
aspnetcore_identity_signIn_type = AttributeKey "aspnetcore.identity.sign_in.type"

-- |
-- A flag indicating whether the sign in is persistent.
aspnetcore_signIn_isPersistent :: AttributeKey Bool
aspnetcore_signIn_isPersistent = AttributeKey "aspnetcore.sign_in.is_persistent"

-- |
-- Whether the sign in result was success or failure.
aspnetcore_identity_signIn_result :: AttributeKey Text
aspnetcore_identity_signIn_result = AttributeKey "aspnetcore.identity.sign_in.result"

-- $aspnetcore_common_rateLimiting_metrics_attributes
-- Common ASP.NET Core rate-limiting metrics attributes
--
-- === Attributes
-- - 'aspnetcore_rateLimiting_policy'
--
--     Requirement level: conditionally required: if the matched endpoint for the request had a rate-limiting policy.
--


-- $aspnetcore_common_authentication_metrics_attributes
-- Common ASP.NET Core authentication metrics attributes
--
-- === Attributes
-- - 'aspnetcore_authentication_scheme'
--
--     Requirement level: conditionally required: if a scheme is specified during authentication.
--
-- - 'error_type'
--
--     The full name of exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--



-- $aspnetcore_common_identity_metrics_attributes
-- Common ASP.NET Core Identity metrics attributes
--
-- === Attributes
-- - 'aspnetcore_identity_userType'
--
--     Requirement level: required
--


-- $aspnetcore_common_memoryPool_metrics_attributes
-- Common ASP.NET Core memory pool metrics attributes
--
-- === Attributes
-- - 'aspnetcore_memoryPool_owner'
--
--     Requirement level: conditionally required: if owner is specified when the memory pool is created.
--


-- $metric_aspnetcore_routing_matchAttempts
-- Number of requests that were attempted to be matched to an endpoint.
--
-- Stability: stable
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




-- $metric_aspnetcore_diagnostics_exceptions
-- Number of exceptions caught by exception handling middleware.
--
-- Stability: stable
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
--     ==== Note
--     
--
-- - 'aspnetcore_diagnostics_handler_type'
--
--     Requirement level: conditionally required: if and only if the exception was handled by this handler.
--
-- - 'aspnetcore_diagnostics_exception_result'
--
--     Requirement level: required
--




-- $metric_aspnetcore_rateLimiting_activeRequestLeases
-- Number of requests that are currently active on the server that hold a rate limiting lease.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.RateLimiting@; Added in: ASP.NET Core 8.0
--

-- $metric_aspnetcore_rateLimiting_requestLease_duration
-- The duration of rate limiting lease held by requests on the server.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.RateLimiting@; Added in: ASP.NET Core 8.0
--

-- $metric_aspnetcore_rateLimiting_request_timeInQueue
-- The time the request spent in a queue waiting to acquire a rate limiting lease.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.RateLimiting@; Added in: ASP.NET Core 8.0
--
-- === Attributes
-- - 'aspnetcore_rateLimiting_result'
--
--     Requirement level: required
--


-- $metric_aspnetcore_rateLimiting_queuedRequests
-- Number of requests that are currently queued, waiting to acquire a rate limiting lease.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.RateLimiting@; Added in: ASP.NET Core 8.0
--

-- $metric_aspnetcore_rateLimiting_requests
-- Number of requests that tried to acquire a rate limiting lease.
--
-- Stability: stable
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
-- - 'aspnetcore_rateLimiting_result'
--
--     Requirement level: required
--


-- $metric_aspnetcore_memoryPool_pooled
-- Number of bytes currently pooled and available for reuse.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.MemoryPool@; Added in: ASP.NET Core 10.0
--

-- $metric_aspnetcore_memoryPool_allocated
-- Total number of bytes allocated by the memory pool. Allocation occurs when a memory rental request exceeds the available pooled memory.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.MemoryPool@; Added in: ASP.NET Core 10.0
--

-- $metric_aspnetcore_memoryPool_evicted
-- Total number of bytes evicted from the memory pool. Eviction occurs when idle pooled memory is reclaimed.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.MemoryPool@; Added in: ASP.NET Core 10.0
--

-- $metric_aspnetcore_memoryPool_rented
-- Total number of bytes rented from the memory pool.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.MemoryPool@; Added in: ASP.NET Core 10.0
--

-- $metric_aspnetcore_authentication_authenticate_duration
-- The authentication duration for a request.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Authentication@; Added in: ASP.NET Core 10.0
--
-- === Attributes
-- - 'aspnetcore_authentication_result'
--
--     Requirement level: required
--


-- $metric_aspnetcore_authentication_challenges
-- The total number of times a scheme is challenged.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Authentication@; Added in: ASP.NET Core 10.0
--

-- $metric_aspnetcore_authentication_forbids
-- The total number of times an authenticated user attempts to access a resource they are not permitted to access.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Authentication@; Added in: ASP.NET Core 10.0
--

-- $metric_aspnetcore_authentication_signIns
-- The total number of times a principal is signed in with a scheme.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Authentication@; Added in: ASP.NET Core 10.0
--

-- $metric_aspnetcore_authentication_signOuts
-- The total number of times a principal is signed out with a scheme.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Authentication@; Added in: ASP.NET Core 10.0
--

-- $metric_aspnetcore_authorization_attempts
-- The total number of authorization attempts.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Authorization@; Added in: ASP.NET Core 10.0
--
-- === Attributes
-- - 'aspnetcore_user_isAuthenticated'
--
--     Requirement level: required
--
-- - 'aspnetcore_authorization_policy'
--
--     Requirement level: conditionally required: if a policy is specified.
--
-- - 'aspnetcore_authorization_result'
--
--     Requirement level: conditionally required: if no exception was thrown.
--
-- - 'error_type'
--
--     The full name of exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--





-- $metric_aspnetcore_identity_user_create_duration
-- The duration of user creation operations.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Identity@; Added in: ASP.NET Core 10.0
--
-- === Attributes
-- - 'aspnetcore_identity_result'
--
--     Requirement level: conditionally required: if no exception was thrown.
--
-- - 'aspnetcore_identity_errorCode'
--
--     Requirement level: conditionally required: if an error was set on a failed identity result.
--
-- - 'error_type'
--
--     The full name of exception type or the identity error code.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--




-- $metric_aspnetcore_identity_user_update_duration
-- The duration of user update operations.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Identity@; Added in: ASP.NET Core 10.0
--
-- === Attributes
-- - 'aspnetcore_identity_user_updateType'
--
--     Requirement level: required
--
-- - 'aspnetcore_identity_result'
--
--     Requirement level: conditionally required: if no exception was thrown.
--
-- - 'aspnetcore_identity_errorCode'
--
--     Requirement level: conditionally required: if an error was set on a failed identity result.
--
-- - 'error_type'
--
--     The full name of exception type or the identity error code.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--





-- $metric_aspnetcore_identity_user_delete_duration
-- The duration of user deletion operations.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Identity@; Added in: ASP.NET Core 10.0
--
-- === Attributes
-- - 'aspnetcore_identity_result'
--
--     Requirement level: conditionally required: if no exception was thrown.
--
-- - 'aspnetcore_identity_errorCode'
--
--     Requirement level: conditionally required: if an error was set on a failed identity result.
--
-- - 'error_type'
--
--     The full name of exception type or the identity error code.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--




-- $metric_aspnetcore_identity_user_checkPasswordAttempts
-- The number of check password attempts. Only checks whether the password is valid and not whether the user account is in a state that can log in.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Identity@; Added in: ASP.NET Core 10.0
--
-- === Attributes
-- - 'aspnetcore_identity_passwordCheckResult'
--
--     Requirement level: conditionally required: if no exception was thrown.
--
-- - 'error_type'
--
--     The full name of exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--



-- $metric_aspnetcore_identity_user_verifyTokenAttempts
-- The total number of token verification attempts.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Identity@; Added in: ASP.NET Core 10.0
--
-- === Attributes
-- - 'aspnetcore_identity_tokenPurpose'
--
--     Requirement level: required
--
-- - 'aspnetcore_identity_tokenVerified'
--
--     Requirement level: conditionally required: if no exception was thrown.
--
-- - 'error_type'
--
--     The full name of exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--




-- $metric_aspnetcore_identity_user_generatedTokens
-- The total number of token generations.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Identity@; Added in: ASP.NET Core 10.0
--
-- === Attributes
-- - 'aspnetcore_identity_tokenPurpose'
--
--     Requirement level: required
--
-- - 'error_type'
--
--     The full name of exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--



-- $metric_aspnetcore_identity_signIn_authenticate_duration
-- The duration of authenticate attempts. The authenticate metrics is recorded by sign in methods such as PasswordSignInAsync and TwoFactorSignInAsync.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Identity@; Added in: ASP.NET Core 10.0
--
-- === Attributes
-- - 'aspnetcore_authentication_scheme'
--
--     Requirement level: required
--
-- - 'aspnetcore_signIn_isPersistent'
--
--     Requirement level: conditionally required: if no exception was thrown.
--
-- - 'aspnetcore_identity_signIn_type'
--
--     Requirement level: required
--
-- - 'aspnetcore_identity_signIn_result'
--
--     Requirement level: conditionally required: if no exception was thrown.
--
-- - 'error_type'
--
--     The full name of exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--






-- $metric_aspnetcore_identity_signIn_twoFactorClientsRemembered
-- The total number of two factor clients remembered.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Identity@; Added in: ASP.NET Core 10.0
--
-- === Attributes
-- - 'aspnetcore_authentication_scheme'
--
--     Requirement level: required
--
-- - 'error_type'
--
--     The full name of exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--



-- $metric_aspnetcore_identity_signIn_twoFactorClientsForgotten
-- The total number of two factor clients forgotten.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Identity@; Added in: ASP.NET Core 10.0
--
-- === Attributes
-- - 'aspnetcore_authentication_scheme'
--
--     Requirement level: required
--
-- - 'error_type'
--
--     The full name of exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--



-- $metric_aspnetcore_identity_signIn_checkPasswordAttempts
-- The total number of check password attempts. Checks that the account is in a state that can log in and that the password is valid using the UserManager.CheckPasswordAsync method.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Identity@; Added in: ASP.NET Core 10.0
--
-- === Attributes
-- - 'aspnetcore_identity_signIn_result'
--
--     Requirement level: conditionally required: if no exception was thrown.
--
-- - 'error_type'
--
--     The full name of exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--



-- $metric_aspnetcore_identity_signIn_signIns
-- The total number of calls to sign in user principals.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Identity@; Added in: ASP.NET Core 10.0
--
-- === Attributes
-- - 'aspnetcore_authentication_scheme'
--
--     Requirement level: required
--
-- - 'aspnetcore_signIn_isPersistent'
--
--     Requirement level: conditionally required: if no exception was thrown.
--
-- - 'error_type'
--
--     The full name of exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--




-- $metric_aspnetcore_identity_signIn_signOuts
-- The total number of calls to sign out user principals.
--
-- Stability: development
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Identity@; Added in: ASP.NET Core 10.0
--
-- === Attributes
-- - 'aspnetcore_authentication_scheme'
--
--     Requirement level: required
--
-- - 'error_type'
--
--     The full name of exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--



-- $registry_nodejs
-- Describes Node.js related attributes.
--
-- === Attributes
-- - 'nodejs_eventloop_state'
--
--     Stability: development
--

-- |
-- The state of event loop time.
nodejs_eventloop_state :: AttributeKey Text
nodejs_eventloop_state = AttributeKey "nodejs.eventloop.state"

-- $metric_nodejs_eventloop_delay_min
-- Event loop minimum delay.
--
-- Stability: development
--
-- ==== Note
-- Value can be retrieved from value @histogram.min@ of [@perf_hooks.monitorEventLoopDelay([options])@](https:\/\/nodejs.org\/api\/perf_hooks.html#perf_hooksmonitoreventloopdelayoptions)
--

-- $metric_nodejs_eventloop_delay_max
-- Event loop maximum delay.
--
-- Stability: development
--
-- ==== Note
-- Value can be retrieved from value @histogram.max@ of [@perf_hooks.monitorEventLoopDelay([options])@](https:\/\/nodejs.org\/api\/perf_hooks.html#perf_hooksmonitoreventloopdelayoptions)
--

-- $metric_nodejs_eventloop_delay_mean
-- Event loop mean delay.
--
-- Stability: development
--
-- ==== Note
-- Value can be retrieved from value @histogram.mean@ of [@perf_hooks.monitorEventLoopDelay([options])@](https:\/\/nodejs.org\/api\/perf_hooks.html#perf_hooksmonitoreventloopdelayoptions)
--

-- $metric_nodejs_eventloop_delay_stddev
-- Event loop standard deviation delay.
--
-- Stability: development
--
-- ==== Note
-- Value can be retrieved from value @histogram.stddev@ of [@perf_hooks.monitorEventLoopDelay([options])@](https:\/\/nodejs.org\/api\/perf_hooks.html#perf_hooksmonitoreventloopdelayoptions)
--

-- $metric_nodejs_eventloop_delay_p50
-- Event loop 50 percentile delay.
--
-- Stability: development
--
-- ==== Note
-- Value can be retrieved from value @histogram.percentile(50)@ of [@perf_hooks.monitorEventLoopDelay([options])@](https:\/\/nodejs.org\/api\/perf_hooks.html#perf_hooksmonitoreventloopdelayoptions)
--

-- $metric_nodejs_eventloop_delay_p90
-- Event loop 90 percentile delay.
--
-- Stability: development
--
-- ==== Note
-- Value can be retrieved from value @histogram.percentile(90)@ of [@perf_hooks.monitorEventLoopDelay([options])@](https:\/\/nodejs.org\/api\/perf_hooks.html#perf_hooksmonitoreventloopdelayoptions)
--

-- $metric_nodejs_eventloop_delay_p99
-- Event loop 99 percentile delay.
--
-- Stability: development
--
-- ==== Note
-- Value can be retrieved from value @histogram.percentile(99)@ of [@perf_hooks.monitorEventLoopDelay([options])@](https:\/\/nodejs.org\/api\/perf_hooks.html#perf_hooksmonitoreventloopdelayoptions)
--

-- $metric_nodejs_eventloop_utilization
-- Event loop utilization.
--
-- Stability: development
--
-- ==== Note
-- The value range is [0.0, 1.0] and can be retrieved from [@performance.eventLoopUtilization([utilization1[, utilization2]])@](https:\/\/nodejs.org\/api\/perf_hooks.html#performanceeventlooputilizationutilization1-utilization2)
--

-- $metric_nodejs_eventloop_time
-- Cumulative duration of time the event loop has been in each state.
--
-- Stability: development
--
-- ==== Note
-- Value can be retrieved from [@performance.eventLoopUtilization([utilization1[, utilization2]])@](https:\/\/nodejs.org\/api\/perf_hooks.html#performanceeventlooputilizationutilization1-utilization2)
--
-- === Attributes
-- - 'nodejs_eventloop_state'
--
--     Requirement level: required
--


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
--     Requirement level: recommended
--
-- - 'cloudevents_eventType'
--
--     Requirement level: recommended
--
-- - 'cloudevents_eventSubject'
--
--     Requirement level: recommended
--






-- $registry_cloudevents
-- This document defines attributes for CloudEvents.
--
-- === Attributes
-- - 'cloudevents_eventId'
--
--     Stability: development
--
-- - 'cloudevents_eventSource'
--
--     Stability: development
--
-- - 'cloudevents_eventSpecVersion'
--
--     Stability: development
--
-- - 'cloudevents_eventType'
--
--     Stability: development
--
-- - 'cloudevents_eventSubject'
--
--     Stability: development
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

-- $metricAttributes_hw_network
-- Common attributes for network adapter metrics
--
-- === Attributes
-- - 'hw_model'
--
--     Requirement level: recommended
--
-- - 'hw_network_logicalAddresses'
--
--     Requirement level: recommended
--
-- - 'hw_network_physicalAddress'
--
--     Requirement level: recommended
--
-- - 'hw_serialNumber'
--
--     Requirement level: recommended
--
-- - 'hw_vendor'
--
--     Requirement level: recommended
--






-- $metric_hw_network_bandwidth_limit
-- Link speed.
--
-- Stability: development
--

-- $metric_hw_network_bandwidth_utilization
-- Utilization of the network bandwidth as a fraction.
--
-- Stability: development
--

-- $metric_hw_network_io
-- Received and transmitted network traffic in bytes.
--
-- Stability: development
--
-- === Attributes
-- - 'network_io_direction'
--
--     Requirement level: required
--


-- $metric_hw_network_packets
-- Received and transmitted network traffic in packets (or frames).
--
-- Stability: development
--
-- === Attributes
-- - 'network_io_direction'
--
--     Requirement level: required
--


-- $metric_hw_network_up
-- Link status: @1@ (up) or @0@ (down).
--
-- Stability: development
--

-- $metricAttributes_hw_logicalDisk
-- Common attributes for logical disk metrics
--
-- === Attributes
-- - 'hw_logicalDisk_raidLevel'
--
--     Requirement level: recommended
--


-- $metric_hw_logicalDisk_limit
-- Size of the logical disk.
--
-- Stability: development
--

-- $metric_hw_logicalDisk_usage
-- Logical disk space usage.
--
-- Stability: development
--
-- === Attributes
-- - 'hw_logicalDisk_state'
--
--     Requirement level: required
--


-- $metric_hw_logicalDisk_utilization
-- Logical disk space utilization as a fraction.
--
-- Stability: development
--
-- === Attributes
-- - 'hw_logicalDisk_state'
--
--     Requirement level: required
--


-- $metricAttributes_hw_fan
-- Common attributes for fan metrics
--
-- === Attributes
-- - 'hw_sensorLocation'
--
--     Requirement level: recommended
--


-- $metric_hw_fan_speed
-- Fan speed in revolutions per minute.
--
-- Stability: development
--

-- $metric_hw_fan_speed_limit
-- Speed limit in rpm.
--
-- Stability: development
--
-- === Attributes
-- - 'hw_limitType'
--
--     Requirement level: recommended
--


-- $metric_hw_fan_speedRatio
-- Fan speed expressed as a fraction of its maximum speed.
--
-- Stability: development
--

-- $metricAttributes_hw_battery
-- Common attributes for battery metrics
--
-- === Attributes
-- - 'hw_battery_chemistry'
--
--     Requirement level: recommended
--
-- - 'hw_battery_capacity'
--
--     Requirement level: recommended
--
-- - 'hw_model'
--
--     Requirement level: recommended
--
-- - 'hw_vendor'
--
--     Requirement level: recommended
--





-- $metric_hw_battery_charge
-- Remaining fraction of battery charge.
--
-- Stability: development
--

-- $metric_hw_battery_charge_limit
-- Lower limit of battery charge fraction to ensure proper operation.
--
-- Stability: development
--
-- === Attributes
-- - 'hw_limitType'
--
--     Represents battery charge level thresholds relevant to device operation and health. Each @limit_type@ denotes a specific charge limit such as the minimum or maximum optimal charge, the shutdown threshold, or energy-saving thresholds. These values are typically provided by the hardware or firmware to guide safe and efficient battery usage.
--
--     Requirement level: recommended
--


-- $metric_hw_battery_timeLeft
-- Time left before battery is completely charged or discharged.
--
-- Stability: development
--
-- === Attributes
-- - 'hw_state'
--
--     Requirement level: required
--
-- - 'hw_battery_state'
--
--     Requirement level: conditionally required: If the battery is charging or discharging
--
--     ==== Note
--     The @hw.state@ attribute should indicate the current state of the battery. It should be one of the predefined states such as "charging" or "discharging".
--



-- $metricAttributes_hw_memory
-- Common attributes for memory module metrics
--
-- === Attributes
-- - 'hw_model'
--
--     Requirement level: recommended
--
-- - 'hw_serialNumber'
--
--     Requirement level: recommended
--
-- - 'hw_memory_type'
--
--     Requirement level: recommended
--
-- - 'hw_vendor'
--
--     Requirement level: recommended
--





-- $metric_hw_memory_size
-- Size of the memory module.
--
-- Stability: development
--

-- $metricAttributes_hw_diskController
-- Common attributes for disk controller metrics
--
-- === Attributes
-- - 'hw_biosVersion'
--
--     Requirement level: recommended
--
-- - 'hw_driverVersion'
--
--     Requirement level: recommended
--
-- - 'hw_firmwareVersion'
--
--     Requirement level: recommended
--
-- - 'hw_model'
--
--     Requirement level: recommended
--
-- - 'hw_serialNumber'
--
--     Requirement level: recommended
--
-- - 'hw_vendor'
--
--     Requirement level: recommended
--







-- $metric_hw_host_ambientTemperature
-- Ambient (external) temperature of the physical host.
--
-- Stability: development
--

-- $metric_hw_host_energy
-- Total energy consumed by the entire physical host, in joules.
--
-- Stability: development
--
-- ==== Note
-- The overall energy usage of a host MUST be reported using the specific @hw.host.energy@ and @hw.host.power@ metrics __only__, instead of the generic @hw.energy@ and @hw.power@ described in the previous section, to prevent summing up overlapping values.
--

-- $metric_hw_host_heatingMargin
-- By how many degrees Celsius the temperature of the physical host can be increased, before reaching a warning threshold on one of the internal sensors.
--
-- Stability: development
--

-- $metric_hw_host_power
-- Instantaneous power consumed by the entire physical host in Watts (@hw.host.energy@ is preferred).
--
-- Stability: development
--
-- ==== Note
-- The overall energy usage of a host MUST be reported using the specific @hw.host.energy@ and @hw.host.power@ metrics __only__, instead of the generic @hw.energy@ and @hw.power@ described in the previous section, to prevent summing up overlapping values.
--

-- $metricAttributes_hw_cpu
-- Common attributes for CPU metrics
--
-- === Attributes
-- - 'hw_model'
--
--     Requirement level: recommended
--
-- - 'hw_vendor'
--
--     Requirement level: recommended
--



-- $metric_hw_cpu_speed
-- CPU current frequency.
--
-- Stability: development
--

-- $metric_hw_cpu_speed_limit
-- CPU maximum frequency.
--
-- Stability: development
--
-- === Attributes
-- - 'hw_limitType'
--
--     Requirement level: recommended
--


-- $metricAttributes_hw_voltage_common
-- Common attributes for voltage metrics
--
-- === Attributes
-- - 'hw_sensorLocation'
--
--     Requirement level: recommended
--


-- $metric_hw_voltage
-- Voltage measured by the sensor.
--
-- Stability: development
--

-- $metric_hw_voltage_limit
-- Voltage limit in Volts.
--
-- Stability: development
--
-- === Attributes
-- - 'hw_limitType'
--
--     Requirement level: recommended
--


-- $metric_hw_voltage_nominal
-- Nominal (expected) voltage.
--
-- Stability: development
--

-- $metricAttributes_hw_temperature_common
-- Common attributes for temperature metrics
--
-- === Attributes
-- - 'hw_sensorLocation'
--
--     Requirement level: recommended
--


-- $metric_hw_temperature
-- Temperature in degrees Celsius.
--
-- Stability: development
--

-- $metric_hw_temperature_limit
-- Temperature limit in degrees Celsius.
--
-- Stability: development
--
-- === Attributes
-- - 'hw_limitType'
--
--     Requirement level: recommended
--


-- $hardware_attributes_common
-- Common hardware attributes
--
-- Stability: development
--
-- === Attributes
-- - 'hw_id'
--
--     Requirement level: required
--
-- - 'hw_name'
--
--     Requirement level: recommended
--
-- - 'hw_parent'
--
--     Requirement level: recommended
--




-- $metricAttributes_hw_gpu
-- Common attributes for GPU metrics
--
-- === Attributes
-- - 'hw_driverVersion'
--
--     Requirement level: recommended
--
-- - 'hw_firmwareVersion'
--
--     Requirement level: recommended
--
-- - 'hw_model'
--
--     Requirement level: recommended
--
-- - 'hw_serialNumber'
--
--     Requirement level: recommended
--
-- - 'hw_vendor'
--
--     Requirement level: recommended
--






-- $metric_hw_gpu_io
-- Received and transmitted bytes by the GPU.
--
-- Stability: development
--
-- === Attributes
-- - 'network_io_direction'
--
--     Requirement level: required
--


-- $metric_hw_gpu_memory_limit
-- Size of the GPU memory.
--
-- Stability: development
--

-- $metric_hw_gpu_memory_utilization
-- Fraction of GPU memory used.
--
-- Stability: development
--

-- $metric_hw_gpu_memory_usage
-- GPU memory used.
--
-- Stability: development
--

-- $metric_hw_gpu_utilization
-- Fraction of time spent in a specific task.
--
-- Stability: development
--
-- === Attributes
-- - 'hw_gpu_task'
--
--     Requirement level: recommended
--


-- $registry_hardware
-- Attributes for hardware.
--
-- === Attributes
-- - 'hw_id'
--
--     Stability: development
--
-- - 'hw_name'
--
--     Stability: development
--
-- - 'hw_parent'
--
--     Stability: development
--
-- - 'hw_type'
--
--     Stability: development
--
-- - 'hw_state'
--
--     Stability: development
--
-- - 'hw_battery_state'
--
--     Stability: development
--
-- - 'hw_limitType'
--
--     Stability: development
--
-- - 'hw_biosVersion'
--
--     Stability: development
--
-- - 'hw_driverVersion'
--
--     Stability: development
--
-- - 'hw_firmwareVersion'
--
--     Stability: development
--
-- - 'hw_model'
--
--     Stability: development
--
-- - 'hw_serialNumber'
--
--     Stability: development
--
-- - 'hw_vendor'
--
--     Stability: development
--
-- - 'hw_sensorLocation'
--
--     Stability: development
--
-- - 'hw_battery_chemistry'
--
--     Stability: development
--
-- - 'hw_battery_capacity'
--
--     Stability: development
--
-- - 'hw_enclosure_type'
--
--     Stability: development
--
-- - 'hw_gpu_task'
--
--     Stability: development
--
-- - 'hw_logicalDisk_raidLevel'
--
--     Stability: development
--
-- - 'hw_logicalDisk_state'
--
--     Stability: development
--
-- - 'hw_memory_type'
--
--     Stability: development
--
-- - 'hw_network_logicalAddresses'
--
--     Stability: development
--
-- - 'hw_network_physicalAddress'
--
--     Stability: development
--
-- - 'hw_physicalDisk_type'
--
--     Stability: development
--
-- - 'hw_physicalDisk_state'
--
--     Stability: development
--
-- - 'hw_physicalDisk_smartAttribute'
--
--     Stability: development
--
-- - 'hw_tapeDrive_operationType'
--
--     Stability: development
--

-- |
-- An identifier for the hardware component, unique within the monitored host
hw_id :: AttributeKey Text
hw_id = AttributeKey "hw.id"

-- |
-- An easily-recognizable name for the hardware component
hw_name :: AttributeKey Text
hw_name = AttributeKey "hw.name"

-- |
-- Unique identifier of the parent component (typically the @hw.id@ attribute of the enclosure, or disk controller)
hw_parent :: AttributeKey Text
hw_parent = AttributeKey "hw.parent"

-- |
-- Type of the component

-- ==== Note
-- Describes the category of the hardware component for which @hw.state@ is being reported. For example, @hw.type=temperature@ along with @hw.state=degraded@ would indicate that the temperature of the hardware component has been reported as @degraded@.
hw_type :: AttributeKey Text
hw_type = AttributeKey "hw.type"

-- |
-- The current state of the component
hw_state :: AttributeKey Text
hw_state = AttributeKey "hw.state"

-- |
-- The current state of the battery
hw_battery_state :: AttributeKey Text
hw_battery_state = AttributeKey "hw.battery.state"

-- |
-- Type of limit for hardware components
hw_limitType :: AttributeKey Text
hw_limitType = AttributeKey "hw.limit_type"

-- |
-- BIOS version of the hardware component
hw_biosVersion :: AttributeKey Text
hw_biosVersion = AttributeKey "hw.bios_version"

-- |
-- Driver version for the hardware component
hw_driverVersion :: AttributeKey Text
hw_driverVersion = AttributeKey "hw.driver_version"

-- |
-- Firmware version of the hardware component
hw_firmwareVersion :: AttributeKey Text
hw_firmwareVersion = AttributeKey "hw.firmware_version"

-- |
-- Descriptive model name of the hardware component
hw_model :: AttributeKey Text
hw_model = AttributeKey "hw.model"

-- |
-- Serial number of the hardware component
hw_serialNumber :: AttributeKey Text
hw_serialNumber = AttributeKey "hw.serial_number"

-- |
-- Vendor name of the hardware component
hw_vendor :: AttributeKey Text
hw_vendor = AttributeKey "hw.vendor"

-- |
-- Location of the sensor
hw_sensorLocation :: AttributeKey Text
hw_sensorLocation = AttributeKey "hw.sensor_location"

-- |
-- Battery [chemistry](https:\/\/schemas.dmtf.org\/wbem\/cim-html\/2.31.0\/CIM_Battery.html), e.g. Lithium-Ion, Nickel-Cadmium, etc.
hw_battery_chemistry :: AttributeKey Text
hw_battery_chemistry = AttributeKey "hw.battery.chemistry"

-- |
-- Design capacity in Watts-hours or Amper-hours
hw_battery_capacity :: AttributeKey Text
hw_battery_capacity = AttributeKey "hw.battery.capacity"

-- |
-- Type of the enclosure (useful for modular systems)
hw_enclosure_type :: AttributeKey Text
hw_enclosure_type = AttributeKey "hw.enclosure.type"

-- |
-- Type of task the GPU is performing
hw_gpu_task :: AttributeKey Text
hw_gpu_task = AttributeKey "hw.gpu.task"

-- |
-- RAID Level of the logical disk
hw_logicalDisk_raidLevel :: AttributeKey Text
hw_logicalDisk_raidLevel = AttributeKey "hw.logical_disk.raid_level"

-- |
-- State of the logical disk space usage
hw_logicalDisk_state :: AttributeKey Text
hw_logicalDisk_state = AttributeKey "hw.logical_disk.state"

-- |
-- Type of the memory module
hw_memory_type :: AttributeKey Text
hw_memory_type = AttributeKey "hw.memory.type"

-- |
-- Logical addresses of the adapter (e.g. IP address, or WWPN)
hw_network_logicalAddresses :: AttributeKey [Text]
hw_network_logicalAddresses = AttributeKey "hw.network.logical_addresses"

-- |
-- Physical address of the adapter (e.g. MAC address, or WWNN)
hw_network_physicalAddress :: AttributeKey Text
hw_network_physicalAddress = AttributeKey "hw.network.physical_address"

-- |
-- Type of the physical disk
hw_physicalDisk_type :: AttributeKey Text
hw_physicalDisk_type = AttributeKey "hw.physical_disk.type"

-- |
-- State of the physical disk endurance utilization
hw_physicalDisk_state :: AttributeKey Text
hw_physicalDisk_state = AttributeKey "hw.physical_disk.state"

-- |
-- [S.M.A.R.T.](https:\/\/wikipedia.org\/wiki\/S.M.A.R.T.) (Self-Monitoring, Analysis, and Reporting Technology) attribute of the physical disk
hw_physicalDisk_smartAttribute :: AttributeKey Text
hw_physicalDisk_smartAttribute = AttributeKey "hw.physical_disk.smart_attribute"

-- |
-- Type of tape drive operation
hw_tapeDrive_operationType :: AttributeKey Text
hw_tapeDrive_operationType = AttributeKey "hw.tape_drive.operation_type"

-- $metricAttributes_hw_powerSupply
-- Common attributes for power supply metrics
--
-- === Attributes
-- - 'hw_model'
--
--     Requirement level: recommended
--
-- - 'hw_serialNumber'
--
--     Requirement level: recommended
--
-- - 'hw_vendor'
--
--     Requirement level: recommended
--




-- $metric_hw_powerSupply_limit
-- Maximum power output of the power supply.
--
-- Stability: development
--
-- === Attributes
-- - 'hw_limitType'
--
--     Requirement level: recommended
--


-- $metric_hw_powerSupply_utilization
-- Utilization of the power supply as a fraction of its maximum output.
--
-- Stability: development
--

-- $metric_hw_powerSupply_usage
-- Current power output of the power supply.
--
-- Stability: development
--

-- $metricAttributes_hw_attributes
-- Attributes for hardware metrics
--
-- === Attributes
-- - 'hw_type'
--
--     Requirement level: required
--


-- $metric_hw_energy
-- Energy consumed by the component.
--
-- Stability: development
--

-- $metric_hw_errors
-- Number of errors encountered by the component.
--
-- Stability: development
--
-- === Attributes
-- - 'error_type'
--
--     The type of error encountered by the component.
--
--     Requirement level: conditionally required: if and only if an error has occurred
--
--     ==== Note
--     The @error.type@ SHOULD match the error code reported by the component, the canonical name of the error, or another low-cardinality error identifier. Instrumentations SHOULD document the list of errors they report.
--
-- - 'network_io_direction'
--
--     Direction of network traffic for network errors.
--
--     Requirement level: recommended
--
--     ==== Note
--     This attribute SHOULD only be used when @hw.type@ is set to @"network"@ to indicate the direction of the error.
--



-- $metric_hw_power
-- Instantaneous power consumed by the component.
--
-- Stability: development
--
-- ==== Note
-- It is recommended to report @hw.energy@ instead of @hw.power@ when possible.
--

-- $metric_hw_status
-- Operational status: @1@ (true) or @0@ (false) for each of the possible states.
--
-- Stability: development
--
-- ==== Note
-- @hw.status@ is currently specified as an *UpDownCounter* but would ideally be represented using a [*StateSet* as defined in OpenMetrics](https:\/\/github.com\/prometheus\/OpenMetrics\/blob\/v1.0.0\/specification\/OpenMetrics.md#stateset). This semantic convention will be updated once *StateSet* is specified in OpenTelemetry. This planned change is not expected to have any consequence on the way users query their timeseries backend to retrieve the values of @hw.status@ over time.
--
-- === Attributes
-- - 'hw_state'
--
--     Requirement level: required
--


-- $metricAttributes_hw_tapeDrive
-- Common attributes for tape drive metrics
--
-- === Attributes
-- - 'hw_model'
--
--     Requirement level: recommended
--
-- - 'hw_serialNumber'
--
--     Requirement level: recommended
--
-- - 'hw_vendor'
--
--     Requirement level: recommended
--




-- $metric_hw_tapeDrive_operations
-- Operations performed by the tape drive.
--
-- Stability: development
--
-- === Attributes
-- - 'hw_tapeDrive_operationType'
--
--     Requirement level: recommended
--


-- $metricAttributes_hw_enclosure
-- Common attributes for enclosure metrics
--
-- === Attributes
-- - 'hw_biosVersion'
--
--     Requirement level: recommended
--
-- - 'hw_model'
--
--     Requirement level: recommended
--
-- - 'hw_serialNumber'
--
--     Requirement level: recommended
--
-- - 'hw_enclosure_type'
--
--     Requirement level: recommended
--
-- - 'hw_vendor'
--
--     Requirement level: recommended
--






-- $metricAttributes_hw_physicalDisk
-- Common attributes for physical disk metrics
--
-- === Attributes
-- - 'hw_firmwareVersion'
--
--     Requirement level: recommended
--
-- - 'hw_model'
--
--     Requirement level: recommended
--
-- - 'hw_serialNumber'
--
--     Requirement level: recommended
--
-- - 'hw_physicalDisk_type'
--
--     Requirement level: recommended
--
-- - 'hw_vendor'
--
--     Requirement level: recommended
--






-- $metric_hw_physicalDisk_enduranceUtilization
-- Endurance remaining for this SSD disk.
--
-- Stability: development
--
-- === Attributes
-- - 'hw_physicalDisk_state'
--
--     Requirement level: required
--


-- $metric_hw_physicalDisk_size
-- Size of the disk.
--
-- Stability: development
--

-- $metric_hw_physicalDisk_smart
-- Value of the corresponding [S.M.A.R.T.](https:\/\/wikipedia.org\/wiki\/S.M.A.R.T.) (Self-Monitoring, Analysis, and Reporting Technology) attribute.
--
-- Stability: development
--
-- === Attributes
-- - 'hw_physicalDisk_smartAttribute'
--
--     Requirement level: recommended
--


-- $registry_go
-- This document defines Go related attributes.
--
-- === Attributes
-- - 'go_memory_type'
--
--     Stability: development
--

-- |
-- The type of memory.
go_memory_type :: AttributeKey Text
go_memory_type = AttributeKey "go.memory.type"

-- $metric_go_memory_used
-- Memory used by the Go runtime.
--
-- Stability: development
--
-- ==== Note
-- Computed from @(\/memory\/classes\/total:bytes - \/memory\/classes\/heap\/released:bytes)@.
--
-- === Attributes
-- - 'go_memory_type'
--
--     Requirement level: recommended
--


-- $metric_go_memory_limit
-- Go runtime memory limit configured by the user, if a limit exists.
--
-- Stability: development
--
-- ==== Note
-- Computed from @\/gc\/gomemlimit:bytes@. This metric is excluded if the limit obtained from the Go runtime is math.MaxInt64.
--

-- $metric_go_memory_allocated
-- Memory allocated to the heap by the application.
--
-- Stability: development
--
-- ==== Note
-- Computed from @\/gc\/heap\/allocs:bytes@.
--

-- $metric_go_memory_allocations
-- Count of allocations to the heap by the application.
--
-- Stability: development
--
-- ==== Note
-- Computed from @\/gc\/heap\/allocs:objects@.
--

-- $metric_go_memory_gc_goal
-- Heap size target for the end of the GC cycle.
--
-- Stability: development
--
-- ==== Note
-- Computed from @\/gc\/heap\/goal:bytes@.
--

-- $metric_go_goroutine_count
-- Count of live goroutines.
--
-- Stability: development
--
-- ==== Note
-- Computed from @\/sched\/goroutines:goroutines@.
--

-- $metric_go_processor_limit
-- The number of OS threads that can execute user-level Go code simultaneously.
--
-- Stability: development
--
-- ==== Note
-- Computed from @\/sched\/gomaxprocs:threads@.
--

-- $metric_go_schedule_duration
-- The time goroutines have spent in the scheduler in a runnable state before actually running.
--
-- Stability: development
--
-- ==== Note
-- Computed from @\/sched\/latencies:seconds@. Bucket boundaries are provided by the runtime, and are subject to change.
--

-- $metric_go_config_gogc
-- Heap size target percentage configured by the user, otherwise 100.
--
-- Stability: development
--
-- ==== Note
-- The value range is [0.0,100.0]. Computed from @\/gc\/gogc:percent@.
--

-- $entity_host
-- A host is defined as a computing instance. For example, physical servers, virtual machines, switches or disk array.
--
-- Stability: development
--
-- === Attributes
-- - 'host_id'
--
--     ==== Note
--     Collecting @host.id@ from non-containerized systems
--     
--     __Non-privileged Machine ID Lookup__
--     
--     When collecting @host.id@ for non-containerized systems non-privileged lookups
--     of the machine id are preferred. SDK detector implementations MUST use the
--     sources listed below to obtain the machine id.
--     
--     | OS | Primary | Fallback |
--     | --- | --- | --- |
--     | Linux | contents of @\/etc\/machine-id@ | contents of @\/var\/lib\/dbus\/machine-id@ |
--     | BSD | contents of @\/etc\/hostid@ | output of @kenv -q smbios.system.uuid@ |
--     | MacOS | @IOPlatformUUID@ line from the output of @ioreg -rd1 -c "IOPlatformExpertDevice"@ | - |
--     | Windows | @MachineGuid@ from registry @HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography@ | - |
--     
--     __Privileged Machine ID Lookup__
--     
--     The @host.id@ can be looked up using privileged sources. For example, Linux
--     systems can use the output of @dmidecode -t system@, @dmidecode -t baseboard@,
--     @dmidecode -t chassis@, or read the corresponding data from the filesystem
--     (e.g. @cat \/sys\/devices\/virtual\/dmi\/id\/product_id@,
--     @cat \/sys\/devices\/virtual\/dmi\/id\/product_uuid@, etc), however, SDK resource
--     detector implementations MUST not collect @host.id@ from privileged sources. If
--     privileged lookup of @host.id@ is required, the value should be injected via the
--     @OTEL_RESOURCE_ATTRIBUTES@ environment variable.
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










-- $entity_host_cpu
-- A host\'s CPU information
--
-- Stability: development
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







-- $registry_host
-- A host is defined as a computing instance. For example, physical servers, virtual machines, switches or disk array.
--
-- === Attributes
-- - 'host_id'
--
--     Stability: development
--
-- - 'host_name'
--
--     Stability: development
--
-- - 'host_type'
--
--     Stability: development
--
-- - 'host_arch'
--
--     Stability: development
--
-- - 'host_image_name'
--
--     Stability: development
--
-- - 'host_image_id'
--
--     Stability: development
--
-- - 'host_image_version'
--
--     Stability: development
--
-- - 'host_ip'
--
--     Stability: development
--
-- - 'host_mac'
--
--     Stability: development
--
-- - 'host_cpu_vendor_id'
--
--     Stability: development
--
-- - 'host_cpu_family'
--
--     Stability: development
--
-- - 'host_cpu_model_id'
--
--     Stability: development
--
-- - 'host_cpu_model_name'
--
--     Stability: development
--
-- - 'host_cpu_stepping'
--
--     Stability: development
--
-- - 'host_cpu_cache_l2_size'
--
--     Stability: development
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

-- $entity_app
-- An app used directly by end users — like mobile, web, or desktop.
--
-- Stability: development
--
-- === Attributes
-- - 'app_installation_id'
--
-- - 'app_buildId'
--



-- $registry_app
-- Describes attributes related to client-side applications (e.g. web apps or mobile apps).
--
-- Stability: development
--
-- === Attributes
-- - 'app_installation_id'
--
--     Stability: development
--
-- - 'app_jank_frameCount'
--
--     Stability: development
--
-- - 'app_jank_threshold'
--
--     Stability: development
--
-- - 'app_jank_period'
--
--     Stability: development
--
-- - 'app_screen_coordinate_x'
--
--     Stability: development
--
-- - 'app_screen_coordinate_y'
--
--     Stability: development
--
-- - 'app_screen_id'
--
--     Stability: development
--
-- - 'app_screen_name'
--
--     Stability: development
--
-- - 'app_widget_id'
--
--     Stability: development
--
-- - 'app_widget_name'
--
--     Stability: development
--
-- - 'app_buildId'
--
--     Stability: development
--

-- |
-- A unique identifier representing the installation of an application on a specific device

-- ==== Note
-- Its value SHOULD persist across launches of the same application installation, including through application upgrades.
-- It SHOULD change if the application is uninstalled or if all applications of the vendor are uninstalled.
-- Additionally, users might be able to reset this value (e.g. by clearing application data).
-- If an app is installed multiple times on the same device (e.g. in different accounts on Android), each @app.installation.id@ SHOULD have a different value.
-- If multiple OpenTelemetry SDKs are used within the same application, they SHOULD use the same value for @app.installation.id@.
-- Hardware IDs (e.g. serial number, IMEI, MAC address) MUST NOT be used as the @app.installation.id@.
-- 
-- For iOS, this value SHOULD be equal to the [vendor identifier](https:\/\/developer.apple.com\/documentation\/uikit\/uidevice\/identifierforvendor).
-- 
-- For Android, examples of @app.installation.id@ implementations include:
-- 
-- - [Firebase Installation ID](https:\/\/firebase.google.com\/docs\/projects\/manage-installations).
-- - A globally unique UUID which is persisted across sessions in your application.
-- - [App set ID](https:\/\/developer.android.com\/identity\/app-set-id).
-- - [@Settings.getString(Settings.Secure.ANDROID_ID)@](https:\/\/developer.android.com\/reference\/android\/provider\/Settings.Secure#ANDROID_ID).
-- 
-- More information about Android identifier best practices can be found in the [Android user data IDs guide](https:\/\/developer.android.com\/training\/articles\/user-data-ids).
app_installation_id :: AttributeKey Text
app_installation_id = AttributeKey "app.installation.id"

-- |
-- A number of frame renders that experienced jank.

-- ==== Note
-- Depending on platform limitations, the value provided MAY be approximation.
app_jank_frameCount :: AttributeKey Int64
app_jank_frameCount = AttributeKey "app.jank.frame_count"

-- |
-- The minimum rendering threshold for this jank, in seconds.
app_jank_threshold :: AttributeKey Double
app_jank_threshold = AttributeKey "app.jank.threshold"

-- |
-- The time period, in seconds, for which this jank is being reported.
app_jank_period :: AttributeKey Double
app_jank_period = AttributeKey "app.jank.period"

-- |
-- The x (horizontal) coordinate of a screen coordinate, in screen pixels.
app_screen_coordinate_x :: AttributeKey Int64
app_screen_coordinate_x = AttributeKey "app.screen.coordinate.x"

-- |
-- The y (vertical) component of a screen coordinate, in screen pixels.
app_screen_coordinate_y :: AttributeKey Int64
app_screen_coordinate_y = AttributeKey "app.screen.coordinate.y"

-- |
-- An identifier that uniquely differentiates this screen from other screens in the same application.

-- ==== Note
-- A screen represents only the part of the device display drawn by the app. It typically contains multiple widgets or UI components and is larger in scope than individual widgets. Multiple screens can coexist on the same display simultaneously (e.g., split view on tablets).
app_screen_id :: AttributeKey Text
app_screen_id = AttributeKey "app.screen.id"

-- |
-- The name of an application screen.

-- ==== Note
-- A screen represents only the part of the device display drawn by the app. It typically contains multiple widgets or UI components and is larger in scope than individual widgets. Multiple screens can coexist on the same display simultaneously (e.g., split view on tablets).
app_screen_name :: AttributeKey Text
app_screen_name = AttributeKey "app.screen.name"

-- |
-- An identifier that uniquely differentiates this widget from other widgets in the same application.

-- ==== Note
-- A widget is an application component, typically an on-screen visual GUI element.
app_widget_id :: AttributeKey Text
app_widget_id = AttributeKey "app.widget.id"

-- |
-- The name of an application widget.

-- ==== Note
-- A widget is an application component, typically an on-screen visual GUI element.
app_widget_name :: AttributeKey Text
app_widget_name = AttributeKey "app.widget.name"

-- |
-- Unique identifier for a particular build or compilation of the application.
app_buildId :: AttributeKey Text
app_buildId = AttributeKey "app.build_id"

-- $event_app_screen_click
-- This event represents an instantaneous click on the screen of an application.
--
-- Stability: development
--
-- ==== Note
-- The @app.screen.click@ event can be used to indicate that a user has clicked or tapped on the screen portion of an application. Clicks outside of an application\'s active area SHOULD NOT generate this event. This event does not differentiate between touch\/mouse down and touch\/mouse up. Implementations SHOULD give preference to generating this event at the time the click is complete, typically on touch release or mouse up. The location of the click event MUST be provided in absolute screen pixels.
--
-- === Attributes
-- - 'app_screen_coordinate_x'
--
--     Requirement level: required
--
-- - 'app_screen_coordinate_y'
--
--     Requirement level: required
--
-- - 'app_screen_id'
--
--     Requirement level: recommended
--
-- - 'app_screen_name'
--
--     Requirement level: opt-in
--





-- $event_app_widget_click
-- This event indicates that an application widget has been clicked.
--
-- Stability: development
--
-- ==== Note
-- Use this event to indicate that visual application component has been clicked, typically through a user\'s manual interaction.
--
-- === Attributes
-- - 'app_widget_id'
--
--     Requirement level: required
--
-- - 'app_widget_name'
--
--     Requirement level: opt-in
--
-- - 'app_screen_coordinate_x'
--
--     Requirement level: opt-in
--
-- - 'app_screen_coordinate_y'
--
--     Requirement level: opt-in
--
-- - 'app_screen_id'
--
--     Requirement level: recommended
--
-- - 'app_screen_name'
--
--     Requirement level: opt-in
--







-- $event_app_jank
-- This event indicates that the application has detected substandard UI rendering performance.
--
-- Stability: development
--
-- ==== Note
-- Jank happens when the UI is rendered slowly enough for the user to experience some disruption or sluggishness.
--
-- === Attributes
-- - 'app_jank_frameCount'
--
--     Requirement level: recommended
--
-- - 'app_jank_threshold'
--
--     Requirement level: recommended
--
-- - 'app_jank_period'
--
--     Requirement level: recommended
--




-- $entity_heroku
-- [Heroku dyno metadata](https:\/\/devcenter.heroku.com\/articles\/dyno-metadata)
--
-- Stability: development
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




-- $registry_heroku
-- This document defines attributes for the Heroku platform on which application\/s are running.
--
-- === Attributes
-- - 'heroku_release_creationTimestamp'
--
--     Stability: development
--
-- - 'heroku_release_commit'
--
--     Stability: development
--
-- - 'heroku_app_id'
--
--     Stability: development
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

-- $registry_test
-- This group describes attributes specific to [software tests](https:\/\/wikipedia.org\/wiki\/Software_testing).
--
-- === Attributes
-- - 'test_suite_name'
--
--     Stability: development
--
-- - 'test_suite_run_status'
--
--     Stability: development
--
-- - 'test_case_name'
--
--     Stability: development
--
-- - 'test_case_result_status'
--
--     Stability: development
--

-- |
-- The human readable name of a [test suite](https:\/\/wikipedia.org\/wiki\/Test_suite).
test_suite_name :: AttributeKey Text
test_suite_name = AttributeKey "test.suite.name"

-- |
-- The status of the test suite run.
test_suite_run_status :: AttributeKey Text
test_suite_run_status = AttributeKey "test.suite.run.status"

-- |
-- The fully qualified human readable name of the [test case](https:\/\/wikipedia.org\/wiki\/Test_case).
test_case_name :: AttributeKey Text
test_case_name = AttributeKey "test.case.name"

-- |
-- The status of the actual test case result from test execution.
test_case_result_status :: AttributeKey Text
test_case_result_status = AttributeKey "test.case.result.status"

-- $registry_nfs
-- Describes NFS Attributes
--
-- === Attributes
-- - 'nfs_server_repcache_status'
--
--     Stability: development
--
-- - 'nfs_operation_name'
--
--     Stability: development
--

-- |
-- Linux: one of "hit" (NFSD_STATS_RC_HITS), "miss" (NFSD_STATS_RC_MISSES), or "nocache" (NFSD_STATS_RC_NOCACHE -- uncacheable)
nfs_server_repcache_status :: AttributeKey Text
nfs_server_repcache_status = AttributeKey "nfs.server.repcache.status"

-- |
-- NFSv4+ operation name.
nfs_operation_name :: AttributeKey Text
nfs_operation_name = AttributeKey "nfs.operation.name"

-- $metric_nfs_client_net_count
-- Reports the count of kernel NFS client TCP segments and UDP datagrams handled.
--
-- Stability: development
--
-- ==== Note
-- Linux: this metric is taken from the Linux kernel\'s svc_stat.netudpcnt and svc_stat.nettcpcnt
--
-- === Attributes
-- - 'network_transport'
--


-- $metric_nfs_client_net_tcp_connection_accepted
-- Reports the count of kernel NFS client TCP connections accepted.
--
-- Stability: development
--
-- ==== Note
-- Linux: this metric is taken from the Linux kernel\'s svc_stat.nettcpconn
--

-- $metric_nfs_client_rpc_count
-- Reports the count of kernel NFS client RPCs sent, regardless of whether they\'re accepted\/rejected by the server.
--
-- Stability: development
--
-- ==== Note
-- Linux: this metric is taken from the Linux kernel\'s svc_stat.rpccnt
--

-- $metric_nfs_client_rpc_retransmit_count
-- Reports the count of kernel NFS client RPC retransmits.
--
-- Stability: development
--
-- ==== Note
-- Linux: this metric is taken from the Linux kernel\'s svc_stat.rpcretrans
--

-- $metric_nfs_client_rpc_authrefresh_count
-- Reports the count of kernel NFS client RPC authentication refreshes.
--
-- Stability: development
--
-- ==== Note
-- Linux: this metric is taken from the Linux kernel\'s svc_stat.rpcauthrefresh
--

-- $metric_nfs_client_operation_count
-- Reports the count of kernel NFSv4+ client operations.
--
-- Stability: development
--
-- === Attributes
-- - 'oncRpc_version'
--
-- - 'nfs_operation_name'
--



-- $metric_nfs_client_procedure_count
-- Reports the count of kernel NFS client procedures.
--
-- Stability: development
--
-- === Attributes
-- - 'oncRpc_version'
--
-- - 'oncRpc_procedure_name'
--



-- $metric_nfs_server_repcache_requests
-- Reports the kernel NFS server reply cache request count by cache hit status.
--
-- Stability: development
--
-- === Attributes
-- - 'nfs_server_repcache_status'
--


-- $metric_nfs_server_fh_stale_count
-- Reports the count of kernel NFS server stale file handles.
--
-- Stability: development
--
-- ==== Note
-- Linux: this metric is taken from the Linux kernel NFSD_STATS_FH_STALE counter in the nfsd_net struct
--

-- $metric_nfs_server_io
-- Reports the count of kernel NFS server bytes returned to receive and transmit (read and write) requests.
--
-- Stability: development
--
-- ==== Note
-- Linux: this metric is taken from the Linux kernel NFSD_STATS_IO_READ and NFSD_STATS_IO_WRITE counters in the nfsd_net struct
--
-- === Attributes
-- - 'network_io_direction'
--


-- $metric_nfs_server_thread_count
-- Reports the count of kernel NFS server available threads.
--
-- Stability: development
--
-- ==== Note
-- Linux: this metric is taken from the Linux kernel nfsd_th_cnt variable
--

-- $metric_nfs_server_net_count
-- Reports the count of kernel NFS server TCP segments and UDP datagrams handled.
--
-- Stability: development
--
-- ==== Note
-- Linux: this metric is taken from the Linux kernel\'s svc_stat.nettcpcnt and svc_stat.netudpcnt
--
-- === Attributes
-- - 'network_transport'
--


-- $metric_nfs_server_net_tcp_connection_accepted
-- Reports the count of kernel NFS server TCP connections accepted.
--
-- Stability: development
--
-- ==== Note
-- Linux: this metric is taken from the Linux kernel\'s svc_stat.nettcpconn
--

-- $metric_nfs_server_rpc_count
-- Reports the count of kernel NFS server RPCs handled.
--
-- Stability: development
--
-- ==== Note
-- Linux: this metric is taken from the Linux kernel\'s svc_stat.rpccnt, the count of good RPCs. This metric can have
-- an error.type of "format", "auth", or "client" for svc_stat.badfmt, svc_stat.badauth, and svc_stat.badclnt.
--
-- === Attributes
-- - 'error_type'
--


-- $metric_nfs_server_operation_count
-- Reports the count of kernel NFSv4+ server operations.
--
-- Stability: development
--
-- === Attributes
-- - 'oncRpc_version'
--
-- - 'nfs_operation_name'
--



-- $metric_nfs_server_procedure_count
-- Reports the count of kernel NFS server procedures.
--
-- Stability: development
--
-- === Attributes
-- - 'oncRpc_version'
--
-- - 'oncRpc_procedure_name'
--



-- $pprof
-- Attributes specific to pprof that help convert from pprof to Profiling signal.
--
-- === Attributes
-- - 'pprof_mapping_hasFunctions'
--
--     Requirement level: recommended
--
-- - 'pprof_mapping_hasFilenames'
--
--     Requirement level: recommended
--
-- - 'pprof_mapping_hasLineNumbers'
--
--     Requirement level: recommended
--
-- - 'pprof_mapping_hasInlineFrames'
--
--     Requirement level: recommended
--
-- - 'pprof_location_isFolded'
--
--     Requirement level: recommended
--
-- - 'pprof_profile_comment'
--
--     Requirement level: recommended
--
-- - 'pprof_profile_dropFrames'
--
--     Requirement level: recommended
--
-- - 'pprof_profile_keepFrames'
--
--     Requirement level: recommended
--
-- - 'pprof_profile_docUrl'
--
--     Requirement level: recommended
--
-- - 'pprof_scope_defaultSampleType'
--
--     Requirement level: recommended
--
-- - 'pprof_scope_sampleTypeOrder'
--
--     Requirement level: recommended
--












-- $registry_pprof
-- Attributes specific to pprof that help convert from pprof to Profiling signal.
--
-- === Attributes
-- - 'pprof_mapping_hasFunctions'
--
--     Stability: development
--
-- - 'pprof_mapping_hasFilenames'
--
--     Stability: development
--
-- - 'pprof_mapping_hasLineNumbers'
--
--     Stability: development
--
-- - 'pprof_mapping_hasInlineFrames'
--
--     Stability: development
--
-- - 'pprof_location_isFolded'
--
--     Stability: development
--
-- - 'pprof_profile_comment'
--
--     Stability: development
--
-- - 'pprof_profile_dropFrames'
--
--     Stability: development
--
-- - 'pprof_profile_keepFrames'
--
--     Stability: development
--
-- - 'pprof_profile_docUrl'
--
--     Stability: development
--
-- - 'pprof_scope_defaultSampleType'
--
--     Stability: development
--
-- - 'pprof_scope_sampleTypeOrder'
--
--     Stability: development
--

-- |
-- Indicates that there are functions related to this mapping.
pprof_mapping_hasFunctions :: AttributeKey Bool
pprof_mapping_hasFunctions = AttributeKey "pprof.mapping.has_functions"

-- |
-- Indicates that there are filenames related to this mapping.
pprof_mapping_hasFilenames :: AttributeKey Bool
pprof_mapping_hasFilenames = AttributeKey "pprof.mapping.has_filenames"

-- |
-- Indicates that there are line numbers related to this mapping.
pprof_mapping_hasLineNumbers :: AttributeKey Bool
pprof_mapping_hasLineNumbers = AttributeKey "pprof.mapping.has_line_numbers"

-- |
-- Indicates that there are inline frames related to this mapping.
pprof_mapping_hasInlineFrames :: AttributeKey Bool
pprof_mapping_hasInlineFrames = AttributeKey "pprof.mapping.has_inline_frames"

-- |
-- Provides an indication that multiple symbols map to this location\'s address, for example due to identical code folding by the linker. In that case the line information represents one of the multiple symbols. This field must be recomputed when the symbolization state of the profile changes.
pprof_location_isFolded :: AttributeKey Bool
pprof_location_isFolded = AttributeKey "pprof.location.is_folded"

-- |
-- Free-form text associated with the profile. This field should not be used to store any machine-readable information, it is only for human-friendly content.
pprof_profile_comment :: AttributeKey [Text]
pprof_profile_comment = AttributeKey "pprof.profile.comment"

-- |
-- Frames with Function.function_name fully matching the regexp will be dropped from the samples, along with their successors.
pprof_profile_dropFrames :: AttributeKey Text
pprof_profile_dropFrames = AttributeKey "pprof.profile.drop_frames"

-- |
-- Frames with Function.function_name fully matching the regexp will be kept, even if it matches drop_frames.
pprof_profile_keepFrames :: AttributeKey Text
pprof_profile_keepFrames = AttributeKey "pprof.profile.keep_frames"

-- |
-- Documentation link for this profile type.

-- ==== Note
-- The URL must be absolute and may be missing if the profile was generated by code that did not supply a link
pprof_profile_docUrl :: AttributeKey Text
pprof_profile_docUrl = AttributeKey "pprof.profile.doc_url"

-- |
-- Records the pprof\'s default_sample_type in the original profile. Not set if the default sample type was missing.

-- ==== Note
-- This attribute, if present, MUST be set at the scope level (resource_profiles[].scope_profiles[].scope.attributes[]).
pprof_scope_defaultSampleType :: AttributeKey Text
pprof_scope_defaultSampleType = AttributeKey "pprof.scope.default_sample_type"

-- |
-- Records the indexes of the sample types in the original profile.

-- ==== Note
-- This attribute, if present, MUST be set at the scope level (resource_profiles[].scope_profiles[].scope.attributes[]).
pprof_scope_sampleTypeOrder :: AttributeKey [Int64]
pprof_scope_sampleTypeOrder = AttributeKey "pprof.scope.sample_type_order"

-- $registry_file
-- Describes file attributes.
--
-- === Attributes
-- - 'file_accessed'
--
--     Stability: development
--
-- - 'file_attributes'
--
--     Stability: development
--
-- - 'file_created'
--
--     Stability: development
--
-- - 'file_changed'
--
--     Stability: development
--
-- - 'file_directory'
--
--     Stability: development
--
-- - 'file_extension'
--
--     Stability: development
--
-- - 'file_forkName'
--
--     Stability: development
--
-- - 'file_group_id'
--
--     Stability: development
--
-- - 'file_group_name'
--
--     Stability: development
--
-- - 'file_inode'
--
--     Stability: development
--
-- - 'file_mode'
--
--     Stability: development
--
-- - 'file_modified'
--
--     Stability: development
--
-- - 'file_name'
--
--     Stability: development
--
-- - 'file_owner_id'
--
--     Stability: development
--
-- - 'file_owner_name'
--
--     Stability: development
--
-- - 'file_path'
--
--     Stability: development
--
-- - 'file_size'
--
--     Stability: development
--
-- - 'file_symbolicLink_targetPath'
--
--     Stability: development
--

-- |
-- Time when the file was last accessed, in ISO 8601 format.

-- ==== Note
-- This attribute might not be supported by some file systems — NFS, FAT32, in embedded OS, etc.
file_accessed :: AttributeKey Text
file_accessed = AttributeKey "file.accessed"

-- |
-- Array of file attributes.

-- ==== Note
-- Attributes names depend on the OS or file system. Here’s a non-exhaustive list of values expected for this attribute: @archive@, @compressed@, @directory@, @encrypted@, @execute@, @hidden@, @immutable@, @journaled@, @read@, @readonly@, @symbolic link@, @system@, @temporary@, @write@.
file_attributes :: AttributeKey [Text]
file_attributes = AttributeKey "file.attributes"

-- |
-- Time when the file was created, in ISO 8601 format.

-- ==== Note
-- This attribute might not be supported by some file systems — NFS, FAT32, in embedded OS, etc.
file_created :: AttributeKey Text
file_created = AttributeKey "file.created"

-- |
-- Time when the file attributes or metadata was last changed, in ISO 8601 format.

-- ==== Note
-- @file.changed@ captures the time when any of the file\'s properties or attributes (including the content) are changed, while @file.modified@ captures the timestamp when the file content is modified.
file_changed :: AttributeKey Text
file_changed = AttributeKey "file.changed"

-- |
-- Directory where the file is located. It should include the drive letter, when appropriate.
file_directory :: AttributeKey Text
file_directory = AttributeKey "file.directory"

-- |
-- File extension, excluding the leading dot.

-- ==== Note
-- When the file name has multiple extensions (example.tar.gz), only the last one should be captured ("gz", not "tar.gz").
file_extension :: AttributeKey Text
file_extension = AttributeKey "file.extension"

-- |
-- Name of the fork. A fork is additional data associated with a filesystem object.

-- ==== Note
-- On Linux, a resource fork is used to store additional data with a filesystem object. A file always has at least one fork for the data portion, and additional forks may exist.
-- On NTFS, this is analogous to an Alternate Data Stream (ADS), and the default data stream for a file is just called $DATA. Zone.Identifier is commonly used by Windows to track contents downloaded from the Internet. An ADS is typically of the form: C:\path\to\filename.extension:some_fork_name, and some_fork_name is the value that should populate @fork_name@. @filename.extension@ should populate @file.name@, and @extension@ should populate @file.extension@. The full path, @file.path@, will include the fork name.
file_forkName :: AttributeKey Text
file_forkName = AttributeKey "file.fork_name"

-- |
-- Primary Group ID (GID) of the file.
file_group_id :: AttributeKey Text
file_group_id = AttributeKey "file.group.id"

-- |
-- Primary group name of the file.
file_group_name :: AttributeKey Text
file_group_name = AttributeKey "file.group.name"

-- |
-- Inode representing the file in the filesystem.
file_inode :: AttributeKey Text
file_inode = AttributeKey "file.inode"

-- |
-- Mode of the file in octal representation.
file_mode :: AttributeKey Text
file_mode = AttributeKey "file.mode"

-- |
-- Time when the file content was last modified, in ISO 8601 format.
file_modified :: AttributeKey Text
file_modified = AttributeKey "file.modified"

-- |
-- Name of the file including the extension, without the directory.
file_name :: AttributeKey Text
file_name = AttributeKey "file.name"

-- |
-- The user ID (UID) or security identifier (SID) of the file owner.
file_owner_id :: AttributeKey Text
file_owner_id = AttributeKey "file.owner.id"

-- |
-- Username of the file owner.
file_owner_name :: AttributeKey Text
file_owner_name = AttributeKey "file.owner.name"

-- |
-- Full path to the file, including the file name. It should include the drive letter, when appropriate.
file_path :: AttributeKey Text
file_path = AttributeKey "file.path"

-- |
-- File size in bytes.
file_size :: AttributeKey Int64
file_size = AttributeKey "file.size"

-- |
-- Path to the target of a symbolic link.

-- ==== Note
-- This attribute is only applicable to symbolic links.
file_symbolicLink_targetPath :: AttributeKey Text
file_symbolicLink_targetPath = AttributeKey "file.symbolic_link.target_path"

-- $metric_cpu_time
-- Deprecated. Use @system.cpu.time@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: system.cpu.time
--
-- === Attributes
-- - 'cpu_mode'
--
--     ==== Note
--     Following states SHOULD be used: @user@, @system@, @nice@, @idle@, @iowait@, @interrupt@, @steal@
--
-- - 'cpu_logicalNumber'
--



-- $metric_cpu_utilization
-- Deprecated. Use @system.cpu.utilization@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: system.cpu.utilization
--
-- === Attributes
-- - 'cpu_mode'
--
--     ==== Note
--     Following states SHOULD be used: @user@, @system@, @nice@, @idle@, @iowait@, @interrupt@, @steal@
--
-- - 'cpu_logicalNumber'
--



-- $metric_cpu_frequency
-- Deprecated. Use @system.cpu.frequency@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: system.cpu.frequency
--

-- $registry_cpu
-- Attributes specific to a cpu instance.
--
-- === Attributes
-- - 'cpu_mode'
--
--     Stability: development
--
-- - 'cpu_logicalNumber'
--
--     Stability: development
--

-- |
-- The mode of the CPU
cpu_mode :: AttributeKey Text
cpu_mode = AttributeKey "cpu.mode"

-- |
-- The logical CPU number [0..n-1]
cpu_logicalNumber :: AttributeKey Int64
cpu_logicalNumber = AttributeKey "cpu.logical_number"

-- $registry_azure_client_sdk
-- This section defines generic attributes used by Azure Client Libraries.
--
-- === Attributes
-- - 'azure_service_request_id'
--
--     Stability: development
--
-- - 'azure_resourceProvider_namespace'
--
--     Stability: development
--
-- - 'azure_client_id'
--
--     Stability: development
--

-- |
-- The unique identifier of the service request. It\'s generated by the Azure service and returned with the response.
azure_service_request_id :: AttributeKey Text
azure_service_request_id = AttributeKey "azure.service.request.id"

-- |
-- [Azure Resource Provider Namespace](https:\/\/learn.microsoft.com\/azure\/azure-resource-manager\/management\/azure-services-resource-providers) as recognized by the client.
azure_resourceProvider_namespace :: AttributeKey Text
azure_resourceProvider_namespace = AttributeKey "azure.resource_provider.namespace"

-- |
-- The unique identifier of the client instance.
azure_client_id :: AttributeKey Text
azure_client_id = AttributeKey "azure.client.id"

-- $registry_azure_cosmosdb
-- This section defines attributes for Azure Cosmos DB.
--
-- Stability: development
--
-- === Attributes
-- - 'azure_cosmosdb_connection_mode'
--
--     Stability: development
--
-- - 'azure_cosmosdb_operation_requestCharge'
--
--     Stability: development
--
-- - 'azure_cosmosdb_request_body_size'
--
--     Stability: development
--
-- - 'azure_cosmosdb_operation_contactedRegions'
--
--     Stability: development
--
-- - 'azure_cosmosdb_response_subStatusCode'
--
--     Stability: development
--
-- - 'azure_cosmosdb_consistency_level'
--
--     Stability: development
--

-- |
-- Cosmos client connection mode.
azure_cosmosdb_connection_mode :: AttributeKey Text
azure_cosmosdb_connection_mode = AttributeKey "azure.cosmosdb.connection.mode"

-- |
-- The number of request units consumed by the operation.
azure_cosmosdb_operation_requestCharge :: AttributeKey Double
azure_cosmosdb_operation_requestCharge = AttributeKey "azure.cosmosdb.operation.request_charge"

-- |
-- Request payload size in bytes.
azure_cosmosdb_request_body_size :: AttributeKey Int64
azure_cosmosdb_request_body_size = AttributeKey "azure.cosmosdb.request.body.size"

-- |
-- List of regions contacted during operation in the order that they were contacted. If there is more than one region listed, it indicates that the operation was performed on multiple regions i.e. cross-regional call.

-- ==== Note
-- Region name matches the format of @displayName@ in [Azure Location API](https:\/\/learn.microsoft.com\/rest\/api\/resources\/subscriptions\/list-locations)
azure_cosmosdb_operation_contactedRegions :: AttributeKey [Text]
azure_cosmosdb_operation_contactedRegions = AttributeKey "azure.cosmosdb.operation.contacted_regions"

-- |
-- Cosmos DB sub status code.
azure_cosmosdb_response_subStatusCode :: AttributeKey Int64
azure_cosmosdb_response_subStatusCode = AttributeKey "azure.cosmosdb.response.sub_status_code"

-- |
-- Account or request [consistency level](https:\/\/learn.microsoft.com\/azure\/cosmos-db\/consistency-levels).
azure_cosmosdb_consistency_level :: AttributeKey Text
azure_cosmosdb_consistency_level = AttributeKey "azure.cosmosdb.consistency.level"

-- $metric_azure_cosmosdb_client_operation_requestCharge
-- [Request units](https:\/\/learn.microsoft.com\/azure\/cosmos-db\/request-units) consumed by the operation.
--
-- Stability: development
--
-- === Attributes
-- - 'azure_cosmosdb_operation_contactedRegions'
--
--     Requirement level: recommended: If available
--
-- - 'db_collection_name'
--
--     Cosmos DB container name.
--
--     ==== Note
--     It is RECOMMENDED to capture the value as provided by the application without attempting to do any case normalization.
--



-- $metric_azure_cosmosdb_client_activeInstance_count
-- Number of active client instances.
--
-- Stability: development
--
-- === Attributes
-- - 'server_address'
--
--     Name of the database host.
--
-- - 'server_port'
--
--     Requirement level: conditionally required: If using a port other than the default port for this DBMS and if @server.address@ is set.
--



-- $event_azure_resource_log
-- Describes Azure Resource Log event, see [Azure Resource Log Top-level Schema](https:\/\/learn.microsoft.com\/azure\/azure-monitor\/essentials\/resource-logs-schema#top-level-common-schema) for more details.
--
-- Stability: development
--
-- === Attributes
-- - 'azure_service_request_id'
--
-- - 'cloud_resourceId'
--
--     The [Fully Qualified Azure Resource ID](https:\/\/learn.microsoft.com\/rest\/api\/resources\/resources\/get-by-id) the log is emitted for.
--
--     ==== Note
--     
--



-- $registry_azure_deprecated
-- This section describes deprecated Azure attributes.
--
-- === Attributes
-- - 'az_serviceRequestId'
--
--     Stability: development
--
--     Deprecated: renamed: azure.service.request.id
--
-- - 'az_namespace'
--
--     Stability: development
--
--     Deprecated: renamed: azure.resource_provider.namespace
--

-- |
-- Deprecated, use @azure.service.request.id@ instead.
az_serviceRequestId :: AttributeKey Text
az_serviceRequestId = AttributeKey "az.service_request_id"

-- |
-- Deprecated, use @azure.resource_provider.namespace@ instead.
az_namespace :: AttributeKey Text
az_namespace = AttributeKey "az.namespace"

-- $event_az_resource_log
-- Deprecated. Use @azure.resource.log@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: azure.resource.log
--
-- === Attributes
-- - 'az_serviceRequestId'
--
-- - 'cloud_resourceId'
--
--     The [Fully Qualified Azure Resource ID](https:\/\/learn.microsoft.com\/rest\/api\/resources\/resources\/get-by-id) the log is emitted for.
--
--     ==== Note
--     
--



-- $registry_signalr
-- SignalR attributes
--
-- === Attributes
-- - 'signalr_connection_status'
--
--     Stability: stable
--
-- - 'signalr_transport'
--
--     Stability: stable
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
-- Stability: stable
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
-- Stability: stable
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Http.Connections@; Added in: ASP.NET Core 8.0
--
-- === Attributes
-- - 'signalr_connection_status'
--
-- - 'signalr_transport'
--



-- $entity_cloudfoundry_system
-- The system component which is monitored.
--
-- Stability: development
--
-- === Attributes
-- - 'cloudfoundry_system_id'
--
-- - 'cloudfoundry_system_instance_id'
--



-- $entity_cloudfoundry_app
-- The application which is monitored.
--
-- Stability: development
--
-- === Attributes
-- - 'cloudfoundry_app_id'
--
-- - 'cloudfoundry_app_name'
--



-- $entity_cloudfoundry_space
-- The space of the application which is monitored.
--
-- Stability: development
--
-- === Attributes
-- - 'cloudfoundry_space_id'
--
-- - 'cloudfoundry_space_name'
--



-- $entity_cloudfoundry_org
-- The organization of the application which is monitored.
--
-- Stability: development
--
-- === Attributes
-- - 'cloudfoundry_org_id'
--
-- - 'cloudfoundry_org_name'
--



-- $entity_cloudfoundry_process
-- The process of the application which is monitored.
--
-- Stability: development
--
-- === Attributes
-- - 'cloudfoundry_process_id'
--
-- - 'cloudfoundry_process_type'
--



-- $registry_cloudfoundry
-- CloudFoundry resource attributes.
--
-- === Attributes
-- - 'cloudfoundry_system_id'
--
--     Stability: development
--
-- - 'cloudfoundry_system_instance_id'
--
--     Stability: development
--
-- - 'cloudfoundry_app_name'
--
--     Stability: development
--
-- - 'cloudfoundry_app_id'
--
--     Stability: development
--
-- - 'cloudfoundry_app_instance_id'
--
--     Stability: development
--
-- - 'cloudfoundry_space_name'
--
--     Stability: development
--
-- - 'cloudfoundry_space_id'
--
--     Stability: development
--
-- - 'cloudfoundry_org_name'
--
--     Stability: development
--
-- - 'cloudfoundry_org_id'
--
--     Stability: development
--
-- - 'cloudfoundry_process_id'
--
--     Stability: development
--
-- - 'cloudfoundry_process_type'
--
--     Stability: development
--

-- |
-- A guid or another name describing the event source.

-- ==== Note
-- CloudFoundry defines the @source_id@ in the [Loggregator v2 envelope](https:\/\/github.com\/cloudfoundry\/loggregator-api#v2-envelope).
-- It is used for logs and metrics emitted by CloudFoundry. It is
-- supposed to contain the component name, e.g. "gorouter", for
-- CloudFoundry components.
-- 
-- When system components are instrumented, values from the
-- [Bosh spec](https:\/\/bosh.io\/docs\/jobs\/#properties-spec)
-- should be used. The @system.id@ should be set to
-- @spec.deployment\/spec.name@.
cloudfoundry_system_id :: AttributeKey Text
cloudfoundry_system_id = AttributeKey "cloudfoundry.system.id"

-- |
-- A guid describing the concrete instance of the event source.

-- ==== Note
-- CloudFoundry defines the @instance_id@ in the [Loggregator v2 envelope](https:\/\/github.com\/cloudfoundry\/loggregator-api#v2-envelope).
-- It is used for logs and metrics emitted by CloudFoundry. It is
-- supposed to contain the vm id for CloudFoundry components.
-- 
-- When system components are instrumented, values from the
-- [Bosh spec](https:\/\/bosh.io\/docs\/jobs\/#properties-spec)
-- should be used. The @system.instance.id@ should be set to @spec.id@.
cloudfoundry_system_instance_id :: AttributeKey Text
cloudfoundry_system_instance_id = AttributeKey "cloudfoundry.system.instance.id"

-- |
-- The name of the application.

-- ==== Note
-- Application instrumentation should use the value from environment
-- variable @VCAP_APPLICATION.application_name@. This is the same value
-- as reported by @cf apps@.
cloudfoundry_app_name :: AttributeKey Text
cloudfoundry_app_name = AttributeKey "cloudfoundry.app.name"

-- |
-- The guid of the application.

-- ==== Note
-- Application instrumentation should use the value from environment
-- variable @VCAP_APPLICATION.application_id@. This is the same value as
-- reported by @cf app \<app-name\> --guid@.
cloudfoundry_app_id :: AttributeKey Text
cloudfoundry_app_id = AttributeKey "cloudfoundry.app.id"

-- |
-- The index of the application instance. 0 when just one instance is active.

-- ==== Note
-- CloudFoundry defines the @instance_id@ in the [Loggregator v2 envelope](https:\/\/github.com\/cloudfoundry\/loggregator-api#v2-envelope).
-- It is used for logs and metrics emitted by CloudFoundry. It is
-- supposed to contain the application instance index for applications
-- deployed on the runtime.
-- 
-- Application instrumentation should use the value from environment
-- variable @CF_INSTANCE_INDEX@.
cloudfoundry_app_instance_id :: AttributeKey Text
cloudfoundry_app_instance_id = AttributeKey "cloudfoundry.app.instance.id"

-- |
-- The name of the CloudFoundry space the application is running in.

-- ==== Note
-- Application instrumentation should use the value from environment
-- variable @VCAP_APPLICATION.space_name@. This is the same value as
-- reported by @cf spaces@.
cloudfoundry_space_name :: AttributeKey Text
cloudfoundry_space_name = AttributeKey "cloudfoundry.space.name"

-- |
-- The guid of the CloudFoundry space the application is running in.

-- ==== Note
-- Application instrumentation should use the value from environment
-- variable @VCAP_APPLICATION.space_id@. This is the same value as
-- reported by @cf space \<space-name\> --guid@.
cloudfoundry_space_id :: AttributeKey Text
cloudfoundry_space_id = AttributeKey "cloudfoundry.space.id"

-- |
-- The name of the CloudFoundry organization the app is running in.

-- ==== Note
-- Application instrumentation should use the value from environment
-- variable @VCAP_APPLICATION.org_name@. This is the same value as
-- reported by @cf orgs@.
cloudfoundry_org_name :: AttributeKey Text
cloudfoundry_org_name = AttributeKey "cloudfoundry.org.name"

-- |
-- The guid of the CloudFoundry org the application is running in.

-- ==== Note
-- Application instrumentation should use the value from environment
-- variable @VCAP_APPLICATION.org_id@. This is the same value as
-- reported by @cf org \<org-name\> --guid@.
cloudfoundry_org_id :: AttributeKey Text
cloudfoundry_org_id = AttributeKey "cloudfoundry.org.id"

-- |
-- The UID identifying the process.

-- ==== Note
-- Application instrumentation should use the value from environment
-- variable @VCAP_APPLICATION.process_id@. It is supposed to be equal to
-- @VCAP_APPLICATION.app_id@ for applications deployed to the runtime.
-- For system components, this could be the actual PID.
cloudfoundry_process_id :: AttributeKey Text
cloudfoundry_process_id = AttributeKey "cloudfoundry.process.id"

-- |
-- The type of process.

-- ==== Note
-- CloudFoundry applications can consist of multiple jobs. Usually the
-- main process will be of type @web@. There can be additional background
-- tasks or side-cars with different process types.
cloudfoundry_process_type :: AttributeKey Text
cloudfoundry_process_type = AttributeKey "cloudfoundry.process.type"

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
--     Stability: development
--
-- - 'userAgent_version'
--
--     Stability: development
--

-- |
-- Value of the [HTTP User-Agent](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#field.user-agent) header sent by the client.
userAgent_original :: AttributeKey Text
userAgent_original = AttributeKey "user_agent.original"

-- |
-- Name of the user-agent extracted from original. Usually refers to the browser\'s name.

-- ==== Note
-- [Example](https:\/\/uaparser.dev\/#demo) of extracting browser\'s name from original string. In the case of using a user-agent for non-browser products, such as microservices with multiple names\/versions inside the @user_agent.original@, the most significant name SHOULD be selected. In such a scenario it should align with @user_agent.version@
userAgent_name :: AttributeKey Text
userAgent_name = AttributeKey "user_agent.name"

-- |
-- Version of the user-agent extracted from original. Usually refers to the browser\'s version

-- ==== Note
-- [Example](https:\/\/uaparser.dev\/#demo) of extracting browser\'s version from original string. In the case of using a user-agent for non-browser products, such as microservices with multiple names\/versions inside the @user_agent.original@, the most significant version SHOULD be selected. In such a scenario it should align with @user_agent.name@
userAgent_version :: AttributeKey Text
userAgent_version = AttributeKey "user_agent.version"

-- $registry_userAgent_os
-- Describes the OS user-agent attributes.
--
-- === Attributes
-- - 'userAgent_os_name'
--
--     Stability: development
--
-- - 'userAgent_os_version'
--
--     Stability: development
--
-- - 'userAgent_synthetic_type'
--
--     Stability: development
--

-- |
-- Human readable operating system name.

-- ==== Note
-- For mapping user agent strings to OS names, libraries such as [ua-parser](https:\/\/github.com\/ua-parser) can be utilized.
userAgent_os_name :: AttributeKey Text
userAgent_os_name = AttributeKey "user_agent.os.name"

-- |
-- The version string of the operating system as defined in [Version Attributes](\/docs\/resource\/README.md#version-attributes).

-- ==== Note
-- For mapping user agent strings to OS versions, libraries such as [ua-parser](https:\/\/github.com\/ua-parser) can be utilized.
userAgent_os_version :: AttributeKey Text
userAgent_os_version = AttributeKey "user_agent.os.version"

-- |
-- Specifies the category of synthetic traffic, such as tests or bots.

-- ==== Note
-- This attribute MAY be derived from the contents of the @user_agent.original@ attribute. Components that populate the attribute are responsible for determining what they consider to be synthetic bot or test traffic. This attribute can either be set for self-identification purposes, or on telemetry detected to be generated as a result of a synthetic request. This attribute is useful for distinguishing between genuine client traffic and synthetic traffic generated by bots or tests.
userAgent_synthetic_type :: AttributeKey Text
userAgent_synthetic_type = AttributeKey "user_agent.synthetic.type"

-- $entity_k8s_cluster
-- A Kubernetes Cluster.
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_cluster_name'
--
-- - 'k8s_cluster_uid'
--



-- $entity_k8s_node
-- A Kubernetes Node object.
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_node_name'
--
-- - 'k8s_node_uid'
--
-- - 'k8s_node_label'
--
--     Requirement level: opt-in
--
-- - 'k8s_node_annotation'
--
--     Requirement level: opt-in
--





-- $entity_k8s_namespace
-- A Kubernetes Namespace.
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_namespace_name'
--
-- - 'k8s_namespace_label'
--
--     Requirement level: opt-in
--
-- - 'k8s_namespace_annotation'
--
--     Requirement level: opt-in
--




-- $entity_k8s_pod
-- A Kubernetes Pod object.
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_pod_uid'
--
-- - 'k8s_pod_name'
--
-- - 'k8s_pod_label'
--
--     Requirement level: opt-in
--
-- - 'k8s_pod_annotation'
--
--     Requirement level: opt-in
--
-- - 'k8s_pod_ip'
--
--     Requirement level: opt-in
--
-- - 'k8s_pod_hostname'
--
--     Requirement level: opt-in
--
-- - 'k8s_pod_startTime'
--
--     Requirement level: opt-in
--








-- $entity_k8s_container
-- A container in a [PodTemplate](https:\/\/kubernetes.io\/docs\/concepts\/workloads\/pods\/#pod-templates).
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_container_name'
--
-- - 'k8s_container_restartCount'
--
-- - 'k8s_container_status_lastTerminatedReason'
--




-- $entity_k8s_replicaset
-- A Kubernetes ReplicaSet object.
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_replicaset_uid'
--
-- - 'k8s_replicaset_name'
--
-- - 'k8s_replicaset_label'
--
--     Requirement level: opt-in
--
-- - 'k8s_replicaset_annotation'
--
--     Requirement level: opt-in
--





-- $entity_k8s_deployment
-- A Kubernetes Deployment object.
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_deployment_uid'
--
-- - 'k8s_deployment_name'
--
-- - 'k8s_deployment_label'
--
--     Requirement level: opt-in
--
-- - 'k8s_deployment_annotation'
--
--     Requirement level: opt-in
--





-- $entity_k8s_statefulset
-- A Kubernetes StatefulSet object.
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_statefulset_uid'
--
-- - 'k8s_statefulset_name'
--
-- - 'k8s_statefulset_label'
--
--     Requirement level: opt-in
--
-- - 'k8s_statefulset_annotation'
--
--     Requirement level: opt-in
--





-- $entity_k8s_daemonset
-- A Kubernetes DaemonSet object.
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_daemonset_uid'
--
-- - 'k8s_daemonset_name'
--
-- - 'k8s_daemonset_label'
--
--     Requirement level: opt-in
--
-- - 'k8s_daemonset_annotation'
--
--     Requirement level: opt-in
--





-- $entity_k8s_job
-- A Kubernetes Job object.
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_job_uid'
--
-- - 'k8s_job_name'
--
-- - 'k8s_job_label'
--
--     Requirement level: opt-in
--
-- - 'k8s_job_annotation'
--
--     Requirement level: opt-in
--





-- $entity_k8s_cronjob
-- A Kubernetes CronJob object.
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_cronjob_uid'
--
-- - 'k8s_cronjob_name'
--
-- - 'k8s_cronjob_label'
--
--     Requirement level: opt-in
--
-- - 'k8s_cronjob_annotation'
--
--     Requirement level: opt-in
--





-- $entity_k8s_replicationcontroller
-- A Kubernetes ReplicationController object.
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_replicationcontroller_uid'
--
-- - 'k8s_replicationcontroller_name'
--



-- $entity_k8s_hpa
-- A Kubernetes HorizontalPodAutoscaler object.
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_hpa_uid'
--
-- - 'k8s_hpa_name'
--
-- - 'k8s_hpa_scaletargetref_kind'
--
--     Requirement level: recommended
--
-- - 'k8s_hpa_scaletargetref_name'
--
--     Requirement level: recommended
--
-- - 'k8s_hpa_scaletargetref_apiVersion'
--
--     Requirement level: recommended
--






-- $entity_k8s_resourcequota
-- A Kubernetes ResourceQuota object.
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_resourcequota_uid'
--
-- - 'k8s_resourcequota_name'
--



-- $entity_k8s_service
-- A Kubernetes Service object.
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_service_uid'
--
-- - 'k8s_service_name'
--
-- - 'k8s_service_type'
--
-- - 'k8s_service_trafficDistribution'
--
--     Requirement level: opt-in
--
-- - 'k8s_service_publishNotReadyAddresses'
--
--     Requirement level: opt-in
--
-- - 'k8s_service_selector'
--
--     Requirement level: opt-in
--
-- - 'k8s_service_label'
--
--     Requirement level: opt-in
--
-- - 'k8s_service_annotation'
--
--     Requirement level: opt-in
--









-- $registry_k8s
-- Kubernetes resource attributes.
--
-- === Attributes
-- - 'k8s_cluster_name'
--
--     Stability: beta
--
-- - 'k8s_cluster_uid'
--
--     Stability: beta
--
-- - 'k8s_node_name'
--
--     Stability: beta
--
-- - 'k8s_node_uid'
--
--     Stability: beta
--
-- - 'k8s_node_label'
--
--     Stability: beta
--
-- - 'k8s_node_annotation'
--
--     Stability: beta
--
-- - 'k8s_namespace_name'
--
--     Stability: beta
--
-- - 'k8s_namespace_label'
--
--     Stability: beta
--
-- - 'k8s_namespace_annotation'
--
--     Stability: beta
--
-- - 'k8s_pod_uid'
--
--     Stability: beta
--
-- - 'k8s_pod_name'
--
--     Stability: beta
--
-- - 'k8s_pod_ip'
--
--     Stability: beta
--
-- - 'k8s_pod_hostname'
--
--     Stability: beta
--
-- - 'k8s_pod_startTime'
--
--     Stability: beta
--
-- - 'k8s_pod_label'
--
--     Stability: beta
--
-- - 'k8s_pod_annotation'
--
--     Stability: beta
--
-- - 'k8s_container_name'
--
--     Stability: beta
--
-- - 'k8s_container_restartCount'
--
--     Stability: beta
--
-- - 'k8s_container_status_lastTerminatedReason'
--
--     Stability: development
--
-- - 'k8s_replicaset_uid'
--
--     Stability: beta
--
-- - 'k8s_replicaset_name'
--
--     Stability: beta
--
-- - 'k8s_replicaset_label'
--
--     Stability: beta
--
-- - 'k8s_replicaset_annotation'
--
--     Stability: beta
--
-- - 'k8s_replicationcontroller_uid'
--
--     Stability: development
--
-- - 'k8s_replicationcontroller_name'
--
--     Stability: development
--
-- - 'k8s_resourcequota_uid'
--
--     Stability: development
--
-- - 'k8s_resourcequota_name'
--
--     Stability: development
--
-- - 'k8s_deployment_uid'
--
--     Stability: beta
--
-- - 'k8s_deployment_name'
--
--     Stability: beta
--
-- - 'k8s_deployment_label'
--
--     Stability: beta
--
-- - 'k8s_deployment_annotation'
--
--     Stability: beta
--
-- - 'k8s_statefulset_uid'
--
--     Stability: beta
--
-- - 'k8s_statefulset_name'
--
--     Stability: beta
--
-- - 'k8s_statefulset_label'
--
--     Stability: beta
--
-- - 'k8s_statefulset_annotation'
--
--     Stability: beta
--
-- - 'k8s_daemonset_uid'
--
--     Stability: beta
--
-- - 'k8s_daemonset_name'
--
--     Stability: beta
--
-- - 'k8s_daemonset_label'
--
--     Stability: beta
--
-- - 'k8s_daemonset_annotation'
--
--     Stability: beta
--
-- - 'k8s_hpa_uid'
--
--     Stability: development
--
-- - 'k8s_hpa_name'
--
--     Stability: development
--
-- - 'k8s_hpa_scaletargetref_kind'
--
--     Stability: development
--
-- - 'k8s_hpa_scaletargetref_name'
--
--     Stability: development
--
-- - 'k8s_hpa_scaletargetref_apiVersion'
--
--     Stability: development
--
-- - 'k8s_hpa_metric_type'
--
--     Stability: development
--
-- - 'k8s_job_uid'
--
--     Stability: beta
--
-- - 'k8s_job_name'
--
--     Stability: beta
--
-- - 'k8s_job_label'
--
--     Stability: beta
--
-- - 'k8s_job_annotation'
--
--     Stability: beta
--
-- - 'k8s_cronjob_uid'
--
--     Stability: beta
--
-- - 'k8s_cronjob_name'
--
--     Stability: beta
--
-- - 'k8s_cronjob_label'
--
--     Stability: beta
--
-- - 'k8s_cronjob_annotation'
--
--     Stability: beta
--
-- - 'k8s_volume_name'
--
--     Stability: development
--
-- - 'k8s_volume_type'
--
--     Stability: development
--
-- - 'k8s_namespace_phase'
--
--     Stability: development
--
-- - 'k8s_node_condition_type'
--
--     Stability: development
--
-- - 'k8s_node_condition_status'
--
--     Stability: development
--
-- - 'k8s_container_status_state'
--
--     Stability: experimental
--
-- - 'k8s_container_status_reason'
--
--     Stability: experimental
--
-- - 'k8s_hugepage_size'
--
--     Stability: development
--
-- - 'k8s_storageclass_name'
--
--     Stability: development
--
-- - 'k8s_resourcequota_resourceName'
--
--     Stability: development
--
-- - 'k8s_pod_status_reason'
--
--     Stability: development
--
-- - 'k8s_pod_status_phase'
--
--     Stability: development
--
-- - 'k8s_service_uid'
--
--     Stability: development
--
-- - 'k8s_service_name'
--
--     Stability: development
--
-- - 'k8s_service_type'
--
--     Stability: development
--
-- - 'k8s_service_trafficDistribution'
--
--     Stability: development
--
-- - 'k8s_service_selector'
--
--     Stability: development
--
-- - 'k8s_service_label'
--
--     Stability: development
--
-- - 'k8s_service_annotation'
--
--     Stability: development
--
-- - 'k8s_service_publishNotReadyAddresses'
--
--     Stability: development
--
-- - 'k8s_service_endpoint_condition'
--
--     Stability: development
--
-- - 'k8s_service_endpoint_addressType'
--
--     Stability: development
--
-- - 'k8s_service_endpoint_zone'
--
--     Stability: development
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
-- \> ITU-T X.667 | ISO\/IEC 9834-8, a UUID is either guaranteed to be
-- \> different from all other UUIDs generated before 3603 A.D., or is
-- \> extremely likely to be different (depending on the mechanism chosen).
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
-- The label placed on the Node, the @\<key\>@ being the label name, the value being the label value, even if the value is empty.

-- ==== Note
-- Examples:
-- 
-- - A label @kubernetes.io\/arch@ with value @arm64@ SHOULD be recorded
--   as the @k8s.node.label.kubernetes.io\/arch@ attribute with value @"arm64"@.
-- - A label @data@ with empty string value SHOULD be recorded as
--   the @k8s.node.label.data@ attribute with value @""@.
k8s_node_label :: Text -> AttributeKey Text
k8s_node_label = \k -> AttributeKey $ "k8s.node.label." <> k

-- |
-- The annotation placed on the Node, the @\<key\>@ being the annotation name, the value being the annotation value, even if the value is empty.

-- ==== Note
-- Examples:
-- 
-- - An annotation @node.alpha.kubernetes.io\/ttl@ with value @0@ SHOULD be recorded as
--   the @k8s.node.annotation.node.alpha.kubernetes.io\/ttl@ attribute with value @"0"@.
-- - An annotation @data@ with empty string value SHOULD be recorded as
--   the @k8s.node.annotation.data@ attribute with value @""@.
k8s_node_annotation :: Text -> AttributeKey Text
k8s_node_annotation = \k -> AttributeKey $ "k8s.node.annotation." <> k

-- |
-- The name of the namespace that the pod is running in.
k8s_namespace_name :: AttributeKey Text
k8s_namespace_name = AttributeKey "k8s.namespace.name"

-- |
-- The label placed on the Namespace, the @\<key\>@ being the label name, the value being the label value, even if the value is empty.

-- ==== Note
-- 
-- Examples:
-- 
-- - A label @kubernetes.io\/metadata.name@ with value @default@ SHOULD be recorded
--   as the @k8s.namespace.label.kubernetes.io\/metadata.name@ attribute with value @"default"@.
-- - A label @data@ with empty string value SHOULD be recorded as
--   the @k8s.namespace.label.data@ attribute with value @""@.
k8s_namespace_label :: Text -> AttributeKey Text
k8s_namespace_label = \k -> AttributeKey $ "k8s.namespace.label." <> k

-- |
-- The annotation placed on the Namespace, the @\<key\>@ being the annotation name, the value being the annotation value, even if the value is empty.

-- ==== Note
-- 
-- Examples:
-- 
-- - A label @ttl@ with value @0@ SHOULD be recorded
--   as the @k8s.namespace.annotation.ttl@ attribute with value @"0"@.
-- - A label @data@ with empty string value SHOULD be recorded as
--   the @k8s.namespace.annotation.data@ attribute with value @""@.
k8s_namespace_annotation :: Text -> AttributeKey Text
k8s_namespace_annotation = \k -> AttributeKey $ "k8s.namespace.annotation." <> k

-- |
-- The UID of the Pod.
k8s_pod_uid :: AttributeKey Text
k8s_pod_uid = AttributeKey "k8s.pod.uid"

-- |
-- The name of the Pod.
k8s_pod_name :: AttributeKey Text
k8s_pod_name = AttributeKey "k8s.pod.name"

-- |
-- IP address allocated to the Pod.

-- ==== Note
-- This attribute aligns with the @podIP@ field of the
-- [K8s PodStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.34\/#podstatus-v1-core).
k8s_pod_ip :: AttributeKey Text
k8s_pod_ip = AttributeKey "k8s.pod.ip"

-- |
-- Specifies the hostname of the Pod.

-- ==== Note
-- The K8s Pod spec has an optional hostname field, which can be used to specify a hostname.
-- Refer to [K8s docs](https:\/\/kubernetes.io\/docs\/concepts\/services-networking\/dns-pod-service\/#pod-hostname-and-subdomain-field)
-- for more information about this field.
-- 
-- This attribute aligns with the @hostname@ field of the
-- [K8s PodSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.34\/#podspec-v1-core).
k8s_pod_hostname :: AttributeKey Text
k8s_pod_hostname = AttributeKey "k8s.pod.hostname"

-- |
-- The start timestamp of the Pod.

-- ==== Note
-- Date and time at which the object was acknowledged by the Kubelet.
-- This is before the Kubelet pulled the container image(s) for the pod.
-- 
-- This attribute aligns with the @startTime@ field of the
-- [K8s PodStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.34\/#podstatus-v1-core),
-- in ISO 8601 (RFC 3339 compatible) format.
k8s_pod_startTime :: AttributeKey Text
k8s_pod_startTime = AttributeKey "k8s.pod.start_time"

-- |
-- The label placed on the Pod, the @\<key\>@ being the label name, the value being the label value.

-- ==== Note
-- Examples:
-- 
-- - A label @app@ with value @my-app@ SHOULD be recorded as
--   the @k8s.pod.label.app@ attribute with value @"my-app"@.
-- - A label @mycompany.io\/arch@ with value @x64@ SHOULD be recorded as
--   the @k8s.pod.label.mycompany.io\/arch@ attribute with value @"x64"@.
-- - A label @data@ with empty string value SHOULD be recorded as
--   the @k8s.pod.label.data@ attribute with value @""@.
k8s_pod_label :: Text -> AttributeKey Text
k8s_pod_label = \k -> AttributeKey $ "k8s.pod.label." <> k

-- |
-- The annotation placed on the Pod, the @\<key\>@ being the annotation name, the value being the annotation value.

-- ==== Note
-- Examples:
-- 
-- - An annotation @kubernetes.io\/enforce-mountable-secrets@ with value @true@ SHOULD be recorded as
--   the @k8s.pod.annotation.kubernetes.io\/enforce-mountable-secrets@ attribute with value @"true"@.
-- - An annotation @mycompany.io\/arch@ with value @x64@ SHOULD be recorded as
--   the @k8s.pod.annotation.mycompany.io\/arch@ attribute with value @"x64"@.
-- - An annotation @data@ with empty string value SHOULD be recorded as
--   the @k8s.pod.annotation.data@ attribute with value @""@.
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
-- Last terminated reason of the Container.
k8s_container_status_lastTerminatedReason :: AttributeKey Text
k8s_container_status_lastTerminatedReason = AttributeKey "k8s.container.status.last_terminated_reason"

-- |
-- The UID of the ReplicaSet.
k8s_replicaset_uid :: AttributeKey Text
k8s_replicaset_uid = AttributeKey "k8s.replicaset.uid"

-- |
-- The name of the ReplicaSet.
k8s_replicaset_name :: AttributeKey Text
k8s_replicaset_name = AttributeKey "k8s.replicaset.name"

-- |
-- The label placed on the ReplicaSet, the @\<key\>@ being the label name, the value being the label value, even if the value is empty.

-- ==== Note
-- 
-- Examples:
-- 
-- - A label @app@ with value @guestbook@ SHOULD be recorded
--   as the @k8s.replicaset.label.app@ attribute with value @"guestbook"@.
-- - A label @injected@ with empty string value SHOULD be recorded as
--   the @k8s.replicaset.label.injected@ attribute with value @""@.
k8s_replicaset_label :: Text -> AttributeKey Text
k8s_replicaset_label = \k -> AttributeKey $ "k8s.replicaset.label." <> k

-- |
-- The annotation placed on the ReplicaSet, the @\<key\>@ being the annotation name, the value being the annotation value, even if the value is empty.

-- ==== Note
-- 
-- Examples:
-- 
-- - A label @replicas@ with value @0@ SHOULD be recorded
--   as the @k8s.replicaset.annotation.replicas@ attribute with value @"0"@.
-- - A label @data@ with empty string value SHOULD be recorded as
--   the @k8s.replicaset.annotation.data@ attribute with value @""@.
k8s_replicaset_annotation :: Text -> AttributeKey Text
k8s_replicaset_annotation = \k -> AttributeKey $ "k8s.replicaset.annotation." <> k

-- |
-- The UID of the replication controller.
k8s_replicationcontroller_uid :: AttributeKey Text
k8s_replicationcontroller_uid = AttributeKey "k8s.replicationcontroller.uid"

-- |
-- The name of the replication controller.
k8s_replicationcontroller_name :: AttributeKey Text
k8s_replicationcontroller_name = AttributeKey "k8s.replicationcontroller.name"

-- |
-- The UID of the resource quota.
k8s_resourcequota_uid :: AttributeKey Text
k8s_resourcequota_uid = AttributeKey "k8s.resourcequota.uid"

-- |
-- The name of the resource quota.
k8s_resourcequota_name :: AttributeKey Text
k8s_resourcequota_name = AttributeKey "k8s.resourcequota.name"

-- |
-- The UID of the Deployment.
k8s_deployment_uid :: AttributeKey Text
k8s_deployment_uid = AttributeKey "k8s.deployment.uid"

-- |
-- The name of the Deployment.
k8s_deployment_name :: AttributeKey Text
k8s_deployment_name = AttributeKey "k8s.deployment.name"

-- |
-- The label placed on the Deployment, the @\<key\>@ being the label name, the value being the label value, even if the value is empty.

-- ==== Note
-- 
-- Examples:
-- 
-- - A label @replicas@ with value @0@ SHOULD be recorded
--   as the @k8s.deployment.label.app@ attribute with value @"guestbook"@.
-- - A label @injected@ with empty string value SHOULD be recorded as
--   the @k8s.deployment.label.injected@ attribute with value @""@.
k8s_deployment_label :: Text -> AttributeKey Text
k8s_deployment_label = \k -> AttributeKey $ "k8s.deployment.label." <> k

-- |
-- The annotation placed on the Deployment, the @\<key\>@ being the annotation name, the value being the annotation value, even if the value is empty.

-- ==== Note
-- 
-- Examples:
-- 
-- - A label @replicas@ with value @1@ SHOULD be recorded
--   as the @k8s.deployment.annotation.replicas@ attribute with value @"1"@.
-- - A label @data@ with empty string value SHOULD be recorded as
--   the @k8s.deployment.annotation.data@ attribute with value @""@.
k8s_deployment_annotation :: Text -> AttributeKey Text
k8s_deployment_annotation = \k -> AttributeKey $ "k8s.deployment.annotation." <> k

-- |
-- The UID of the StatefulSet.
k8s_statefulset_uid :: AttributeKey Text
k8s_statefulset_uid = AttributeKey "k8s.statefulset.uid"

-- |
-- The name of the StatefulSet.
k8s_statefulset_name :: AttributeKey Text
k8s_statefulset_name = AttributeKey "k8s.statefulset.name"

-- |
-- The label placed on the StatefulSet, the @\<key\>@ being the label name, the value being the label value, even if the value is empty.

-- ==== Note
-- 
-- Examples:
-- 
-- - A label @replicas@ with value @0@ SHOULD be recorded
--   as the @k8s.statefulset.label.app@ attribute with value @"guestbook"@.
-- - A label @injected@ with empty string value SHOULD be recorded as
--   the @k8s.statefulset.label.injected@ attribute with value @""@.
k8s_statefulset_label :: Text -> AttributeKey Text
k8s_statefulset_label = \k -> AttributeKey $ "k8s.statefulset.label." <> k

-- |
-- The annotation placed on the StatefulSet, the @\<key\>@ being the annotation name, the value being the annotation value, even if the value is empty.

-- ==== Note
-- 
-- Examples:
-- 
-- - A label @replicas@ with value @1@ SHOULD be recorded
--   as the @k8s.statefulset.annotation.replicas@ attribute with value @"1"@.
-- - A label @data@ with empty string value SHOULD be recorded as
--   the @k8s.statefulset.annotation.data@ attribute with value @""@.
k8s_statefulset_annotation :: Text -> AttributeKey Text
k8s_statefulset_annotation = \k -> AttributeKey $ "k8s.statefulset.annotation." <> k

-- |
-- The UID of the DaemonSet.
k8s_daemonset_uid :: AttributeKey Text
k8s_daemonset_uid = AttributeKey "k8s.daemonset.uid"

-- |
-- The name of the DaemonSet.
k8s_daemonset_name :: AttributeKey Text
k8s_daemonset_name = AttributeKey "k8s.daemonset.name"

-- |
-- The label placed on the DaemonSet, the @\<key\>@ being the label name, the value being the label value, even if the value is empty.

-- ==== Note
-- 
-- Examples:
-- 
-- - A label @app@ with value @guestbook@ SHOULD be recorded
--   as the @k8s.daemonset.label.app@ attribute with value @"guestbook"@.
-- - A label @data@ with empty string value SHOULD be recorded as
--   the @k8s.daemonset.label.injected@ attribute with value @""@.
k8s_daemonset_label :: Text -> AttributeKey Text
k8s_daemonset_label = \k -> AttributeKey $ "k8s.daemonset.label." <> k

-- |
-- The annotation placed on the DaemonSet, the @\<key\>@ being the annotation name, the value being the annotation value, even if the value is empty.

-- ==== Note
-- 
-- Examples:
-- 
-- - A label @replicas@ with value @1@ SHOULD be recorded
--   as the @k8s.daemonset.annotation.replicas@ attribute with value @"1"@.
-- - A label @data@ with empty string value SHOULD be recorded as
--   the @k8s.daemonset.annotation.data@ attribute with value @""@.
k8s_daemonset_annotation :: Text -> AttributeKey Text
k8s_daemonset_annotation = \k -> AttributeKey $ "k8s.daemonset.annotation." <> k

-- |
-- The UID of the horizontal pod autoscaler.
k8s_hpa_uid :: AttributeKey Text
k8s_hpa_uid = AttributeKey "k8s.hpa.uid"

-- |
-- The name of the horizontal pod autoscaler.
k8s_hpa_name :: AttributeKey Text
k8s_hpa_name = AttributeKey "k8s.hpa.name"

-- |
-- The kind of the target resource to scale for the HorizontalPodAutoscaler.

-- ==== Note
-- This maps to the @kind@ field in the @scaleTargetRef@ of the HPA spec.
k8s_hpa_scaletargetref_kind :: AttributeKey Text
k8s_hpa_scaletargetref_kind = AttributeKey "k8s.hpa.scaletargetref.kind"

-- |
-- The name of the target resource to scale for the HorizontalPodAutoscaler.

-- ==== Note
-- This maps to the @name@ field in the @scaleTargetRef@ of the HPA spec.
k8s_hpa_scaletargetref_name :: AttributeKey Text
k8s_hpa_scaletargetref_name = AttributeKey "k8s.hpa.scaletargetref.name"

-- |
-- The API version of the target resource to scale for the HorizontalPodAutoscaler.

-- ==== Note
-- This maps to the @apiVersion@ field in the @scaleTargetRef@ of the HPA spec.
k8s_hpa_scaletargetref_apiVersion :: AttributeKey Text
k8s_hpa_scaletargetref_apiVersion = AttributeKey "k8s.hpa.scaletargetref.api_version"

-- |
-- The type of metric source for the horizontal pod autoscaler.

-- ==== Note
-- This attribute reflects the @type@ field of spec.metrics[] in the HPA.
k8s_hpa_metric_type :: AttributeKey Text
k8s_hpa_metric_type = AttributeKey "k8s.hpa.metric.type"

-- |
-- The UID of the Job.
k8s_job_uid :: AttributeKey Text
k8s_job_uid = AttributeKey "k8s.job.uid"

-- |
-- The name of the Job.
k8s_job_name :: AttributeKey Text
k8s_job_name = AttributeKey "k8s.job.name"

-- |
-- The label placed on the Job, the @\<key\>@ being the label name, the value being the label value, even if the value is empty.

-- ==== Note
-- 
-- Examples:
-- 
-- - A label @jobtype@ with value @ci@ SHOULD be recorded
--   as the @k8s.job.label.jobtype@ attribute with value @"ci"@.
-- - A label @data@ with empty string value SHOULD be recorded as
--   the @k8s.job.label.automated@ attribute with value @""@.
k8s_job_label :: Text -> AttributeKey Text
k8s_job_label = \k -> AttributeKey $ "k8s.job.label." <> k

-- |
-- The annotation placed on the Job, the @\<key\>@ being the annotation name, the value being the annotation value, even if the value is empty.

-- ==== Note
-- 
-- Examples:
-- 
-- - A label @number@ with value @1@ SHOULD be recorded
--   as the @k8s.job.annotation.number@ attribute with value @"1"@.
-- - A label @data@ with empty string value SHOULD be recorded as
--   the @k8s.job.annotation.data@ attribute with value @""@.
k8s_job_annotation :: Text -> AttributeKey Text
k8s_job_annotation = \k -> AttributeKey $ "k8s.job.annotation." <> k

-- |
-- The UID of the CronJob.
k8s_cronjob_uid :: AttributeKey Text
k8s_cronjob_uid = AttributeKey "k8s.cronjob.uid"

-- |
-- The name of the CronJob.
k8s_cronjob_name :: AttributeKey Text
k8s_cronjob_name = AttributeKey "k8s.cronjob.name"

-- |
-- The label placed on the CronJob, the @\<key\>@ being the label name, the value being the label value.

-- ==== Note
-- Examples:
-- 
-- - A label @type@ with value @weekly@ SHOULD be recorded as the
--   @k8s.cronjob.label.type@ attribute with value @"weekly"@.
-- - A label @automated@ with empty string value SHOULD be recorded as
--   the @k8s.cronjob.label.automated@ attribute with value @""@.
k8s_cronjob_label :: Text -> AttributeKey Text
k8s_cronjob_label = \k -> AttributeKey $ "k8s.cronjob.label." <> k

-- |
-- The cronjob annotation placed on the CronJob, the @\<key\>@ being the annotation name, the value being the annotation value.

-- ==== Note
-- Examples:
-- 
-- - An annotation @retries@ with value @4@ SHOULD be recorded as the
--   @k8s.cronjob.annotation.retries@ attribute with value @"4"@.
-- - An annotation @data@ with empty string value SHOULD be recorded as
--   the @k8s.cronjob.annotation.data@ attribute with value @""@.
k8s_cronjob_annotation :: Text -> AttributeKey Text
k8s_cronjob_annotation = \k -> AttributeKey $ "k8s.cronjob.annotation." <> k

-- |
-- The name of the K8s volume.
k8s_volume_name :: AttributeKey Text
k8s_volume_name = AttributeKey "k8s.volume.name"

-- |
-- The type of the K8s volume.
k8s_volume_type :: AttributeKey Text
k8s_volume_type = AttributeKey "k8s.volume.type"

-- |
-- The phase of the K8s namespace.

-- ==== Note
-- This attribute aligns with the @phase@ field of the
-- [K8s NamespaceStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#namespacestatus-v1-core)
k8s_namespace_phase :: AttributeKey Text
k8s_namespace_phase = AttributeKey "k8s.namespace.phase"

-- |
-- The condition type of a K8s Node.

-- ==== Note
-- K8s Node conditions as described
-- by [K8s documentation](https:\/\/v1-32.docs.kubernetes.io\/docs\/reference\/node\/node-status\/#condition).
-- 
-- This attribute aligns with the @type@ field of the
-- [NodeCondition](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#nodecondition-v1-core)
-- 
-- The set of possible values is not limited to those listed here. Managed Kubernetes environments,
-- or custom controllers MAY introduce additional node condition types.
-- When this occurs, the exact value as reported by the Kubernetes API SHOULD be used.
k8s_node_condition_type :: AttributeKey Text
k8s_node_condition_type = AttributeKey "k8s.node.condition.type"

-- |
-- The status of the condition, one of True, False, Unknown.

-- ==== Note
-- This attribute aligns with the @status@ field of the
-- [NodeCondition](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#nodecondition-v1-core)
k8s_node_condition_status :: AttributeKey Text
k8s_node_condition_status = AttributeKey "k8s.node.condition.status"

-- |
-- The state of the container. [K8s ContainerState](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#containerstate-v1-core)
k8s_container_status_state :: AttributeKey Text
k8s_container_status_state = AttributeKey "k8s.container.status.state"

-- |
-- The reason for the container state. Corresponds to the @reason@ field of the: [K8s ContainerStateWaiting](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#containerstatewaiting-v1-core) or [K8s ContainerStateTerminated](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#containerstateterminated-v1-core)
k8s_container_status_reason :: AttributeKey Text
k8s_container_status_reason = AttributeKey "k8s.container.status.reason"

-- |
-- The size (identifier) of the K8s huge page.
k8s_hugepage_size :: AttributeKey Text
k8s_hugepage_size = AttributeKey "k8s.hugepage.size"

-- |
-- The name of K8s [StorageClass](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#storageclass-v1-storage-k8s-io) object.
k8s_storageclass_name :: AttributeKey Text
k8s_storageclass_name = AttributeKey "k8s.storageclass.name"

-- |
-- The name of the K8s resource a resource quota defines.

-- ==== Note
-- The value for this attribute can be either the full @count\/\<resource\>[.\<group\>]@ string (e.g., count\/deployments.apps, count\/pods), or, for certain core Kubernetes resources, just the resource name (e.g., pods, services, configmaps). Both forms are supported by Kubernetes for object count quotas. See [Kubernetes Resource Quotas documentation](https:\/\/kubernetes.io\/docs\/concepts\/policy\/resource-quotas\/#quota-on-object-count) for more details.
k8s_resourcequota_resourceName :: AttributeKey Text
k8s_resourcequota_resourceName = AttributeKey "k8s.resourcequota.resource_name"

-- |
-- The reason for the pod state. Corresponds to the @reason@ field of the: [K8s PodStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.33\/#podstatus-v1-core)
k8s_pod_status_reason :: AttributeKey Text
k8s_pod_status_reason = AttributeKey "k8s.pod.status.reason"

-- |
-- The phase for the pod. Corresponds to the @phase@ field of the: [K8s PodStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.33\/#podstatus-v1-core)
k8s_pod_status_phase :: AttributeKey Text
k8s_pod_status_phase = AttributeKey "k8s.pod.status.phase"

-- |
-- The UID of the Service.
k8s_service_uid :: AttributeKey Text
k8s_service_uid = AttributeKey "k8s.service.uid"

-- |
-- The name of the Service.
k8s_service_name :: AttributeKey Text
k8s_service_name = AttributeKey "k8s.service.name"

-- |
-- The type of the Kubernetes Service.

-- ==== Note
-- This attribute aligns with the @type@ field of the
-- [K8s ServiceSpec](https:\/\/kubernetes.io\/docs\/reference\/kubernetes-api\/service-resources\/service-v1\/#ServiceSpec).
k8s_service_type :: AttributeKey Text
k8s_service_type = AttributeKey "k8s.service.type"

-- |
-- The traffic distribution policy for the Service.

-- ==== Note
-- Specifies how traffic is distributed to endpoints for this Service.
-- This attribute aligns with the @trafficDistribution@ field of the
-- [K8s ServiceSpec](https:\/\/kubernetes.io\/docs\/reference\/networking\/virtual-ips\/#traffic-distribution).
-- Known values include @PreferSameZone@ (prefer endpoints in the same zone as the client) and
-- @PreferSameNode@ (prefer endpoints on the same node, fallback to same zone, then cluster-wide).
-- If this field is not set on the Service, the attribute SHOULD NOT be emitted.
-- When not set, Kubernetes distributes traffic evenly across all endpoints cluster-wide.
k8s_service_trafficDistribution :: AttributeKey Text
k8s_service_trafficDistribution = AttributeKey "k8s.service.traffic_distribution"

-- |
-- The selector key-value pair placed on the Service, the @\<key\>@ being the selector key, the value being the selector value.

-- ==== Note
-- These selectors are used to correlate with pod labels. Each selector key-value pair becomes a separate attribute.
-- 
-- Examples:
-- 
-- - A selector @app=my-app@ SHOULD be recorded as
--   the @k8s.service.selector.app@ attribute with value @"my-app"@.
-- - A selector @version=v1@ SHOULD be recorded as
--   the @k8s.service.selector.version@ attribute with value @"v1"@.
k8s_service_selector :: Text -> AttributeKey Text
k8s_service_selector = \k -> AttributeKey $ "k8s.service.selector." <> k

-- |
-- The label placed on the Service, the @\<key\>@ being the label name, the value being the label value, even if the value is empty.

-- ==== Note
-- Examples:
-- 
-- - A label @app@ with value @my-service@ SHOULD be recorded as
--   the @k8s.service.label.app@ attribute with value @"my-service"@.
-- - A label @data@ with empty string value SHOULD be recorded as
--   the @k8s.service.label.data@ attribute with value @""@.
k8s_service_label :: Text -> AttributeKey Text
k8s_service_label = \k -> AttributeKey $ "k8s.service.label." <> k

-- |
-- The annotation placed on the Service, the @\<key\>@ being the annotation name, the value being the annotation value, even if the value is empty.

-- ==== Note
-- Examples:
-- 
-- - An annotation @prometheus.io\/scrape@ with value @true@ SHOULD be recorded as
--   the @k8s.service.annotation.prometheus.io\/scrape@ attribute with value @"true"@.
-- - An annotation @data@ with empty string value SHOULD be recorded as
--   the @k8s.service.annotation.data@ attribute with value @""@.
k8s_service_annotation :: Text -> AttributeKey Text
k8s_service_annotation = \k -> AttributeKey $ "k8s.service.annotation." <> k

-- |
-- Whether the Service publishes not-ready endpoints.

-- ==== Note
-- Whether the Service is configured to publish endpoints before the pods are ready.
-- This attribute is typically used to indicate that a Service (such as a headless
-- Service for a StatefulSet) allows peer discovery before pods pass their readiness probes.
-- It aligns with the @publishNotReadyAddresses@ field of the
-- [K8s ServiceSpec](https:\/\/kubernetes.io\/docs\/reference\/kubernetes-api\/service-resources\/service-v1\/#ServiceSpec).
k8s_service_publishNotReadyAddresses :: AttributeKey Bool
k8s_service_publishNotReadyAddresses = AttributeKey "k8s.service.publish_not_ready_addresses"

-- |
-- The condition of the service endpoint.

-- ==== Note
-- The current operational condition of the service endpoint.
-- An endpoint can have multiple conditions set at once (e.g., both @serving@ and @terminating@ during rollout).
-- This attribute aligns with the condition fields in the [K8s EndpointSlice](https:\/\/kubernetes.io\/docs\/reference\/kubernetes-api\/service-resources\/endpoint-slice-v1\/).
k8s_service_endpoint_condition :: AttributeKey Text
k8s_service_endpoint_condition = AttributeKey "k8s.service.endpoint.condition"

-- |
-- The address type of the service endpoint.

-- ==== Note
-- The network address family or type of the endpoint.
-- This attribute aligns with the @addressType@ field of the
-- [K8s EndpointSlice](https:\/\/kubernetes.io\/docs\/reference\/kubernetes-api\/service-resources\/endpoint-slice-v1\/).
-- It is used to differentiate metrics when a Service is backed by multiple address types
-- (e.g., in dual-stack clusters).
k8s_service_endpoint_addressType :: AttributeKey Text
k8s_service_endpoint_addressType = AttributeKey "k8s.service.endpoint.address_type"

-- |
-- The zone of the service endpoint.

-- ==== Note
-- The zone where the endpoint is located, typically corresponding to a failure domain.
-- This attribute aligns with the @zone@ field of endpoints in the
-- [K8s EndpointSlice](https:\/\/kubernetes.io\/docs\/reference\/kubernetes-api\/service-resources\/endpoint-slice-v1\/).
-- It enables zone-aware monitoring of service endpoint distribution and supports
-- features like [Topology Aware Routing](https:\/\/kubernetes.io\/docs\/concepts\/services-networking\/topology-aware-routing\/).
-- 
-- If the zone is not populated (e.g., nodes without the @topology.kubernetes.io\/zone@ label),
-- the attribute value will be an empty string.
k8s_service_endpoint_zone :: AttributeKey Text
k8s_service_endpoint_zone = AttributeKey "k8s.service.endpoint.zone"

-- $metric_k8s_pod_uptime
-- The time the Pod has been running.
--
-- Stability: development
--
-- ==== Note
-- Instrumentations SHOULD use a gauge with type @double@ and measure uptime in seconds as a floating point number with the highest precision available.
-- The actual accuracy would depend on the instrumentation and operating system.
--

-- $metric_k8s_pod_status_reason
-- Describes the number of K8s Pods that are currently in a state for a given reason.
--
-- Stability: development
--
-- ==== Note
-- All possible pod status reasons will be reported at each time interval to avoid missing metrics.
-- Only the value corresponding to the current reason will be non-zero.
--
-- === Attributes
-- - 'k8s_pod_status_reason'
--
--     Requirement level: required
--


-- $metric_k8s_pod_status_phase
-- Describes number of K8s Pods that are currently in a given phase.
--
-- Stability: development
--
-- ==== Note
-- All possible pod phases will be reported at each time interval to avoid missing metrics.
-- Only the value corresponding to the current phase will be non-zero.
--
-- === Attributes
-- - 'k8s_pod_status_phase'
--
--     Requirement level: required
--


-- $metric_k8s_pod_cpu_time
-- Total CPU time consumed.
--
-- Stability: development
--
-- ==== Note
-- Total CPU time consumed by the specific Pod on all available CPU cores
--

-- $metric_k8s_pod_cpu_usage
-- Pod\'s CPU usage, measured in cpus. Range from 0 to the number of allocatable CPUs.
--
-- Stability: development
--
-- ==== Note
-- CPU usage of the specific Pod on all available CPU cores, averaged over the sample window
--

-- $metric_k8s_pod_memory_usage
-- Memory usage of the Pod.
--
-- Stability: development
--
-- ==== Note
-- Total memory usage of the Pod
--

-- $metric_k8s_pod_memory_available
-- Pod memory available.
--
-- Stability: development
--
-- ==== Note
-- Available memory for use.  This is defined as the memory limit - workingSetBytes. If memory limit is undefined, the available bytes is omitted.
-- This metric is derived from the [MemoryStats.AvailableBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#MemoryStats) field of the [PodStats.Memory](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#PodStats) of the Kubelet\'s stats API.
--

-- $metric_k8s_pod_memory_rss
-- Pod memory RSS.
--
-- Stability: development
--
-- ==== Note
-- The amount of anonymous and swap cache memory (includes transparent hugepages).
-- This metric is derived from the [MemoryStats.RSSBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#MemoryStats) field of the [PodStats.Memory](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#PodStats) of the Kubelet\'s stats API.
--

-- $metric_k8s_pod_memory_workingSet
-- Pod memory working set.
--
-- Stability: development
--
-- ==== Note
-- The amount of working set memory. This includes recently accessed memory, dirty memory, and kernel memory. WorkingSetBytes is \<= UsageBytes.
-- This metric is derived from the [MemoryStats.WorkingSetBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#MemoryStats) field of the [PodStats.Memory](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#PodStats) of the Kubelet\'s stats API.
--

-- $metric_k8s_pod_memory_paging_faults
-- Pod memory paging faults.
--
-- Stability: development
--
-- ==== Note
-- Cumulative number of major\/minor page faults.
-- This metric is derived from the [MemoryStats.PageFaults](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#MemoryStats) and [MemoryStats.MajorPageFaults](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#MemoryStats) field of the [PodStats.Memory](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#PodStats) of the Kubelet\'s stats API.
--
-- === Attributes
-- - 'system_paging_fault_type'
--


-- $metric_k8s_pod_network_io
-- Network bytes for the Pod.
--
-- Stability: development
--
-- === Attributes
-- - 'network_interface_name'
--
-- - 'network_io_direction'
--



-- $metric_k8s_pod_network_errors
-- Pod network errors.
--
-- Stability: development
--
-- === Attributes
-- - 'network_interface_name'
--
-- - 'network_io_direction'
--



-- $metric_k8s_pod_filesystem_available
-- Pod filesystem available bytes.
--
-- Stability: development
--
-- ==== Note
-- This metric is derived from the
-- [FsStats.AvailableBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#FsStats) field
-- of the [PodStats.EphemeralStorage](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#PodStats)
-- of the Kubelet\'s stats API.
--

-- $metric_k8s_pod_filesystem_capacity
-- Pod filesystem capacity.
--
-- Stability: development
--
-- ==== Note
-- This metric is derived from the
-- [FsStats.CapacityBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#FsStats) field
-- of the [PodStats.EphemeralStorage](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#PodStats)
-- of the Kubelet\'s stats API.
--

-- $metric_k8s_pod_filesystem_usage
-- Pod filesystem usage.
--
-- Stability: development
--
-- ==== Note
-- This may not equal capacity - available.
-- 
-- This metric is derived from the
-- [FsStats.UsedBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#FsStats) field
-- of the [PodStats.EphemeralStorage](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#PodStats)
-- of the Kubelet\'s stats API.
--

-- $metric_k8s_pod_volume_available
-- Pod volume storage space available.
--
-- Stability: development
--
-- ==== Note
-- This metric is derived from the
-- [VolumeStats.AvailableBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#VolumeStats) field
-- of the [PodStats](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#PodStats) of the
-- Kubelet\'s stats API.
--
-- === Attributes
-- - 'k8s_volume_name'
--
--     Requirement level: required
--
-- - 'k8s_volume_type'
--
--     Requirement level: recommended
--



-- $metric_k8s_pod_volume_capacity
-- Pod volume total capacity.
--
-- Stability: development
--
-- ==== Note
-- This metric is derived from the
-- [VolumeStats.CapacityBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#VolumeStats) field
-- of the [PodStats](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#PodStats) of the
-- Kubelet\'s stats API.
--
-- === Attributes
-- - 'k8s_volume_name'
--
--     Requirement level: required
--
-- - 'k8s_volume_type'
--
--     Requirement level: recommended
--



-- $metric_k8s_pod_volume_usage
-- Pod volume usage.
--
-- Stability: development
--
-- ==== Note
-- This may not equal capacity - available.
-- 
-- This metric is derived from the
-- [VolumeStats.UsedBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#VolumeStats) field
-- of the [PodStats](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#PodStats) of the
-- Kubelet\'s stats API.
--
-- === Attributes
-- - 'k8s_volume_name'
--
--     Requirement level: required
--
-- - 'k8s_volume_type'
--
--     Requirement level: recommended
--



-- $metric_k8s_pod_volume_inode_count
-- The total inodes in the filesystem of the Pod\'s volume.
--
-- Stability: development
--
-- ==== Note
-- This metric is derived from the
-- [VolumeStats.Inodes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#VolumeStats) field
-- of the [PodStats](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#PodStats) of the
-- Kubelet\'s stats API.
--
-- === Attributes
-- - 'k8s_volume_name'
--
--     Requirement level: required
--
-- - 'k8s_volume_type'
--
--     Requirement level: recommended
--



-- $metric_k8s_pod_volume_inode_used
-- The inodes used by the filesystem of the Pod\'s volume.
--
-- Stability: development
--
-- ==== Note
-- This metric is derived from the
-- [VolumeStats.InodesUsed](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#VolumeStats) field
-- of the [PodStats](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#PodStats) of the
-- Kubelet\'s stats API.
-- 
-- This may not be equal to @inodes - free@ because filesystem may share inodes with other filesystems.
--
-- === Attributes
-- - 'k8s_volume_name'
--
--     Requirement level: required
--
-- - 'k8s_volume_type'
--
--     Requirement level: recommended
--



-- $metric_k8s_pod_volume_inode_free
-- The free inodes in the filesystem of the Pod\'s volume.
--
-- Stability: development
--
-- ==== Note
-- This metric is derived from the
-- [VolumeStats.InodesFree](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#VolumeStats) field
-- of the [PodStats](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#PodStats) of the
-- Kubelet\'s stats API.
--
-- === Attributes
-- - 'k8s_volume_name'
--
--     Requirement level: required
--
-- - 'k8s_volume_type'
--
--     Requirement level: recommended
--



-- $metric_k8s_container_status_state
-- Describes the number of K8s containers that are currently in a given state.
--
-- Stability: development
--
-- ==== Note
-- All possible container states will be reported at each time interval to avoid missing metrics.
-- Only the value corresponding to the current state will be non-zero.
--
-- === Attributes
-- - 'k8s_container_status_state'
--
--     Requirement level: required
--


-- $metric_k8s_container_status_reason
-- Describes the number of K8s containers that are currently in a state for a given reason.
--
-- Stability: development
--
-- ==== Note
-- All possible container state reasons will be reported at each time interval to avoid missing metrics.
-- Only the value corresponding to the current state reason will be non-zero.
--
-- === Attributes
-- - 'k8s_container_status_reason'
--
--     Requirement level: required
--


-- $metric_k8s_node_uptime
-- The time the Node has been running.
--
-- Stability: development
--
-- ==== Note
-- Instrumentations SHOULD use a gauge with type @double@ and measure uptime in seconds as a floating point number with the highest precision available.
-- The actual accuracy would depend on the instrumentation and operating system.
--

-- $metric_k8s_node_cpu_allocatable
-- Amount of cpu allocatable on the node.
--
-- Stability: development
--

-- $metric_k8s_node_ephemeralStorage_allocatable
-- Amount of ephemeral-storage allocatable on the node.
--
-- Stability: development
--

-- $metric_k8s_node_memory_allocatable
-- Amount of memory allocatable on the node.
--
-- Stability: development
--

-- $metric_k8s_node_pod_allocatable
-- Amount of pods allocatable on the node.
--
-- Stability: development
--

-- $metric_k8s_node_condition_status
-- Describes the condition of a particular Node.
--
-- Stability: development
--
-- ==== Note
-- All possible node condition pairs (type and status) will be reported at each time interval to avoid missing metrics. Condition pairs corresponding to the current conditions\' statuses will be non-zero.
--
-- === Attributes
-- - 'k8s_node_condition_type'
--
--     Requirement level: required
--
-- - 'k8s_node_condition_status'
--
--     Requirement level: required
--



-- $metric_k8s_node_cpu_time
-- Total CPU time consumed.
--
-- Stability: development
--
-- ==== Note
-- Total CPU time consumed by the specific Node on all available CPU cores
--

-- $metric_k8s_node_cpu_usage
-- Node\'s CPU usage, measured in cpus. Range from 0 to the number of allocatable CPUs.
--
-- Stability: development
--
-- ==== Note
-- CPU usage of the specific Node on all available CPU cores, averaged over the sample window
--

-- $metric_k8s_node_filesystem_available
-- Node filesystem available bytes.
--
-- Stability: development
--
-- ==== Note
-- This metric is derived from the
-- [FsStats.AvailableBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#FsStats) field
-- of the [NodeStats.Fs](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#NodeStats)
-- of the Kubelet\'s stats API.
--

-- $metric_k8s_node_filesystem_capacity
-- Node filesystem capacity.
--
-- Stability: development
--
-- ==== Note
-- This metric is derived from the
-- [FsStats.CapacityBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#FsStats) field
-- of the [NodeStats.Fs](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#NodeStats)
-- of the Kubelet\'s stats API.
--

-- $metric_k8s_node_filesystem_usage
-- Node filesystem usage.
--
-- Stability: development
--
-- ==== Note
-- This may not equal capacity - available.
-- 
-- This metric is derived from the
-- [FsStats.UsedBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#FsStats) field
-- of the [NodeStats.Fs](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#NodeStats)
-- of the Kubelet\'s stats API.
--

-- $metric_k8s_node_memory_usage
-- Memory usage of the Node.
--
-- Stability: development
--
-- ==== Note
-- Total memory usage of the Node
--

-- $metric_k8s_node_memory_available
-- Node memory available.
--
-- Stability: development
--
-- ==== Note
-- Available memory for use.  This is defined as the memory limit - workingSetBytes. If memory limit is undefined, the available bytes is omitted.
-- This metric is derived from the [MemoryStats.AvailableBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#MemoryStats) field of the [NodeStats.Memory](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#NodeStats) of the Kubelet\'s stats API.
--

-- $metric_k8s_node_memory_rss
-- Node memory RSS.
--
-- Stability: development
--
-- ==== Note
-- The amount of anonymous and swap cache memory (includes transparent hugepages).
-- This metric is derived from the [MemoryStats.RSSBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#MemoryStats) field of the [NodeStats.Memory](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#NodeStats) of the Kubelet\'s stats API.
--

-- $metric_k8s_node_memory_workingSet
-- Node memory working set.
--
-- Stability: development
--
-- ==== Note
-- The amount of working set memory. This includes recently accessed memory, dirty memory, and kernel memory. WorkingSetBytes is \<= UsageBytes.
-- This metric is derived from the [MemoryStats.WorkingSetBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#MemoryStats) field of the [NodeStats.Memory](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#NodeStats) of the Kubelet\'s stats API.
--

-- $metric_k8s_node_memory_paging_faults
-- Node memory paging faults.
--
-- Stability: development
--
-- ==== Note
-- Cumulative number of major\/minor page faults.
-- This metric is derived from the [MemoryStats.PageFaults](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#MemoryStats) and [MemoryStats.MajorPageFaults](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#MemoryStats) fields of the [NodeStats.Memory](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#NodeStats) of the Kubelet\'s stats API.
--
-- === Attributes
-- - 'system_paging_fault_type'
--


-- $metric_k8s_node_network_io
-- Network bytes for the Node.
--
-- Stability: development
--
-- === Attributes
-- - 'network_interface_name'
--
-- - 'network_io_direction'
--



-- $metric_k8s_node_network_errors
-- Node network errors.
--
-- Stability: development
--
-- === Attributes
-- - 'network_interface_name'
--
-- - 'network_io_direction'
--



-- $metric_k8s_deployment_pod_desired
-- Number of desired replica pods in this deployment.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @replicas@ field of the
-- [K8s DeploymentSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#deploymentspec-v1-apps).
--

-- $metric_k8s_deployment_pod_available
-- Total number of available replica pods (ready for at least minReadySeconds) targeted by this deployment.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @availableReplicas@ field of the
-- [K8s DeploymentStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#deploymentstatus-v1-apps).
--

-- $metric_k8s_replicaset_pod_desired
-- Number of desired replica pods in this replicaset.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @replicas@ field of the
-- [K8s ReplicaSetSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#replicasetspec-v1-apps).
--

-- $metric_k8s_replicaset_pod_available
-- Total number of available replica pods (ready for at least minReadySeconds) targeted by this replicaset.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @availableReplicas@ field of the
-- [K8s ReplicaSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#replicasetstatus-v1-apps).
--

-- $metric_k8s_replicationcontroller_pod_desired
-- Number of desired replica pods in this replication controller.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @replicas@ field of the
-- [K8s ReplicationControllerSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#replicationcontrollerspec-v1-core)
--

-- $metric_k8s_replicationcontroller_pod_available
-- Total number of available replica pods (ready for at least minReadySeconds) targeted by this replication controller.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @availableReplicas@ field of the
-- [K8s ReplicationControllerStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#replicationcontrollerstatus-v1-core)
--

-- $metric_k8s_statefulset_pod_desired
-- Number of desired replica pods in this statefulset.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @replicas@ field of the
-- [K8s StatefulSetSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#statefulsetspec-v1-apps).
--

-- $metric_k8s_statefulset_pod_ready
-- The number of replica pods created for this statefulset with a Ready Condition.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @readyReplicas@ field of the
-- [K8s StatefulSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#statefulsetstatus-v1-apps).
--

-- $metric_k8s_statefulset_pod_current
-- The number of replica pods created by the statefulset controller from the statefulset version indicated by currentRevision.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @currentReplicas@ field of the
-- [K8s StatefulSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#statefulsetstatus-v1-apps).
--

-- $metric_k8s_statefulset_pod_updated
-- Number of replica pods created by the statefulset controller from the statefulset version indicated by updateRevision.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @updatedReplicas@ field of the
-- [K8s StatefulSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#statefulsetstatus-v1-apps).
--

-- $metric_k8s_hpa_pod_desired
-- Desired number of replica pods managed by this horizontal pod autoscaler, as last calculated by the autoscaler.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @desiredReplicas@ field of the
-- [K8s HorizontalPodAutoscalerStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#horizontalpodautoscalerstatus-v2-autoscaling)
--

-- $metric_k8s_hpa_pod_current
-- Current number of replica pods managed by this horizontal pod autoscaler, as last seen by the autoscaler.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @currentReplicas@ field of the
-- [K8s HorizontalPodAutoscalerStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#horizontalpodautoscalerstatus-v2-autoscaling)
--

-- $metric_k8s_hpa_pod_max
-- The upper limit for the number of replica pods to which the autoscaler can scale up.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @maxReplicas@ field of the
-- [K8s HorizontalPodAutoscalerSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#horizontalpodautoscalerspec-v2-autoscaling)
--

-- $metric_k8s_hpa_pod_min
-- The lower limit for the number of replica pods to which the autoscaler can scale down.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @minReplicas@ field of the
-- [K8s HorizontalPodAutoscalerSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#horizontalpodautoscalerspec-v2-autoscaling)
--

-- $metric_k8s_hpa_metric_target_cpu_value
-- Target value for CPU resource in HPA config.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @value@ field of the
-- [K8s HPA MetricTarget](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#metrictarget-v2-autoscaling).
-- If the type of the metric is [@ContainerResource@](https:\/\/kubernetes.io\/docs\/tasks\/run-application\/horizontal-pod-autoscale\/#support-for-metrics-apis),
-- the @k8s.container.name@ attribute MUST be set to identify the specific container within the pod to which the metric applies.
--
-- === Attributes
-- - 'k8s_hpa_metric_type'
--
-- - 'k8s_container_name'
--
--     Requirement level: conditionally required: if and only if k8s.hpa.metric.type is ContainerResource
--



-- $metric_k8s_hpa_metric_target_cpu_averageValue
-- Target average value for CPU resource in HPA config.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @averageValue@ field of the
-- [K8s HPA MetricTarget](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#metrictarget-v2-autoscaling).
-- If the type of the metric is [@ContainerResource@](https:\/\/kubernetes.io\/docs\/tasks\/run-application\/horizontal-pod-autoscale\/#support-for-metrics-apis),
-- the @k8s.container.name@ attribute MUST be set to identify the specific container within the pod to which the metric applies.
--
-- === Attributes
-- - 'k8s_hpa_metric_type'
--
-- - 'k8s_container_name'
--
--     Requirement level: conditionally required: if and only if k8s.hpa.metric.type is ContainerResource
--



-- $metric_k8s_hpa_metric_target_cpu_averageUtilization
-- Target average utilization, in percentage, for CPU resource in HPA config.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @averageUtilization@ field of the
-- [K8s HPA MetricTarget](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#metrictarget-v2-autoscaling).
-- If the type of the metric is [@ContainerResource@](https:\/\/kubernetes.io\/docs\/tasks\/run-application\/horizontal-pod-autoscale\/#support-for-metrics-apis),
-- the @k8s.container.name@ attribute MUST be set to identify the specific container within the pod to which the metric applies.
--
-- === Attributes
-- - 'k8s_hpa_metric_type'
--
-- - 'k8s_container_name'
--
--     Requirement level: conditionally required: if and only if k8s.hpa.metric.type is ContainerResource.
--



-- $metric_k8s_daemonset_node_currentScheduled
-- Number of nodes that are running at least 1 daemon pod and are supposed to run the daemon pod.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @currentNumberScheduled@ field of the
-- [K8s DaemonSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#daemonsetstatus-v1-apps).
--

-- $metric_k8s_daemonset_node_desiredScheduled
-- Number of nodes that should be running the daemon pod (including nodes currently running the daemon pod).
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @desiredNumberScheduled@ field of the
-- [K8s DaemonSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#daemonsetstatus-v1-apps).
--

-- $metric_k8s_daemonset_node_misscheduled
-- Number of nodes that are running the daemon pod, but are not supposed to run the daemon pod.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @numberMisscheduled@ field of the
-- [K8s DaemonSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#daemonsetstatus-v1-apps).
--

-- $metric_k8s_daemonset_node_ready
-- Number of nodes that should be running the daemon pod and have one or more of the daemon pod running and ready.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @numberReady@ field of the
-- [K8s DaemonSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#daemonsetstatus-v1-apps).
--

-- $metric_k8s_job_pod_active
-- The number of pending and actively running pods for a job.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @active@ field of the
-- [K8s JobStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#jobstatus-v1-batch).
--

-- $metric_k8s_job_pod_failed
-- The number of pods which reached phase Failed for a job.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @failed@ field of the
-- [K8s JobStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#jobstatus-v1-batch).
--

-- $metric_k8s_job_pod_successful
-- The number of pods which reached phase Succeeded for a job.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @succeeded@ field of the
-- [K8s JobStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#jobstatus-v1-batch).
--

-- $metric_k8s_job_pod_desiredSuccessful
-- The desired number of successfully finished pods the job should be run with.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @completions@ field of the
-- [K8s JobSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#jobspec-v1-batch)..
--

-- $metric_k8s_job_pod_maxParallel
-- The max desired number of pods the job should run at any given time.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @parallelism@ field of the
-- [K8s JobSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#jobspec-v1-batch).
--

-- $metric_k8s_cronjob_job_active
-- The number of actively running jobs for a cronjob.
--
-- Stability: development
--
-- ==== Note
-- This metric aligns with the @active@ field of the
-- [K8s CronJobStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#cronjobstatus-v1-batch).
--

-- $metric_k8s_namespace_phase
-- Describes number of K8s namespaces that are currently in a given phase.
--
-- Stability: development
--
-- === Attributes
-- - 'k8s_namespace_phase'
--
--     Requirement level: required
--


-- $metric_k8s_container_cpu_limit
-- Maximum CPU resource limit set for the container.
--
-- Stability: development
--
-- ==== Note
-- See https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#resourcerequirements-v1-core for details.
--

-- $metric_k8s_container_cpu_request
-- CPU resource requested for the container.
--
-- Stability: development
--
-- ==== Note
-- See https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#resourcerequirements-v1-core for details.
--

-- $metric_k8s_container_memory_limit
-- Maximum memory resource limit set for the container.
--
-- Stability: development
--
-- ==== Note
-- See https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#resourcerequirements-v1-core for details.
--

-- $metric_k8s_container_memory_request
-- Memory resource requested for the container.
--
-- Stability: development
--
-- ==== Note
-- See https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#resourcerequirements-v1-core for details.
--

-- $metric_k8s_container_storage_limit
-- Maximum storage resource limit set for the container.
--
-- Stability: development
--
-- ==== Note
-- See https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#resourcerequirements-v1-core for details.
--

-- $metric_k8s_container_storage_request
-- Storage resource requested for the container.
--
-- Stability: development
--
-- ==== Note
-- See https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#resourcerequirements-v1-core for details.
--

-- $metric_k8s_container_ephemeralStorage_limit
-- Maximum ephemeral storage resource limit set for the container.
--
-- Stability: development
--
-- ==== Note
-- See https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#resourcerequirements-v1-core for details.
--

-- $metric_k8s_container_ephemeralStorage_request
-- Ephemeral storage resource requested for the container.
--
-- Stability: development
--
-- ==== Note
-- See https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#resourcerequirements-v1-core for details.
--

-- $metric_k8s_container_restart_count
-- Describes how many times the container has restarted (since the last counter reset).
--
-- Stability: development
--
-- ==== Note
-- This value is pulled directly from the K8s API and the value can go indefinitely high and be reset to 0
-- at any time depending on how your kubelet is configured to prune dead containers.
-- It is best to not depend too much on the exact value but rather look at it as
-- either == 0, in which case you can conclude there were no restarts in the recent past, or \> 0, in which case
-- you can conclude there were restarts in the recent past, and not try and analyze the value beyond that.
--

-- $metric_k8s_container_ready
-- Indicates whether the container is currently marked as ready to accept traffic, based on its readiness probe (1 = ready, 0 = not ready).
--
-- Stability: development
--
-- ==== Note
-- This metric SHOULD reflect the value of the @ready@ field in the
-- [K8s ContainerStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#containerstatus-v1-core).
--

-- $metric_k8s_container_cpu_limitUtilization
-- The ratio of container CPU usage to its CPU limit.
--
-- Stability: development
--
-- ==== Note
-- The value range is [0.0,1.0]. A value of 1.0 means the container is using 100% of its CPU limit. If the CPU limit is not set, this metric SHOULD NOT be emitted for that container.
--

-- $metric_k8s_container_cpu_requestUtilization
-- The ratio of container CPU usage to its CPU request.
--
-- Stability: development
--

-- $metric_k8s_resourcequota_cpu_limit_hard
-- The CPU limits in a specific namespace.
-- The value represents the configured quota limit of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--

-- $metric_k8s_resourcequota_cpu_limit_used
-- The CPU limits in a specific namespace.
-- The value represents the current observed total usage of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--

-- $metric_k8s_resourcequota_cpu_request_hard
-- The CPU requests in a specific namespace.
-- The value represents the configured quota limit of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--

-- $metric_k8s_resourcequota_cpu_request_used
-- The CPU requests in a specific namespace.
-- The value represents the current observed total usage of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--

-- $metric_k8s_resourcequota_memory_limit_hard
-- The memory limits in a specific namespace.
-- The value represents the configured quota limit of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--

-- $metric_k8s_resourcequota_memory_limit_used
-- The memory limits in a specific namespace.
-- The value represents the current observed total usage of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--

-- $metric_k8s_resourcequota_memory_request_hard
-- The memory requests in a specific namespace.
-- The value represents the configured quota limit of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--

-- $metric_k8s_resourcequota_memory_request_used
-- The memory requests in a specific namespace.
-- The value represents the current observed total usage of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--

-- $metric_k8s_resourcequota_hugepageCount_request_hard
-- The huge page requests in a specific namespace.
-- The value represents the configured quota limit of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--
-- === Attributes
-- - 'k8s_hugepage_size'
--
--     Requirement level: required
--


-- $metric_k8s_resourcequota_hugepageCount_request_used
-- The huge page requests in a specific namespace.
-- The value represents the current observed total usage of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--
-- === Attributes
-- - 'k8s_hugepage_size'
--
--     Requirement level: required
--


-- $metric_k8s_resourcequota_storage_request_hard
-- The storage requests in a specific namespace.
-- The value represents the configured quota limit of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
-- 
-- The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
-- storage class.
--
-- === Attributes
-- - 'k8s_storageclass_name'
--
--     Requirement level: conditionally required: The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
--     storage class.
--


-- $metric_k8s_resourcequota_storage_request_used
-- The storage requests in a specific namespace.
-- The value represents the current observed total usage of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
-- 
-- The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
-- storage class.
--
-- === Attributes
-- - 'k8s_storageclass_name'
--
--     Requirement level: conditionally required: The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
--     storage class.
--


-- $metric_k8s_resourcequota_persistentvolumeclaimCount_hard
-- The total number of PersistentVolumeClaims that can exist in the namespace.
-- The value represents the configured quota limit of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
-- 
-- The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
-- storage class.
--
-- === Attributes
-- - 'k8s_storageclass_name'
--
--     Requirement level: conditionally required: The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
--     storage class.
--


-- $metric_k8s_resourcequota_persistentvolumeclaimCount_used
-- The total number of PersistentVolumeClaims that can exist in the namespace.
-- The value represents the current observed total usage of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
-- 
-- The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
-- storage class.
--
-- === Attributes
-- - 'k8s_storageclass_name'
--
--     Requirement level: conditionally required: The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
--     storage class.
--


-- $metric_k8s_resourcequota_ephemeralStorage_request_hard
-- The sum of local ephemeral storage requests in the namespace.
-- The value represents the configured quota limit of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--

-- $metric_k8s_resourcequota_ephemeralStorage_request_used
-- The sum of local ephemeral storage requests in the namespace.
-- The value represents the current observed total usage of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--

-- $metric_k8s_resourcequota_ephemeralStorage_limit_hard
-- The sum of local ephemeral storage limits in the namespace.
-- The value represents the configured quota limit of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--

-- $metric_k8s_resourcequota_ephemeralStorage_limit_used
-- The sum of local ephemeral storage limits in the namespace.
-- The value represents the current observed total usage of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--

-- $metric_k8s_resourcequota_objectCount_hard
-- The object count limits in a specific namespace.
-- The value represents the configured quota limit of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--
-- === Attributes
-- - 'k8s_resourcequota_resourceName'
--
--     Requirement level: required
--


-- $metric_k8s_resourcequota_objectCount_used
-- The object count limits in a specific namespace.
-- The value represents the current observed total usage of the resource in the namespace.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core).
--
-- === Attributes
-- - 'k8s_resourcequota_resourceName'
--
--     Requirement level: required
--


-- $metric_k8s_service_endpoint_count
-- Number of endpoints for a service by condition and address type.
--
-- Stability: development
--
-- ==== Note
-- This metric is derived from the Kubernetes [EndpointSlice API](https:\/\/kubernetes.io\/docs\/reference\/kubernetes-api\/service-resources\/endpoint-slice-v1\/).
-- It reports the number of network endpoints backing a Service, broken down by their condition and address type.
-- 
-- In dual-stack or multi-protocol clusters, separate counts are reported for each address family (@IPv4@, @IPv6@, @FQDN@).
-- 
-- When the optional @zone@ attribute is enabled, counts are further broken down by availability zone for zone-aware monitoring.
-- 
-- An endpoint may be reported under multiple conditions simultaneously (e.g., both @serving@ and @terminating@ during a graceful shutdown).
-- See [K8s EndpointConditions](https:\/\/kubernetes.io\/docs\/reference\/kubernetes-api\/service-resources\/endpoint-slice-v1\/) for more details.
-- 
-- The conditions represent:
-- - @ready@: Endpoints capable of receiving new connections.
-- - @serving@: Endpoints currently handling traffic.
-- - @terminating@: Endpoints that are being phased out but may still be handling existing connections.
-- 
-- For Services with @publishNotReadyAddresses@ enabled (common for headless StatefulSets),
-- this metric will include endpoints that are published despite not being ready.
-- The @k8s.service.publish_not_ready_addresses@ resource attribute indicates this setting.
--
-- === Attributes
-- - 'k8s_service_endpoint_condition'
--
--     Requirement level: required
--
-- - 'k8s_service_endpoint_addressType'
--
--     Requirement level: required
--
-- - 'k8s_service_endpoint_zone'
--
--     Requirement level: recommended
--




-- $metric_k8s_service_loadBalancer_ingress_count
-- Number of load balancer ingress points (external IPs\/hostnames) assigned to the service.
--
-- Stability: development
--
-- ==== Note
-- This metric reports the number of external ingress points (IP addresses or hostnames)
-- assigned to a LoadBalancer Service.
-- 
-- It is only emitted for Services of type @LoadBalancer@ and reflects the assignments
-- made by the underlying infrastructure\'s load balancer controller in the
-- [.status.loadBalancer.ingress](https:\/\/kubernetes.io\/docs\/reference\/kubernetes-api\/service-resources\/service-v1\/#ServiceStatus) field.
-- 
-- A value of @0@ indicates that no ingress points have been assigned yet (e.g., during provisioning).
-- A value greater than @1@ may occur when multiple IPs or hostnames are assigned (e.g., dual-stack configurations).
-- 
-- This metric signals that external endpoints have been assigned by the load balancer controller, but it does not
-- guarantee that the load balancer is healthy.
--

-- $registry_k8s_deprecated
-- Describes deprecated k8s attributes.
--
-- === Attributes
-- - 'k8s_pod_labels'
--
--     Stability: development
--
--     Deprecated: renamed: k8s.pod.label
--

-- |
-- Deprecated, use @k8s.pod.label@ instead.
k8s_pod_labels :: Text -> AttributeKey Text
k8s_pod_labels = \k -> AttributeKey $ "k8s.pod.labels." <> k

-- $metric_k8s_replicationController_desiredPods
-- Deprecated, use @k8s.replicationcontroller.pod.desired@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.replicationcontroller.pod.desired
--

-- $metric_k8s_replicationController_availablePods
-- Deprecated, use @k8s.replicationcontroller.pod.available@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.replicationcontroller.pod.available
--

-- $metric_k8s_replicationcontroller_desiredPods
-- Deprecated, use @k8s.replicationcontroller.pod.desired@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.replicationcontroller.pod.desired
--

-- $metric_k8s_daemonset_currentScheduledNodes
-- Deprecated, use @k8s.daemonset.node.current_scheduled@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.daemonset.node.current_scheduled
--
-- ==== Note
-- This metric aligns with the @currentNumberScheduled@ field of the
-- [K8s DaemonSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#daemonsetstatus-v1-apps).
--

-- $metric_k8s_daemonset_desiredScheduledNodes
-- Deprecated, use @k8s.daemonset.node.desired_scheduled@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.daemonset.node.desired_scheduled
--
-- ==== Note
-- This metric aligns with the @desiredNumberScheduled@ field of the
-- [K8s DaemonSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#daemonsetstatus-v1-apps).
--

-- $metric_k8s_daemonset_misscheduledNodes
-- Deprecated, use @k8s.daemonset.node.misscheduled@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.daemonset.node.misscheduled
--
-- ==== Note
-- This metric aligns with the @numberMisscheduled@ field of the
-- [K8s DaemonSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#daemonsetstatus-v1-apps).
--

-- $metric_k8s_daemonset_readyNodes
-- Deprecated, use @k8s.daemonset.node.ready@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.daemonset.node.ready
--
-- ==== Note
-- This metric aligns with the @numberReady@ field of the
-- [K8s DaemonSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#daemonsetstatus-v1-apps).
--

-- $metric_k8s_job_activePods
-- Deprecated, use @k8s.job.pod.active@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.job.pod.active
--
-- ==== Note
-- This metric aligns with the @active@ field of the
-- [K8s JobStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#jobstatus-v1-batch).
--

-- $metric_k8s_job_failedPods
-- Deprecated, use @k8s.job.pod.failed@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.job.pod.failed
--
-- ==== Note
-- This metric aligns with the @failed@ field of the
-- [K8s JobStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#jobstatus-v1-batch).
--

-- $metric_k8s_job_successfulPods
-- Deprecated, use @k8s.job.pod.successful@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.job.pod.successful
--
-- ==== Note
-- This metric aligns with the @succeeded@ field of the
-- [K8s JobStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#jobstatus-v1-batch).
--

-- $metric_k8s_job_desiredSuccessfulPods
-- Deprecated, use @k8s.job.pod.desired_successful@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.job.pod.desired_successful
--
-- ==== Note
-- This metric aligns with the @completions@ field of the
-- [K8s JobSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#jobspec-v1-batch)..
--

-- $metric_k8s_job_maxParallelPods
-- Deprecated, use @k8s.job.pod.max_parallel@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.job.pod.max_parallel
--
-- ==== Note
-- This metric aligns with the @parallelism@ field of the
-- [K8s JobSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#jobspec-v1-batch).
--

-- $metric_k8s_cronjob_activeJobs
-- Deprecated, use @k8s.cronjob.job.active@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.cronjob.job.active
--
-- ==== Note
-- This metric aligns with the @active@ field of the
-- [K8s CronJobStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#cronjobstatus-v1-batch).
--

-- $metric_k8s_replicationcontroller_availablePods
-- Deprecated, use @k8s.replicationcontroller.pod.available@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.replicationcontroller.pod.available
--

-- $metric_k8s_node_allocatable_pods
-- Deprecated, use @k8s.node.pod.allocatable@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.node.pod.allocatable
--

-- $metric_k8s_deployment_desiredPods
-- Deprecated, use @k8s.deployment.pod.desired@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.deployment.pod.desired
--
-- ==== Note
-- This metric aligns with the @replicas@ field of the
-- [K8s DeploymentSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#deploymentspec-v1-apps).
--

-- $metric_k8s_deployment_availablePods
-- Deprecated, use @k8s.deployment.pod.available@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.deployment.pod.available
--
-- ==== Note
-- This metric aligns with the @availableReplicas@ field of the
-- [K8s DeploymentStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#deploymentstatus-v1-apps).
--

-- $metric_k8s_replicaset_desiredPods
-- Deprecated, use @k8s.replicaset.pod.desired@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.replicaset.pod.desired
--
-- ==== Note
-- This metric aligns with the @replicas@ field of the
-- [K8s ReplicaSetSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#replicasetspec-v1-apps).
--

-- $metric_k8s_replicaset_availablePods
-- Deprecated, use @k8s.replicaset.pod.available@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.replicaset.pod.available
--
-- ==== Note
-- This metric aligns with the @availableReplicas@ field of the
-- [K8s ReplicaSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#replicasetstatus-v1-apps).
--

-- $metric_k8s_statefulset_desiredPods
-- Deprecated, use @k8s.statefulset.pod.desired@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.statefulset.pod.desired
--
-- ==== Note
-- This metric aligns with the @replicas@ field of the
-- [K8s StatefulSetSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#statefulsetspec-v1-apps).
--

-- $metric_k8s_statefulset_readyPods
-- Deprecated, use @k8s.statefulset.pod.ready@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.statefulset.pod.ready
--
-- ==== Note
-- This metric aligns with the @readyReplicas@ field of the
-- [K8s StatefulSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#statefulsetstatus-v1-apps).
--

-- $metric_k8s_statefulset_currentPods
-- Deprecated, use @k8s.statefulset.pod.current@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.statefulset.pod.current
--
-- ==== Note
-- This metric aligns with the @currentReplicas@ field of the
-- [K8s StatefulSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#statefulsetstatus-v1-apps).
--

-- $metric_k8s_statefulset_updatedPods
-- Deprecated, use @k8s.statefulset.pod.updated@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.statefulset.pod.updated
--
-- ==== Note
-- This metric aligns with the @updatedReplicas@ field of the
-- [K8s StatefulSetStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#statefulsetstatus-v1-apps).
--

-- $metric_k8s_hpa_desiredPods
-- Deprecated, use @k8s.hpa.pod.desired@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.hpa.pod.desired
--
-- ==== Note
-- This metric aligns with the @desiredReplicas@ field of the
-- [K8s HorizontalPodAutoscalerStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#horizontalpodautoscalerstatus-v2-autoscaling)
--

-- $metric_k8s_hpa_currentPods
-- Deprecated, use @k8s.hpa.pod.current@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.hpa.pod.current
--
-- ==== Note
-- This metric aligns with the @currentReplicas@ field of the
-- [K8s HorizontalPodAutoscalerStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#horizontalpodautoscalerstatus-v2-autoscaling)
--

-- $metric_k8s_hpa_maxPods
-- Deprecated, use @k8s.hpa.pod.max@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.hpa.pod.max
--
-- ==== Note
-- This metric aligns with the @maxReplicas@ field of the
-- [K8s HorizontalPodAutoscalerSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#horizontalpodautoscalerspec-v2-autoscaling)
--

-- $metric_k8s_hpa_minPods
-- Deprecated, use @k8s.hpa.pod.min@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.hpa.pod.min
--
-- ==== Note
-- This metric aligns with the @minReplicas@ field of the
-- [K8s HorizontalPodAutoscalerSpec](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.30\/#horizontalpodautoscalerspec-v2-autoscaling)
--

-- $metric_k8s_node_allocatable_cpu
-- Deprecated, use @k8s.node.cpu.allocatable@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.node.cpu.allocatable
--

-- $metric_k8s_node_allocatable_ephemeralStorage
-- Deprecated, use @k8s.node.ephemeral_storage.allocatable@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.node.ephemeral_storage.allocatable
--

-- $metric_k8s_node_allocatable_memory
-- Deprecated, use @k8s.node.memory.allocatable@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: k8s.node.memory.allocatable
--

-- $registry_enduser
-- Describes the end user.
--
-- === Attributes
-- - 'enduser_id'
--
--     Stability: development
--
-- - 'enduser_pseudo_id'
--
--     Stability: development
--

-- |
-- Unique identifier of an end user in the system. It maybe a username, email address, or other identifier.

-- ==== Note
-- Unique identifier of an end user in the system.
-- 
-- \> [!Warning]
-- \> This field contains sensitive (PII) information.
enduser_id :: AttributeKey Text
enduser_id = AttributeKey "enduser.id"

-- |
-- Pseudonymous identifier of an end user. This identifier should be a random value that is not directly linked or associated with the end user\'s actual identity.

-- ==== Note
-- Pseudonymous identifier of an end user.
-- 
-- \> [!Warning]
-- \> This field contains sensitive (linkable PII) information.
enduser_pseudo_id :: AttributeKey Text
enduser_pseudo_id = AttributeKey "enduser.pseudo.id"

-- $registry_enduser_deprecated
-- Describes deprecated enduser attributes.
--
-- === Attributes
-- - 'enduser_role'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'enduser_scope'
--
--     Stability: development
--
--     Deprecated: obsoleted
--

-- |
-- Deprecated, use @user.roles@ instead.
enduser_role :: AttributeKey Text
enduser_role = AttributeKey "enduser.role"

-- |
-- Deprecated, no replacement at this time.
enduser_scope :: AttributeKey Text
enduser_scope = AttributeKey "enduser.scope"

-- $registry_v8js
-- Describes V8 JS Engine Runtime related attributes.
--
-- === Attributes
-- - 'v8js_gc_type'
--
--     Stability: development
--
-- - 'v8js_heap_space_name'
--
--     Stability: development
--

-- |
-- The type of garbage collection.
v8js_gc_type :: AttributeKey Text
v8js_gc_type = AttributeKey "v8js.gc.type"

-- |
-- The name of the space type of heap memory.

-- ==== Note
-- Value can be retrieved from value @space_name@ of [@v8.getHeapSpaceStatistics()@](https:\/\/nodejs.org\/api\/v8.html#v8getheapspacestatistics)
v8js_heap_space_name :: AttributeKey Text
v8js_heap_space_name = AttributeKey "v8js.heap.space.name"

-- $metric_v8js_gc_duration
-- Garbage collection duration.
--
-- Stability: development
--
-- ==== Note
-- The values can be retrieved from [@perf_hooks.PerformanceObserver(...).observe({ entryTypes: [\'gc\'] })@](https:\/\/nodejs.org\/api\/perf_hooks.html#performanceobserverobserveoptions)
--
-- === Attributes
-- - 'v8js_gc_type'
--
--     Requirement level: required
--


-- $metric_v8js_memory_heap_limit
-- Total heap memory size pre-allocated.
--
-- Stability: development
--
-- ==== Note
-- The value can be retrieved from value @space_size@ of [@v8.getHeapSpaceStatistics()@](https:\/\/nodejs.org\/api\/v8.html#v8getheapspacestatistics)
--
-- === Attributes
-- - 'v8js_heap_space_name'
--
--     Requirement level: required
--


-- $metric_v8js_memory_heap_used
-- Heap Memory size allocated.
--
-- Stability: development
--
-- ==== Note
-- The value can be retrieved from value @space_used_size@ of [@v8.getHeapSpaceStatistics()@](https:\/\/nodejs.org\/api\/v8.html#v8getheapspacestatistics)
--
-- === Attributes
-- - 'v8js_heap_space_name'
--
--     Requirement level: required
--


-- $metric_v8js_memory_heap_space_availableSize
-- Heap space available size.
--
-- Stability: development
--
-- ==== Note
-- Value can be retrieved from value @space_available_size@ of [@v8.getHeapSpaceStatistics()@](https:\/\/nodejs.org\/api\/v8.html#v8getheapspacestatistics)
--
-- === Attributes
-- - 'v8js_heap_space_name'
--
--     Requirement level: required
--


-- $metric_v8js_memory_heap_space_physicalSize
-- Committed size of a heap space.
--
-- Stability: development
--
-- ==== Note
-- Value can be retrieved from value @physical_space_size@ of [@v8.getHeapSpaceStatistics()@](https:\/\/nodejs.org\/api\/v8.html#v8getheapspacestatistics)
--
-- === Attributes
-- - 'v8js_heap_space_name'
--
--     Requirement level: required
--


-- $metric_v8js_heap_space_availableSize
-- Deprecated, use @v8js.memory.heap.space.available_size@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: v8js.memory.heap.space.available_size
--
-- === Attributes
-- - 'v8js_heap_space_name'
--
--     Requirement level: required
--


-- $metric_v8js_heap_space_physicalSize
-- Deprecated, use @v8js.memory.heap.space.physical_size@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: v8js.memory.heap.space.physical_size
--
-- === Attributes
-- - 'v8js_heap_space_name'
--
--     Requirement level: required
--


-- $registry_featureFlag
-- This document defines attributes for Feature Flags.
--
-- Stability: release candidate
--
-- === Attributes
-- - 'featureFlag_key'
--
--     Stability: release candidate
--
-- - 'featureFlag_provider_name'
--
--     Stability: release candidate
--
-- - 'featureFlag_result_variant'
--
--     Stability: release candidate
--
-- - 'featureFlag_context_id'
--
--     Stability: release candidate
--
-- - 'featureFlag_version'
--
--     Stability: release candidate
--
-- - 'featureFlag_set_id'
--
--     Stability: release candidate
--
-- - 'featureFlag_result_reason'
--
--     Stability: release candidate
--
-- - 'featureFlag_result_value'
--
--     Stability: release candidate
--
-- - 'featureFlag_error_message'
--
--     Stability: release candidate
--

-- |
-- The lookup key of the feature flag.
featureFlag_key :: AttributeKey Text
featureFlag_key = AttributeKey "feature_flag.key"

-- |
-- Identifies the feature flag provider.
featureFlag_provider_name :: AttributeKey Text
featureFlag_provider_name = AttributeKey "feature_flag.provider.name"

-- |
-- A semantic identifier for an evaluated flag value.

-- ==== Note
-- A semantic identifier, commonly referred to as a variant, provides a means
-- for referring to a value without including the value itself. This can
-- provide additional context for understanding the meaning behind a value.
-- For example, the variant @red@ maybe be used for the value @#c05543@.
featureFlag_result_variant :: AttributeKey Text
featureFlag_result_variant = AttributeKey "feature_flag.result.variant"

-- |
-- The unique identifier for the flag evaluation context. For example, the targeting key.
featureFlag_context_id :: AttributeKey Text
featureFlag_context_id = AttributeKey "feature_flag.context.id"

-- |
-- The version of the ruleset used during the evaluation. This may be any stable value which uniquely identifies the ruleset.
featureFlag_version :: AttributeKey Text
featureFlag_version = AttributeKey "feature_flag.version"

-- |
-- The identifier of the [flag set](https:\/\/openfeature.dev\/specification\/glossary\/#flag-set) to which the feature flag belongs.
featureFlag_set_id :: AttributeKey Text
featureFlag_set_id = AttributeKey "feature_flag.set.id"

-- |
-- The reason code which shows how a feature flag value was determined.
featureFlag_result_reason :: AttributeKey Text
featureFlag_result_reason = AttributeKey "feature_flag.result.reason"

-- |
-- The evaluated value of the feature flag.

-- ==== Note
-- With some feature flag providers, feature flag results can be quite large or contain private or sensitive details.
-- Because of this, @feature_flag.result.variant@ is often the preferred attribute if it is available.
-- 
-- It may be desirable to redact or otherwise limit the size and scope of @feature_flag.result.value@ if possible.
-- Because the evaluated flag value is unstructured and may be any type, it is left to the instrumentation author to determine how best to achieve this.
featureFlag_result_value :: AttributeKey Text
featureFlag_result_value = AttributeKey "feature_flag.result.value"

-- |
-- A message providing more detail about an error that occurred during feature flag evaluation in human-readable form.
featureFlag_error_message :: AttributeKey Text
featureFlag_error_message = AttributeKey "feature_flag.error.message"

-- $event_featureFlag_evaluation
-- Defines feature flag evaluation as an event.
--
-- Stability: release candidate
--
-- ==== Note
-- A @feature_flag.evaluation@ event SHOULD be emitted whenever a feature flag value is evaluated, which may happen many times over the course of an application lifecycle. For example, a website A\/B testing different animations may evaluate a flag each time a button is clicked. A @feature_flag.evaluation@ event is emitted on each evaluation even if the result is the same.
--
-- === Attributes
-- - 'featureFlag_key'
--
--     Requirement level: required
--
-- - 'featureFlag_result_variant'
--
--     Requirement level: conditionally required: If feature flag provider supplies a variant or equivalent concept.
--
-- - 'featureFlag_result_value'
--
--     Requirement level: conditionally required: If and only if feature flag provider does not supply variant or equivalent concept. Otherwise, @feature_flag.result.value@ should be treated as opt-in.
--
-- - 'featureFlag_provider_name'
--
--     Requirement level: recommended
--
-- - 'featureFlag_context_id'
--
--     Requirement level: recommended
--
-- - 'featureFlag_version'
--
--     Requirement level: recommended
--
-- - 'featureFlag_set_id'
--
--     Requirement level: recommended
--
-- - 'featureFlag_result_reason'
--
--     Requirement level: recommended
--
-- - 'error_type'
--
--     Requirement level: conditionally required: If and only if an error occurred during flag evaluation.
--
--     ==== Note
--     If one of these values applies, then it MUST be used; otherwise, a custom value MAY be used.
--     
--     | Value | Description | Stability |
--     | --- | --- | --- |
--     | @flag_not_found@ | The flag could not be found. | ![Release Candidate](https:\/\/img.shields.io\/badge\/-rc-mediumorchid) |
--     | @invalid_context@ | The evaluation context does not meet provider requirements. | ![Release Candidate](https:\/\/img.shields.io\/badge\/-rc-mediumorchid) |
--     | @parse_error@ | An error was encountered parsing data, such as a flag configuration. | ![Release Candidate](https:\/\/img.shields.io\/badge\/-rc-mediumorchid) |
--     | @provider_fatal@ | The provider has entered an irrecoverable error state. | ![Release Candidate](https:\/\/img.shields.io\/badge\/-rc-mediumorchid) |
--     | @provider_not_ready@ | The value was resolved before the provider was initialized. | ![Release Candidate](https:\/\/img.shields.io\/badge\/-rc-mediumorchid) |
--     | @targeting_key_missing@ | The provider requires a targeting key and one was not provided in the evaluation context. | ![Release Candidate](https:\/\/img.shields.io\/badge\/-rc-mediumorchid) |
--     | @type_mismatch@ | The type of the flag value does not match the expected type. | ![Release Candidate](https:\/\/img.shields.io\/badge\/-rc-mediumorchid) |
--     | @general@ | The error was for a reason not enumerated above. | ![Release Candidate](https:\/\/img.shields.io\/badge\/-rc-mediumorchid) |
--
-- - 'featureFlag_error_message'
--
--     Requirement level: recommended: If and only if an error occurred during flag evaluation and @error.type@ does not sufficiently describe the error.
--
--     ==== Note
--     Should not simply duplicate the value of @error.type@, but should provide more context. For example, if @error.type@ is @invalid_context@ the @feature_flag.error.message@ may enumerate which context keys are missing or invalid.
--











-- $registry_featureFlag_deprecated
-- Describes deprecated feature flag attributes.
--
-- === Attributes
-- - 'featureFlag_providerName'
--
--     Stability: development
--
--     Deprecated: renamed: feature_flag.provider.name
--
-- - 'featureFlag_evaluation_reason'
--
--     Stability: development
--
--     Deprecated: renamed: feature_flag.result.reason
--
-- - 'featureFlag_variant'
--
--     Stability: development
--
--     Deprecated: renamed: feature_flag.result.variant
--
-- - 'featureFlag_evaluation_error_message'
--
--     Stability: development
--
--     Deprecated: renamed: feature_flag.error.message
--

-- |
-- Deprecated, use @feature_flag.provider.name@ instead.
featureFlag_providerName :: AttributeKey Text
featureFlag_providerName = AttributeKey "feature_flag.provider_name"

-- |
-- Deprecated, use @feature_flag.result.reason@ instead.
featureFlag_evaluation_reason :: AttributeKey Text
featureFlag_evaluation_reason = AttributeKey "feature_flag.evaluation.reason"

-- |
-- Deprecated, use @feature_flag.result.variant@ instead.
featureFlag_variant :: AttributeKey Text
featureFlag_variant = AttributeKey "feature_flag.variant"

-- |
-- Deprecated, use @feature_flag.error.message@ instead.
featureFlag_evaluation_error_message :: AttributeKey Text
featureFlag_evaluation_error_message = AttributeKey "feature_flag.evaluation.error.message"

-- $registry_jsonrpc
-- This document defines attributes for JSON-RPC.
--
-- === Attributes
-- - 'jsonrpc_request_id'
--
--     Stability: development
--
-- - 'jsonrpc_protocol_version'
--
--     Stability: development
--

-- |
-- A string representation of the @id@ property of the request and its corresponding response.

-- ==== Note
-- Under the [JSON-RPC specification](https:\/\/www.jsonrpc.org\/specification), the @id@ property may be a string, number, null, or omitted entirely. When omitted, the request is treated as a notification. Using @null@ is not equivalent to omitting the @id@, but it is discouraged.
-- Instrumentations SHOULD NOT capture this attribute when the @id@ is @null@ or omitted.
jsonrpc_request_id :: AttributeKey Text
jsonrpc_request_id = AttributeKey "jsonrpc.request.id"

-- |
-- Protocol version, as specified in the @jsonrpc@ property of the request and its corresponding response.
jsonrpc_protocol_version :: AttributeKey Text
jsonrpc_protocol_version = AttributeKey "jsonrpc.protocol.version"

-- $source
-- General source attributes.
--
-- === Attributes
-- - 'source_address'
--
-- - 'source_port'
--



-- $registry_source
-- These attributes may be used to describe the sender of a network exchange\/packet. These should be used when there is no client\/server relationship between the two sides, or when that relationship is unknown. This covers low-level network interactions (e.g. packet tracing) where you don\'t know if there was a connection or which side initiated it. This also covers unidirectional UDP flows and peer-to-peer communication where the "user-facing" surface of the protocol \/ API doesn\'t expose a clear notion of client and server.
--
-- === Attributes
-- - 'source_address'
--
--     Stability: development
--
-- - 'source_port'
--
--     Stability: development
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







-- $registry_network
-- These attributes may be used for any network related operation.
--
-- === Attributes
-- - 'network_carrier_icc'
--
--     Stability: development
--
-- - 'network_carrier_mcc'
--
--     Stability: development
--
-- - 'network_carrier_mnc'
--
--     Stability: development
--
-- - 'network_carrier_name'
--
--     Stability: development
--
-- - 'network_connection_subtype'
--
--     Stability: development
--
-- - 'network_connection_type'
--
--     Stability: development
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
--     Stability: development
--
-- - 'network_interface_name'
--
--     Stability: development
--
-- - 'network_connection_state'
--
--     Stability: development
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
-- [OSI application layer](https:\/\/wikipedia.org\/wiki\/Application_layer) or non-OSI equivalent.

-- ==== Note
-- The value SHOULD be normalized to lowercase.
network_protocol_name :: AttributeKey Text
network_protocol_name = AttributeKey "network.protocol.name"

-- |
-- The actual version of the protocol used for network communication.

-- ==== Note
-- If protocol version is subject to negotiation (for example using [ALPN](https:\/\/www.rfc-editor.org\/rfc\/rfc7301.html)), this attribute SHOULD be set to the negotiated version. If the actual protocol version is not known, this attribute SHOULD NOT be set.
network_protocol_version :: AttributeKey Text
network_protocol_version = AttributeKey "network.protocol.version"

-- |
-- [OSI transport layer](https:\/\/wikipedia.org\/wiki\/Transport_layer) or [inter-process communication method](https:\/\/wikipedia.org\/wiki\/Inter-process_communication).

-- ==== Note
-- The value SHOULD be normalized to lowercase.
-- 
-- Consider always setting the transport when setting a port number, since
-- a port number is ambiguous without knowing the transport. For example
-- different processes could be listening on TCP port 12345 and UDP port 12345.
network_transport :: AttributeKey Text
network_transport = AttributeKey "network.transport"

-- |
-- [OSI network layer](https:\/\/wikipedia.org\/wiki\/Network_layer) or non-OSI equivalent.

-- ==== Note
-- The value SHOULD be normalized to lowercase.
network_type :: AttributeKey Text
network_type = AttributeKey "network.type"

-- |
-- The network IO operation direction.
network_io_direction :: AttributeKey Text
network_io_direction = AttributeKey "network.io.direction"

-- |
-- The network interface name.
network_interface_name :: AttributeKey Text
network_interface_name = AttributeKey "network.interface.name"

-- |
-- The state of network connection

-- ==== Note
-- Connection states are defined as part of the [rfc9293](https:\/\/datatracker.ietf.org\/doc\/html\/rfc9293#section-3.3.2)
network_connection_state :: AttributeKey Text
network_connection_state = AttributeKey "network.connection.state"

-- $registry_network_deprecated
-- These attributes may be used for any network related operation.
--
-- === Attributes
-- - 'net_sock_peer_name'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'net_sock_peer_addr'
--
--     Stability: development
--
--     Deprecated: renamed: network.peer.address
--
-- - 'net_sock_peer_port'
--
--     Stability: development
--
--     Deprecated: renamed: network.peer.port
--
-- - 'net_peer_name'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'net_peer_port'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'net_peer_ip'
--
--     Stability: development
--
--     Deprecated: renamed: network.peer.address
--
-- - 'net_host_name'
--
--     Stability: development
--
--     Deprecated: renamed: server.address
--
-- - 'net_host_ip'
--
--     Stability: development
--
--     Deprecated: renamed: network.local.address
--
-- - 'net_host_port'
--
--     Stability: development
--
--     Deprecated: renamed: server.port
--
-- - 'net_sock_host_addr'
--
--     Stability: development
--
--     Deprecated: renamed: network.local.address
--
-- - 'net_sock_host_port'
--
--     Stability: development
--
--     Deprecated: renamed: network.local.port
--
-- - 'net_transport'
--
--     Stability: development
--
--     Deprecated: renamed: network.transport
--
-- - 'net_protocol_name'
--
--     Stability: development
--
--     Deprecated: renamed: network.protocol.name
--
-- - 'net_protocol_version'
--
--     Stability: development
--
--     Deprecated: renamed: network.protocol.version
--
-- - 'net_sock_family'
--
--     Stability: development
--
--     Deprecated: uncategorized
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
-- Deprecated, use @network.peer.address@.
net_peer_ip :: AttributeKey Text
net_peer_ip = AttributeKey "net.peer.ip"

-- |
-- Deprecated, use @server.address@.
net_host_name :: AttributeKey Text
net_host_name = AttributeKey "net.host.name"

-- |
-- Deprecated, use @network.local.address@.
net_host_ip :: AttributeKey Text
net_host_ip = AttributeKey "net.host.ip"

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

-- $entity_faas
-- A serverless instance.
--
-- Stability: development
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






-- $faas_attributes
-- This span represents a serverless function (FaaS) execution.
--
-- Stability: development
--
-- ==== Note
-- Span @name@ should be set to the function name being executed.
-- Depending on the value of the @faas.trigger@ attribute, additional attributes MUST be set.
-- 
-- For example, an @http@ trigger SHOULD follow the [HTTP Server semantic conventions](\/docs\/http\/http-spans.md#http-server-span).
-- For more information, refer to the [Function Trigger Type](#function-trigger-type) section.
-- 
-- If Spans following this convention are produced, a Resource of type @faas@ MUST exist following the [Resource semantic convention](\/docs\/resource\/faas.md).
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




-- $span_faas_datasource_server
-- This span represents server side if the FaaS invocations triggered in response response to some data source operation such as a database or filesystem read\/write.
--
-- Stability: development
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





-- $span_faas_timer_server
-- This span represents server side if the FaaS invocations triggered by a timer.
--
-- Stability: development
--
-- === Attributes
-- - 'faas_time'
--
-- - 'faas_cron'
--



-- $span_faas_server
-- This span represents server (incoming) side of the FaaS invocation.
--
-- Stability: development
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



-- $span_faas_client
-- This span represents an outgoing call to a FaaS service.
--
-- Stability: development
--
-- ==== Note
-- The values reported by the client for the attributes listed below SHOULD be equal to
-- the corresponding [FaaS resource attributes][] and [Cloud resource attributes][],
-- which the invoked FaaS instance reports about itself, if it\'s instrumented.
--
-- === Attributes
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





-- $registry_faas
-- FaaS attributes
--
-- === Attributes
-- - 'faas_name'
--
--     Stability: development
--
-- - 'faas_version'
--
--     Stability: development
--
-- - 'faas_instance'
--
--     Stability: development
--
-- - 'faas_maxMemory'
--
--     Stability: development
--
-- - 'faas_trigger'
--
--     Stability: development
--
-- - 'faas_invokedName'
--
--     Stability: development
--
-- - 'faas_invokedProvider'
--
--     Stability: development
--
-- - 'faas_invokedRegion'
--
--     Stability: development
--
-- - 'faas_invocationId'
--
--     Stability: development
--
-- - 'faas_time'
--
--     Stability: development
--
-- - 'faas_cron'
--
--     Stability: development
--
-- - 'faas_coldstart'
--
--     Stability: development
--
-- - 'faas_document_collection'
--
--     Stability: development
--
-- - 'faas_document_operation'
--
--     Stability: development
--
-- - 'faas_document_time'
--
--     Stability: development
--
-- - 'faas_document_name'
--
--     Stability: development
--

-- |
-- The name of the single function that this runtime instance executes.

-- ==== Note
-- This is the name of the function as configured\/deployed on the FaaS
-- platform and is usually different from the name of the callback
-- function (which may be stored in the
-- [@code.namespace@\/@code.function.name@](\/docs\/general\/attributes.md#source-code-attributes)
-- span attributes).
-- 
-- For some cloud providers, the above definition is ambiguous. The following
-- definition of function name MUST be used for this attribute
-- (and consequently the span name) for the listed cloud providers\/products:
-- 
-- - __Azure:__  The full name @\<FUNCAPP\>\/\<FUNC\>@, i.e., function app name
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
-- - __AWS Lambda:__ The [function version](https:\/\/docs.aws.amazon.com\/lambda\/latest\/dg\/configuration-versions.html)
--   (an integer represented as a decimal string).
-- - __Google Cloud Run (Services):__ The [revision](https:\/\/cloud.google.com\/run\/docs\/managing\/revisions)
--   (i.e., the function name plus the revision suffix).
-- - __Google Cloud Functions:__ The value of the
--   [@K_REVISION@ environment variable](https:\/\/cloud.google.com\/run\/docs\/container-contract#services-env-vars).
-- - __Azure Functions:__ Not applicable. Do not set this attribute.
faas_version :: AttributeKey Text
faas_version = AttributeKey "faas.version"

-- |
-- The execution environment ID as a string, that will be potentially reused for other invocations to the same function\/function version.

-- ==== Note
-- - __AWS Lambda:__ Use the (full) log stream name.
faas_instance :: AttributeKey Text
faas_instance = AttributeKey "faas.instance"

-- |
-- The amount of memory available to the serverless function converted to Bytes.

-- ==== Note
-- It\'s recommended to set this attribute since e.g. too little memory can easily stop a Java AWS Lambda function from working correctly. On AWS Lambda, the environment variable @AWS_LAMBDA_FUNCTION_MEMORY_SIZE@ provides this information (which must be multiplied by 1,048,576).
faas_maxMemory :: AttributeKey Int64
faas_maxMemory = AttributeKey "faas.max_memory"

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

-- |
-- The invocation ID of the current function invocation.
faas_invocationId :: AttributeKey Text
faas_invocationId = AttributeKey "faas.invocation_id"

-- |
-- A string containing the function invocation time in the [ISO 8601](https:\/\/www.iso.org\/iso-8601-date-and-time-format.html) format expressed in [UTC](https:\/\/www.w3.org\/TR\/NOTE-datetime).
faas_time :: AttributeKey Text
faas_time = AttributeKey "faas.time"

-- |
-- A string containing the schedule period as [Cron Expression](https:\/\/docs.oracle.com\/cd\/E12058_01\/doc\/doc.1014\/e12030\/cron_expressions.htm).
faas_cron :: AttributeKey Text
faas_cron = AttributeKey "faas.cron"

-- |
-- A boolean that is true if the serverless function is executed for the first time (aka cold-start).
faas_coldstart :: AttributeKey Bool
faas_coldstart = AttributeKey "faas.coldstart"

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

-- $metric_faas_invokeDuration
-- Measures the duration of the function\'s logic execution.
--
-- Stability: development
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_initDuration
-- Measures the duration of the function\'s initialization, such as a cold start.
--
-- Stability: development
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_coldstarts
-- Number of invocation cold starts.
--
-- Stability: development
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_errors
-- Number of invocation errors.
--
-- Stability: development
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_invocations
-- Number of successful invocations.
--
-- Stability: development
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_timeouts
-- Number of invocation timeouts.
--
-- Stability: development
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_memUsage
-- Distribution of max memory usage per invocation.
--
-- Stability: development
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_cpuUsage
-- Distribution of CPU usage per invocation.
--
-- Stability: development
--
-- === Attributes
-- - 'faas_trigger'
--


-- $metric_faas_netIo
-- Distribution of net I\/O usage per invocation.
--
-- Stability: development
--
-- === Attributes
-- - 'faas_trigger'
--


-- $registry_geo
-- Geo fields can carry data about a specific location related to an event. This geolocation information can be derived from techniques such as Geo IP, or be user-supplied.
-- Note: Geo attributes are typically used under another namespace, such as client.* and describe the location of the corresponding entity (device, end-user, etc). Semantic conventions that reference geo attributes (as a root namespace) or embed them (under their own namespace) SHOULD document what geo attributes describe in the scope of that convention.
--
-- === Attributes
-- - 'geo_locality_name'
--
--     Stability: development
--
-- - 'geo_continent_code'
--
--     Stability: development
--
-- - 'geo_country_isoCode'
--
--     Stability: development
--
-- - 'geo_location_lon'
--
--     Stability: development
--
-- - 'geo_location_lat'
--
--     Stability: development
--
-- - 'geo_postalCode'
--
--     Stability: development
--
-- - 'geo_region_isoCode'
--
--     Stability: development
--

-- |
-- Locality name. Represents the name of a city, town, village, or similar populated place.
geo_locality_name :: AttributeKey Text
geo_locality_name = AttributeKey "geo.locality.name"

-- |
-- Two-letter code representing continent’s name.
geo_continent_code :: AttributeKey Text
geo_continent_code = AttributeKey "geo.continent.code"

-- |
-- Two-letter ISO Country Code ([ISO 3166-1 alpha2](https:\/\/wikipedia.org\/wiki\/ISO_3166-1#Codes)).
geo_country_isoCode :: AttributeKey Text
geo_country_isoCode = AttributeKey "geo.country.iso_code"

-- |
-- Longitude of the geo location in [WGS84](https:\/\/wikipedia.org\/wiki\/World_Geodetic_System#WGS84).
geo_location_lon :: AttributeKey Double
geo_location_lon = AttributeKey "geo.location.lon"

-- |
-- Latitude of the geo location in [WGS84](https:\/\/wikipedia.org\/wiki\/World_Geodetic_System#WGS84).
geo_location_lat :: AttributeKey Double
geo_location_lat = AttributeKey "geo.location.lat"

-- |
-- Postal code associated with the location. Values appropriate for this field may also be known as a postcode or ZIP code and will vary widely from country to country.
geo_postalCode :: AttributeKey Text
geo_postalCode = AttributeKey "geo.postal_code"

-- |
-- Region ISO code ([ISO 3166-2](https:\/\/wikipedia.org\/wiki\/ISO_3166-2)).
geo_region_isoCode :: AttributeKey Text
geo_region_isoCode = AttributeKey "geo.region.iso_code"

-- $registry_securityRule
-- Describes security rule attributes. Rule fields are used to capture the specifics of any observer or agent rules that generate alerts or other notable events.
--
-- === Attributes
-- - 'securityRule_category'
--
--     Stability: development
--
-- - 'securityRule_description'
--
--     Stability: development
--
-- - 'securityRule_license'
--
--     Stability: development
--
-- - 'securityRule_name'
--
--     Stability: development
--
-- - 'securityRule_reference'
--
--     Stability: development
--
-- - 'securityRule_ruleset_name'
--
--     Stability: development
--
-- - 'securityRule_uuid'
--
--     Stability: development
--
-- - 'securityRule_version'
--
--     Stability: development
--

-- |
-- A categorization value keyword used by the entity using the rule for detection of this event
securityRule_category :: AttributeKey Text
securityRule_category = AttributeKey "security_rule.category"

-- |
-- The description of the rule generating the event.
securityRule_description :: AttributeKey Text
securityRule_description = AttributeKey "security_rule.description"

-- |
-- Name of the license under which the rule used to generate this event is made available.
securityRule_license :: AttributeKey Text
securityRule_license = AttributeKey "security_rule.license"

-- |
-- The name of the rule or signature generating the event.
securityRule_name :: AttributeKey Text
securityRule_name = AttributeKey "security_rule.name"

-- |
-- Reference URL to additional information about the rule used to generate this event.

-- ==== Note
-- The URL can point to the vendor’s documentation about the rule. If that’s not available, it can also be a link to a more general page describing this type of alert.
securityRule_reference :: AttributeKey Text
securityRule_reference = AttributeKey "security_rule.reference"

-- |
-- Name of the ruleset, policy, group, or parent category in which the rule used to generate this event is a member.
securityRule_ruleset_name :: AttributeKey Text
securityRule_ruleset_name = AttributeKey "security_rule.ruleset.name"

-- |
-- A rule ID that is unique within the scope of a set or group of agents, observers, or other entities using the rule for detection of this event.
securityRule_uuid :: AttributeKey Text
securityRule_uuid = AttributeKey "security_rule.uuid"

-- |
-- The version \/ revision of the rule being used for analysis.
securityRule_version :: AttributeKey Text
securityRule_version = AttributeKey "security_rule.version"

-- $registry_code_deprecated
-- These deprecated attributes provide context about source code
--
-- === Attributes
-- - 'code_function'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'code_filepath'
--
--     Stability: development
--
--     Deprecated: renamed: code.file.path
--
-- - 'code_lineno'
--
--     Stability: development
--
--     Deprecated: renamed: code.line.number
--
-- - 'code_column'
--
--     Stability: development
--
--     Deprecated: renamed: code.column.number
--
-- - 'code_namespace'
--
--     Stability: development
--
--     Deprecated: uncategorized
--

-- |
-- Deprecated, use @code.function.name@ instead
code_function :: AttributeKey Text
code_function = AttributeKey "code.function"

-- |
-- Deprecated, use @code.file.path@ instead
code_filepath :: AttributeKey Text
code_filepath = AttributeKey "code.filepath"

-- |
-- Deprecated, use @code.line.number@ instead
code_lineno :: AttributeKey Int64
code_lineno = AttributeKey "code.lineno"

-- |
-- Deprecated, use @code.column.number@
code_column :: AttributeKey Int64
code_column = AttributeKey "code.column"

-- |
-- Deprecated, namespace is now included into @code.function.name@
code_namespace :: AttributeKey Text
code_namespace = AttributeKey "code.namespace"

-- $code
-- These attributes provide context about source code
--
-- === Attributes
-- - 'code_function_name'
--
-- - 'code_file_path'
--
-- - 'code_line_number'
--
-- - 'code_column_number'
--
-- - 'code_stacktrace'
--
--     Requirement level: opt-in
--






-- $registry_code
-- These attributes provide context about source code
--
-- === Attributes
-- - 'code_function_name'
--
--     Stability: stable
--
-- - 'code_file_path'
--
--     Stability: stable
--
-- - 'code_line_number'
--
--     Stability: stable
--
-- - 'code_column_number'
--
--     Stability: stable
--
-- - 'code_stacktrace'
--
--     Stability: stable
--

-- |
-- The method or function fully-qualified name without arguments. The value should fit the natural representation of the language runtime, which is also likely the same used within @code.stacktrace@ attribute value. This attribute MUST NOT be used on the Profile signal since the data is already captured in \'message Function\'. This constraint is imposed to prevent redundancy and maintain data integrity.

-- ==== Note
-- Values and format depends on each language runtime, thus it is impossible to provide an exhaustive list of examples.
-- The values are usually the same (or prefixes of) the ones found in native stack trace representation stored in
-- @code.stacktrace@ without information on arguments.
-- 
-- Examples:
-- 
-- * Java method: @com.example.MyHttpService.serveRequest@
-- * Java anonymous class method: @com.mycompany.Main$1.myMethod@
-- * Java lambda method: @com.mycompany.Main$$Lambda\/0x0000748ae4149c00.myMethod@
-- * PHP function: @GuzzleHttp\Client::transfer@
-- * Go function: @github.com\/my\/repo\/pkg.foo.func5@
-- * Elixir: @OpenTelemetry.Ctx.new@
-- * Erlang: @opentelemetry_ctx:new@
-- * Rust: @playground::my_module::my_cool_func@
-- * C function: @fopen@
code_function_name :: AttributeKey Text
code_function_name = AttributeKey "code.function.name"

-- |
-- The source code file name that identifies the code unit as uniquely as possible (preferably an absolute file path). This attribute MUST NOT be used on the Profile signal since the data is already captured in \'message Function\'. This constraint is imposed to prevent redundancy and maintain data integrity.
code_file_path :: AttributeKey Text
code_file_path = AttributeKey "code.file.path"

-- |
-- The line number in @code.file.path@ best representing the operation. It SHOULD point within the code unit named in @code.function.name@. This attribute MUST NOT be used on the Profile signal since the data is already captured in \'message Line\'. This constraint is imposed to prevent redundancy and maintain data integrity.
code_line_number :: AttributeKey Int64
code_line_number = AttributeKey "code.line.number"

-- |
-- The column number in @code.file.path@ best representing the operation. It SHOULD point within the code unit named in @code.function.name@. This attribute MUST NOT be used on the Profile signal since the data is already captured in \'message Line\'. This constraint is imposed to prevent redundancy and maintain data integrity.
code_column_number :: AttributeKey Int64
code_column_number = AttributeKey "code.column.number"

-- |
-- A stacktrace as a string in the natural representation for the language runtime. The representation is identical to [@exception.stacktrace@](\/docs\/exceptions\/exceptions-spans.md#stacktrace-representation). This attribute MUST NOT be used on the Profile signal since the data is already captured in \'message Location\'. This constraint is imposed to prevent redundancy and maintain data integrity.
code_stacktrace :: AttributeKey Text
code_stacktrace = AttributeKey "code.stacktrace"

-- $metric_jvm_memory_init
-- Measure of initial memory requested.
--
-- Stability: development
--

-- $metric_jvm_system_cpu_utilization
-- Recent CPU utilization for the whole system as reported by the JVM.
--
-- Stability: development
--
-- ==== Note
-- The value range is [0.0,1.0]. This utilization is not defined as being for the specific interval since last measurement (unlike @system.cpu.utilization@). [Reference](https:\/\/docs.oracle.com\/en\/java\/javase\/17\/docs\/api\/jdk.management\/com\/sun\/management\/OperatingSystemMXBean.html#getCpuLoad()).
--

-- $metric_jvm_system_cpu_load1m
-- Average CPU load of the whole system for the last minute as reported by the JVM.
--
-- Stability: development
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


-- $metric_jvm_buffer_memory_used
-- Measure of memory used by buffers.
--
-- Stability: development
--

-- $metric_jvm_buffer_memory_limit
-- Measure of total memory capacity of buffers.
--
-- Stability: development
--

-- $metric_jvm_buffer_count
-- Number of buffers in the pool.
--
-- Stability: development
--

-- $metric_jvm_fileDescriptor_count
-- Number of open file descriptors as reported by the JVM.
--
-- Stability: development
--

-- $metric_jvm_fileDescriptor_limit
-- Measure of max open file descriptors as reported by the JVM.
--
-- Stability: development
--

-- $registry_jvm
-- This document defines Java Virtual machine related attributes.
--
-- === Attributes
-- - 'jvm_gc_action'
--
--     Stability: stable
--
-- - 'jvm_gc_cause'
--
--     Stability: development
--
-- - 'jvm_gc_name'
--
--     Stability: stable
--
-- - 'jvm_memory_type'
--
--     Stability: stable
--
-- - 'jvm_memory_pool_name'
--
--     Stability: stable
--
-- - 'jvm_thread_daemon'
--
--     Stability: stable
--
-- - 'jvm_thread_state'
--
--     Stability: stable
--
-- - 'jvm_buffer_pool_name'
--
--     Stability: development
--

-- |
-- Name of the garbage collector action.

-- ==== Note
-- Garbage collector action is generally obtained via [GarbageCollectionNotificationInfo#getGcAction()](https:\/\/docs.oracle.com\/en\/java\/javase\/11\/docs\/api\/jdk.management\/com\/sun\/management\/GarbageCollectionNotificationInfo.html#getGcAction()).
jvm_gc_action :: AttributeKey Text
jvm_gc_action = AttributeKey "jvm.gc.action"

-- |
-- Name of the garbage collector cause.

-- ==== Note
-- Garbage collector cause is generally obtained via [GarbageCollectionNotificationInfo#getGcCause()](https:\/\/docs.oracle.com\/en\/java\/javase\/11\/docs\/api\/jdk.management\/com\/sun\/management\/GarbageCollectionNotificationInfo.html#getGcCause()).
jvm_gc_cause :: AttributeKey Text
jvm_gc_cause = AttributeKey "jvm.gc.cause"

-- |
-- Name of the garbage collector.

-- ==== Note
-- Garbage collector name is generally obtained via [GarbageCollectionNotificationInfo#getGcName()](https:\/\/docs.oracle.com\/en\/java\/javase\/11\/docs\/api\/jdk.management\/com\/sun\/management\/GarbageCollectionNotificationInfo.html#getGcName()).
jvm_gc_name :: AttributeKey Text
jvm_gc_name = AttributeKey "jvm.gc.name"

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

-- |
-- Whether the thread is daemon or not.
jvm_thread_daemon :: AttributeKey Bool
jvm_thread_daemon = AttributeKey "jvm.thread.daemon"

-- |
-- State of the thread.
jvm_thread_state :: AttributeKey Text
jvm_thread_state = AttributeKey "jvm.thread.state"

-- |
-- Name of the buffer pool.

-- ==== Note
-- Pool names are generally obtained via [BufferPoolMXBean#getName()](https:\/\/docs.oracle.com\/en\/java\/javase\/11\/docs\/api\/java.management\/java\/lang\/management\/BufferPoolMXBean.html#getName()).
jvm_buffer_pool_name :: AttributeKey Text
jvm_buffer_pool_name = AttributeKey "jvm.buffer.pool.name"

-- $attributes_jvm_memory
-- Describes JVM memory metric attributes.
--
-- === Attributes
-- - 'jvm_memory_type'
--
--     Requirement level: recommended
--
-- - 'jvm_memory_pool_name'
--
--     Name of the memory pool.
--
--     Requirement level: recommended
--



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
--     Requirement level: recommended
--
-- - 'jvm_gc_action'
--
--     Requirement level: recommended
--
-- - 'jvm_gc_cause'
--
--     Requirement level: opt-in
--




-- $metric_jvm_thread_count
-- Number of executing platform threads.
--
-- Stability: stable
--
-- === Attributes
-- - 'jvm_thread_daemon'
--
--     Requirement level: recommended
--
-- - 'jvm_thread_state'
--
--     Requirement level: recommended
--



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

-- $metric_jvm_buffer_memory_usage
-- Deprecated, use @jvm.buffer.memory.used@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: jvm.buffer.memory.used
--

-- $registry_oci_manifest
-- An OCI image manifest.
--
-- === Attributes
-- - 'oci_manifest_digest'
--
--     Stability: development
--

-- |
-- The digest of the OCI image manifest. For container images specifically is the digest by which the container image is known.

-- ==== Note
-- Follows [OCI Image Manifest Specification](https:\/\/github.com\/opencontainers\/image-spec\/blob\/main\/manifest.md), and specifically the [Digest property](https:\/\/github.com\/opencontainers\/image-spec\/blob\/main\/descriptor.md#digests).
-- An example can be found in [Example Image Manifest](https:\/\/github.com\/opencontainers\/image-spec\/blob\/main\/manifest.md#example-image-manifest).
oci_manifest_digest :: AttributeKey Text
oci_manifest_digest = AttributeKey "oci.manifest.digest"

-- $server
-- General server attributes.
--
-- === Attributes
-- - 'server_address'
--
-- - 'server_port'
--



-- $registry_server
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

-- $registry_user
-- Describes information about the user.
--
-- === Attributes
-- - 'user_email'
--
--     Stability: development
--
-- - 'user_fullName'
--
--     Stability: development
--
-- - 'user_hash'
--
--     Stability: development
--
-- - 'user_id'
--
--     Stability: development
--
-- - 'user_name'
--
--     Stability: development
--
-- - 'user_roles'
--
--     Stability: development
--

-- |
-- User email address.
user_email :: AttributeKey Text
user_email = AttributeKey "user.email"

-- |
-- User\'s full name
user_fullName :: AttributeKey Text
user_fullName = AttributeKey "user.full_name"

-- |
-- Unique user hash to correlate information for a user in anonymized form.

-- ==== Note
-- Useful if @user.id@ or @user.name@ contain confidential information and cannot be used.
user_hash :: AttributeKey Text
user_hash = AttributeKey "user.hash"

-- |
-- Unique identifier of the user.
user_id :: AttributeKey Text
user_id = AttributeKey "user.id"

-- |
-- Short name or login\/username of the user.
user_name :: AttributeKey Text
user_name = AttributeKey "user.name"

-- |
-- Array of user roles at the time of the event.
user_roles :: AttributeKey [Text]
user_roles = AttributeKey "user.roles"

-- $trace_mcp_common_attributes
-- MCP common span attributes
--
-- === Attributes
-- - 'mcp_session_id'
--
--     Requirement level: recommended: When the MCP request or notification is part of a session.
--
-- - 'mcp_resource_uri'
--
--     Requirement level: conditionally required: When the client executes a request type that includes a resource URI parameter.
--
-- - 'jsonrpc_request_id'
--
--     Requirement level: conditionally required: When the client executes a request.
--




-- $span_mcp_client
-- This span describes the MCP call from the client side.
--
-- Stability: development
--
-- ==== Note
-- It\'s reported by the MCP client when it initiates the request
-- or notification or by the MCP server when server initiates the operation.
-- It covers the time to receive the response or ack from the peer.
-- 
-- __Span name__ SHOULD follow the format @{mcp.method.name} {target}@
-- where target SHOULD match @{gen_ai.tool.name}@ or @{gen_ai.prompt.name}@ when
-- applicable.
-- If there is no low-cardinality @target@ available, the Span name SHOULD be @{mcp.method.name}@.
-- 
-- Instrumentation MAY allow users to opt into including @{mcp.resource.uri}@
-- as @target@ in the span name when it is available but SHOULD NOT include it by default
-- to avoid high cardinality span names.
-- 
-- __Span status__ SHOULD be set to @ERROR@ when @error.type@ attribute is present.
-- The status description SHOULD match the @JSONRPCError.message@ if the message is available.
-- 
-- Refer to the [Recording Errors](\/docs\/general\/recording-errors.md) document
-- for more details.
-- 
-- MCP tool call execution spans are compatible with GenAI [execute_tool spans](\/docs\/gen-ai\/gen-ai-spans.md#execute-tool-span).
-- 
-- If the MCP instrumentation can reliably detect that outer GenAI instrumentation
-- is already tracing the tool execution, it SHOULD NOT create a separate span.
-- Instead, it SHOULD add MCP-specific attributes to the existing tool execution span.
-- 
-- Instrumentations that support this behavior MAY provide a configuration
-- option to enable it.
--
-- === Attributes
-- - 'server_address'
--
--     Requirement level: recommended: If applicable
--
-- - 'server_port'
--
--     Requirement level: recommended: When @server.address@ is set
--
-- - 'genAi_tool_call_arguments'
--
--     Requirement level: opt-in
--
-- - 'genAi_tool_call_result'
--
--     Requirement level: opt-in
--





-- $span_mcp_server
-- This span describes the processing of the MCP request or notification initiated by the peer.
--
-- Stability: development
--
-- ==== Note
-- It\'s reported by the MCP server when client initiates the request
-- (or notification) or by the MCP client when server initiates the operation.
-- 
-- __Span name__ SHOULD follow the format @{mcp.method.name} {target}@
-- where target SHOULD match @{gen_ai.tool.name}@ or @{gen_ai.prompt.name}@ when
-- applicable.
-- If there is no low-cardinality @target@ available, the Span name SHOULD be @{mcp.method.name}@.
-- 
-- Instrumentation MAY allow users to opt into including @{mcp.resource.uri}@
-- as @target@ in the span name when it is available but SHOULD NOT include it by default
-- to avoid high cardinality span names.
-- 
-- __Span status__ SHOULD be set to @ERROR@ when @error.type@ attribute is present.
-- The status description SHOULD match the @JSONRPCError.message@ if the message is available.
-- 
-- Refer to the [Recording Errors](\/docs\/general\/recording-errors.md) document
-- for more details.
--
-- === Attributes
-- - 'client_address'
--
--     Requirement level: recommended: If applicable
--
-- - 'client_port'
--
--     Requirement level: recommended: When @client.address@ is set
--



-- $mcp_common_attributes
-- Common MCP attributes
--
-- === Attributes
-- - 'genAi_tool_name'
--
--     Requirement level: conditionally required: When operation is related to a specific tool.
--
-- - 'genAi_operation_name'
--
--     The name of the GenAI operation being performed.
--
--     Requirement level: recommended: SHOULD be set to @execute_tool@ when the operation describes a tool call and SHOULD NOT be set otherwise.
--
--     ==== Note
--     Populating this attribute for tool calling along with @mcp.method.name@ allows consumers to treat MCP tool calls spans similarly with other tool call types.
--
-- - 'genAi_prompt_name'
--
--     The name of the prompt or prompt template provided in the request or response.
--
--     Requirement level: conditionally required: When operation is related to a specific prompt.
--
-- - 'network_transport'
--
--     The transport protocol used for the MCP session.
--
--     ==== Note
--     This attribute SHOULD be set to @tcp@ or @quic@ if the transport protocol
--     is HTTP.
--     It SHOULD be set to @pipe@ if the transport is stdio.
--
-- - 'error_type'
--
--     Requirement level: conditionally required: If and only if the operation fails.
--
--     ==== Note
--     This attribute SHOULD be set to the string representation of the JSON-RPC
--     error code, if one is returned.
--     
--     When JSON-RPC call is successful, but an error is returned within the
--     result payload, this attribute SHOULD be set to the low-cardinality
--     string representation of the error. When
--     [CallToolResult](https:\/\/github.com\/modelcontextprotocol\/modelcontextprotocol\/blob\/9c8a44e47e16b789a1f9d47c89ea23ed13a37cf9\/schema\/2025-06-18\/schema.ts#L715)
--     is returned with @isError@ set to @true@, this attribute SHOULD be set to
--     @tool_error@.
--
-- - 'mcp_method_name'
--
--     Requirement level: required
--
-- - 'mcp_protocol_version'
--
-- - 'rpc_response_statusCode'
--
--     The error code from the JSON-RPC response.
--
--     Requirement level: conditionally required: If response contains an error code.
--
-- - 'network_protocol_name'
--
--     Requirement level: recommended: When applicable.
--
-- - 'network_protocol_version'
--
--     Requirement level: recommended: When applicable.
--
--     ==== Note
--     
--
-- - 'jsonrpc_protocol_version'
--
--     Requirement level: recommended: when it\'s not @2.0@.
--












-- $registry_mcp
-- [Model Context Protocol (MCP)](https:\/\/modelcontextprotocol.io) attributes
--
-- === Attributes
-- - 'mcp_method_name'
--
--     Stability: development
--
-- - 'mcp_session_id'
--
--     Stability: development
--
-- - 'mcp_resource_uri'
--
--     Stability: development
--
-- - 'mcp_protocol_version'
--
--     Stability: development
--

-- |
-- The name of the request or notification method.
mcp_method_name :: AttributeKey Text
mcp_method_name = AttributeKey "mcp.method.name"

-- |
-- Identifies [MCP session](https:\/\/modelcontextprotocol.io\/specification\/2025-06-18\/basic\/transports#session-management).
mcp_session_id :: AttributeKey Text
mcp_session_id = AttributeKey "mcp.session.id"

-- |
-- The value of the resource uri.

-- ==== Note
-- This is a URI of the resource provided in the following requests or notifications: @resources\/read@, @resources\/subscribe@, @resources\/unsubscribe@, or @notifications\/resources\/updated@.
mcp_resource_uri :: AttributeKey Text
mcp_resource_uri = AttributeKey "mcp.resource.uri"

-- |
-- The [version](https:\/\/modelcontextprotocol.io\/specification\/versioning) of the Model Context Protocol used.
mcp_protocol_version :: AttributeKey Text
mcp_protocol_version = AttributeKey "mcp.protocol.version"

-- $mcp_operation_metrics_attributes
-- MCP request metrics attributes
--
-- === Attributes
-- - 'mcp_resource_uri'
--
--     Requirement level: opt-in
--


-- $mcp_session_metrics_attributes
-- MCP session metrics attributes
--
-- === Attributes
-- - 'mcp_protocol_version'
--
-- - 'network_protocol_name'
--
--     Requirement level: recommended: When applicable.
--
-- - 'network_protocol_version'
--
--     Requirement level: recommended: When applicable.
--
--     ==== Note
--     
--
-- - 'jsonrpc_protocol_version'
--
--     Requirement level: recommended: when it\'s not @2.0@.
--
-- - 'network_transport'
--
--     The transport protocol used for the MCP session.
--
--     ==== Note
--     This attribute SHOULD be set to @tcp@ or @quic@ if the transport protocol
--     is HTTP. It SHOULD be set to @pipe@ if the transport is stdio.
--
-- - 'error_type'
--
--     Requirement level: conditionally required: If and only if session ends with an error.
--







-- $metric_mcp_client_operation_duration
-- The duration of the MCP request or notification as observed on the sender from the time it was sent until the response or ack is received.
--
-- Stability: development
--
-- === Attributes
-- - 'server_address'
--
--     Requirement level: recommended: If applicable
--
-- - 'server_port'
--
--     Requirement level: recommended: When @server.address@ is set
--



-- $metric_mcp_server_operation_duration
-- MCP request or notification duration as observed on the receiver from the time it was received until the result or ack is sent.
--
-- Stability: development
--

-- $metric_mcp_client_session_duration
-- The duration of the MCP session as observed on the MCP client.
--
-- Stability: development
--
-- === Attributes
-- - 'server_address'
--
--     Requirement level: recommended: If applicable
--
-- - 'server_port'
--
--     Requirement level: recommended: When @server.address@ is set
--



-- $metric_mcp_server_session_duration
-- The duration of the MCP session as observed on the MCP server.
--
-- Stability: development
--

-- $destination
-- General destination attributes.
--
-- === Attributes
-- - 'destination_address'
--
-- - 'destination_port'
--



-- $registry_destination
-- These attributes may be used to describe the receiver of a network exchange\/packet. These should be used when there is no client\/server relationship between the two sides, or when that relationship is unknown. This covers low-level network interactions (e.g. packet tracing) where you don\'t know if there was a connection or which side initiated it. This also covers unidirectional UDP flows and peer-to-peer communication where the "user-facing" surface of the protocol \/ API doesn\'t expose a clear notion of client and server.
--
-- === Attributes
-- - 'destination_address'
--
--     Stability: development
--
-- - 'destination_port'
--
--     Stability: development
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

-- $otelSpan
-- Span attributes used by non-OTLP exporters or on metrics to represent OpenTelemetry Span\'s concepts.
--
-- === Attributes
-- - 'otel_statusCode'
--
--     Requirement level: recommended
--
-- - 'otel_statusDescription'
--
--     Requirement level: recommended
--



-- $registry_otel
-- Attributes reserved for OpenTelemetry
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
-- - 'otel_span_samplingResult'
--
--     Stability: development
--
-- - 'otel_span_parent_origin'
--
--     Stability: development
--

-- |
-- Name of the code, either "OK" or "ERROR". MUST NOT be set if the status code is UNSET.
otel_statusCode :: AttributeKey Text
otel_statusCode = AttributeKey "otel.status_code"

-- |
-- Description of the Status if it has a value, otherwise not set.
otel_statusDescription :: AttributeKey Text
otel_statusDescription = AttributeKey "otel.status_description"

-- |
-- The result value of the sampler for this span
otel_span_samplingResult :: AttributeKey Text
otel_span_samplingResult = AttributeKey "otel.span.sampling_result"

-- |
-- Determines whether the span has a parent span, and if so, [whether it is a remote parent](https:\/\/opentelemetry.io\/docs\/specs\/otel\/trace\/api\/#isremote)
otel_span_parent_origin :: AttributeKey Text
otel_span_parent_origin = AttributeKey "otel.span.parent.origin"

-- $registry_otel_scope
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
-- - 'otel_scope_schemaUrl'
--
--     Stability: development
--

-- |
-- The name of the instrumentation scope - (@InstrumentationScope.Name@ in OTLP).
otel_scope_name :: AttributeKey Text
otel_scope_name = AttributeKey "otel.scope.name"

-- |
-- The version of the instrumentation scope - (@InstrumentationScope.Version@ in OTLP).
otel_scope_version :: AttributeKey Text
otel_scope_version = AttributeKey "otel.scope.version"

-- |
-- The schema URL of the instrumentation scope.
otel_scope_schemaUrl :: AttributeKey Text
otel_scope_schemaUrl = AttributeKey "otel.scope.schema_url"

-- $registry_otel_event
-- Attributes used by non-OTLP exporters to represent OpenTelemetry Event\'s concepts.
--
-- === Attributes
-- - 'otel_event_name'
--
--     Stability: development
--

-- |
-- Identifies the class \/ type of event.

-- ==== Note
-- This attribute SHOULD be used by non-OTLP exporters when destination does not support @EventName@ or equivalent field. This attribute MAY be used by applications using existing logging libraries so that it can be used to set the @EventName@ field by Collector or SDK components.
otel_event_name :: AttributeKey Text
otel_event_name = AttributeKey "otel.event.name"

-- $registry_otel_component
-- Attributes used for OpenTelemetry component self-monitoring
--
-- === Attributes
-- - 'otel_component_type'
--
--     Stability: development
--
-- - 'otel_component_name'
--
--     Stability: development
--

-- |
-- A name identifying the type of the OpenTelemetry component.

-- ==== Note
-- If none of the standardized values apply, implementations SHOULD use the language-defined name of the type.
-- E.g. for Java the fully qualified classname SHOULD be used in this case.
otel_component_type :: AttributeKey Text
otel_component_type = AttributeKey "otel.component.type"

-- |
-- A name uniquely identifying the instance of the OpenTelemetry component within its containing SDK instance.

-- ==== Note
-- Implementations SHOULD ensure a low cardinality for this attribute, even across application or SDK restarts.
-- E.g. implementations MUST NOT use UUIDs as values for this attribute.
-- 
-- Implementations MAY achieve these goals by following a @\<otel.component.type\>\/\<instance-counter\>@ pattern, e.g. @batching_span_processor\/0@.
-- Hereby @otel.component.type@ refers to the corresponding attribute value of the component.
-- 
-- The value of @instance-counter@ MAY be automatically assigned by the component and uniqueness within the enclosing SDK instance MUST be guaranteed.
-- For example, @\<instance-counter\>@ MAY be implemented by using a monotonically increasing counter (starting with @0@), which is incremented every time an
-- instance of the given component type is started.
-- 
-- With this implementation, for example the first Batching Span Processor would have @batching_span_processor\/0@
-- as @otel.component.name@, the second one @batching_span_processor\/1@ and so on.
-- These values will therefore be reused in the case of an application restart.
otel_component_name :: AttributeKey Text
otel_component_name = AttributeKey "otel.component.name"

-- $metric_otel_sdk_span_live
-- The number of created spans with @recording=true@ for which the end operation has not been called yet.
--
-- Stability: development
--
-- === Attributes
-- - 'otel_span_samplingResult'
--


-- $metric_otel_sdk_span_started
-- The number of created spans.
--
-- Stability: development
--
-- ==== Note
-- Implementations MUST record this metric for all spans, even for non-recording ones.
--
-- === Attributes
-- - 'otel_span_samplingResult'
--
-- - 'otel_span_parent_origin'
--



-- $metric_otel_sdk_processor_span_queue_size
-- The number of spans in the queue of a given instance of an SDK span processor.
--
-- Stability: development
--
-- ==== Note
-- Only applies to span processors which use a queue, e.g. the SDK Batching Span Processor.
--
-- === Attributes
-- - 'otel_component_type'
--
-- - 'otel_component_name'
--



-- $metric_otel_sdk_processor_span_queue_capacity
-- The maximum number of spans the queue of a given instance of an SDK span processor can hold.
--
-- Stability: development
--
-- ==== Note
-- Only applies to span processors which use a queue, e.g. the SDK Batching Span Processor.
--
-- === Attributes
-- - 'otel_component_type'
--
-- - 'otel_component_name'
--



-- $metric_otel_sdk_processor_span_processed
-- The number of spans for which the processing has finished, either successful or failed.
--
-- Stability: development
--
-- ==== Note
-- For successful processing, @error.type@ MUST NOT be set. For failed processing, @error.type@ MUST contain the failure cause.
-- For the SDK Simple and Batching Span Processor a span is considered to be processed already when it has been submitted to the exporter, not when the corresponding export call has finished.
--
-- === Attributes
-- - 'otel_component_type'
--
-- - 'otel_component_name'
--
-- - 'error_type'
--
--     A low-cardinality description of the failure reason. SDK Batching Span Processors MUST use @queue_full@ for spans dropped due to a full queue.
--




-- $metric_otel_sdk_exporter_span_inflight
-- The number of spans which were passed to the exporter, but that have not been exported yet (neither successful, nor failed).
--
-- Stability: development
--
-- ==== Note
-- For successful exports, @error.type@ MUST NOT be set. For failed exports, @error.type@ MUST contain the failure cause.
--
-- === Attributes
-- - 'otel_component_type'
--
-- - 'otel_component_name'
--
-- - 'server_address'
--
--     Requirement level: recommended: when applicable
--
-- - 'server_port'
--
--     Requirement level: recommended: when applicable
--





-- $metric_otel_sdk_exporter_span_exported
-- The number of spans for which the export has finished, either successful or failed.
--
-- Stability: development
--
-- ==== Note
-- For successful exports, @error.type@ MUST NOT be set. For failed exports, @error.type@ MUST contain the failure cause.
-- For exporters with partial success semantics (e.g. OTLP with @rejected_spans@), rejected spans MUST count as failed and only non-rejected spans count as success.
-- If no rejection reason is available, @rejected@ SHOULD be used as value for @error.type@.
--
-- === Attributes
-- - 'otel_component_type'
--
-- - 'otel_component_name'
--
-- - 'server_address'
--
--     Requirement level: recommended: when applicable
--
-- - 'server_port'
--
--     Requirement level: recommended: when applicable
--
-- - 'error_type'
--






-- $metric_otel_sdk_log_created
-- The number of logs submitted to enabled SDK Loggers.
--
-- Stability: development
--

-- $metric_otel_sdk_processor_log_queue_size
-- The number of log records in the queue of a given instance of an SDK log processor.
--
-- Stability: development
--
-- ==== Note
-- Only applies to log record processors which use a queue, e.g. the SDK Batching Log Record Processor.
--
-- === Attributes
-- - 'otel_component_type'
--
-- - 'otel_component_name'
--



-- $metric_otel_sdk_processor_log_queue_capacity
-- The maximum number of log records the queue of a given instance of an SDK Log Record processor can hold.
--
-- Stability: development
--
-- ==== Note
-- Only applies to Log Record processors which use a queue, e.g. the SDK Batching Log Record Processor.
--
-- === Attributes
-- - 'otel_component_type'
--
-- - 'otel_component_name'
--



-- $metric_otel_sdk_processor_log_processed
-- The number of log records for which the processing has finished, either successful or failed.
--
-- Stability: development
--
-- ==== Note
-- For successful processing, @error.type@ MUST NOT be set. For failed processing, @error.type@ MUST contain the failure cause.
-- For the SDK Simple and Batching Log Record Processor a log record is considered to be processed already when it has been submitted to the exporter,
-- not when the corresponding export call has finished.
--
-- === Attributes
-- - 'otel_component_type'
--
-- - 'otel_component_name'
--
-- - 'error_type'
--
--     A low-cardinality description of the failure reason. SDK Batching Log Record Processors MUST use @queue_full@ for log records dropped due to a full queue.
--




-- $metric_otel_sdk_exporter_log_inflight
-- The number of log records which were passed to the exporter, but that have not been exported yet (neither successful, nor failed).
--
-- Stability: development
--
-- ==== Note
-- For successful exports, @error.type@ MUST NOT be set. For failed exports, @error.type@ MUST contain the failure cause.
--
-- === Attributes
-- - 'otel_component_type'
--
-- - 'otel_component_name'
--
-- - 'server_address'
--
--     Requirement level: recommended: when applicable
--
-- - 'server_port'
--
--     Requirement level: recommended: when applicable
--





-- $metric_otel_sdk_exporter_log_exported
-- The number of log records for which the export has finished, either successful or failed.
--
-- Stability: development
--
-- ==== Note
-- For successful exports, @error.type@ MUST NOT be set. For failed exports, @error.type@ MUST contain the failure cause.
-- For exporters with partial success semantics (e.g. OTLP with @rejected_log_records@), rejected log records MUST count as failed and only non-rejected log records count as success.
-- If no rejection reason is available, @rejected@ SHOULD be used as value for @error.type@.
--
-- === Attributes
-- - 'otel_component_type'
--
-- - 'otel_component_name'
--
-- - 'server_address'
--
--     Requirement level: recommended: when applicable
--
-- - 'server_port'
--
--     Requirement level: recommended: when applicable
--
-- - 'error_type'
--






-- $metric_otel_sdk_exporter_metricDataPoint_inflight
-- The number of metric data points which were passed to the exporter, but that have not been exported yet (neither successful, nor failed).
--
-- Stability: development
--
-- ==== Note
-- For successful exports, @error.type@ MUST NOT be set. For failed exports, @error.type@ MUST contain the failure cause.
--
-- === Attributes
-- - 'otel_component_type'
--
-- - 'otel_component_name'
--
-- - 'server_address'
--
--     Requirement level: recommended: when applicable
--
-- - 'server_port'
--
--     Requirement level: recommended: when applicable
--





-- $metric_otel_sdk_exporter_metricDataPoint_exported
-- The number of metric data points for which the export has finished, either successful or failed.
--
-- Stability: development
--
-- ==== Note
-- For successful exports, @error.type@ MUST NOT be set. For failed exports, @error.type@ MUST contain the failure cause.
-- For exporters with partial success semantics (e.g. OTLP with @rejected_data_points@), rejected data points MUST count as failed and only non-rejected data points count as success.
-- If no rejection reason is available, @rejected@ SHOULD be used as value for @error.type@.
--
-- === Attributes
-- - 'otel_component_type'
--
-- - 'otel_component_name'
--
-- - 'server_address'
--
--     Requirement level: recommended: when applicable
--
-- - 'server_port'
--
--     Requirement level: recommended: when applicable
--
-- - 'error_type'
--






-- $metric_otel_sdk_metricReader_collection_duration
-- The duration of the collect operation of the metric reader.
--
-- Stability: development
--
-- ==== Note
-- For successful collections, @error.type@ MUST NOT be set. For failed collections, @error.type@ SHOULD contain the failure cause.
-- It can happen that metrics collection is successful for some MetricProducers, while others fail. In that case @error.type@ SHOULD be set to any of the failure causes.
--
-- === Attributes
-- - 'otel_component_type'
--
-- - 'otel_component_name'
--
-- - 'error_type'
--




-- $metric_otel_sdk_exporter_operation_duration
-- The duration of exporting a batch of telemetry records.
--
-- Stability: development
--
-- ==== Note
-- This metric defines successful operations using the full success definitions for [http](https:\/\/github.com\/open-telemetry\/opentelemetry-proto\/blob\/v1.5.0\/docs\/specification.md#full-success-1)
-- and [grpc](https:\/\/github.com\/open-telemetry\/opentelemetry-proto\/blob\/v1.5.0\/docs\/specification.md#full-success). Anything else is defined as an unsuccessful operation. For successful
-- operations, @error.type@ MUST NOT be set. For unsuccessful export operations, @error.type@ MUST contain a relevant failure cause.
--
-- === Attributes
-- - 'otel_component_type'
--
-- - 'otel_component_name'
--
-- - 'server_address'
--
--     Requirement level: recommended: when applicable
--
-- - 'server_port'
--
--     Requirement level: recommended: when applicable
--
-- - 'error_type'
--
--     Requirement level: conditionally required: If operation has ended with an error
--
-- - 'http_response_statusCode'
--
--     The HTTP status code of the last HTTP request performed in scope of this export call.
--
--     Requirement level: recommended: when applicable
--
-- - 'rpc_response_statusCode'
--
--     The gRPC status code of the last gRPC request performed in scope of this export call.
--
--     Requirement level: recommended: when applicable
--








-- $registry_otel_library_deprecated
-- Describes deprecated otel.library attributes.
--
-- === Attributes
-- - 'otel_library_name'
--
--     Stability: development
--
--     Deprecated: renamed: otel.scope.name
--
-- - 'otel_library_version'
--
--     Stability: development
--
--     Deprecated: renamed: otel.scope.version
--

-- |
-- Deprecated. Use the @otel.scope.name@ attribute
otel_library_name :: AttributeKey Text
otel_library_name = AttributeKey "otel.library.name"

-- |
-- Deprecated. Use the @otel.scope.version@ attribute.
otel_library_version :: AttributeKey Text
otel_library_version = AttributeKey "otel.library.version"

-- $entity_otel_scope
-- Attributes used by non-OTLP exporters to represent OpenTelemetry Scope\'s concepts.
--
-- Stability: development
--
-- Deprecated: obsoleted
--
-- === Attributes
-- - 'otel_scope_name'
--
--     Requirement level: recommended
--
-- - 'otel_scope_version'
--
--     Requirement level: recommended
--



-- $metric_otel_sdk_span_live_count
-- Deprecated, use @otel.sdk.span.live@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: otel.sdk.span.live
--

-- $metric_otel_sdk_span_ended_count
-- Use @otel.sdk.span.started@ minus @otel.sdk.span.live@ to derive this value.
--
-- Stability: development
--
-- Deprecated: obsoleted
--

-- $metric_otel_sdk_processor_span_processed_count
-- Deprecated, use @otel.sdk.processor.span.processed@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: otel.sdk.processor.span.processed
--

-- $metric_otel_sdk_exporter_span_inflight_count
-- Deprecated, use @otel.sdk.exporter.span.inflight@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: otel.sdk.exporter.span.inflight
--

-- $metric_otel_sdk_exporter_span_exported_count
-- Deprecated, use @otel.sdk.exporter.span.exported@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: otel.sdk.exporter.span.exported
--

-- $metric_otel_sdk_span_ended
-- Use @otel.sdk.span.started@ minus @otel.sdk.span.live@ to derive this value.
--
-- Stability: development
--
-- Deprecated: obsoleted
--

-- $attributes_cli_common
-- Common CLI attributes.
--
-- === Attributes
-- - 'process_executable_name'
--
--     Requirement level: required
--
-- - 'process_executable_path'
--
--     Requirement level: recommended
--
-- - 'process_pid'
--
--     Requirement level: required
--
-- - 'process_exit_code'
--
--     Requirement level: required
--
-- - 'process_commandArgs'
--
--     Requirement level: recommended
--
-- - 'error_type'
--
--     Requirement level: conditionally required: if and only if process.exit.code is not 0
--







-- $span_cli_internal
-- This span describes CLI (Command Line Interfaces) program execution from a callee perspective.
--
-- Stability: development
--
-- ==== Note
-- __Span name__ SHOULD be set to {process.executable.name}.
-- Instrumentations that have additional context about executed commands MAY use
-- a different low-cardinality span name format and SHOULD document it.
-- 
-- __Span status__ SHOULD follow the [Recording Errors](\/docs\/general\/recording-errors.md) document.
-- An Error is defined as when the @{process.exit.code}@ attribute is not 0.
--

-- $span_cli_client
-- This span describes CLI (Command Line Interfaces) program execution from a caller perspective.
--
-- Stability: development
--
-- ==== Note
-- __Span name__ SHOULD be set to {process.executable.name}.
-- Instrumentations that have additional context about executed commands MAY use
-- a different low-cardinality span name format and SHOULD document it.
-- 
-- __Span status__ SHOULD follow the [Recording Errors](\/docs\/general\/recording-errors.md) document.
-- An Error is defined as when the @{process.exit.code}@ attribute is not 0.
--

-- $entity_gcp_gce
-- Resources used by Google Compute Engine (GCE).
--
-- Stability: development
--
-- === Attributes
-- - 'gcp_gce_instance_name'
--
--     Requirement level: recommended
--
-- - 'gcp_gce_instance_hostname'
--
--     Requirement level: recommended
--



-- $entity_gcp_gce_instanceGroupManager
-- A GCE instance group manager.
--
-- Stability: development
--
-- === Attributes
-- - 'gcp_gce_instanceGroupManager_name'
--
--     Requirement level: required
--
-- - 'gcp_gce_instanceGroupManager_zone'
--
--     Requirement level: conditionally required: When the instance group is zonal, then zone MUST be filled out.
--
-- - 'gcp_gce_instanceGroupManager_region'
--
--     Requirement level: conditionally required: When the instance group is regional, then region MUST be filled out.
--




-- $entity_gcp_cloudRun
-- Resource used by Google Cloud Run.
--
-- Stability: development
--
-- === Attributes
-- - 'gcp_cloudRun_job_execution'
--
--     Requirement level: recommended
--
-- - 'gcp_cloudRun_job_taskIndex'
--
--     Requirement level: recommended
--



-- $entity_gcp_apphub_application
-- Attributes denoting data from an Application in AppHub. See [AppHub overview](https:\/\/cloud.google.com\/app-hub\/docs\/overview).
--
-- Stability: development
--
-- === Attributes
-- - 'gcp_apphub_application_container'
--
--     Requirement level: required
--
-- - 'gcp_apphub_application_location'
--
--     Requirement level: required
--
-- - 'gcp_apphub_application_id'
--
--     Requirement level: required
--




-- $entity_gcp_apphub_service
-- Attributes denoting data from a Service in AppHub. See [AppHub overview](https:\/\/cloud.google.com\/app-hub\/docs\/overview).
--
-- Stability: development
--
-- === Attributes
-- - 'gcp_apphub_service_id'
--
--     Requirement level: required
--
-- - 'gcp_apphub_service_environmentType'
--
--     Requirement level: required
--
-- - 'gcp_apphub_service_criticalityType'
--
--     Requirement level: required
--




-- $entity_gcp_apphub_workload
-- Attributes denoting data from a Workload in AppHub. See [AppHub overview](https:\/\/cloud.google.com\/app-hub\/docs\/overview).
--
-- Stability: development
--
-- === Attributes
-- - 'gcp_apphub_workload_id'
--
--     Requirement level: required
--
-- - 'gcp_apphub_workload_environmentType'
--
--     Requirement level: required
--
-- - 'gcp_apphub_workload_criticalityType'
--
--     Requirement level: required
--




-- $registry_gcp_client
-- Attributes for Google Cloud client libraries.
--
-- === Attributes
-- - 'gcp_client_service'
--
--     Stability: development
--

-- |
-- Identifies the Google Cloud service for which the official client library is intended.

-- ==== Note
-- Intended to be a stable identifier for Google Cloud client libraries that is uniform across implementation languages. The value should be derived from the canonical service domain for the service; for example, \'foo.googleapis.com\' should result in a value of \'foo\'.
gcp_client_service :: AttributeKey Text
gcp_client_service = AttributeKey "gcp.client.service"

-- $registry_gcp_cloudRun
-- This document defines attributes for Google Cloud Run.
--
-- === Attributes
-- - 'gcp_cloudRun_job_execution'
--
--     Stability: development
--
-- - 'gcp_cloudRun_job_taskIndex'
--
--     Stability: development
--

-- |
-- The name of the Cloud Run [execution](https:\/\/cloud.google.com\/run\/docs\/managing\/job-executions) being run for the Job, as set by the [@CLOUD_RUN_EXECUTION@](https:\/\/cloud.google.com\/run\/docs\/container-contract#jobs-env-vars) environment variable.
gcp_cloudRun_job_execution :: AttributeKey Text
gcp_cloudRun_job_execution = AttributeKey "gcp.cloud_run.job.execution"

-- |
-- The index for a task within an execution as provided by the [@CLOUD_RUN_TASK_INDEX@](https:\/\/cloud.google.com\/run\/docs\/container-contract#jobs-env-vars) environment variable.
gcp_cloudRun_job_taskIndex :: AttributeKey Int64
gcp_cloudRun_job_taskIndex = AttributeKey "gcp.cloud_run.job.task_index"

-- $registry_gcp_apphub
-- This document defines attributes AppHub will apply to resources in GCP. See [AppHub overview](https:\/\/cloud.google.com\/app-hub\/docs\/overview).
--
-- === Attributes
-- - 'gcp_apphub_application_container'
--
--     Stability: development
--
-- - 'gcp_apphub_application_location'
--
--     Stability: development
--
-- - 'gcp_apphub_application_id'
--
--     Stability: development
--
-- - 'gcp_apphub_service_id'
--
--     Stability: development
--
-- - 'gcp_apphub_service_environmentType'
--
--     Stability: development
--
-- - 'gcp_apphub_service_criticalityType'
--
--     Stability: development
--
-- - 'gcp_apphub_workload_id'
--
--     Stability: development
--
-- - 'gcp_apphub_workload_environmentType'
--
--     Stability: development
--
-- - 'gcp_apphub_workload_criticalityType'
--
--     Stability: development
--

-- |
-- The container within GCP where the AppHub application is defined.
gcp_apphub_application_container :: AttributeKey Text
gcp_apphub_application_container = AttributeKey "gcp.apphub.application.container"

-- |
-- The GCP zone or region where the application is defined.
gcp_apphub_application_location :: AttributeKey Text
gcp_apphub_application_location = AttributeKey "gcp.apphub.application.location"

-- |
-- The name of the application as configured in AppHub.
gcp_apphub_application_id :: AttributeKey Text
gcp_apphub_application_id = AttributeKey "gcp.apphub.application.id"

-- |
-- The name of the service as configured in AppHub.
gcp_apphub_service_id :: AttributeKey Text
gcp_apphub_service_id = AttributeKey "gcp.apphub.service.id"

-- |
-- Environment of a service is the stage of a software lifecycle.

-- ==== Note
-- [See AppHub environment type](https:\/\/cloud.google.com\/app-hub\/docs\/reference\/rest\/v1\/Attributes#type_1)
gcp_apphub_service_environmentType :: AttributeKey Text
gcp_apphub_service_environmentType = AttributeKey "gcp.apphub.service.environment_type"

-- |
-- Criticality of a service indicates its importance to the business.

-- ==== Note
-- [See AppHub type enum](https:\/\/cloud.google.com\/app-hub\/docs\/reference\/rest\/v1\/Attributes#type)
gcp_apphub_service_criticalityType :: AttributeKey Text
gcp_apphub_service_criticalityType = AttributeKey "gcp.apphub.service.criticality_type"

-- |
-- The name of the workload as configured in AppHub.
gcp_apphub_workload_id :: AttributeKey Text
gcp_apphub_workload_id = AttributeKey "gcp.apphub.workload.id"

-- |
-- Environment of a workload is the stage of a software lifecycle.

-- ==== Note
-- [See AppHub environment type](https:\/\/cloud.google.com\/app-hub\/docs\/reference\/rest\/v1\/Attributes#type_1)
gcp_apphub_workload_environmentType :: AttributeKey Text
gcp_apphub_workload_environmentType = AttributeKey "gcp.apphub.workload.environment_type"

-- |
-- Criticality of a workload indicates its importance to the business.

-- ==== Note
-- [See AppHub type enum](https:\/\/cloud.google.com\/app-hub\/docs\/reference\/rest\/v1\/Attributes#type)
gcp_apphub_workload_criticalityType :: AttributeKey Text
gcp_apphub_workload_criticalityType = AttributeKey "gcp.apphub.workload.criticality_type"

-- $registry_gcp_apphubDestination
-- This document defines attributes AppHub will apply to destination resources in GCP. See [AppHub overview](https:\/\/cloud.google.com\/app-hub\/docs\/overview).
--
-- === Attributes
-- - 'gcp_apphubDestination_application_container'
--
--     Stability: development
--
-- - 'gcp_apphubDestination_application_location'
--
--     Stability: development
--
-- - 'gcp_apphubDestination_application_id'
--
--     Stability: development
--
-- - 'gcp_apphubDestination_service_id'
--
--     Stability: development
--
-- - 'gcp_apphubDestination_service_environmentType'
--
--     Stability: development
--
-- - 'gcp_apphubDestination_service_criticalityType'
--
--     Stability: development
--
-- - 'gcp_apphubDestination_workload_id'
--
--     Stability: development
--
-- - 'gcp_apphubDestination_workload_environmentType'
--
--     Stability: development
--
-- - 'gcp_apphubDestination_workload_criticalityType'
--
--     Stability: development
--

-- |
-- The container within GCP where the AppHub destination application is defined.
gcp_apphubDestination_application_container :: AttributeKey Text
gcp_apphubDestination_application_container = AttributeKey "gcp.apphub_destination.application.container"

-- |
-- The GCP zone or region where the destination application is defined.
gcp_apphubDestination_application_location :: AttributeKey Text
gcp_apphubDestination_application_location = AttributeKey "gcp.apphub_destination.application.location"

-- |
-- The name of the destination application as configured in AppHub.
gcp_apphubDestination_application_id :: AttributeKey Text
gcp_apphubDestination_application_id = AttributeKey "gcp.apphub_destination.application.id"

-- |
-- The name of the destination service as configured in AppHub.
gcp_apphubDestination_service_id :: AttributeKey Text
gcp_apphubDestination_service_id = AttributeKey "gcp.apphub_destination.service.id"

-- |
-- Software lifecycle stage of a destination service as defined [AppHub environment type](https:\/\/cloud.google.com\/app-hub\/docs\/reference\/rest\/v1\/Attributes#type_1)
gcp_apphubDestination_service_environmentType :: AttributeKey Text
gcp_apphubDestination_service_environmentType = AttributeKey "gcp.apphub_destination.service.environment_type"

-- |
-- Criticality of a destination workload indicates its importance to the business as specified in [AppHub type enum](https:\/\/cloud.google.com\/app-hub\/docs\/reference\/rest\/v1\/Attributes#type)
gcp_apphubDestination_service_criticalityType :: AttributeKey Text
gcp_apphubDestination_service_criticalityType = AttributeKey "gcp.apphub_destination.service.criticality_type"

-- |
-- The name of the destination workload as configured in AppHub.
gcp_apphubDestination_workload_id :: AttributeKey Text
gcp_apphubDestination_workload_id = AttributeKey "gcp.apphub_destination.workload.id"

-- |
-- Environment of a destination workload is the stage of a software lifecycle as provided in the [AppHub environment type](https:\/\/cloud.google.com\/app-hub\/docs\/reference\/rest\/v1\/Attributes#type_1)
gcp_apphubDestination_workload_environmentType :: AttributeKey Text
gcp_apphubDestination_workload_environmentType = AttributeKey "gcp.apphub_destination.workload.environment_type"

-- |
-- Criticality of a destination workload indicates its importance to the business as specified in [AppHub type enum](https:\/\/cloud.google.com\/app-hub\/docs\/reference\/rest\/v1\/Attributes#type)
gcp_apphubDestination_workload_criticalityType :: AttributeKey Text
gcp_apphubDestination_workload_criticalityType = AttributeKey "gcp.apphub_destination.workload.criticality_type"

-- $registry_gcp_gce
-- This document defines attributes for Google Compute Engine (GCE).
--
-- === Attributes
-- - 'gcp_gce_instance_name'
--
--     Stability: development
--
-- - 'gcp_gce_instance_hostname'
--
--     Stability: development
--
-- - 'gcp_gce_instanceGroupManager_name'
--
--     Stability: development
--
-- - 'gcp_gce_instanceGroupManager_zone'
--
--     Stability: development
--
-- - 'gcp_gce_instanceGroupManager_region'
--
--     Stability: development
--

-- |
-- The instance name of a GCE instance. This is the value provided by @host.name@, the visible name of the instance in the Cloud Console UI, and the prefix for the default hostname of the instance as defined by the [default internal DNS name](https:\/\/cloud.google.com\/compute\/docs\/internal-dns#instance-fully-qualified-domain-names).
gcp_gce_instance_name :: AttributeKey Text
gcp_gce_instance_name = AttributeKey "gcp.gce.instance.name"

-- |
-- The hostname of a GCE instance. This is the full value of the default or [custom hostname](https:\/\/cloud.google.com\/compute\/docs\/instances\/custom-hostname-vm).
gcp_gce_instance_hostname :: AttributeKey Text
gcp_gce_instance_hostname = AttributeKey "gcp.gce.instance.hostname"

-- |
-- The name of the Instance Group Manager (IGM) that manages this VM, if any.
gcp_gce_instanceGroupManager_name :: AttributeKey Text
gcp_gce_instanceGroupManager_name = AttributeKey "gcp.gce.instance_group_manager.name"

-- |
-- The zone of a __zonal__ Instance Group Manager (e.g., @us-central1-a@). Set this __only__ when the IGM is zonal.
gcp_gce_instanceGroupManager_zone :: AttributeKey Text
gcp_gce_instanceGroupManager_zone = AttributeKey "gcp.gce.instance_group_manager.zone"

-- |
-- The region of a __regional__ Instance Group Manager (e.g., @us-central1@). Set this __only__ when the IGM is regional.
gcp_gce_instanceGroupManager_region :: AttributeKey Text
gcp_gce_instanceGroupManager_region = AttributeKey "gcp.gce.instance_group_manager.region"

-- $gcp_client_attributes
-- Conventions for official Google Cloud client libraries.
--
-- Stability: development
--
-- === Attributes
-- - 'gcp_client_service'
--
--     Requirement level: conditionally required: Required if and only if the instrumentation library is an official, Google-provided GCP and\/or Firebase client library.
--


-- $registry_peer
-- These attribute may be used for any operation that accesses some remote service.
--
-- ==== Note
-- Users can define what the name of a service is based on their particular semantics in their distributed system. Instrumentations SHOULD provide a way for users to configure this name.
--
-- === Attributes
-- - 'peer_service'
--
--     Stability: development
--
--     Deprecated: renamed: service.peer.name
--

-- |
-- The [@service.name@](\/docs\/resource\/README.md#service) of the remote service. SHOULD be equal to the actual @service.name@ resource attribute of the remote service if any.

-- ==== Note
-- Examples of @peer.service@ that users may specify:
-- 
-- - A Redis cache of auth tokens as @peer.service="AuthTokenCache"@.
-- - A gRPC service @rpc.service="io.opentelemetry.AuthService"@ may be hosted in both a gateway, @peer.service="ExternalApiService"@ and a backend, @peer.service="AuthService"@.
peer_service :: AttributeKey Text
peer_service = AttributeKey "peer.service"

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

-- |
-- The type of the exception (its fully-qualified class name, if applicable). The dynamic type of the exception should be preferred over the static type in languages that support it.
exception_type :: AttributeKey Text
exception_type = AttributeKey "exception.type"

-- |
-- The exception message.

-- ==== Note
-- \> [!WARNING]
-- \>
-- \> This attribute may contain sensitive information.
exception_message :: AttributeKey Text
exception_message = AttributeKey "exception.message"

-- |
-- A stacktrace as a string in the natural representation for the language runtime. The representation is to be determined and documented by each language SIG.
exception_stacktrace :: AttributeKey Text
exception_stacktrace = AttributeKey "exception.stacktrace"

-- $log-exception
-- This document defines attributes for exceptions represented using Log Records.
--
-- === Attributes
-- - 'exception_type'
--
--     Requirement level: conditionally required: Required if @exception.message@ is not set, recommended otherwise.
--
-- - 'exception_message'
--
--     Requirement level: conditionally required: Required if @exception.type@ is not set, recommended otherwise.
--
-- - 'exception_stacktrace'
--




-- $event_exception
-- This event describes a single exception.
--
-- Stability: stable
--
-- === Attributes
-- - 'exception_type'
--
--     Requirement level: conditionally required: Required if @exception.message@ is not set, recommended otherwise.
--
-- - 'exception_message'
--
--     Requirement level: conditionally required: Required if @exception.type@ is not set, recommended otherwise.
--
-- - 'exception_stacktrace'
--
-- - 'exception_escaped'
--





-- $registry_exception_deprecated
-- Deprecated exception attributes.
--
-- === Attributes
-- - 'exception_escaped'
--
--     Stability: stable
--
--     Deprecated: obsoleted
--

-- |
-- Indicates that the exception is escaping the scope of the span.
exception_escaped :: AttributeKey Bool
exception_escaped = AttributeKey "exception.escaped"

-- $registry_ios
-- This group describes iOS-specific attributes.
--
-- === Attributes
-- - 'ios_app_state'
--
--     Stability: development
--

-- |
-- This attribute represents the state of the application.

-- ==== Note
-- The iOS lifecycle states are defined in the [UIApplicationDelegate documentation](https:\/\/developer.apple.com\/documentation\/uikit\/uiapplicationdelegate), and from which the @OS terminology@ column values are derived.
ios_app_state :: AttributeKey Text
ios_app_state = AttributeKey "ios.app.state"

-- $registry_ios_deprecated
-- The iOS platform on which the iOS application is running.
--
-- === Attributes
-- - 'ios_state'
--
--     Stability: development
--
--     Deprecated: renamed: ios.app.state
--

-- |
-- Deprecated. Use the @ios.app.state@ attribute.

-- ==== Note
-- The iOS lifecycle states are defined in the [UIApplicationDelegate documentation](https:\/\/developer.apple.com\/documentation\/uikit\/uiapplicationdelegate), and from which the @OS terminology@ column values are derived.
ios_state :: AttributeKey Text
ios_state = AttributeKey "ios.state"

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






-- $registry_url
-- Attributes describing URL.
--
-- === Attributes
-- - 'url_domain'
--
--     Stability: development
--
-- - 'url_extension'
--
--     Stability: development
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
--     Stability: development
--
-- - 'url_path'
--
--     Stability: stable
--
-- - 'url_port'
--
--     Stability: development
--
-- - 'url_query'
--
--     Stability: stable
--
-- - 'url_registeredDomain'
--
--     Stability: development
--
-- - 'url_scheme'
--
--     Stability: stable
--
-- - 'url_subdomain'
--
--     Stability: development
--
-- - 'url_template'
--
--     Stability: development
--
-- - 'url_topLevelDomain'
--
--     Stability: development
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
-- For network calls, URL usually has @scheme:\/\/host[:port][path][?query][#fragment]@ format, where the fragment
-- is not transmitted over HTTP, but if it is known, it SHOULD be included nevertheless.
-- 
-- @url.full@ MUST NOT contain credentials passed via URL in form of @https:\/\/username:password\@www.example.com\/@.
-- In such case username and password SHOULD be redacted and attribute\'s value SHOULD be @https:\/\/REDACTED:REDACTED\@www.example.com\/@.
-- 
-- @url.full@ SHOULD capture the absolute URL when it is available (or can be reconstructed).
-- 
-- Sensitive content provided in @url.full@ SHOULD be scrubbed when instrumentations can identify it.
-- 
-- ![Development](https:\/\/img.shields.io\/badge\/-development-blue)
-- Query string values for the following keys SHOULD be redacted by default and replaced by the
-- value @REDACTED@:
-- 
-- * [@AWSAccessKeyId@](https:\/\/docs.aws.amazon.com\/AmazonS3\/latest\/userguide\/RESTAuthentication.html#RESTAuthenticationQueryStringAuth)
-- * [@Signature@](https:\/\/docs.aws.amazon.com\/AmazonS3\/latest\/userguide\/RESTAuthentication.html#RESTAuthenticationQueryStringAuth)
-- * [@sig@](https:\/\/learn.microsoft.com\/azure\/storage\/common\/storage-sas-overview#sas-token)
-- * [@X-Goog-Signature@](https:\/\/cloud.google.com\/storage\/docs\/access-control\/signed-urls)
-- 
-- This list is subject to change over time.
-- 
-- Matching of query parameter keys against the sensitive list SHOULD be case-sensitive.
-- 
-- ![Development](https:\/\/img.shields.io\/badge\/-development-blue)
-- Instrumentation MAY provide a way to override this list via declarative configuration.
-- If so, it SHOULD use the @sensitive_query_parameters@ property
-- (an array of case-sensitive strings with minimum items 0) under
-- @.instrumentation\/development.general.sanitization.url@.
-- This list is a full override of the default sensitive query parameter keys,
-- it is not a list of keys in addition to the defaults.
-- 
-- When a query string value is redacted, the query string key SHOULD still be preserved, e.g.
-- @https:\/\/www.example.com\/path?color=blue&sig=REDACTED@.
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
-- 
-- ![Development](https:\/\/img.shields.io\/badge\/-development-blue)
-- Query string values for the following keys SHOULD be redacted by default and replaced by the value @REDACTED@:
-- 
-- * [@AWSAccessKeyId@](https:\/\/docs.aws.amazon.com\/AmazonS3\/latest\/userguide\/RESTAuthentication.html#RESTAuthenticationQueryStringAuth)
-- * [@Signature@](https:\/\/docs.aws.amazon.com\/AmazonS3\/latest\/userguide\/RESTAuthentication.html#RESTAuthenticationQueryStringAuth)
-- * [@sig@](https:\/\/learn.microsoft.com\/azure\/storage\/common\/storage-sas-overview#sas-token)
-- * [@X-Goog-Signature@](https:\/\/cloud.google.com\/storage\/docs\/access-control\/signed-urls)
-- 
-- This list is subject to change over time.
-- 
-- Matching of query parameter keys against the sensitive list SHOULD be case-sensitive.
-- 
-- Instrumentation MAY provide a way to override this list via declarative configuration.
-- If so, it SHOULD use the @sensitive_query_parameters@ property
-- (an array of case-sensitive strings with minimum items 0) under
-- @.instrumentation\/development.general.sanitization.url@.
-- This list is a full override of the default sensitive query parameter keys,
-- it is not a list of keys in addition to the defaults.
-- 
-- When a query string value is redacted, the query string key SHOULD still be preserved, e.g.
-- @q=OpenTelemetry&sig=REDACTED@.
url_query :: AttributeKey Text
url_query = AttributeKey "url.query"

-- |
-- The highest registered url domain, stripped of the subdomain.

-- ==== Note
-- This value can be determined precisely with the [public suffix list](https:\/\/publicsuffix.org\/). For example, the registered domain for @foo.example.com@ is @example.com@. Trying to approximate this by simply taking the last two labels will not work well for TLDs such as @co.uk@.
url_registeredDomain :: AttributeKey Text
url_registeredDomain = AttributeKey "url.registered_domain"

-- |
-- The [URI scheme](https:\/\/www.rfc-editor.org\/rfc\/rfc3986#section-3.1) component identifying the used protocol.
url_scheme :: AttributeKey Text
url_scheme = AttributeKey "url.scheme"

-- |
-- The subdomain portion of a fully qualified domain name includes all of the names except the host name under the registered_domain. In a partially qualified domain, or if the qualification level of the full name cannot be determined, subdomain contains all of the names below the registered domain.

-- ==== Note
-- The subdomain portion of @www.east.mydomain.co.uk@ is @east@. If the domain has multiple levels of subdomain, such as @sub2.sub1.example.com@, the subdomain field should contain @sub2.sub1@, with no trailing period.
url_subdomain :: AttributeKey Text
url_subdomain = AttributeKey "url.subdomain"

-- |
-- The low-cardinality template of an [absolute path reference](https:\/\/www.rfc-editor.org\/rfc\/rfc3986#section-4.2).
url_template :: AttributeKey Text
url_template = AttributeKey "url.template"

-- |
-- The effective top level domain (eTLD), also known as the domain suffix, is the last part of the domain name. For example, the top level domain for example.com is @com@.

-- ==== Note
-- This value can be determined precisely with the [public suffix list](https:\/\/publicsuffix.org\/).
url_topLevelDomain :: AttributeKey Text
url_topLevelDomain = AttributeKey "url.top_level_domain"

-- $span_dotnet_http_request_waitForConnection_internal
-- The span describes the time it takes for the HTTP request to obtain a connection from the connection pool.
--
-- Stability: development
--
-- ==== Note
-- The span is reported only if there was no connection readily available when request has started.
-- It\'s reported as a child of *HTTP client request* span.
-- 
-- The span ends when the connection is obtained - it could happen when an existing connection becomes available or once
-- a new connection is established, so the duration of *Wait For Connection* span is different from duration of the
-- [*HTTP connection setup*](\/docs\/dotnet\/dotnet-network-traces.md#http-connection-setup) span.
-- 
-- The time it takes to get a connection from the pool is also reported by the
-- [@http.client.request.time_in_queue@ metric](\/docs\/dotnet\/dotnet-http-metrics.md#metric-httpclientrequesttime_in_queue).
-- 
-- Corresponding @Activity.OperationName@ is @Experimental.System.Net.Http.Connections.WaitForConnection@, @ActivitySource@ name - @Experimental.System.Net.Http@.
-- Added in .NET 9.
-- 
-- __Span name__ SHOULD be @HTTP wait_for_connection {server.address}:{server.port}@.
--
-- === Attributes
-- - 'error_type'
--
--     One of the [HTTP Request errors](https:\/\/learn.microsoft.com\/dotnet\/api\/system.net.http.httprequesterror) in snake_case, or a full exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--


-- $span_dotnet_http_connectionSetup_internal
-- The span describes the establishment of the HTTP connection. It includes the time it takes to resolve the DNS, establish the socket connection, and perform the TLS handshake.
--
-- Stability: development
--
-- ==== Note
-- There is no parent-child relationship between the [*HTTP client request*](\/docs\/dotnet\/dotnet-network-traces.md#http-client-request) and the
-- [*HTTP connection setup*]\/docs\/dotnet\/dotnet-network-traces.md(\/docs\/dotnet\/dotnet-network-traces.md#http-connection-setup) spans;
-- the latter will always be a root span, defining a separate trace.
-- 
-- However, if the connection attempt represented by the [*HTTP connection setup*](\/docs\/dotnet\/dotnet-network-traces.md#http-connection-setup) span results in a
-- successful HTTP connection, and that connection is picked up by a request to serve it, the instrumentation adds a link
-- to the [*HTTP client request*](\/docs\/dotnet\/dotnet-network-traces.md#http-client-request) span pointing to the *HTTP connection setup* span.
-- I.e., each request is linked to the connection that served this request.
-- 
-- Corresponding @Activity.OperationName@ is @Experimental.System.Net.Http.Connections.ConnectionSetup@, @ActivitySource@ name - @Experimental.System.Net.Http.Connections@.
-- Added in .NET 9.
-- 
-- __Span name__ SHOULD be @HTTP connection_setup {server.address}:{server.port}@.
--
-- === Attributes
-- - 'network_peer_address'
--
--     Peer IP address of the socket connection.
--
--     ==== Note
--     The @network.peer.address@ attribute is available only if the connection was successfully established and only for IP sockets.
--
-- - 'server_address'
--
-- - 'server_port'
--
-- - 'error_type'
--
--     One of the [HTTP Request errors](https:\/\/learn.microsoft.com\/dotnet\/api\/system.net.http.httprequesterror) in snake_case, or a full exception type.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--
-- - 'url_scheme'
--






-- $span_dotnet_socket_connect_internal
-- The span describes the establishment of the socket connection.
--
-- Stability: development
--
-- ==== Note
-- It\'s different from [*HTTP connection setup*](\/docs\/dotnet\/dotnet-network-traces.md#http-connection-setup) span, which also covers the DNS lookup and TLS handshake.
-- 
-- When *socket connect* span is reported along with *HTTP connection setup* span, the socket span becomes a child of HTTP connection setup.
-- 
-- Corresponding @Activity.OperationName@ is @Experimental.System.Net.Sockets.Connect@, @ActivitySource@ name - @Experimental.System.Net.Sockets@.
-- Added in .NET 9.
-- 
-- __Span name__ SHOULD be @socket connect {network.peer.address}:{network.peer.port}@ when socket address family has a
-- notion of port and @socket connect {network.peer.address}@
-- otherwise.
--
-- === Attributes
-- - 'network_peer_port'
--
--     Requirement level: recommended: If port is supported for the socket address family.
--
-- - 'network_peer_address'
--
-- - 'network_type'
--
--     Requirement level: recommended: if @network.peer.address@ is an IP address.
--
-- - 'network_transport'
--
--     Requirement level: recommended: If value is not @tcp@. When missing, the value is assumed to be @tcp@.
--
-- - 'error_type'
--
--     Socket error code.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     The following errors codes are reported:
--     
--     - @network_down@
--     - @address_already_in_use@
--     - @interrupted@
--     - @in_progress@
--     - @already_in_progress@
--     - @address_not_available@
--     - @address_family_not_supported@
--     - @connection_refused@
--     - @fault@
--     - @invalid_argument@
--     - @is_connected@
--     - @network_unreachable@
--     - @host_unreachable@
--     - @no_buffer_space_available@
--     - @timed_out@
--     - @access_denied@
--     - @protocol_type@
--     
--     See socket errors on [Windows](https:\/\/learn.microsoft.com\/windows\/win32\/api\/winsock2\/nf-winsock2-connect#return-value) and
--     [Linux](https:\/\/man7.org\/linux\/man-pages\/man2\/connect.2.html) for more details.
--






-- $span_dotnet_dns_lookup_internal
-- The span describes DNS lookup or reverse lookup performed with one of the methods on [System.Net.Dns](https:\/\/learn.microsoft.com\/dotnet\/api\/system.net.dns) class.
--
-- Stability: development
--
-- ==== Note
-- DNS spans track logical operations rather than physical DNS calls and the actual behavior depends on the
-- resolver implementation which could be changed in the future versions of .NET.
-- .NET 9 uses OS DNS resolver which may do zero or more physical lookups for one API call.
-- 
-- When the *DNS lookup* span is reported along with *HTTP connection setup* and *socket connect* span,
-- the *DNS lookup* span span becomes a child of *HTTP connection setup* and a sibling of *socket connect*.
-- 
-- DNS lookup duration is also reported by [@dns.lookup.duration@ metric](\/docs\/dotnet\/dotnet-dns-metrics.md#metric-dnslookupduration).
-- 
-- Corresponding @Activity.OperationName@ is @Experimental.System.Net.NameResolution.DnsLookup@, @ActivitySource@ name - @Experimental.System.Net.NameResolution@.
-- Added in .NET 9.
-- 
-- __Span name__ SHOULD be @DNS lookup {dns.question.name}@ for DNS lookup (IP addresses from host name)
-- and @DNS reverse lookup {dns.question.name}@ for reverse lookup (host names from IP address).
--
-- === Attributes
-- - 'dns_question_name'
--
--     The domain name or an IP address being queried.
--
--     ==== Note
--     
--
-- - 'dns_answers'
--
--     List of resolved IP addresses (for DNS lookup) or a single element containing domain name (for reverse lookup).
--
--     Requirement level: recommended: if DNS lookup was successful.
--
-- - 'error_type'
--
--     The error code or exception name returned by [System.Net.Dns](https:\/\/learn.microsoft.com\/dotnet\/api\/system.net.dns).
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     The following errors are reported:
--     
--     - @host_not_found@
--     - @try_again@
--     - @no_recovery@
--     - @address_family_not_supported@
--     - the full exception type name
--     
--     See [SocketError](https:\/\/learn.microsoft.com\/dotnet\/api\/system.net.sockets.socketerror) for more details.
--




-- $span_dotnet_tls_handshake_internal
-- The span describes TLS client or server handshake performed with [System.Net.Security.SslStream](https:\/\/learn.microsoft.com\/dotnet\/api\/system.net.security.sslstream).
--
-- Stability: development
--
-- ==== Note
-- When *TLS* span is reported for client-side authentication along with *HTTP connection setup* and *socket connect* span, the *TLS* span becomes a child of *HTTP connection setup*.
-- 
-- Corresponding @Activity.OperationName@ is @Experimental.System.Net.Security.TlsHandshake@, @ActivitySource@ name - @Experimental.System.Net.Security@.
-- Added in .NET 9.
-- 
-- __Span name__ SHOULD be @TLS client handshake {server.address}@ when authenticating on the client
-- side and @TLS server handshake@ when authenticating the server.
-- 
-- __Span kind__ SHOULD be @INTERNAL@ in both cases.
--
-- === Attributes
-- - 'tls_protocol_name'
--
--     Requirement level: recommended: when available
--
-- - 'tls_protocol_version'
--
--     Requirement level: recommended: when available
--
-- - 'server_address'
--
--     The [server name indication (SNI)](https:\/\/en.wikipedia.org\/wiki\/Server_Name_Indication) used in the \'Client Hello\' message during TLS handshake.
--
--     Requirement level: recommended: when authenticating the client.
--
-- - 'error_type'
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     
--





-- $registry_dotnet
-- This document defines .NET related attributes.
--
-- === Attributes
-- - 'dotnet_gc_heap_generation'
--
--     Stability: stable
--

-- |
-- Name of the garbage collector managed heap generation.
dotnet_gc_heap_generation :: AttributeKey Text
dotnet_gc_heap_generation = AttributeKey "dotnet.gc.heap.generation"

-- $metric_dotnet_process_cpu_count
-- The number of processors available to the process.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as accessing [@Environment.ProcessorCount@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.environment.processorcount).
--

-- $metric_dotnet_process_cpu_time
-- CPU time used by the process.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as accessing the corresponding processor time properties on [@System.Diagnostics.Process@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.diagnostics.process).
--
-- === Attributes
-- - 'cpu_mode'
--
--     Requirement level: required
--


-- $metric_dotnet_process_memory_workingSet
-- The number of bytes of physical memory mapped to the process context.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as calling [@Environment.WorkingSet@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.environment.workingset).
--

-- $metric_dotnet_gc_collections
-- The number of garbage collections that have occurred since the process has started.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric uses the [@GC.CollectionCount(int generation)@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.gc.collectioncount) API to calculate exclusive collections per generation.
--
-- === Attributes
-- - 'dotnet_gc_heap_generation'
--
--     Requirement level: required
--


-- $metric_dotnet_gc_heap_totalAllocated
-- The _approximate_ number of bytes allocated on the managed GC heap since the process has started. The returned value does not include any native allocations.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as calling [@GC.GetTotalAllocatedBytes()@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.gc.gettotalallocatedbytes).
--

-- $metric_dotnet_gc_lastCollection_memory_committedSize
-- The amount of committed virtual memory in use by the .NET GC, as observed during the latest garbage collection.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as calling [@GC.GetGCMemoryInfo().TotalCommittedBytes@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.gcmemoryinfo.totalcommittedbytes). Committed virtual memory may be larger than the heap size because it includes both memory for storing existing objects (the heap size) and some extra memory that is ready to handle newly allocated objects in the future.
--

-- $metric_dotnet_gc_lastCollection_heap_size
-- The managed GC heap size (including fragmentation), as observed during the latest garbage collection.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as calling [@GC.GetGCMemoryInfo().GenerationInfo.SizeAfterBytes@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.gcgenerationinfo.sizeafterbytes).
--
-- === Attributes
-- - 'dotnet_gc_heap_generation'
--
--     Requirement level: required
--


-- $metric_dotnet_gc_lastCollection_heap_fragmentation_size
-- The heap fragmentation, as observed during the latest garbage collection.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as calling [@GC.GetGCMemoryInfo().GenerationInfo.FragmentationAfterBytes@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.gcgenerationinfo.fragmentationafterbytes).
--
-- === Attributes
-- - 'dotnet_gc_heap_generation'
--
--     Requirement level: required
--


-- $metric_dotnet_gc_pause_time
-- The total amount of time paused in GC since the process has started.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as calling [@GC.GetTotalPauseDuration()@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.gc.gettotalpauseduration).
--

-- $metric_dotnet_jit_compiledIl_size
-- Count of bytes of intermediate language that have been compiled since the process has started.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as calling [@JitInfo.GetCompiledILBytes()@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.runtime.jitinfo.getcompiledilbytes).
--

-- $metric_dotnet_jit_compiledMethods
-- The number of times the JIT compiler (re)compiled methods since the process has started.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as calling [@JitInfo.GetCompiledMethodCount()@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.runtime.jitinfo.getcompiledmethodcount).
--

-- $metric_dotnet_jit_compilation_time
-- The amount of time the JIT compiler has spent compiling methods since the process has started.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as calling [@JitInfo.GetCompilationTime()@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.runtime.jitinfo.getcompilationtime).
--

-- $metric_dotnet_monitor_lockContentions
-- The number of times there was contention when trying to acquire a monitor lock since the process has started.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as calling [@Monitor.LockContentionCount@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.threading.monitor.lockcontentioncount).
--

-- $metric_dotnet_threadPool_thread_count
-- The number of thread pool threads that currently exist.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as calling [@ThreadPool.ThreadCount@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.threading.threadpool.threadcount).
--

-- $metric_dotnet_threadPool_workItem_count
-- The number of work items that the thread pool has completed since the process has started.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as calling [@ThreadPool.CompletedWorkItemCount@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.threading.threadpool.completedworkitemcount).
--

-- $metric_dotnet_threadPool_queue_length
-- The number of work items that are currently queued to be processed by the thread pool.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as calling [@ThreadPool.PendingWorkItemCount@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.threading.threadpool.pendingworkitemcount).
--

-- $metric_dotnet_timer_count
-- The number of timer instances that are currently active.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as calling [@Timer.ActiveCount@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.threading.timer.activecount).
--

-- $metric_dotnet_assembly_count
-- The number of .NET assemblies that are currently loaded.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as calling [@AppDomain.CurrentDomain.GetAssemblies().Length@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.appdomain.getassemblies).
--

-- $metric_dotnet_exceptions
-- The number of exceptions that have been thrown in managed code.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @System.Runtime@; Added in: .NET 9.0.
-- This metric reports the same values as counting calls to [@AppDomain.CurrentDomain.FirstChanceException@](https:\/\/learn.microsoft.com\/dotnet\/api\/system.appdomain.firstchanceexception).
--
-- === Attributes
-- - 'error_type'
--
--     Requirement level: required
--
--     ==== Note
--     
--


-- $entity_cicd_pipeline
-- A pipeline is a series of automated steps that helps software teams deliver code.
--
-- Stability: development
--
-- === Attributes
-- - 'cicd_pipeline_name'
--


-- $entity_cicd_pipeline_run
-- A pipeline run is a singular execution of a given pipeline\'s tasks.
--
-- Stability: development
--
-- === Attributes
-- - 'cicd_pipeline_run_id'
--
-- - 'cicd_pipeline_run_url_full'
--



-- $entity_cicd_worker
-- A CICD worker is a component of the CICD system that performs work (eg. running pipeline tasks or performing sync).
-- A single pipeline run may be distributed across multiple workers. Any OpenTelemetry signal associated with a worker should be associated to the worker that performed the corresponding work.
-- For example, when a pipeline run involves several workers, its task run spans may reference the different @cicd.worker@ resources corresponding to the workers that executed each task run. The pipeline run\'s parent span may instead reference the CICD controller as the @cicd.worker@ resource.
--
-- Stability: development
--
-- === Attributes
-- - 'cicd_worker_id'
--
--     Requirement level: required
--
-- - 'cicd_worker_name'
--
-- - 'cicd_worker_url_full'
--
--     Requirement level: recommended: If available
--




-- $span_cicd_pipeline_run_server
-- This span describes a CICD pipeline run.
--
-- Stability: development
--
-- ==== Note
-- For all pipeline runs, a span with kind @SERVER@ SHOULD be created corresponding to the execution of the pipeline run.
-- 
-- __Span name__ MUST follow the overall [guidelines for span names](https:\/\/github.com\/open-telemetry\/opentelemetry-specification\/blob\/v1.43.0\/specification\/trace\/api.md#span).
-- 
-- The span name SHOULD be @{action} {pipeline}@ if there is a (low-cardinality) pipeline name available.
-- If the pipeline name is not available or is likely to have high cardinality, then the span name SHOULD be @{action}@.
-- 
-- The @{action}@ SHOULD be the [@cicd.pipeline.action.name@](\/docs\/registry\/attributes\/cicd.md#cicd-pipeline-action-name).
-- 
-- The @{pipeline}@ SHOULD be the [@cicd.pipeline.name@](\/docs\/registry\/attributes\/cicd.md#cicd-pipeline-name).
--
-- === Attributes
-- - 'cicd_pipeline_result'
--
--     Requirement level: required
--
-- - 'error_type'
--
--     Requirement level: conditionally required: if the pipeline result is @failure@ or @error@
--
-- - 'cicd_pipeline_action_name'
--
--     Requirement level: opt-in
--




-- $span_cicd_pipeline_task_internal
-- This span describes task execution in a pipeline run.
--
-- Stability: development
--
-- === Attributes
-- - 'cicd_pipeline_task_name'
--
--     Requirement level: required
--
-- - 'cicd_pipeline_task_run_id'
--
--     Requirement level: required
--
-- - 'cicd_pipeline_task_run_url_full'
--
--     Requirement level: required
--
-- - 'cicd_pipeline_task_run_result'
--
--     Requirement level: required
--
-- - 'error_type'
--
--     Requirement level: conditionally required: if the task result is @failure@ or @error@
--






-- $registry_cicd_pipeline
-- This group describes attributes specific to pipelines within a Continuous Integration and Continuous Deployment (CI\/CD) system. A [pipeline](https:\/\/wikipedia.org\/wiki\/Pipeline_(computing)) in this case is a series of steps that are performed in order to deliver a new version of software. This aligns with the [Britannica](https:\/\/www.britannica.com\/dictionary\/pipeline) definition of a pipeline where a __pipeline__ is the system for developing and producing something. In the context of CI\/CD, a pipeline produces or delivers software.
--
-- === Attributes
-- - 'cicd_pipeline_name'
--
--     Stability: development
--
-- - 'cicd_pipeline_run_id'
--
--     Stability: development
--
-- - 'cicd_pipeline_run_url_full'
--
--     Stability: development
--
-- - 'cicd_pipeline_run_state'
--
--     Stability: development
--
-- - 'cicd_pipeline_task_name'
--
--     Stability: development
--
-- - 'cicd_pipeline_task_run_id'
--
--     Stability: development
--
-- - 'cicd_pipeline_task_run_url_full'
--
--     Stability: development
--
-- - 'cicd_pipeline_task_run_result'
--
--     Stability: development
--
-- - 'cicd_pipeline_task_type'
--
--     Stability: development
--
-- - 'cicd_pipeline_result'
--
--     Stability: development
--
-- - 'cicd_pipeline_action_name'
--
--     Stability: development
--
-- - 'cicd_worker_id'
--
--     Stability: development
--
-- - 'cicd_worker_name'
--
--     Stability: development
--
-- - 'cicd_worker_url_full'
--
--     Stability: development
--
-- - 'cicd_worker_state'
--
--     Stability: development
--
-- - 'cicd_system_component'
--
--     Stability: development
--

-- |
-- The human readable name of the pipeline within a CI\/CD system.
cicd_pipeline_name :: AttributeKey Text
cicd_pipeline_name = AttributeKey "cicd.pipeline.name"

-- |
-- The unique identifier of a pipeline run within a CI\/CD system.
cicd_pipeline_run_id :: AttributeKey Text
cicd_pipeline_run_id = AttributeKey "cicd.pipeline.run.id"

-- |
-- The [URL](https:\/\/wikipedia.org\/wiki\/URL) of the pipeline run, providing the complete address in order to locate and identify the pipeline run.
cicd_pipeline_run_url_full :: AttributeKey Text
cicd_pipeline_run_url_full = AttributeKey "cicd.pipeline.run.url.full"

-- |
-- The pipeline run goes through these states during its lifecycle.
cicd_pipeline_run_state :: AttributeKey Text
cicd_pipeline_run_state = AttributeKey "cicd.pipeline.run.state"

-- |
-- The human readable name of a task within a pipeline. Task here most closely aligns with a [computing process](https:\/\/wikipedia.org\/wiki\/Pipeline_(computing)) in a pipeline. Other terms for tasks include commands, steps, and procedures.
cicd_pipeline_task_name :: AttributeKey Text
cicd_pipeline_task_name = AttributeKey "cicd.pipeline.task.name"

-- |
-- The unique identifier of a task run within a pipeline.
cicd_pipeline_task_run_id :: AttributeKey Text
cicd_pipeline_task_run_id = AttributeKey "cicd.pipeline.task.run.id"

-- |
-- The [URL](https:\/\/wikipedia.org\/wiki\/URL) of the pipeline task run, providing the complete address in order to locate and identify the pipeline task run.
cicd_pipeline_task_run_url_full :: AttributeKey Text
cicd_pipeline_task_run_url_full = AttributeKey "cicd.pipeline.task.run.url.full"

-- |
-- The result of a task run.
cicd_pipeline_task_run_result :: AttributeKey Text
cicd_pipeline_task_run_result = AttributeKey "cicd.pipeline.task.run.result"

-- |
-- The type of the task within a pipeline.
cicd_pipeline_task_type :: AttributeKey Text
cicd_pipeline_task_type = AttributeKey "cicd.pipeline.task.type"

-- |
-- The result of a pipeline run.
cicd_pipeline_result :: AttributeKey Text
cicd_pipeline_result = AttributeKey "cicd.pipeline.result"

-- |
-- The kind of action a pipeline run is performing.
cicd_pipeline_action_name :: AttributeKey Text
cicd_pipeline_action_name = AttributeKey "cicd.pipeline.action.name"

-- |
-- The unique identifier of a worker within a CICD system.
cicd_worker_id :: AttributeKey Text
cicd_worker_id = AttributeKey "cicd.worker.id"

-- |
-- The name of a worker within a CICD system.
cicd_worker_name :: AttributeKey Text
cicd_worker_name = AttributeKey "cicd.worker.name"

-- |
-- The [URL](https:\/\/wikipedia.org\/wiki\/URL) of the worker, providing the complete address in order to locate and identify the worker.
cicd_worker_url_full :: AttributeKey Text
cicd_worker_url_full = AttributeKey "cicd.worker.url.full"

-- |
-- The state of a CICD worker \/ agent.
cicd_worker_state :: AttributeKey Text
cicd_worker_state = AttributeKey "cicd.worker.state"

-- |
-- The name of a component of the CICD system.
cicd_system_component :: AttributeKey Text
cicd_system_component = AttributeKey "cicd.system.component"

-- $metric_cicd_pipeline_run_duration
-- Duration of a pipeline run grouped by pipeline, state and result.
--
-- Stability: development
--
-- === Attributes
-- - 'cicd_pipeline_name'
--
--     Requirement level: required
--
-- - 'cicd_pipeline_run_state'
--
--     Requirement level: required
--
-- - 'cicd_pipeline_result'
--
--     Requirement level: conditionally required: If and only if the pipeline run result has been set during that state.
--
-- - 'error_type'
--
--     Requirement level: conditionally required: If and only if the pipeline run failed.
--





-- $metric_cicd_pipeline_run_active
-- The number of pipeline runs currently active in the system by state.
--
-- Stability: development
--
-- === Attributes
-- - 'cicd_pipeline_name'
--
--     Requirement level: required
--
-- - 'cicd_pipeline_run_state'
--
--     Requirement level: required
--



-- $metric_cicd_worker_count
-- The number of workers on the CICD system by state.
--
-- Stability: development
--
-- === Attributes
-- - 'cicd_worker_state'
--
--     Requirement level: required
--


-- $metric_cicd_pipeline_run_errors
-- The number of errors encountered in pipeline runs (eg. compile, test failures).
--
-- Stability: development
--
-- ==== Note
-- There might be errors in a pipeline run that are non fatal (eg. they are suppressed) or in a parallel stage multiple stages could have a fatal error.
-- This means that this error count might not be the same as the count of metric @cicd.pipeline.run.duration@ with run result @failure@.
--
-- === Attributes
-- - 'cicd_pipeline_name'
--
--     Requirement level: required
--
-- - 'error_type'
--
--     Requirement level: required
--



-- $metric_cicd_system_errors
-- The number of errors in a component of the CICD system (eg. controller, scheduler, agent).
--
-- Stability: development
--
-- ==== Note
-- Errors in pipeline run execution are explicitly excluded. Ie a test failure is not counted in this metric.
--
-- === Attributes
-- - 'cicd_system_component'
--
--     Requirement level: required
--
-- - 'error_type'
--
--     Requirement level: required
--



-- $entity_container
-- A container instance.
--
-- Stability: development
--
-- === Attributes
-- - 'container_name'
--
-- - 'container_id'
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








-- $entity_container_image
-- The image used for the container.
--
-- Stability: development
--
-- === Attributes
-- - 'container_image_name'
--
-- - 'container_image_tags'
--
-- - 'container_image_id'
--
-- - 'container_image_repoDigests'
--





-- $entity_container_runtime
-- The runtime being used to run the container
--
-- Stability: development
--
-- === Attributes
-- - 'container_runtime_description'
--
-- - 'container_runtime_name'
--
-- - 'container_runtime_version'
--




-- $registry_container
-- A container instance.
--
-- === Attributes
-- - 'container_name'
--
--     Stability: development
--
-- - 'container_id'
--
--     Stability: beta
--
-- - 'container_runtime_name'
--
--     Stability: development
--
-- - 'container_runtime_version'
--
--     Stability: development
--
-- - 'container_runtime_description'
--
--     Stability: development
--
-- - 'container_image_name'
--
--     Stability: beta
--
-- - 'container_image_tags'
--
--     Stability: beta
--
-- - 'container_image_id'
--
--     Stability: development
--
-- - 'container_image_repoDigests'
--
--     Stability: beta
--
-- - 'container_command'
--
--     Stability: development
--
-- - 'container_commandLine'
--
--     Stability: development
--
-- - 'container_commandArgs'
--
--     Stability: development
--
-- - 'container_label'
--
--     Stability: development
--
-- - 'container_csi_plugin_name'
--
--     Stability: development
--
-- - 'container_csi_volume_id'
--
--     Stability: development
--

-- |
-- Container name used by container runtime.
container_name :: AttributeKey Text
container_name = AttributeKey "container.name"

-- |
-- Container ID. Usually a UUID, as for example used to [identify Docker containers](https:\/\/docs.docker.com\/engine\/containers\/run\/#container-identification). The UUID might be abbreviated.
container_id :: AttributeKey Text
container_id = AttributeKey "container.id"

-- |
-- The container runtime managing this container.
container_runtime_name :: AttributeKey Text
container_runtime_name = AttributeKey "container.runtime.name"

-- |
-- The version of the runtime of this process, as returned by the runtime without modification.
container_runtime_version :: AttributeKey Text
container_runtime_version = AttributeKey "container.runtime.version"

-- |
-- A description about the runtime which could include, for example details about the CRI\/API version being used or other customisations.
container_runtime_description :: AttributeKey Text
container_runtime_description = AttributeKey "container.runtime.description"

-- |
-- Name of the image the container was built on.
container_image_name :: AttributeKey Text
container_image_name = AttributeKey "container.image.name"

-- |
-- Container image tags. An example can be found in [Docker Image Inspect](https:\/\/docs.docker.com\/reference\/api\/engine\/version\/v1.52\/#tag\/Image\/operation\/ImageInspect). Should be only the @\<tag\>@ section of the full name for example from @registry.example.com\/my-org\/my-image:\<tag\>@.
container_image_tags :: AttributeKey [Text]
container_image_tags = AttributeKey "container.image.tags"

-- |
-- Runtime specific image identifier. Usually a hash algorithm followed by a UUID.

-- ==== Note
-- Docker defines a sha256 of the image id; @container.image.id@ corresponds to the @Image@ field from the Docker container inspect [API](https:\/\/docs.docker.com\/reference\/api\/engine\/version\/v1.52\/#tag\/Container\/operation\/ContainerInspect) endpoint.
-- K8s defines a link to the container registry repository with digest @"imageID": "registry.azurecr.io \/namespace\/service\/dockerfile\@sha256:bdeabd40c3a8a492eaf9e8e44d0ebbb84bac7ee25ac0cf8a7159d25f62555625"@.
-- The ID is assigned by the container runtime and can vary in different environments. Consider using @oci.manifest.digest@ if it is important to identify the same image in different environments\/runtimes.
container_image_id :: AttributeKey Text
container_image_id = AttributeKey "container.image.id"

-- |
-- Repo digests of the container image as provided by the container runtime.

-- ==== Note
-- [Docker](https:\/\/docs.docker.com\/reference\/api\/engine\/version\/v1.52\/#tag\/Image\/operation\/ImageInspect) and [CRI](https:\/\/github.com\/kubernetes\/cri-api\/blob\/c75ef5b473bbe2d0a4fc92f82235efd665ea8e9f\/pkg\/apis\/runtime\/v1\/api.proto#L1237-L1238) report those under the @RepoDigests@ field.
container_image_repoDigests :: AttributeKey [Text]
container_image_repoDigests = AttributeKey "container.image.repo_digests"

-- |
-- The command used to run the container (i.e. the command name).

-- ==== Note
-- If using embedded credentials or sensitive data, it is recommended to remove them to prevent potential leakage.
container_command :: AttributeKey Text
container_command = AttributeKey "container.command"

-- |
-- The full command run by the container as a single string representing the full command.
container_commandLine :: AttributeKey Text
container_commandLine = AttributeKey "container.command_line"

-- |
-- All the command arguments (including the command\/executable itself) run by the container.
container_commandArgs :: AttributeKey [Text]
container_commandArgs = AttributeKey "container.command_args"

-- |
-- Container labels, @\<key\>@ being the label name, the value being the label value.

-- ==== Note
-- For example, a docker container label @app@ with value @nginx@ SHOULD be recorded as the @container.label.app@ attribute with value @"nginx"@.
container_label :: Text -> AttributeKey Text
container_label = \k -> AttributeKey $ "container.label." <> k

-- |
-- The name of the CSI ([Container Storage Interface](https:\/\/github.com\/container-storage-interface\/spec)) plugin used by the volume.

-- ==== Note
-- This can sometimes be referred to as a "driver" in CSI implementations. This should represent the @name@ field of the GetPluginInfo RPC.
container_csi_plugin_name :: AttributeKey Text
container_csi_plugin_name = AttributeKey "container.csi.plugin.name"

-- |
-- The unique volume ID returned by the CSI ([Container Storage Interface](https:\/\/github.com\/container-storage-interface\/spec)) plugin.

-- ==== Note
-- This can sometimes be referred to as a "volume handle" in CSI implementations. This should represent the @Volume.volume_id@ field in CSI spec.
container_csi_volume_id :: AttributeKey Text
container_csi_volume_id = AttributeKey "container.csi.volume.id"

-- $metric_container_uptime
-- The time the container has been running.
--
-- Stability: development
--
-- ==== Note
-- Instrumentations SHOULD use a gauge with type @double@ and measure uptime in seconds as a floating point number with the highest precision available.
-- The actual accuracy would depend on the instrumentation and operating system.
--

-- $metric_container_cpu_time
-- Total CPU time consumed.
--
-- Stability: development
--
-- ==== Note
-- Total CPU time consumed by the specific container on all available CPU cores
--
-- === Attributes
-- - 'cpu_mode'
--
--     The CPU mode for this data point. A container\'s CPU metric SHOULD be characterized _either_ by data points with no @mode@ labels, _or only_ data points with @mode@ labels.
--
--     Requirement level: conditionally required: Required if mode is available, i.e. metrics coming from the Docker Stats API.
--
--     ==== Note
--     Following states SHOULD be used: @user@, @system@, @kernel@
--


-- $metric_container_cpu_usage
-- Container\'s CPU usage, measured in cpus. Range from 0 to the number of allocatable CPUs.
--
-- Stability: development
--
-- ==== Note
-- CPU usage of the specific container on all available CPU cores, averaged over the sample window
--
-- === Attributes
-- - 'cpu_mode'
--
--     The CPU mode for this data point. A container\'s CPU metric SHOULD be characterized _either_ by data points with no @mode@ labels, _or only_ data points with @mode@ labels.
--
--     Requirement level: conditionally required: Required if mode is available, i.e. metrics coming from the Docker Stats API.
--
--     ==== Note
--     Following states SHOULD be used: @user@, @system@, @kernel@
--


-- $metric_container_memory_usage
-- Memory usage of the container.
--
-- Stability: development
--
-- ==== Note
-- Memory usage of the container.
--

-- $metric_container_memory_available
-- Container memory available.
--
-- Stability: development
--
-- ==== Note
-- Available memory for use.  This is defined as the memory limit - workingSetBytes. If memory limit is undefined, the available bytes is omitted.
-- In general, this metric can be derived from [cadvisor](https:\/\/github.com\/google\/cadvisor\/blob\/v0.53.0\/docs\/storage\/prometheus.md#prometheus-container-metrics) and by subtracting the @container_memory_working_set_bytes@ metric from the @container_spec_memory_limit_bytes@ metric.
-- In K8s, this metric is derived from the [MemoryStats.AvailableBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#MemoryStats) field of the [PodStats.Memory](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#PodStats) of the Kubelet\'s stats API.
--

-- $metric_container_memory_rss
-- Container memory RSS.
--
-- Stability: development
--
-- ==== Note
-- In general, this metric can be derived from [cadvisor](https:\/\/github.com\/google\/cadvisor\/blob\/v0.53.0\/docs\/storage\/prometheus.md#prometheus-container-metrics) and specifically the @container_memory_rss@ metric.
-- In K8s, this metric is derived from the [MemoryStats.RSSBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#MemoryStats) field of the [PodStats.Memory](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#PodStats) of the Kubelet\'s stats API.
--

-- $metric_container_memory_workingSet
-- Container memory working set.
--
-- Stability: development
--
-- ==== Note
-- In general, this metric can be derived from [cadvisor](https:\/\/github.com\/google\/cadvisor\/blob\/v0.53.0\/docs\/storage\/prometheus.md#prometheus-container-metrics) and specifically the @container_memory_working_set_bytes@ metric.
-- In K8s, this metric is derived from the [MemoryStats.WorkingSetBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#MemoryStats) field of the [PodStats.Memory](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#PodStats) of the Kubelet\'s stats API.
--

-- $metric_container_memory_paging_faults
-- Container memory paging faults.
--
-- Stability: development
--
-- ==== Note
-- In general, this metric can be derived from [cadvisor](https:\/\/github.com\/google\/cadvisor\/blob\/v0.53.0\/docs\/storage\/prometheus.md#prometheus-container-metrics) and specifically the @container_memory_failures_total{failure_type=pgfault, scope=container}@ and @container_memory_failures_total{failure_type=pgmajfault, scope=container}@metric.
-- In K8s, this metric is derived from the [MemoryStats.PageFaults](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#MemoryStats) and [MemoryStats.MajorPageFaults](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#MemoryStats) field of the [PodStats.Memory](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.34.0\/pkg\/apis\/stats\/v1alpha1#PodStats) of the Kubelet\'s stats API.
--
-- === Attributes
-- - 'system_paging_fault_type'
--


-- $metric_container_disk_io
-- Disk bytes for the container.
--
-- Stability: development
--
-- ==== Note
-- The total number of bytes read\/written successfully (aggregated from all disks).
--
-- === Attributes
-- - 'disk_io_direction'
--
-- - 'system_device'
--



-- $metric_container_network_io
-- Network bytes for the container.
--
-- Stability: development
--
-- ==== Note
-- The number of bytes sent\/received on all network interfaces by the container.
--
-- === Attributes
-- - 'network_io_direction'
--
-- - 'network_interface_name'
--



-- $metric_container_filesystem_available
-- Container filesystem available bytes.
--
-- Stability: development
--
-- ==== Note
-- In K8s, this metric is derived from the
-- [FsStats.AvailableBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#FsStats) field
-- of the [ContainerStats.Rootfs](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#ContainerStats)
-- of the Kubelet\'s stats API.
--

-- $metric_container_filesystem_capacity
-- Container filesystem capacity.
--
-- Stability: development
--
-- ==== Note
-- In K8s, this metric is derived from the
-- [FsStats.CapacityBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#FsStats) field
-- of the [ContainerStats.Rootfs](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#ContainerStats)
-- of the Kubelet\'s stats API.
--

-- $metric_container_filesystem_usage
-- Container filesystem usage.
--
-- Stability: development
--
-- ==== Note
-- This may not equal capacity - available.
-- 
-- In K8s, this metric is derived from the
-- [FsStats.UsedBytes](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#FsStats) field
-- of the [ContainerStats.Rootfs](https:\/\/pkg.go.dev\/k8s.io\/kubelet\@v0.33.0\/pkg\/apis\/stats\/v1alpha1#ContainerStats)
-- of the Kubelet\'s stats API.
--

-- $registry_container_deprecated
-- Describes deprecated container attributes.
--
-- === Attributes
-- - 'container_labels'
--
--     Stability: development
--
--     Deprecated: renamed: container.label
--
-- - 'container_cpu_state'
--
--     Stability: development
--
--     Deprecated: renamed: cpu.mode
--
-- - 'container_runtime'
--
--     Stability: development
--
--     Deprecated: renamed: container.runtime.name
--

-- |
-- Deprecated, use @container.label@ instead.
container_labels :: Text -> AttributeKey Text
container_labels = \k -> AttributeKey $ "container.labels." <> k

-- |
-- Deprecated, use @cpu.mode@ instead.
container_cpu_state :: AttributeKey Text
container_cpu_state = AttributeKey "container.cpu.state"

-- |
-- The container runtime managing this container.
container_runtime :: AttributeKey Text
container_runtime = AttributeKey "container.runtime"

-- $registry_system
-- Describes System attributes
--
-- === Attributes
-- - 'system_device'
--
--     Stability: development
--

-- |
-- The device identifier
system_device :: AttributeKey Text
system_device = AttributeKey "system.device"

-- $registry_system_memory
-- Describes System Memory attributes
--
-- === Attributes
-- - 'system_memory_state'
--
--     Stability: development
--
-- - 'system_memory_linux_slab_state'
--
--     Stability: development
--

-- |
-- The memory state
system_memory_state :: AttributeKey Text
system_memory_state = AttributeKey "system.memory.state"

-- |
-- The Linux Slab memory state
system_memory_linux_slab_state :: AttributeKey Text
system_memory_linux_slab_state = AttributeKey "system.memory.linux.slab.state"

-- $registry_system_paging
-- Describes System Memory Paging attributes
--
-- === Attributes
-- - 'system_paging_state'
--
--     Stability: development
--
-- - 'system_paging_fault_type'
--
--     Stability: development
--
-- - 'system_paging_direction'
--
--     Stability: development
--

-- |
-- The memory paging state
system_paging_state :: AttributeKey Text
system_paging_state = AttributeKey "system.paging.state"

-- |
-- The paging fault type
system_paging_fault_type :: AttributeKey Text
system_paging_fault_type = AttributeKey "system.paging.fault.type"

-- |
-- The paging access direction
system_paging_direction :: AttributeKey Text
system_paging_direction = AttributeKey "system.paging.direction"

-- $registry_system_filesystem
-- Describes Filesystem attributes
--
-- === Attributes
-- - 'system_filesystem_state'
--
--     Stability: development
--
-- - 'system_filesystem_type'
--
--     Stability: development
--
-- - 'system_filesystem_mode'
--
--     Stability: development
--
-- - 'system_filesystem_mountpoint'
--
--     Stability: development
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

-- $metric_system_uptime
-- The time the system has been running.
--
-- Stability: development
--
-- ==== Note
-- Instrumentations SHOULD use a gauge with type @double@ and measure uptime in seconds as a floating point number with the highest precision available.
-- The actual accuracy would depend on the instrumentation and operating system.
--

-- $metric_system_cpu_physical_count
-- Reports the number of actual physical processor cores on the hardware.
--
-- Stability: development
--
-- ==== Note
-- Calculated by multiplying the number of sockets by the number of cores per socket
--

-- $metric_system_cpu_logical_count
-- Reports the number of logical (virtual) processor cores created by the operating system to manage multitasking.
--
-- Stability: development
--
-- ==== Note
-- Calculated by multiplying the number of sockets by the number of cores per socket, and then by the number of threads per core
--

-- $metric_system_cpu_time
-- Seconds each logical CPU spent on each mode.
--
-- Stability: development
--
-- === Attributes
-- - 'cpu_mode'
--
--     ==== Note
--     Following states SHOULD be used: @user@, @system@, @nice@, @idle@, @iowait@, @interrupt@, @steal@
--
-- - 'cpu_logicalNumber'
--
--     Requirement level: opt-in
--



-- $metric_system_cpu_utilization
-- For each logical CPU, the utilization is calculated as the change in cumulative CPU time (cpu.time) over a measurement interval, divided by the elapsed time.
--
-- Stability: development
--
-- === Attributes
-- - 'cpu_mode'
--
--     ==== Note
--     Following modes SHOULD be used: @user@, @system@, @nice@, @idle@, @iowait@, @interrupt@, @steal@
--
-- - 'cpu_logicalNumber'
--
--     Requirement level: opt-in
--



-- $metric_system_cpu_frequency
-- Operating frequency of the logical CPU in Hertz.
--
-- Stability: development
--
-- === Attributes
-- - 'cpu_logicalNumber'
--


-- $metric_system_memory_usage
-- Reports memory in use by state.
--
-- Stability: development
--
-- === Attributes
-- - 'system_memory_state'
--


-- $metric_system_memory_limit
-- Total virtual memory available in the system.
--
-- Stability: development
--

-- $metric_system_memory_utilization
-- Percentage of memory bytes in use.
--
-- Stability: development
--
-- === Attributes
-- - 'system_memory_state'
--


-- $metric_system_paging_usage
-- Unix swap or windows pagefile usage.
--
-- Stability: development
--
-- === Attributes
-- - 'system_paging_state'
--
-- - 'system_device'
--
--     Unique identifier for the device responsible for managing paging operations.
--



-- $metric_system_paging_utilization
-- Swap (unix) or pagefile (windows) utilization.
--
-- Stability: development
--
-- === Attributes
-- - 'system_paging_state'
--
-- - 'system_device'
--
--     Unique identifier for the device responsible for managing paging operations.
--



-- $metric_system_paging_faults
-- The number of page faults.
--
-- Stability: development
--
-- === Attributes
-- - 'system_paging_fault_type'
--


-- $metric_system_paging_operations
-- The number of paging operations.
--
-- Stability: development
--
-- === Attributes
-- - 'system_paging_fault_type'
--
-- - 'system_paging_direction'
--



-- $metric_system_disk_io
-- Disk bytes transferred.
--
-- Stability: development
--
-- === Attributes
-- - 'system_device'
--
-- - 'disk_io_direction'
--



-- $metric_system_disk_operations
-- Disk operations count.
--
-- Stability: development
--
-- === Attributes
-- - 'system_device'
--
-- - 'disk_io_direction'
--



-- $metric_system_disk_ioTime
-- Time disk spent activated.
--
-- Stability: development
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
-- Sum of the time each operation took to complete.
--
-- Stability: development
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
-- The number of disk reads\/writes merged into single physical disk access operations.
--
-- Stability: development
--
-- === Attributes
-- - 'system_device'
--
-- - 'disk_io_direction'
--



-- $metric_system_disk_limit
-- The total storage capacity of the disk.
--
-- Stability: development
--
-- === Attributes
-- - 'system_device'
--


-- $metric_system_filesystem_usage
-- Reports a filesystem\'s space usage across different states.
--
-- Stability: development
--
-- ==== Note
-- The sum of all @system.filesystem.usage@ values over the different @system.filesystem.state@ attributes
-- SHOULD equal the total storage capacity of the filesystem, that is @system.filesystem.limit@.
--
-- === Attributes
-- - 'system_device'
--
--     Identifier for the device where the filesystem resides.
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
-- Fraction of filesystem bytes used.
--
-- Stability: development
--
-- === Attributes
-- - 'system_device'
--
--     Identifier for the device where the filesystem resides.
--
-- - 'system_filesystem_state'
--
-- - 'system_filesystem_type'
--
-- - 'system_filesystem_mode'
--
-- - 'system_filesystem_mountpoint'
--






-- $metric_system_filesystem_limit
-- The total storage capacity of the filesystem.
--
-- Stability: development
--
-- === Attributes
-- - 'system_device'
--
--     Identifier for the device where the filesystem resides.
--
-- - 'system_filesystem_type'
--
-- - 'system_filesystem_mode'
--
-- - 'system_filesystem_mountpoint'
--





-- $metric_system_network_packet_dropped
-- Count of packets that are dropped or discarded even though there was no error.
--
-- Stability: development
--
-- ==== Note
-- Measured as:
-- 
-- - Linux: the @drop@ column in @\/proc\/net\/dev@ ([source](https:\/\/web.archive.org\/web\/20180321091318\/http:\/\/www.onlamp.com\/pub\/a\/linux\/2000\/11\/16\/LinuxAdmin.html))
-- - Windows: [@InDiscards@\/@OutDiscards@](https:\/\/docs.microsoft.com\/windows\/win32\/api\/netioapi\/ns-netioapi-mib_if_row2)
--   from [@GetIfEntry2@](https:\/\/docs.microsoft.com\/windows\/win32\/api\/netioapi\/nf-netioapi-getifentry2)
--
-- === Attributes
-- - 'network_interface_name'
--
-- - 'network_io_direction'
--



-- $metric_system_network_packet_count
-- The number of packets transferred.
--
-- Stability: development
--
-- === Attributes
-- - 'system_device'
--
-- - 'network_io_direction'
--



-- $metric_system_network_errors
-- Count of network errors detected.
--
-- Stability: development
--
-- ==== Note
-- Measured as:
-- 
-- - Linux: the @errs@ column in @\/proc\/net\/dev@ ([source](https:\/\/web.archive.org\/web\/20180321091318\/http:\/\/www.onlamp.com\/pub\/a\/linux\/2000\/11\/16\/LinuxAdmin.html)).
-- - Windows: [@InErrors@\/@OutErrors@](https:\/\/docs.microsoft.com\/windows\/win32\/api\/netioapi\/ns-netioapi-mib_if_row2)
--   from [@GetIfEntry2@](https:\/\/docs.microsoft.com\/windows\/win32\/api\/netioapi\/nf-netioapi-getifentry2).
--
-- === Attributes
-- - 'network_interface_name'
--
-- - 'network_io_direction'
--



-- $metric_system_network_io
-- The number of bytes transmitted and received.
--
-- Stability: development
--
-- === Attributes
-- - 'network_interface_name'
--
-- - 'network_io_direction'
--



-- $metric_system_network_connection_count
-- The number of connections.
--
-- Stability: development
--
-- === Attributes
-- - 'network_interface_name'
--
-- - 'network_connection_state'
--
-- - 'network_transport'
--




-- $metric_system_process_count
-- Total number of processes in each state.
--
-- Stability: development
--
-- === Attributes
-- - 'process_state'
--


-- $metric_system_process_created
-- Total number of processes created over uptime of the host.
--
-- Stability: development
--

-- $metric_system_memory_linux_available
-- An estimate of how much memory is available for starting new applications, without causing swapping.
--
-- Stability: development
--
-- ==== Note
-- This is an alternative to @system.memory.usage@ metric with @state=free@.
-- Linux starting from 3.14 exports "available" memory. It takes "free" memory as a baseline, and then factors in kernel-specific values.
-- This is supposed to be more accurate than just "free" memory.
-- For reference, see the calculations [here](https:\/\/superuser.com\/a\/980821).
-- See also @MemAvailable@ in [\/proc\/meminfo](https:\/\/man7.org\/linux\/man-pages\/man5\/proc.5.html).
--

-- $metric_system_memory_linux_shared
-- Shared memory used (mostly by tmpfs).
--
-- Stability: development
--
-- ==== Note
-- Equivalent of @shared@ from [@free@ command](https:\/\/man7.org\/linux\/man-pages\/man1\/free.1.html) or
-- @Shmem@ from [@\/proc\/meminfo@](https:\/\/man7.org\/linux\/man-pages\/man5\/proc.5.html)"
--

-- $metric_system_memory_linux_slab_usage
-- Reports the memory used by the Linux kernel for managing caches of frequently used objects.
--
-- Stability: development
--
-- ==== Note
-- The sum over the @reclaimable@ and @unreclaimable@ state values in @memory.linux.slab.usage@ SHOULD be equal to the total slab memory available on the system.
-- Note that the total slab memory is not constant and may vary over time.
-- See also the [Slab allocator](https:\/\/blogs.oracle.com\/linux\/post\/understanding-linux-kernel-memory-statistics) and @Slab@ in [\/proc\/meminfo](https:\/\/man7.org\/linux\/man-pages\/man5\/proc.5.html).
--
-- === Attributes
-- - 'system_memory_linux_slab_state'
--


-- $registry_system_deprecated
-- Deprecated system attributes.
--
-- === Attributes
-- - 'system_processes_status'
--
--     Stability: development
--
--     Deprecated: renamed: process.state
--
-- - 'system_cpu_state'
--
--     Stability: development
--
--     Deprecated: renamed: cpu.mode
--
-- - 'system_network_state'
--
--     Stability: development
--
--     Deprecated: renamed: network.connection.state
--
-- - 'system_cpu_logicalNumber'
--
--     Stability: development
--
--     Deprecated: renamed: cpu.logical_number
--
-- - 'system_paging_type'
--
--     Stability: development
--
--     Deprecated: renamed: system.paging.fault.type
--
-- - 'system_process_status'
--
--     Stability: development
--
--     Deprecated: renamed: process.state
--

-- |
-- Deprecated, use @process.state@ instead.
system_processes_status :: AttributeKey Text
system_processes_status = AttributeKey "system.processes.status"

-- |
-- Deprecated, use @cpu.mode@ instead.
system_cpu_state :: AttributeKey Text
system_cpu_state = AttributeKey "system.cpu.state"

-- |
-- Deprecated, use @network.connection.state@ instead.
system_network_state :: AttributeKey Text
system_network_state = AttributeKey "system.network.state"

-- |
-- Deprecated, use @cpu.logical_number@ instead.
system_cpu_logicalNumber :: AttributeKey Int64
system_cpu_logicalNumber = AttributeKey "system.cpu.logical_number"

-- |
-- Deprecated, use @system.paging.fault.type@ instead.
system_paging_type :: AttributeKey Text
system_paging_type = AttributeKey "system.paging.type"

-- |
-- Deprecated, use @process.state@ instead.
system_process_status :: AttributeKey Text
system_process_status = AttributeKey "system.process.status"

-- $metric_system_memory_shared
-- Deprecated, use @system.memory.linux.shared@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: system.memory.linux.shared
--

-- $metric_system_network_connections
-- Deprecated, use @system.network.connection.count@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: system.network.connection.count
--
-- === Attributes
-- - 'network_interface_name'
--
-- - 'network_connection_state'
--
-- - 'network_transport'
--




-- $metric_system_network_dropped
-- Count of packets that are dropped or discarded even though there was no error.
--
-- Stability: development
--
-- Deprecated: renamed: system.network.packet.dropped
--
-- ==== Note
-- Measured as:
-- 
-- - Linux: the @drop@ column in @\/proc\/dev\/net@ ([source](https:\/\/web.archive.org\/web\/20180321091318\/http:\/\/www.onlamp.com\/pub\/a\/linux\/2000\/11\/16\/LinuxAdmin.html))
-- - Windows: [@InDiscards@\/@OutDiscards@](https:\/\/docs.microsoft.com\/windows\/win32\/api\/netioapi\/ns-netioapi-mib_if_row2)
--   from [@GetIfEntry2@](https:\/\/docs.microsoft.com\/windows\/win32\/api\/netioapi\/nf-netioapi-getifentry2)
--
-- === Attributes
-- - 'network_interface_name'
--
-- - 'network_io_direction'
--



-- $metric_system_network_packets
-- The number of packets transferred.
--
-- Stability: development
--
-- Deprecated: renamed: system.network.packet.count
--
-- === Attributes
-- - 'system_device'
--
-- - 'network_io_direction'
--



-- $metric_system_linux_memory_available
-- The number of packets transferred.
--
-- Stability: development
--
-- Deprecated: renamed: system.memory.linux.available
--

-- $metric_system_linux_memory_slab_usage
-- The number of packets transferred.
--
-- Stability: development
--
-- Deprecated: renamed: system.memory.linux.slab.usage
--
-- === Attributes
-- - 'linux_memory_slab_state'
--


-- $entity_browser
-- The web browser in which the application represented by the resource is running. The @browser.*@ attributes MUST be used only for resources that represent applications running in a web browser (regardless of whether running on a mobile or desktop device).
--
-- Stability: development
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






-- $registry_browser
-- The web browser attributes
--
-- === Attributes
-- - 'browser_brands'
--
--     Stability: development
--
-- - 'browser_platform'
--
--     Stability: development
--
-- - 'browser_mobile'
--
--     Stability: development
--
-- - 'browser_language'
--
--     Stability: development
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

-- $event_browser_webVital
-- This event describes the website performance metrics introduced by Google, See [web vitals](https:\/\/web.dev\/vitals).
--
-- Stability: development
--

-- $entity_zos_software
-- A software resource running on a z\/OS system.
--
-- Stability: development
--
-- === Attributes
-- - 'zos_sysplex_name'
--
--     Requirement level: required
--
-- - 'zos_smf_id'
--
--     Requirement level: required
--
-- - 'mainframe_lpar_name'
--




-- $service_zos_software
-- A software service running on a z\/OS system.
--
-- Stability: development
--
-- === Attributes
-- - 'service_name'
--
--     Requirement level: required
--
--     ==== Note
--     For z\/OS system software, SHOULD be set to an abbreviated name of the z\/OS system software.
--
-- - 'service_version'
--
--     Requirement level: required
--
--     ==== Note
--     For z\/OS system software, SHOULD be set to the version of the z\/OS system software.
--
-- - 'service_instance_id'
--
--     Requirement level: required
--
--     ==== Note
--     For z\/OS system software, SHOULD be set to the identifier representing the current instance of the the z\/OS system software, e.g., the CICS region APPLID or IMS region IMSID.
--
-- - 'service_namespace'
--
--     Requirement level: required
--
--     ==== Note
--     For z\/OS system software, SHOULD be set to the identifier representing of a grouping of the z\/OS system software instances, e.g., the name of the CICSPLEX.
--





-- $process_zos
-- A process running on a z\/OS system.
--
-- Stability: development
--
-- === Attributes
-- - 'process_command'
--
--     The command used to launch the process (i.e. the command name). On z\/OS, SHOULD be set to the name of the job used to start the z\/OS system software.
--
--     Requirement level: required
--
-- - 'process_pid'
--
--     Requirement level: required
--
--     ==== Note
--     On z\/OS, SHOULD be set to the Address Space Identifier.
--
-- - 'process_owner'
--
--     Requirement level: opt-in
--
--     ==== Note
--     On z\/OS, SHOULD be set to the user under which the z\/OS system software is executed.
--
-- - 'process_runtime_description'
--
--     Requirement level: opt-in
--
-- - 'process_runtime_name'
--
--     Requirement level: opt-in
--
-- - 'process_runtime_version'
--
--     Requirement level: opt-in
--







-- $os_zos
-- The operating system on a z\/OS system.
--
-- Stability: development
--
-- === Attributes
-- - 'os_type'
--
--     Requirement level: required
--
-- - 'os_description'
--
--     Human readable OS version information, e.g., as reported by command @d iplinfo@.
--
--     Requirement level: opt-in
--
-- - 'os_name'
--
--     Requirement level: opt-in
--
-- - 'os_version'
--
--     The version string of the operating system. On z\/OS, SHOULD be the release returned by the command @d iplinfo@.
--





-- $host_zos
-- The host of a z\/OS system.
--
-- Stability: development
--
-- === Attributes
-- - 'host_name'
--
--     Name of the host. On z\/OS, SHOULD be the full qualified hostname used to register the z\/OS system in DNS.
--
-- - 'host_arch'
--
-- - 'host_id'
--
--     Unique host ID. On z\/OS, SHOULD be the concatenation of sysplex name and SMFID, separated by a dash
--
--     Requirement level: opt-in
--




-- $registry_zos
-- This document defines attributes of a z\/OS resource.
--
-- === Attributes
-- - 'zos_smf_id'
--
--     Stability: development
--
-- - 'zos_sysplex_name'
--
--     Stability: development
--

-- |
-- The System Management Facility (SMF) Identifier uniquely identified a z\/OS system within a SYSPLEX or mainframe environment and is used for system and performance analysis.
zos_smf_id :: AttributeKey Text
zos_smf_id = AttributeKey "zos.smf.id"

-- |
-- The name of the SYSPLEX to which the z\/OS system belongs too.
zos_sysplex_name :: AttributeKey Text
zos_sysplex_name = AttributeKey "zos.sysplex.name"

-- $registry_cpython
-- This document defines CPython related attributes.
--
-- === Attributes
-- - 'cpython_gc_generation'
--
--     Stability: development
--

-- |
-- Value of the garbage collector collection generation.
cpython_gc_generation :: AttributeKey Text
cpython_gc_generation = AttributeKey "cpython.gc.generation"

-- $metric_cpython_gc_collections
-- The number of times a generation was collected since interpreter start.
--
-- Stability: development
--
-- ==== Note
-- This metric reports data from [@gc.stats()@](https:\/\/docs.python.org\/3\/library\/gc.html#gc.get_stats).
--
-- === Attributes
-- - 'cpython_gc_generation'
--
--     Requirement level: required
--


-- $metric_cpython_gc_collectedObjects
-- The total number of objects collected inside a generation since interpreter start.
--
-- Stability: development
--
-- ==== Note
-- This metric reports data from [@gc.stats()@](https:\/\/docs.python.org\/3\/library\/gc.html#gc.get_stats).
--
-- === Attributes
-- - 'cpython_gc_generation'
--
--     Requirement level: required
--


-- $metric_cpython_gc_uncollectableObjects
-- The total number of objects which were found to be uncollectable inside a generation since interpreter start.
--
-- Stability: development
--
-- ==== Note
-- This metric reports data from [@gc.stats()@](https:\/\/docs.python.org\/3\/library\/gc.html#gc.get_stats).
--
-- === Attributes
-- - 'cpython_gc_generation'
--
--     Requirement level: required
--


-- $registry_tls
-- This document defines semantic convention attributes in the TLS namespace.
--
-- === Attributes
-- - 'tls_cipher'
--
--     Stability: development
--
-- - 'tls_client_certificate'
--
--     Stability: development
--
-- - 'tls_client_certificateChain'
--
--     Stability: development
--
-- - 'tls_client_hash_md5'
--
--     Stability: development
--
-- - 'tls_client_hash_sha1'
--
--     Stability: development
--
-- - 'tls_client_hash_sha256'
--
--     Stability: development
--
-- - 'tls_client_issuer'
--
--     Stability: development
--
-- - 'tls_client_ja3'
--
--     Stability: development
--
-- - 'tls_client_notAfter'
--
--     Stability: development
--
-- - 'tls_client_notBefore'
--
--     Stability: development
--
-- - 'tls_client_subject'
--
--     Stability: development
--
-- - 'tls_client_supportedCiphers'
--
--     Stability: development
--
-- - 'tls_curve'
--
--     Stability: development
--
-- - 'tls_established'
--
--     Stability: development
--
-- - 'tls_nextProtocol'
--
--     Stability: development
--
-- - 'tls_protocol_name'
--
--     Stability: development
--
-- - 'tls_protocol_version'
--
--     Stability: development
--
-- - 'tls_resumed'
--
--     Stability: development
--
-- - 'tls_server_certificate'
--
--     Stability: development
--
-- - 'tls_server_certificateChain'
--
--     Stability: development
--
-- - 'tls_server_hash_md5'
--
--     Stability: development
--
-- - 'tls_server_hash_sha1'
--
--     Stability: development
--
-- - 'tls_server_hash_sha256'
--
--     Stability: development
--
-- - 'tls_server_issuer'
--
--     Stability: development
--
-- - 'tls_server_ja3s'
--
--     Stability: development
--
-- - 'tls_server_notAfter'
--
--     Stability: development
--
-- - 'tls_server_notBefore'
--
--     Stability: development
--
-- - 'tls_server_subject'
--
--     Stability: development
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
-- Normalized lowercase protocol name parsed from original string of the negotiated [SSL\/TLS protocol version](https:\/\/docs.openssl.org\/1.1.1\/man3\/SSL_get_version\/#return-values)
tls_protocol_name :: AttributeKey Text
tls_protocol_name = AttributeKey "tls.protocol.name"

-- |
-- Numeric part of the version parsed from the original string of the negotiated [SSL\/TLS protocol version](https:\/\/docs.openssl.org\/1.1.1\/man3\/SSL_get_version\/#return-values)
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

-- $registry_tls_deprecated
-- Describes deprecated @tls@ attributes.
--
-- === Attributes
-- - 'tls_client_serverName'
--
--     Stability: development
--
--     Deprecated: renamed: server.address
--

-- |
-- Deprecated, use @server.address@ instead.
tls_client_serverName :: AttributeKey Text
tls_client_serverName = AttributeKey "tls.client.server_name"

-- $entity_openshift_clusterquota
-- An OpenShift [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#clusterresourcequota-quota-openshift-io-v1) object.
--
-- Stability: development
--
-- === Attributes
-- - 'openshift_clusterquota_uid'
--
-- - 'openshift_clusterquota_name'
--



-- $registry_openshift
-- OpenShift resource attributes.
--
-- === Attributes
-- - 'openshift_clusterquota_uid'
--
--     Stability: development
--
-- - 'openshift_clusterquota_name'
--
--     Stability: development
--

-- |
-- The UID of the cluster quota.
openshift_clusterquota_uid :: AttributeKey Text
openshift_clusterquota_uid = AttributeKey "openshift.clusterquota.uid"

-- |
-- The name of the cluster quota.
openshift_clusterquota_name :: AttributeKey Text
openshift_clusterquota_name = AttributeKey "openshift.clusterquota.name"

-- $metric_openshift_clusterquota_cpu_limit_hard
-- The enforced hard limit of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--

-- $metric_openshift_clusterquota_cpu_limit_used
-- The current observed total usage of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--

-- $metric_openshift_clusterquota_cpu_request_hard
-- The enforced hard limit of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--

-- $metric_openshift_clusterquota_cpu_request_used
-- The current observed total usage of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--

-- $metric_openshift_clusterquota_memory_limit_hard
-- The enforced hard limit of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--

-- $metric_openshift_clusterquota_memory_limit_used
-- The current observed total usage of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--

-- $metric_openshift_clusterquota_memory_request_hard
-- The enforced hard limit of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--

-- $metric_openshift_clusterquota_memory_request_used
-- The current observed total usage of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--

-- $metric_openshift_clusterquota_hugepageCount_request_hard
-- The enforced hard limit of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--
-- === Attributes
-- - 'k8s_hugepage_size'
--
--     Requirement level: required
--


-- $metric_openshift_clusterquota_hugepageCount_request_used
-- The current observed total usage of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--
-- === Attributes
-- - 'k8s_hugepage_size'
--
--     Requirement level: required
--


-- $metric_openshift_clusterquota_storage_request_hard
-- The enforced hard limit of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
-- 
-- The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
-- storage class.
--
-- === Attributes
-- - 'k8s_storageclass_name'
--
--     Requirement level: conditionally required: The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
--     storage class.
--


-- $metric_openshift_clusterquota_storage_request_used
-- The current observed total usage of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
-- 
-- The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
-- storage class.
--
-- === Attributes
-- - 'k8s_storageclass_name'
--
--     Requirement level: conditionally required: The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
--     storage class.
--


-- $metric_openshift_clusterquota_persistentvolumeclaimCount_hard
-- The enforced hard limit of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
-- 
-- The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
-- storage class.
--
-- === Attributes
-- - 'k8s_storageclass_name'
--
--     Requirement level: conditionally required: The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
--     storage class.
--


-- $metric_openshift_clusterquota_persistentvolumeclaimCount_used
-- The current observed total usage of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
-- 
-- The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
-- storage class.
--
-- === Attributes
-- - 'k8s_storageclass_name'
--
--     Requirement level: conditionally required: The @k8s.storageclass.name@ should be required when a resource quota is defined for a specific
--     storage class.
--


-- $metric_openshift_clusterquota_ephemeralStorage_request_hard
-- The enforced hard limit of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--

-- $metric_openshift_clusterquota_ephemeralStorage_request_used
-- The current observed total usage of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--

-- $metric_openshift_clusterquota_ephemeralStorage_limit_hard
-- The enforced hard limit of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--

-- $metric_openshift_clusterquota_ephemeralStorage_limit_used
-- The current observed total usage of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--

-- $metric_openshift_clusterquota_objectCount_hard
-- The enforced hard limit of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Hard@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--
-- === Attributes
-- - 'k8s_resourcequota_resourceName'
--
--     Requirement level: required
--


-- $metric_openshift_clusterquota_objectCount_used
-- The current observed total usage of the resource across all projects.
--
-- Stability: development
--
-- ==== Note
-- This metric is retrieved from the @Status.Total.Used@ field of the
-- [K8s ResourceQuotaStatus](https:\/\/kubernetes.io\/docs\/reference\/generated\/kubernetes-api\/v1.32\/#resourcequotastatus-v1-core)
-- of the
-- [ClusterResourceQuota](https:\/\/docs.redhat.com\/en\/documentation\/openshift_container_platform\/4.19\/html\/schedule_and_quota_apis\/clusterresourcequota-quota-openshift-io-v1#status-total).
--
-- === Attributes
-- - 'k8s_resourcequota_resourceName'
--
--     Requirement level: required
--


-- $profile_frame
-- Describes the origin of a single frame in a Profile.
--
-- === Attributes
-- - 'profile_frame_type'
--
--     Requirement level: recommended
--


-- $registry_profile_frame
-- Describes the origin of a single frame in a Profile.
--
-- === Attributes
-- - 'profile_frame_type'
--
--     Stability: development
--

-- |
-- Describes the interpreter or compiler of a single frame.
profile_frame_type :: AttributeKey Text
profile_frame_type = AttributeKey "profile.frame.type"

-- $entity_vcs_repo
-- A repository in the Version Control System.
--
-- Stability: development
--
-- === Attributes
-- - 'vcs_repository_url_full'
--
-- - 'vcs_repository_name'
--



-- $entity_vcs_ref
-- A reference to a specific version in the Version Control System.
--
-- Stability: development
--
-- === Attributes
-- - 'vcs_ref_head_name'
--
-- - 'vcs_ref_head_revision'
--
-- - 'vcs_ref_type'
--




-- $registry_vcs_repository
-- This group defines the attributes for [Version Control Systems (VCS)](https:\/\/wikipedia.org\/wiki\/Version_control).
--
-- === Attributes
-- - 'vcs_repository_url_full'
--
--     Stability: development
--
-- - 'vcs_repository_name'
--
--     Stability: development
--
-- - 'vcs_ref_base_name'
--
--     Stability: development
--
-- - 'vcs_ref_base_type'
--
--     Stability: development
--
-- - 'vcs_ref_base_revision'
--
--     Stability: development
--
-- - 'vcs_ref_head_name'
--
--     Stability: development
--
-- - 'vcs_ref_head_type'
--
--     Stability: development
--
-- - 'vcs_ref_head_revision'
--
--     Stability: development
--
-- - 'vcs_ref_type'
--
--     Stability: development
--
-- - 'vcs_revisionDelta_direction'
--
--     Stability: development
--
-- - 'vcs_lineChange_type'
--
--     Stability: development
--
-- - 'vcs_change_title'
--
--     Stability: development
--
-- - 'vcs_change_id'
--
--     Stability: development
--
-- - 'vcs_change_state'
--
--     Stability: development
--
-- - 'vcs_owner_name'
--
--     Stability: development
--
-- - 'vcs_provider_name'
--
--     Stability: development
--

-- |
-- The [canonical URL](https:\/\/support.google.com\/webmasters\/answer\/10347851) of the repository providing the complete HTTP(S) address in order to locate and identify the repository through a browser.

-- ==== Note
-- In Git Version Control Systems, the canonical URL SHOULD NOT include
-- the @.git@ extension.
vcs_repository_url_full :: AttributeKey Text
vcs_repository_url_full = AttributeKey "vcs.repository.url.full"

-- |
-- The human readable name of the repository. It SHOULD NOT include any additional identifier like Group\/SubGroup in GitLab or organization in GitHub.

-- ==== Note
-- Due to it only being the name, it can clash with forks of the same
-- repository if collecting telemetry across multiple orgs or groups in
-- the same backends.
vcs_repository_name :: AttributeKey Text
vcs_repository_name = AttributeKey "vcs.repository.name"

-- |
-- The name of the [reference](https:\/\/git-scm.com\/docs\/gitglossary#def_ref) such as __branch__ or __tag__ in the repository.

-- ==== Note
-- @base@ refers to the starting point of a change. For example, @main@
-- would be the base reference of type branch if you\'ve created a new
-- reference of type branch from it and created new commits.
vcs_ref_base_name :: AttributeKey Text
vcs_ref_base_name = AttributeKey "vcs.ref.base.name"

-- |
-- The type of the [reference](https:\/\/git-scm.com\/docs\/gitglossary#def_ref) in the repository.

-- ==== Note
-- @base@ refers to the starting point of a change. For example, @main@
-- would be the base reference of type branch if you\'ve created a new
-- reference of type branch from it and created new commits.
vcs_ref_base_type :: AttributeKey Text
vcs_ref_base_type = AttributeKey "vcs.ref.base.type"

-- |
-- The revision, literally [revised version](https:\/\/www.merriam-webster.com\/dictionary\/revision), The revision most often refers to a commit object in Git, or a revision number in SVN.

-- ==== Note
-- @base@ refers to the starting point of a change. For example, @main@
-- would be the base reference of type branch if you\'ve created a new
-- reference of type branch from it and created new commits. The
-- revision can be a full [hash value (see
-- glossary)](https:\/\/nvlpubs.nist.gov\/nistpubs\/FIPS\/NIST.FIPS.186-5.pdf),
-- of the recorded change to a ref within a repository pointing to a
-- commit [commit](https:\/\/git-scm.com\/docs\/git-commit) object. It does
-- not necessarily have to be a hash; it can simply define a [revision
-- number](https:\/\/svnbook.red-bean.com\/en\/1.7\/svn.tour.revs.specifiers.html)
-- which is an integer that is monotonically increasing. In cases where
-- it is identical to the @ref.base.name@, it SHOULD still be included.
-- It is up to the implementer to decide which value to set as the
-- revision based on the VCS system and situational context.
vcs_ref_base_revision :: AttributeKey Text
vcs_ref_base_revision = AttributeKey "vcs.ref.base.revision"

-- |
-- The name of the [reference](https:\/\/git-scm.com\/docs\/gitglossary#def_ref) such as __branch__ or __tag__ in the repository.

-- ==== Note
-- @head@ refers to where you are right now; the current reference at a
-- given time.
vcs_ref_head_name :: AttributeKey Text
vcs_ref_head_name = AttributeKey "vcs.ref.head.name"

-- |
-- The type of the [reference](https:\/\/git-scm.com\/docs\/gitglossary#def_ref) in the repository.

-- ==== Note
-- @head@ refers to where you are right now; the current reference at a
-- given time.
vcs_ref_head_type :: AttributeKey Text
vcs_ref_head_type = AttributeKey "vcs.ref.head.type"

-- |
-- The revision, literally [revised version](https:\/\/www.merriam-webster.com\/dictionary\/revision), The revision most often refers to a commit object in Git, or a revision number in SVN.

-- ==== Note
-- @head@ refers to where you are right now; the current reference at a
-- given time.The revision can be a full [hash value (see
-- glossary)](https:\/\/nvlpubs.nist.gov\/nistpubs\/FIPS\/NIST.FIPS.186-5.pdf),
-- of the recorded change to a ref within a repository pointing to a
-- commit [commit](https:\/\/git-scm.com\/docs\/git-commit) object. It does
-- not necessarily have to be a hash; it can simply define a [revision
-- number](https:\/\/svnbook.red-bean.com\/en\/1.7\/svn.tour.revs.specifiers.html)
-- which is an integer that is monotonically increasing. In cases where
-- it is identical to the @ref.head.name@, it SHOULD still be included.
-- It is up to the implementer to decide which value to set as the
-- revision based on the VCS system and situational context.
vcs_ref_head_revision :: AttributeKey Text
vcs_ref_head_revision = AttributeKey "vcs.ref.head.revision"

-- |
-- The type of the [reference](https:\/\/git-scm.com\/docs\/gitglossary#def_ref) in the repository.
vcs_ref_type :: AttributeKey Text
vcs_ref_type = AttributeKey "vcs.ref.type"

-- |
-- The type of revision comparison.
vcs_revisionDelta_direction :: AttributeKey Text
vcs_revisionDelta_direction = AttributeKey "vcs.revision_delta.direction"

-- |
-- The type of line change being measured on a branch or change.
vcs_lineChange_type :: AttributeKey Text
vcs_lineChange_type = AttributeKey "vcs.line_change.type"

-- |
-- The human readable title of the change (pull request\/merge request\/changelist). This title is often a brief summary of the change and may get merged in to a ref as the commit summary.
vcs_change_title :: AttributeKey Text
vcs_change_title = AttributeKey "vcs.change.title"

-- |
-- The ID of the change (pull request\/merge request\/changelist) if applicable. This is usually a unique (within repository) identifier generated by the VCS system.
vcs_change_id :: AttributeKey Text
vcs_change_id = AttributeKey "vcs.change.id"

-- |
-- The state of the change (pull request\/merge request\/changelist).
vcs_change_state :: AttributeKey Text
vcs_change_state = AttributeKey "vcs.change.state"

-- |
-- The group owner within the version control system.
vcs_owner_name :: AttributeKey Text
vcs_owner_name = AttributeKey "vcs.owner.name"

-- |
-- The name of the version control system provider.
vcs_provider_name :: AttributeKey Text
vcs_provider_name = AttributeKey "vcs.provider.name"

-- $metric_vcs_change_count
-- The number of changes (pull requests\/merge requests\/changelists) in a repository, categorized by their state (e.g. open or merged).
--
-- Stability: development
--
-- === Attributes
-- - 'vcs_change_state'
--
--     Requirement level: required
--
-- - 'vcs_repository_url_full'
--
--     Requirement level: required
--
-- - 'vcs_repository_name'
--
--     Requirement level: recommended
--
-- - 'vcs_owner_name'
--
--     Requirement level: recommended
--
-- - 'vcs_provider_name'
--
--     Requirement level: opt-in
--






-- $metric_vcs_change_duration
-- The time duration a change (pull request\/merge request\/changelist) has been in a given state.
--
-- Stability: development
--
-- === Attributes
-- - 'vcs_repository_url_full'
--
--     Requirement level: required
--
-- - 'vcs_repository_name'
--
--     Requirement level: recommended
--
-- - 'vcs_ref_head_name'
--
--     Requirement level: required
--
-- - 'vcs_change_state'
--
--     Requirement level: required
--
-- - 'vcs_owner_name'
--
--     Requirement level: recommended
--
-- - 'vcs_provider_name'
--
--     Requirement level: opt-in
--







-- $metric_vcs_change_timeToApproval
-- The amount of time since its creation it took a change (pull request\/merge request\/changelist) to get the first approval.
--
-- Stability: development
--
-- === Attributes
-- - 'vcs_repository_url_full'
--
--     Requirement level: required
--
-- - 'vcs_repository_name'
--
--     Requirement level: recommended
--
-- - 'vcs_ref_head_name'
--
--     Requirement level: required
--
-- - 'vcs_ref_head_revision'
--
--     Requirement level: opt-in
--
-- - 'vcs_ref_base_name'
--
--     Requirement level: recommended
--
-- - 'vcs_ref_base_revision'
--
--     Requirement level: opt-in
--
-- - 'vcs_owner_name'
--
--     Requirement level: recommended
--
-- - 'vcs_provider_name'
--
--     Requirement level: opt-in
--









-- $metric_vcs_change_timeToMerge
-- The amount of time since its creation it took a change (pull request\/merge request\/changelist) to get merged into the target(base) ref.
--
-- Stability: development
--
-- === Attributes
-- - 'vcs_repository_url_full'
--
--     Requirement level: required
--
-- - 'vcs_repository_name'
--
--     Requirement level: recommended
--
-- - 'vcs_ref_head_name'
--
--     Requirement level: required
--
-- - 'vcs_ref_head_revision'
--
--     Requirement level: opt-in
--
-- - 'vcs_ref_base_name'
--
--     Requirement level: recommended
--
-- - 'vcs_ref_base_revision'
--
--     Requirement level: opt-in
--
-- - 'vcs_owner_name'
--
--     Requirement level: recommended
--
-- - 'vcs_provider_name'
--
--     Requirement level: opt-in
--









-- $metric_vcs_repository_count
-- The number of repositories in an organization.
--
-- Stability: development
--
-- === Attributes
-- - 'vcs_owner_name'
--
--     Requirement level: recommended
--
-- - 'vcs_provider_name'
--
--     Requirement level: opt-in
--



-- $metric_vcs_ref_count
-- The number of refs of type branch or tag in a repository.
--
-- Stability: development
--
-- === Attributes
-- - 'vcs_repository_url_full'
--
--     Requirement level: required
--
-- - 'vcs_repository_name'
--
--     Requirement level: recommended
--
-- - 'vcs_ref_type'
--
--     Requirement level: required
--
-- - 'vcs_owner_name'
--
--     Requirement level: recommended
--
-- - 'vcs_provider_name'
--
--     Requirement level: opt-in
--






-- $metric_vcs_ref_linesDelta
-- The number of lines added\/removed in a ref (branch) relative to the ref from the @vcs.ref.base.name@ attribute.
--
-- Stability: development
--
-- ==== Note
-- This metric should be reported for each @vcs.line_change.type@ value. For example if a ref added 3 lines and removed 2 lines,
-- instrumentation SHOULD report two measurements: 3 and 2 (both positive numbers).
-- If number of lines added\/removed should be calculated from the start of time, then @vcs.ref.base.name@ SHOULD be set to an empty string.
--
-- === Attributes
-- - 'vcs_change_id'
--
--     Requirement level: conditionally required: if a change is associate with the ref.
--
-- - 'vcs_repository_url_full'
--
--     Requirement level: required
--
-- - 'vcs_repository_name'
--
--     Requirement level: recommended
--
-- - 'vcs_ref_head_name'
--
--     Requirement level: required
--
-- - 'vcs_ref_head_type'
--
--     Requirement level: required
--
-- - 'vcs_ref_base_name'
--
--     Requirement level: required
--
-- - 'vcs_ref_base_type'
--
--     Requirement level: required
--
-- - 'vcs_lineChange_type'
--
--     Requirement level: required
--
-- - 'vcs_owner_name'
--
--     Requirement level: recommended
--
-- - 'vcs_provider_name'
--
--     Requirement level: opt-in
--











-- $metric_vcs_ref_revisionsDelta
-- The number of revisions (commits) a ref (branch) is ahead\/behind the branch from the @vcs.ref.base.name@ attribute.
--
-- Stability: development
--
-- ==== Note
-- This metric should be reported for each @vcs.revision_delta.direction@ value. For example if branch @a@ is 3 commits behind and 2 commits ahead of @trunk@,
-- instrumentation SHOULD report two measurements: 3 and 2 (both positive numbers) and @vcs.ref.base.name@ is set to @trunk@.
--
-- === Attributes
-- - 'vcs_change_id'
--
--     Requirement level: conditionally required: if a change is associate with the ref.
--
-- - 'vcs_repository_url_full'
--
--     Requirement level: required
--
-- - 'vcs_repository_name'
--
--     Requirement level: recommended
--
-- - 'vcs_ref_head_name'
--
--     Requirement level: required
--
-- - 'vcs_ref_head_type'
--
--     Requirement level: required
--
-- - 'vcs_ref_base_name'
--
--     Requirement level: required
--
-- - 'vcs_ref_base_type'
--
--     Requirement level: required
--
-- - 'vcs_revisionDelta_direction'
--
--     Requirement level: required
--
-- - 'vcs_owner_name'
--
--     Requirement level: recommended
--
-- - 'vcs_provider_name'
--
--     Requirement level: opt-in
--











-- $metric_vcs_ref_time
-- Time a ref (branch) created from the default branch (trunk) has existed. The @ref.type@ attribute will always be @branch@.
--
-- Stability: development
--
-- === Attributes
-- - 'vcs_repository_url_full'
--
--     Requirement level: required
--
-- - 'vcs_repository_name'
--
--     Requirement level: recommended
--
-- - 'vcs_ref_head_name'
--
--     Requirement level: required
--
-- - 'vcs_ref_head_type'
--
--     Requirement level: required
--
-- - 'vcs_owner_name'
--
--     Requirement level: recommended
--
-- - 'vcs_provider_name'
--
--     Requirement level: opt-in
--







-- $metric_vcs_contributor_count
-- The number of unique contributors to a repository.
--
-- Stability: development
--
-- === Attributes
-- - 'vcs_repository_url_full'
--
--     Requirement level: required
--
-- - 'vcs_repository_name'
--
--     Requirement level: recommended
--
-- - 'vcs_owner_name'
--
--     Requirement level: recommended
--
-- - 'vcs_provider_name'
--
--     Requirement level: opt-in
--





-- $registry_vcs_deprecated
-- Describes deprecated vcs attributes.
--
-- === Attributes
-- - 'vcs_repository_ref_name'
--
--     Stability: development
--
--     Deprecated: renamed: vcs.ref.head.name
--
-- - 'vcs_repository_ref_type'
--
--     Stability: development
--
--     Deprecated: renamed: vcs.ref.head.type
--
-- - 'vcs_repository_ref_revision'
--
--     Stability: development
--
--     Deprecated: renamed: vcs.ref.head.revision
--
-- - 'vcs_repository_change_title'
--
--     Stability: development
--
--     Deprecated: renamed: vcs.change.title
--
-- - 'vcs_repository_change_id'
--
--     Stability: development
--
--     Deprecated: renamed: vcs.change.id
--

-- |
-- Deprecated, use @vcs.ref.head.name@ instead.
vcs_repository_ref_name :: AttributeKey Text
vcs_repository_ref_name = AttributeKey "vcs.repository.ref.name"

-- |
-- Deprecated, use @vcs.ref.head.type@ instead.
vcs_repository_ref_type :: AttributeKey Text
vcs_repository_ref_type = AttributeKey "vcs.repository.ref.type"

-- |
-- Deprecated, use @vcs.ref.head.revision@ instead.
vcs_repository_ref_revision :: AttributeKey Text
vcs_repository_ref_revision = AttributeKey "vcs.repository.ref.revision"

-- |
-- Deprecated, use @vcs.change.title@ instead.
vcs_repository_change_title :: AttributeKey Text
vcs_repository_change_title = AttributeKey "vcs.repository.change.title"

-- |
-- Deprecated, use @vcs.change.id@ instead.
vcs_repository_change_id :: AttributeKey Text
vcs_repository_change_id = AttributeKey "vcs.repository.change.id"

-- $span_http_client
-- This span represents an outbound HTTP request.
--
-- Stability: stable
--
-- ==== Note
-- There are two ways HTTP client spans can be implemented in an instrumentation:
-- 
-- 1. Instrumentations SHOULD create an HTTP span for each attempt to send an HTTP request over the wire.
--    In case the request is resent, the resend attempts MUST follow the [HTTP resend spec](#http-request-retries-and-redirects).
--    In this case, instrumentations SHOULD NOT (also) emit a logical encompassing HTTP client span.
-- 
-- 2. If for some reason it is not possible to emit a span for each send attempt (because e.g. the instrumented library does not expose hooks that would allow this),
--    instrumentations MAY create an HTTP span for the top-most operation of the HTTP client.
--    In this case, the @url.full@ MUST be the absolute URL that was originally requested, before any HTTP-redirects that may happen when executing the request.
-- 
-- __Span name:__ refer to the [Span Name](\/docs\/http\/http-spans.md#name) section.
-- 
-- __Span kind__ MUST be @CLIENT@.
-- 
-- __Span status:__ refer to the [Span Status](\/docs\/http\/http-spans.md#status) section.
--
-- === Attributes
-- - 'http_request_method'
--
-- - 'http_request_methodOriginal'
--
--     Requirement level: conditionally required: If and only if it\'s different than @http.request.method@.
--
-- - 'http_request_resendCount'
--
--     Requirement level: recommended: if and only if request was retried.
--
-- - 'http_request_header'
--
--     Requirement level: opt-in
--
-- - 'http_response_header'
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
-- - 'http_request_size'
--
--     Requirement level: opt-in
--
-- - 'http_response_size'
--
--     Requirement level: opt-in
--
-- - 'http_request_body_size'
--
--     Requirement level: opt-in
--
-- - 'http_response_body_size'
--
--     Requirement level: opt-in
--
-- - 'userAgent_synthetic_type'
--
--     Requirement level: opt-in
--



















-- $span_http_server
-- This span represents an inbound HTTP request.
--
-- Stability: stable
--
-- ==== Note
-- __Span name:__ refer to the [Span Name](\/docs\/http\/http-spans.md#name) section.
-- 
-- __Span kind__ MUST be @SERVER@.
-- 
-- __Span status:__ refer to the [Span Status](\/docs\/http\/http-spans.md#status) section.
--
-- === Attributes
-- - 'http_request_method'
--
-- - 'http_request_methodOriginal'
--
--     Requirement level: conditionally required: If and only if it\'s different than @http.request.method@.
--
-- - 'http_route'
--
-- - 'http_request_header'
--
--     Requirement level: opt-in
--
-- - 'http_response_header'
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
-- - 'http_request_size'
--
--     Requirement level: opt-in
--
-- - 'http_response_size'
--
--     Requirement level: opt-in
--
-- - 'http_request_body_size'
--
--     Requirement level: opt-in
--
-- - 'http_response_body_size'
--
--     Requirement level: opt-in
--
-- - 'userAgent_synthetic_type'
--
--     Requirement level: opt-in
--
























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
--     Requirement level: required
--
--     ==== Note
--     In HTTP\/1.1, when the [request target](https:\/\/www.rfc-editor.org\/rfc\/rfc9112.html#name-request-target)
--     is passed in its [absolute-form](https:\/\/www.rfc-editor.org\/rfc\/rfc9112.html#section-3.2.2),
--     the @server.address@ SHOULD match the host component of the request target.
--     
--     In all other cases, @server.address@ SHOULD match the host component of the
--     @Host@ header in HTTP\/1.1 or the @:authority@ pseudo-header in HTTP\/2 and HTTP\/3.
--
-- - 'server_port'
--
--     Requirement level: required
--
--     ==== Note
--     In the case of HTTP\/1.1, when the [request target](https:\/\/www.rfc-editor.org\/rfc\/rfc9112.html#name-request-target)
--     is passed in its [absolute-form](https:\/\/www.rfc-editor.org\/rfc\/rfc9112.html#section-3.2.2),
--     the @server.port@ SHOULD match the port component of the request target.
--     
--     In all other cases, @server.port@ SHOULD match the port component of the
--     @Host@ header in HTTP\/1.1 or the @:authority@ pseudo-header in HTTP\/2 and HTTP\/3.
--
-- - 'url_scheme'
--
--     Requirement level: opt-in
--
-- - 'url_template'
--
--     Requirement level: opt-in
--
--     ==== Note
--     The @url.template@ MUST have low cardinality. It is not usually available on HTTP clients, but may be known by the application or specialized HTTP instrumentation.
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
--     Requirement level: conditionally required: If available and @server.address@ is set.
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





-- $registry_http
-- This document defines semantic convention attributes in the HTTP namespace.
--
-- === Attributes
-- - 'http_request_body_size'
--
--     Stability: development
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
-- - 'http_request_size'
--
--     Stability: development
--
-- - 'http_response_body_size'
--
--     Stability: development
--
-- - 'http_response_header'
--
--     Stability: stable
--
-- - 'http_response_size'
--
--     Stability: development
--
-- - 'http_response_statusCode'
--
--     Stability: stable
--
-- - 'http_route'
--
--     Stability: stable
--
-- - 'http_connection_state'
--
--     Stability: development
--

-- |
-- The size of the request payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.
http_request_body_size :: AttributeKey Int64
http_request_body_size = AttributeKey "http.request.body.size"

-- |
-- HTTP request headers, @\<key\>@ being the normalized HTTP Header name (lowercase), the value being the header values.

-- ==== Note
-- Instrumentations SHOULD require an explicit configuration of which headers are to be captured.
-- Including all request headers can be a security risk - explicit configuration helps avoid leaking sensitive information.
-- 
-- The @User-Agent@ header is already captured in the @user_agent.original@ attribute.
-- Users MAY explicitly configure instrumentations to capture them even though it is not recommended.
-- 
-- The attribute value MUST consist of either multiple header values as an array of strings
-- or a single-item array containing a possibly comma-concatenated string, depending on the way
-- the HTTP library provides access to headers.
-- 
-- Examples:
-- 
-- - A header @Content-Type: application\/json@ SHOULD be recorded as the @http.request.header.content-type@
--   attribute with value @["application\/json"]@.
-- - A header @X-Forwarded-For: 1.2.3.4, 1.2.3.5@ SHOULD be recorded as the @http.request.header.x-forwarded-for@
--   attribute with value @["1.2.3.4", "1.2.3.5"]@ or @["1.2.3.4, 1.2.3.5"]@ depending on the HTTP library.
http_request_header :: Text -> AttributeKey [Text]
http_request_header = \k -> AttributeKey $ "http.request.header." <> k

-- |
-- HTTP request method.

-- ==== Note
-- HTTP request method value SHOULD be "known" to the instrumentation.
-- By default, this convention defines "known" methods as the ones listed in [RFC9110](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#name-methods),
-- the PATCH method defined in [RFC5789](https:\/\/www.rfc-editor.org\/rfc\/rfc5789.html)
-- and the QUERY method defined in [httpbis-safe-method-w-body](https:\/\/datatracker.ietf.org\/doc\/draft-ietf-httpbis-safe-method-w-body\/?include_text=1).
-- 
-- If the HTTP request method is not known to instrumentation, it MUST set the @http.request.method@ attribute to @_OTHER@.
-- 
-- If the HTTP instrumentation could end up converting valid HTTP request methods to @_OTHER@, then it MUST provide a way to override
-- the list of known HTTP methods. If this override is done via environment variable, then the environment variable MUST be named
-- OTEL_INSTRUMENTATION_HTTP_KNOWN_METHODS and support a comma-separated list of case-sensitive known HTTP methods.
-- 
-- ![Development](https:\/\/img.shields.io\/badge\/-development-blue)
-- If this override is done via declarative configuration, then the list MUST be configurable via the @known_methods@ property
-- (an array of case-sensitive strings with minimum items 0) under @.instrumentation\/development.general.http.client@ and\/or
-- @.instrumentation\/development.general.http.server@.
-- 
-- In either case, this list MUST be a full override of the default known methods,
-- it is not a list of known methods in addition to the defaults.
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
-- The total size of the request in bytes. This should be the total number of bytes sent over the wire, including the request line (HTTP\/1.1), framing (HTTP\/2 and HTTP\/3), headers, and request body if any.
http_request_size :: AttributeKey Int64
http_request_size = AttributeKey "http.request.size"

-- |
-- The size of the response payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.
http_response_body_size :: AttributeKey Int64
http_response_body_size = AttributeKey "http.response.body.size"

-- |
-- HTTP response headers, @\<key\>@ being the normalized HTTP Header name (lowercase), the value being the header values.

-- ==== Note
-- Instrumentations SHOULD require an explicit configuration of which headers are to be captured.
-- Including all response headers can be a security risk - explicit configuration helps avoid leaking sensitive information.
-- 
-- Users MAY explicitly configure instrumentations to capture them even though it is not recommended.
-- 
-- The attribute value MUST consist of either multiple header values as an array of strings
-- or a single-item array containing a possibly comma-concatenated string, depending on the way
-- the HTTP library provides access to headers.
-- 
-- Examples:
-- 
-- - A header @Content-Type: application\/json@ header SHOULD be recorded as the @http.request.response.content-type@
--   attribute with value @["application\/json"]@.
-- - A header @My-custom-header: abc, def@ header SHOULD be recorded as the @http.response.header.my-custom-header@
--   attribute with value @["abc", "def"]@ or @["abc, def"]@ depending on the HTTP library.
http_response_header :: Text -> AttributeKey [Text]
http_response_header = \k -> AttributeKey $ "http.response.header." <> k

-- |
-- The total size of the response in bytes. This should be the total number of bytes sent over the wire, including the status line (HTTP\/1.1), framing (HTTP\/2 and HTTP\/3), headers, and response body and trailers if any.
http_response_size :: AttributeKey Int64
http_response_size = AttributeKey "http.response.size"

-- |
-- [HTTP response status code](https:\/\/tools.ietf.org\/html\/rfc7231#section-6).
http_response_statusCode :: AttributeKey Int64
http_response_statusCode = AttributeKey "http.response.status_code"

-- |
-- The matched route template for the request. This MUST be low-cardinality and include all static path segments, with dynamic path segments represented with placeholders.

-- ==== Note
-- MUST NOT be populated when this is not supported by the HTTP server framework as the route attribute should have low-cardinality and the URI path can NOT substitute it.
-- SHOULD include the [application root](\/docs\/http\/http-spans.md#http-server-definitions) if there is one.
-- 
-- A static path segment is a part of the route template with a fixed, low-cardinality value. This includes literal strings like @\/users\/@ and placeholders that
-- are constrained to a finite, predefined set of values, e.g. @{controller}@ or @{action}@.
-- 
-- A dynamic path segment is a placeholder for a value that can have high cardinality and is not constrained to a predefined list like static path segments.
-- 
-- Instrumentations SHOULD use routing information provided by the corresponding web framework. They SHOULD pick the most precise source of routing information and MAY
-- support custom route formatting. Instrumentations SHOULD document the format and the API used to obtain the route string.
http_route :: AttributeKey Text
http_route = AttributeKey "http.route"

-- |
-- State of the HTTP connection in the HTTP connection pool.
http_connection_state :: AttributeKey Text
http_connection_state = AttributeKey "http.connection.state"

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
--     
--     \> [!WARNING]
--     \> Since this attribute is based on HTTP headers, opting in to it may allow an attacker
--     \> to trigger cardinality limits, degrading the usefulness of the metric.
--
-- - 'server_port'
--
--     Requirement level: opt-in
--
--     ==== Note
--     See [Setting @server.address@ and @server.port@ attributes](\/docs\/http\/http-spans.md#setting-serveraddress-and-serverport-attributes).
--     
--     \> [!WARNING]
--     \> Since this attribute is based on HTTP headers, opting in to it may allow an attacker
--     \> to trigger cardinality limits, degrading the usefulness of the metric.
--
-- - 'userAgent_synthetic_type'
--
--     Requirement level: opt-in
--




-- $metricAttributes_http_client
-- HTTP client attributes
--

-- $metricAttributes_http_client_experimental
-- HTTP client experimental attributes
--
-- === Attributes
-- - 'url_template'
--
--     Requirement level: conditionally required: If available.
--
--     ==== Note
--     The @url.template@ MUST have low cardinality. It is not usually available on HTTP clients, but may be known by the application or specialized HTTP instrumentation.
--


-- $metric_http_server_request_duration
-- Duration of HTTP server requests.
--
-- Stability: stable
--

-- $metric_http_server_activeRequests
-- Number of active HTTP server requests.
--
-- Stability: development
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
--     
--     \> [!WARNING]
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
--     
--     \> [!WARNING]
--     \> Since this attribute is based on HTTP headers, opting in to it may allow an attacker
--     \> to trigger cardinality limits, degrading the usefulness of the metric.
--





-- $metric_http_server_request_body_size
-- Size of HTTP server request bodies.
--
-- Stability: development
--
-- ==== Note
-- The size of the request payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.
--

-- $metric_http_server_response_body_size
-- Size of HTTP server response bodies.
--
-- Stability: development
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
-- Stability: development
--
-- ==== Note
-- The size of the request payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.
--

-- $metric_http_client_response_body_size
-- Size of HTTP client response bodies.
--
-- Stability: development
--
-- ==== Note
-- The size of the response payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https:\/\/www.rfc-editor.org\/rfc\/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.
--

-- $metric_http_client_openConnections
-- Number of outbound HTTP connections that are currently active or idle on the client.
--
-- Stability: development
--
-- === Attributes
-- - 'http_connection_state'
--
--     Requirement level: required
--
-- - 'network_peer_address'
--
--     Requirement level: recommended
--
-- - 'network_protocol_version'
--
--     Requirement level: recommended
--
-- - 'server_address'
--
--     Requirement level: required
--
-- - 'server_port'
--
--     Requirement level: required
--
-- - 'url_scheme'
--
--     Requirement level: opt-in
--







-- $metric_http_client_connection_duration
-- The duration of the successfully established outbound HTTP connections.
--
-- Stability: development
--
-- === Attributes
-- - 'network_peer_address'
--
--     Requirement level: recommended
--
-- - 'network_protocol_version'
--
--     Requirement level: recommended
--
-- - 'server_address'
--
--     Requirement level: required
--
-- - 'server_port'
--
--     Requirement level: required
--
-- - 'url_scheme'
--
--     Requirement level: opt-in
--






-- $metric_http_client_activeRequests
-- Number of active HTTP requests.
--
-- Stability: development
--
-- === Attributes
-- - 'http_request_method'
--
--     Requirement level: recommended
--
-- - 'server_address'
--
--     Requirement level: required
--
--     ==== Note
--     In HTTP\/1.1, when the [request target](https:\/\/www.rfc-editor.org\/rfc\/rfc9112.html#name-request-target)
--     is passed in its [absolute-form](https:\/\/www.rfc-editor.org\/rfc\/rfc9112.html#section-3.2.2),
--     the @server.address@ SHOULD match the host component of the request target.
--     
--     In all other cases, @server.address@ SHOULD match the host component of the
--     @Host@ header in HTTP\/1.1 or the @:authority@ pseudo-header in HTTP\/2 and HTTP\/3.
--
-- - 'server_port'
--
--     Requirement level: required
--
--     ==== Note
--     In the case of HTTP\/1.1, when the [request target](https:\/\/www.rfc-editor.org\/rfc\/rfc9112.html#name-request-target)
--     is passed in its [absolute-form](https:\/\/www.rfc-editor.org\/rfc\/rfc9112.html#section-3.2.2),
--     the @server.port@ SHOULD match the port component of the request target.
--     
--     In all other cases, @server.port@ SHOULD match the port component of the
--     @Host@ header in HTTP\/1.1 or the @:authority@ pseudo-header in HTTP\/2 and HTTP\/3.
--
-- - 'url_scheme'
--
--     Requirement level: opt-in
--
-- - 'url_template'
--
--     Requirement level: conditionally required: If available.
--
--     ==== Note
--     The @url.template@ MUST have low cardinality. It is not usually available on HTTP clients, but may be known by the application or specialized HTTP instrumentation.
--






-- $event_http_client_request_exception
-- This event represents an exception that occurred during an HTTP client request, such as network failures, timeouts, or other errors that prevent the request from completing successfully.
--
-- Stability: development
--
-- ==== Note
-- This event SHOULD be recorded when an exception occurs during HTTP client operations.
-- Instrumentations SHOULD set the severity to WARN (severity number 13) when recording this event.
-- Some HTTP client frameworks generate artificial exceptions for non-successful HTTP status codes (e.g., 404 Not Found). When possible, instrumentations SHOULD NOT record these artificial exceptions, or SHOULD set the severity to DEBUG (severity number 5).
-- Instrumentations MAY provide a configuration option to populate exception events with the attributes captured on the corresponding HTTP client span.
--
-- === Attributes
-- - 'exception_type'
--
--     Requirement level: conditionally required: Required if @exception.message@ is not set, recommended otherwise.
--
-- - 'exception_message'
--
--     Requirement level: conditionally required: Required if @exception.type@ is not set, recommended otherwise.
--
-- - 'exception_stacktrace'
--




-- $event_http_server_request_exception
-- This event represents an exception that occurred during HTTP server request processing, such as application errors, internal failures, or other exceptions that prevent the server from successfully handling the request.
--
-- Stability: development
--
-- ==== Note
-- This event SHOULD be recorded when an exception occurs during HTTP server request processing.
-- Instrumentations SHOULD set the severity to ERROR (severity number 17) when recording this event.
-- Instrumentations MAY provide a configuration option to populate exception events with the attributes captured on the corresponding HTTP server span.
--
-- === Attributes
-- - 'exception_type'
--
--     Requirement level: conditionally required: Required if @exception.message@ is not set, recommended otherwise.
--
-- - 'exception_message'
--
--     Requirement level: conditionally required: Required if @exception.type@ is not set, recommended otherwise.
--
-- - 'exception_stacktrace'
--




-- $registry_http_deprecated
-- Describes deprecated HTTP attributes.
--
-- === Attributes
-- - 'http_method'
--
--     Stability: development
--
--     Deprecated: renamed: http.request.method
--
-- - 'http_statusCode'
--
--     Stability: development
--
--     Deprecated: renamed: http.response.status_code
--
-- - 'http_scheme'
--
--     Stability: development
--
--     Deprecated: renamed: url.scheme
--
-- - 'http_url'
--
--     Stability: development
--
--     Deprecated: renamed: url.full
--
-- - 'http_target'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'http_requestContentLength'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'http_responseContentLength'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'http_clientIp'
--
--     Stability: development
--
--     Deprecated: renamed: client.address
--
-- - 'http_host'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'http_requestContentLengthUncompressed'
--
--     Stability: development
--
--     Deprecated: renamed: http.request.body.size
--
-- - 'http_responseContentLengthUncompressed'
--
--     Stability: development
--
--     Deprecated: renamed: http.response.body.size
--
-- - 'http_serverName'
--
--     Stability: development
--
--     Deprecated: renamed: server.address
--
-- - 'http_flavor'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'http_userAgent'
--
--     Stability: development
--
--     Deprecated: renamed: user_agent.original
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
-- Deprecated, use @client.address@ instead.
http_clientIp :: AttributeKey Text
http_clientIp = AttributeKey "http.client_ip"

-- |
-- Deprecated, use one of @server.address@, @client.address@ or @http.request.header.host@ instead, depending on the usage.
http_host :: AttributeKey Text
http_host = AttributeKey "http.host"

-- |
-- Deprecated, use @http.request.body.size@ instead.
http_requestContentLengthUncompressed :: AttributeKey Int64
http_requestContentLengthUncompressed = AttributeKey "http.request_content_length_uncompressed"

-- |
-- Deprecated, use @http.response.body.size@ instead.
http_responseContentLengthUncompressed :: AttributeKey Int64
http_responseContentLengthUncompressed = AttributeKey "http.response_content_length_uncompressed"

-- |
-- Deprecated, use @server.address@ instead.
http_serverName :: AttributeKey Text
http_serverName = AttributeKey "http.server_name"

-- |
-- Deprecated, use @network.protocol.name@ and @network.protocol.version@ instead.
http_flavor :: AttributeKey Text
http_flavor = AttributeKey "http.flavor"

-- |
-- Deprecated, use @user_agent.original@ instead.
http_userAgent :: AttributeKey Text
http_userAgent = AttributeKey "http.user_agent"

-- $registry_cassandra
-- This section defines attributes for Cassandra.
--
-- === Attributes
-- - 'cassandra_coordinator_dc'
--
--     Stability: development
--
-- - 'cassandra_coordinator_id'
--
--     Stability: development
--
-- - 'cassandra_consistency_level'
--
--     Stability: development
--
-- - 'cassandra_query_idempotent'
--
--     Stability: development
--
-- - 'cassandra_page_size'
--
--     Stability: development
--
-- - 'cassandra_speculativeExecution_count'
--
--     Stability: development
--

-- |
-- The data center of the coordinating node for a query.
cassandra_coordinator_dc :: AttributeKey Text
cassandra_coordinator_dc = AttributeKey "cassandra.coordinator.dc"

-- |
-- The ID of the coordinating node for a query.
cassandra_coordinator_id :: AttributeKey Text
cassandra_coordinator_id = AttributeKey "cassandra.coordinator.id"

-- |
-- The consistency level of the query. Based on consistency values from [CQL](https:\/\/docs.datastax.com\/en\/cassandra-oss\/3.0\/cassandra\/dml\/dmlConfigConsistency.html).
cassandra_consistency_level :: AttributeKey Text
cassandra_consistency_level = AttributeKey "cassandra.consistency.level"

-- |
-- Whether or not the query is idempotent.
cassandra_query_idempotent :: AttributeKey Bool
cassandra_query_idempotent = AttributeKey "cassandra.query.idempotent"

-- |
-- The fetch size used for paging, i.e. how many rows will be returned at once.
cassandra_page_size :: AttributeKey Int64
cassandra_page_size = AttributeKey "cassandra.page.size"

-- |
-- The number of times a query was speculatively executed. Not set or @0@ if the query was not executed speculatively.
cassandra_speculativeExecution_count :: AttributeKey Int64
cassandra_speculativeExecution_count = AttributeKey "cassandra.speculative_execution.count"

-- $span_graphql_server
-- This span represents an incoming operation on a GraphQL server implementation.
--
-- Stability: development
--
-- ==== Note
-- __Span name__ SHOULD be of the format @{graphql.operation.type}@ provided
-- @graphql.operation.type@ is available. If @graphql.operation.type@ is not available,
-- the span SHOULD be named @GraphQL Operation@.
-- 
-- \> [!WARNING]
-- \> The @graphql.operation.name@ value is provided by the client and can have high
-- \> cardinality. Using it in the GraphQL server span name (by default) is
-- \> NOT RECOMMENDED.
-- \>
-- \> Instrumentation MAY provide a configuration option to enable a more descriptive
-- \> span name following @{graphql.operation.type} {graphql.operation.name}@ format
-- \> when @graphql.operation.name@ is available.
--
-- === Attributes
-- - 'graphql_operation_name'
--
--     Requirement level: recommended
--
-- - 'graphql_operation_type'
--
--     Requirement level: recommended
--
-- - 'graphql_document'
--
--     Requirement level: recommended
--




-- $registry_graphql
-- This document defines attributes for GraphQL.
--
-- === Attributes
-- - 'graphql_operation_name'
--
--     Stability: development
--
-- - 'graphql_operation_type'
--
--     Stability: development
--
-- - 'graphql_document'
--
--     Stability: development
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

-- $entity_deployment
-- The software deployment.
--
-- Stability: development
--
-- === Attributes
-- - 'deployment_environment_name'
--
--     Requirement level: recommended
--


-- $registry_deployment
-- This document defines attributes for software deployments.
--
-- === Attributes
-- - 'deployment_name'
--
--     Stability: development
--
-- - 'deployment_id'
--
--     Stability: development
--
-- - 'deployment_status'
--
--     Stability: development
--
-- - 'deployment_environment_name'
--
--     Stability: development
--

-- |
-- The name of the deployment.
deployment_name :: AttributeKey Text
deployment_name = AttributeKey "deployment.name"

-- |
-- The id of the deployment.
deployment_id :: AttributeKey Text
deployment_id = AttributeKey "deployment.id"

-- |
-- The status of the deployment.
deployment_status :: AttributeKey Text
deployment_status = AttributeKey "deployment.status"

-- |
-- Name of the [deployment environment](https:\/\/wikipedia.org\/wiki\/Deployment_environment) (aka deployment tier).

-- ==== Note
-- @deployment.environment.name@ does not affect the uniqueness constraints defined through
-- the @service.namespace@, @service.name@ and @service.instance.id@ resource attributes.
-- This implies that resources carrying the following attribute combinations MUST be
-- considered to be identifying the same service:
-- 
-- - @service.name=frontend@, @deployment.environment.name=production@
-- - @service.name=frontend@, @deployment.environment.name=staging@.
deployment_environment_name :: AttributeKey Text
deployment_environment_name = AttributeKey "deployment.environment.name"

-- $registry_deployment_deprecated
-- Describes deprecated deployment attributes.
--
-- === Attributes
-- - 'deployment_environment'
--
--     Stability: development
--
--     Deprecated: renamed: deployment.environment.name
--

-- |
-- Deprecated, use @deployment.environment.name@ instead.
deployment_environment :: AttributeKey Text
deployment_environment = AttributeKey "deployment.environment"

-- $registry_linux_deprecated
-- Deprecated Linux attributes.
--
-- === Attributes
-- - 'linux_memory_slab_state'
--
--     Stability: development
--
--     Deprecated: renamed: system.memory.linux.slab.state
--

-- |
-- The Linux Slab memory state
linux_memory_slab_state :: AttributeKey Text
linux_memory_slab_state = AttributeKey "linux.memory.slab.state"

-- $entity_android
-- The Android platform on which the Android application is running.
--
-- Stability: development
--
-- === Attributes
-- - 'android_os_apiLevel'
--


-- $registry_android
-- The Android platform on which the Android application is running.
--
-- === Attributes
-- - 'android_os_apiLevel'
--
--     Stability: development
--
-- - 'android_app_state'
--
--     Stability: development
--

-- |
-- Uniquely identifies the framework API revision offered by a version (@os.version@) of the android operating system. More information can be found in the [Android API levels documentation](https:\/\/developer.android.com\/guide\/topics\/manifest\/uses-sdk-element#ApiLevels).
android_os_apiLevel :: AttributeKey Text
android_os_apiLevel = AttributeKey "android.os.api_level"

-- |
-- This attribute represents the state of the application.

-- ==== Note
-- The Android lifecycle states are defined in [Activity lifecycle callbacks](https:\/\/developer.android.com\/guide\/components\/activities\/activity-lifecycle#lc), and from which the @OS identifiers@ are derived.
android_app_state :: AttributeKey Text
android_app_state = AttributeKey "android.app.state"

-- $registry_android_deprecated
-- This document defines attributes that represents an occurrence of a lifecycle transition on the Android platform.
--
-- === Attributes
-- - 'android_state'
--
--     Stability: development
--
--     Deprecated: renamed: android.app.state
--

-- |
-- Deprecated. Use @android.app.state@ attribute instead.
android_state :: AttributeKey Text
android_state = AttributeKey "android.state"

-- $entity_cloud
-- A cloud environment (e.g. GCP, Azure, AWS)
--
-- Stability: development
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







-- $registry_cloud
-- A cloud environment (e.g. GCP, Azure, AWS).
--
-- === Attributes
-- - 'cloud_provider'
--
--     Stability: development
--
-- - 'cloud_account_id'
--
--     Stability: development
--
-- - 'cloud_region'
--
--     Stability: development
--
-- - 'cloud_resourceId'
--
--     Stability: development
--
-- - 'cloud_availabilityZone'
--
--     Stability: development
--
-- - 'cloud_platform'
--
--     Stability: development
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
-- The geographical region within a cloud provider. When associated with a resource, this attribute specifies the region where the resource operates. When calling services or APIs deployed on a cloud, this attribute identifies the region where the called destination is deployed.

-- ==== Note
-- Refer to your provider\'s docs to see the available regions, for example [Alibaba Cloud regions](https:\/\/www.alibabacloud.com\/help\/doc-detail\/40654.htm), [AWS regions](https:\/\/aws.amazon.com\/about-aws\/global-infrastructure\/regions_az\/), [Azure regions](https:\/\/azure.microsoft.com\/global-infrastructure\/geographies\/), [Google Cloud regions](https:\/\/cloud.google.com\/about\/locations), or [Tencent Cloud regions](https:\/\/www.tencentcloud.com\/document\/product\/213\/6091).
cloud_region :: AttributeKey Text
cloud_region = AttributeKey "cloud.region"

-- |
-- Cloud provider-specific native identifier of the monitored cloud resource (e.g. an [ARN](https:\/\/docs.aws.amazon.com\/general\/latest\/gr\/aws-arns-and-namespaces.html) on AWS, a [fully qualified resource ID](https:\/\/learn.microsoft.com\/rest\/api\/resources\/resources\/get-by-id) on Azure, a [full resource name](https:\/\/google.aip.dev\/122#full-resource-names) on GCP)

-- ==== Note
-- On some cloud providers, it may not be possible to determine the full ID at startup,
-- so it may be necessary to set @cloud.resource_id@ as a span attribute instead.
-- 
-- The exact value to use for @cloud.resource_id@ depends on the cloud provider.
-- The following well-known definitions MUST be used if you set this attribute and they apply:
-- 
-- - __AWS Lambda:__ The function [ARN](https:\/\/docs.aws.amazon.com\/general\/latest\/gr\/aws-arns-and-namespaces.html).
--   Take care not to use the "invoked ARN" directly but replace any
--   [alias suffix](https:\/\/docs.aws.amazon.com\/lambda\/latest\/dg\/configuration-aliases.html)
--   with the resolved function version, as the same runtime instance may be invocable with
--   multiple different aliases.
-- - __GCP:__ The [URI of the resource](https:\/\/cloud.google.com\/iam\/docs\/full-resource-names)
-- - __Azure:__ The [Fully Qualified Resource ID](https:\/\/learn.microsoft.com\/rest\/api\/resources\/resources\/get-by-id) of the invoked function,
--   *not* the function app, having the form
--   @\/subscriptions\/\<SUBSCRIPTION_GUID\>\/resourceGroups\/\<RG\>\/providers\/Microsoft.Web\/sites\/\<FUNCAPP\>\/functions\/\<FUNC\>@.
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
-- Stability: stable
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Server.Kestrel@; Added in: ASP.NET Core 8.0
--

-- $metric_kestrel_connection_duration
-- The duration of connections on the server.
--
-- Stability: stable
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
--     Starting from .NET 9, Kestrel @kestrel.connection.duration@ metric reports
--     the following errors types when a corresponding error occurs:
--     
--     | Value | Description |
--     | --- | --- |
--     | @aborted_by_app@ | The HTTP\/1.1 connection was aborted when app code aborted an HTTP request with @HttpContext.Abort()@. |
--     | @app_shutdown_timeout@ | The connection was aborted during app shutdown. During shutdown, the server stops accepting new connections and HTTP requests, and it is given time for active requests to complete. If the app shutdown timeout is exceeded, all remaining connections are aborted. |
--     | @closed_critical_stream@ | A critical control stream for an HTTP\/3 connection was closed. |
--     | @connection_reset@ | The connection was reset while there were active HTTP\/2 or HTTP\/3 streams on the connection. |
--     | @error_after_starting_response@ | An error such as an unhandled application exception or invalid request body occurred after the response was started, causing an abort of the HTTP\/1.1 connection. |
--     | @error_reading_headers@ | An error occurred when decoding HPACK headers in an HTTP\/2 @HEADERS@ frame. |
--     | @error_writing_headers@ | An error occurred when encoding HPACK headers in an HTTP\/2 @HEADERS@ frame. |
--     | @flow_control_queue_size_exceeded@ | The connection exceeded the outgoing flow control maximum queue size and was closed with @INTERNAL_ERROR@. This can be caused by an excessive number of HTTP\/2 stream resets. For more information, see [Microsoft Security Advisory CVE-2023-44487](https:\/\/github.com\/dotnet\/runtime\/issues\/93303). |
--     | @flow_control_window_exceeded@ | The client sent more data than allowed by the current flow-control window. |
--     | @frame_after_stream_close@ | An HTTP\/2 frame was received on a closed stream. |
--     | @insufficient_tls_version@ | The connection doesn\'t have TLS 1.2 or greater, as required by HTTP\/2. |
--     | @invalid_body_reader_state@ | An error occurred when draining the request body, aborting the HTTP\/1.1 connection. This could be caused by app code reading the request body and missing a call to @PipeReader.AdvanceTo@ in a finally block. |
--     | @invalid_data_padding@ | An HTTP\/2 @HEADER@ or @DATA@ frame has an invalid amount of padding. |
--     | @invalid_frame_length@ | An HTTP\/2 frame was received with an invalid frame payload length. The frame could contain a payload that is not valid for the type, or a @DATA@ frame payload does not match the length specified in the frame header. |
--     | @invalid_handshake@ | An invalid HTTP\/2 handshake was received. |
--     | @invalid_http_version@ | The connection received an HTTP request with the wrong version. For example, a browser sends an HTTP\/1.1 request to a plain-text HTTP\/2 connection. |
--     | @invalid_request_headers@ | The HTTP request contains invalid headers. This error can occur in a number of scenarios: a header might not be allowed by the HTTP protocol, such as a pseudo-header in the @HEADERS@ frame of an HTTP\/2 request. A header could also have an invalid value, such as a non-integer @content-length@, or a header name or value might contain invalid characters. |
--     | @invalid_request_line@ | The first line of an HTTP\/1.1 request was invalid, potentially due to invalid content or exceeding the allowed limit. Configured by @KestrelServerLimits.MaxRequestLineSize@. |
--     | @invalid_settings@ | The connection received an HTTP\/2 or HTTP\/3 @SETTINGS@ frame with invalid settings. |
--     | @invalid_stream_id@ | An HTTP\/2 stream with an invalid stream ID was received. |
--     | @invalid_window_update_size@ | The server received an HTTP\/2 @WINDOW_UPDATE@ frame with a zero increment, or an increment that caused a flow-control window to exceed the maximum size. |
--     | @io_error@ | An @IOException@ occurred while reading or writing HTTP\/2 or HTTP\/3 connection data. |
--     | @keep_alive_timeout@ | There was no activity on the connection, and the keep-alive timeout configured by @KestrelServerLimits.KeepAliveTimeout@ was exceeded. |
--     | @max_concurrent_connections_exceeded@ | The connection exceeded the maximum concurrent connection limit. Configured by @KestrelServerLimits.MaxConcurrentConnections@. |
--     | @max_frame_length_exceeded@ | The connection received an HTTP\/2 frame that exceeded the size limit specified by @Http2Limits.MaxFrameSize@. |
--     | @max_request_body_size_exceeded@ | The HTTP request body exceeded the maximum request body size limit. Configured by @KestrelServerLimits.MaxRequestBodySize@. |
--     | @max_request_header_count_exceeded@ | The HTTP request headers exceeded the maximum count limit. Configured by @KestrelServerLimits.MaxRequestHeaderCount@. |
--     | @max_request_headers_total_size_exceeded@ | The HTTP request headers exceeded the maximum total size limit. Configured by @KestrelServerLimits.MaxRequestHeadersTotalSize@. |
--     | @min_request_body_data_rate@ | Reading the request body timed out due to data arriving too slowly. Configured by @KestrelServerLimits.MinRequestBodyDataRate@. |
--     | @min_response_data_rate@ | Writing the response timed out because the client did not read it at the specified minimum data rate. Configured by @KestrelServerLimits.MinResponseDataRate@. |
--     | @missing_stream_end@ | The connection received an HTTP\/2 @HEADERS@ frame for trailers without a stream end flag. |
--     | @output_queue_size_exceeded@ | The connection exceeded the output queue size and was closed with @INTERNAL_ERROR@. This can be caused by an excessive number of HTTP\/2 stream resets. For more information, see [Microsoft Security Advisory CVE-2023-44487](https:\/\/github.com\/dotnet\/runtime\/issues\/93303). |
--     | @request_headers_timeout@ | Request headers timed out while waiting for headers to be received after the request started. Configured by @KestrelServerLimits.RequestHeadersTimeout@. |
--     | @response_content_length_mismatch@ | The HTTP response body sent data that didn\'t match the response\'s @content-length@ header. |
--     | @server_timeout@ | The connection timed out with the @IConnectionTimeoutFeature@. |
--     | @stream_creation_error@ | The HTTP\/3 connection received a stream that it wouldn\'t accept. For example, the client created duplicate control streams. |
--     | @stream_reset_limit_exceeded@ | The connection received an excessive number of HTTP\/2 stream resets and was closed with @ENHANCE_YOUR_CALM@. For more information, see [Microsoft Security Advisory CVE-2023-44487](https:\/\/github.com\/dotnet\/runtime\/issues\/93303). |
--     | @stream_self_dependency@ | The connection received an HTTP\/2 frame that caused a frame to depend on itself. |
--     | @tls_handshake_failed@ | An error occurred during the TLS handshake for a connection. Only reported for HTTP\/1.1 and HTTP\/2 connections. The TLS handshake for HTTP\/3 is internal to QUIC transport. ![Development](https:\/\/img.shields.io\/badge\/-development-blue) |
--     | @tls_not_supported@ | A TLS handshake was received by an endpoint that isn\'t configured to support TLS. |
--     | @unexpected_end_of_request_content@ | The HTTP\/1.1 request body ended before the data specified by the @content-length@ header or chunked transfer encoding mechanism was received. |
--     | @unexpected_frame@ | An unexpected HTTP\/2 or HTTP\/3 frame type was received. The frame type is either unknown, unsupported, or invalid for the current stream state. |
--     | @unknown_stream@ | An HTTP\/2 frame was received on an unknown stream. |
--     | @write_canceled@ | The cancellation of a response body write aborted the HTTP\/1.1 connection. |
--     
--     In other cases, @error.type@ contains the fully qualified type name of the exception.
--





-- $metric_kestrel_rejectedConnections
-- Number of connections rejected by the server.
--
-- Stability: stable
--
-- ==== Note
-- Connections are rejected when the currently active count exceeds the value configured with @MaxConcurrentConnections@.
-- Meter name: @Microsoft.AspNetCore.Server.Kestrel@; Added in: ASP.NET Core 8.0
--

-- $metric_kestrel_queuedConnections
-- Number of connections that are currently queued and are waiting to start.
--
-- Stability: stable
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Server.Kestrel@; Added in: ASP.NET Core 8.0
--

-- $metric_kestrel_queuedRequests
-- Number of HTTP requests on multiplexed connections (HTTP\/2 and HTTP\/3) that are currently queued and are waiting to start.
--
-- Stability: stable
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
-- Stability: stable
--
-- ==== Note
-- The counter only tracks HTTP\/1.1 connections.
-- 
-- Meter name: @Microsoft.AspNetCore.Server.Kestrel@; Added in: ASP.NET Core 8.0
--

-- $metric_kestrel_tlsHandshake_duration
-- The duration of TLS handshakes on the server.
--
-- Stability: stable
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
-- Stability: stable
--
-- ==== Note
-- Meter name: @Microsoft.AspNetCore.Server.Kestrel@; Added in: ASP.NET Core 8.0
--

-- $trace_db_common_minimal
-- This group defines the attributes used to perform database client calls.
--
-- === Attributes
-- - 'db_operation_name'
--
--     Requirement level: conditionally required: If readily available and if there is a single operation name that describes the database call.
--
-- - 'db_operation_batch_size'
--
-- - 'server_address'
--
-- - 'server_port'
--





-- $trace_db_common_query
-- This group defines the attributes used to perform database client calls.
--
-- === Attributes
-- - 'server_address'
--
-- - 'server_port'
--
-- - 'db_operation_batch_size'
--
-- - 'db_response_returnedRows'
--
-- - 'db_query_text'
--
--     Requirement level: recommended: Non-parameterized query text SHOULD NOT be collected by default unless there is sanitization that excludes sensitive data, e.g. by redacting all literal values present in the query text. See [Sanitization of @db.query.text@](\/docs\/db\/database-spans.md#sanitization-of-dbquerytext).
--     Parameterized query text SHOULD be collected by default (the query parameter values themselves are opt-in, see [@db.query.parameter.\<key\>@](\/docs\/registry\/attributes\/db.md)).
--
-- - 'db_query_summary'
--
-- - 'db_query_parameter'
--
--     Requirement level: opt-in
--








-- $trace_db_common_queryAndCollection
-- This group defines the attributes used to perform database client calls.
--
-- === Attributes
-- - 'db_collection_name'
--
-- - 'db_operation_name'
--
-- - 'db_operation_batch_size'
--
-- - 'server_address'
--
-- - 'server_port'
--
-- - 'db_response_returnedRows'
--
-- - 'db_query_text'
--
--     Requirement level: recommended: Non-parameterized query text SHOULD NOT be collected by default unless there is sanitization that excludes sensitive data, e.g. by redacting all literal values present in the query text. See [Sanitization of @db.query.text@](\/docs\/db\/database-spans.md#sanitization-of-dbquerytext).
--     Parameterized query text SHOULD be collected by default (the query parameter values themselves are opt-in, see [@db.query.parameter.\<key\>@](\/docs\/registry\/attributes\/db.md)).
--
-- - 'db_query_summary'
--
-- - 'db_query_parameter'
--
--     Requirement level: opt-in
--










-- $trace_db_common_full
-- This group documents attributes that describe database call along with network information.
--
-- === Attributes
-- - 'network_peer_address'
--
--     Peer address of the database node where the operation was performed.
--
--     Requirement level: recommended: If applicable for this database system.
--
--     ==== Note
--     Semantic conventions for individual database systems SHOULD document whether @network.peer.*@ attributes are applicable. Network peer address and port are useful when the application interacts with individual database nodes directly.
--     If a database operation involved multiple network calls (for example retries), the address of the last contacted node SHOULD be used.
--
-- - 'network_peer_port'
--
--     Requirement level: recommended: if and only if @network.peer.address@ is set.
--
-- - 'db_system_name'
--
--     Requirement level: required
--
-- - 'db_namespace'
--
--     Requirement level: conditionally required: If available.
--
-- - 'db_storedProcedure_name'
--
--     Requirement level: recommended: If operation applies to a specific stored procedure.
--






-- $span_db_client
-- This span describes database client call.
--
-- Stability: stable
--
-- ==== Note
-- Instrumentations SHOULD, when possible, record database spans that cover the duration of
-- the corresponding API call as if it was observed by the caller (such as client application).
-- For example, if a transient issue happened and was retried within this database call, the corresponding
-- span should cover the duration of the logical operation with all retries.
-- 
-- When a database client provides higher-level convenience APIs for specific operations
-- (e.g., calling a stored procedure), which internally generate and execute a generic query,
-- it is RECOMMENDED to instrument the higher-level convenience APIs.
-- These often allow setting @db.operation.*@ attributes, which usually are not
-- readily available at the generic query level.
-- 
-- __Span name__ is covered in the [Name](\/docs\/db\/database-spans.md#name) section.
-- 
-- __Span kind__ SHOULD be @CLIENT@. It MAY be set to @INTERNAL@ on spans representing
-- in-memory database calls.
-- It\'s RECOMMENDED to use @CLIENT@ kind when database system being instrumented usually
-- runs in a different process than its client or when database calls happen over
-- instrumented protocol such as HTTP.
-- 
-- __Span status__ SHOULD follow the [Recording Errors](\/docs\/general\/recording-errors.md) document.
-- Semantic conventions for individual systems SHOULD specify which values of @db.response.status_code@
-- classify as errors.
--
-- === Attributes
-- - 'db_response_returnedRows'
--
--     Requirement level: opt-in
--


-- $span_db_sqlServer_client
-- Spans representing calls to Microsoft SQL Server adhere to the general [Semantic Conventions for Database Client Spans](database-spans.md).
--
-- Stability: stable
--
-- ==== Note
-- @db.system.name@ MUST be set to @"microsoft.sql_server"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'db_namespace'
--
--     The database associated with the connection, qualified by the instance name.
--
--     ==== Note
--     When connected to a default instance, @db.namespace@ SHOULD be set to the name of
--     the database. When connected to a [named instance](https:\/\/learn.microsoft.com\/sql\/connect\/jdbc\/building-the-connection-url#named-and-multiple-sql-server-instances),
--     @db.namespace@ SHOULD be set to the combination of instance and database name following the @{instance_name}|{database_name}@ pattern.
--     
--     A connection\'s currently associated database may change during its lifetime, e.g. from executing @USE \<database\>@.
--     
--     If instrumentation is unable to capture the connection\'s currently associated database on each query
--     without triggering an additional query to be executed (e.g. @SELECT DB_NAME()@),
--     then it is RECOMMENDED to fallback and use the database provided when the connection was established.
--     
--     Instrumentation SHOULD document if @db.namespace@ reflects the database provided when the connection was established.
--     
--     It is RECOMMENDED to capture the value as provided by the application without attempting to do any case normalization.
--
-- - 'db_response_statusCode'
--
--     [Microsoft SQL Server error](https:\/\/learn.microsoft.com\/sql\/relational-databases\/errors-events\/database-engine-events-and-errors) number represented as a string.
--
--     ==== Note
--     Microsoft SQL Server does not report SQLSTATE.
--     Instrumentations SHOULD use [error severity](https:\/\/learn.microsoft.com\/sql\/relational-databases\/errors-events\/database-engine-error-severities) returned along with the status code to determine the status of the span. Response codes with severity 11 or higher SHOULD be considered errors.
--



-- $span_db_postgresql_client
-- Spans representing calls to a PostgreSQL database adhere to the general [Semantic Conventions for Database Client Spans](database-spans.md).
--
-- Stability: stable
--
-- ==== Note
-- @db.system.name@ MUST be set to @"postgresql"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'db_namespace'
--
--     The schema associated with the connection, qualified by the database name.
--
--     ==== Note
--     @db.namespace@ SHOULD be set to the combination of database and schema name following the @{database}|{schema}@ pattern.
--     If either @{database}@ or @{schema}@ is unavailable, @db.namespace@ SHOULD be set to the other (without any @|@ separator).
--     
--     A connection\'s currently associated database may change during its lifetime, e.g. from executing @SET search_path TO \<schema\>@.
--     If the search path has multiple schemas, the first schema in the search path SHOULD be used.
--     
--     If instrumentation is unable to capture the connection\'s currently associated schema on each query
--     without triggering an additional query to be executed (e.g. @SELECT current_schema()@),
--     then it is RECOMMENDED to fallback and use the schema provided when the connection was established.
--     
--     Instrumentation SHOULD document if @db.namespace@ reflects the schema provided when the connection was established.
--     
--     Instrumentation MAY use the user name when the connection was established as a stand-in for the schema name.
--     
--     Instrumentation SHOULD document if @db.namespace@ reflects the user provided when the connection was established.
--     
--     It is RECOMMENDED to capture the value as provided by the application without attempting to do any case normalization.
--
-- - 'db_response_statusCode'
--
--     [PostgreSQL error code](https:\/\/www.postgresql.org\/docs\/current\/errcodes-appendix.html).
--
--     ==== Note
--     PostgreSQL follows SQL standard conventions for [SQLSTATE](https:\/\/wikipedia.org\/wiki\/SQLSTATE). Response codes of "Class 02" or higher SHOULD be considered errors.
--



-- $span_db_mysql_client
-- Spans representing calls to a MySQL Server adhere to the general [Semantic Conventions for Database Client Spans](database-spans.md).
--
-- Stability: stable
--
-- ==== Note
-- @db.system.name@ MUST be set to @"mysql"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'db_namespace'
--
--     The database associated with the connection.
--
--     ==== Note
--     A connection\'s currently associated database may change during its lifetime, e.g. from executing @USE \<database\>@.
--     
--     If instrumentation is unable to capture the connection\'s currently associated database on each query
--     without triggering an additional query to be executed (e.g. @SELECT DATABASE()@),
--     then it is RECOMMENDED to fallback and use the database provided when the connection was established.
--     
--     Instrumentation SHOULD document if @db.namespace@ reflects the database provided when the connection was established.
--     
--     It is RECOMMENDED to capture the value as provided by the application without attempting to do any case normalization.
--
-- - 'db_response_statusCode'
--
--     [MySQL error number](https:\/\/dev.mysql.com\/doc\/mysql-errors\/9.0\/en\/error-reference-introduction.html) recorded as a string.
--
--     ==== Note
--     MySQL error codes are vendor specific error codes and don\'t follow [SQLSTATE](https:\/\/wikipedia.org\/wiki\/SQLSTATE) conventions. All MySQL error codes SHOULD be considered errors.
--



-- $span_db_mariadb_client
-- Spans representing calls to MariaDB adhere to the general [Semantic Conventions for Database Client Spans](\/docs\/db\/README.md).
--
-- Stability: stable
--
-- ==== Note
-- @db.system.name@ MUST be set to @"mariadb"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'db_namespace'
--
--     The database associated with the connection.
--
--     ==== Note
--     A connection\'s currently associated database may change during its lifetime, e.g. from executing @USE \<database\>@.
--     
--     If instrumentation is unable to capture the connection\'s currently associated database on each query
--     without triggering an additional query to be executed (e.g. @SELECT DATABASE()@),
--     then it is RECOMMENDED to fallback and use the database provided when the connection was established.
--     
--     Instrumentation SHOULD document if @db.namespace@ reflects the database provided when the connection was established.
--     
--     It is RECOMMENDED to capture the value as provided by the application without attempting to do any case normalization.
--
-- - 'db_response_statusCode'
--
--     [Maria DB error code](https:\/\/mariadb.com\/docs\/server\/reference\/error-codes) represented as a string.
--
--     ==== Note
--     MariaDB uses vendor-specific error codes on all errors and reports [SQLSTATE](https:\/\/mariadb.com\/kb\/en\/sqlstate\/) in some cases.
--     MariaDB error codes are more granular than SQLSTATE, so MariaDB instrumentations SHOULD set the @db.response.status_code@ to this known error code.
--     When SQLSTATE is available, SQLSTATE of "Class 02" or higher SHOULD be considered errors. When SQLSTATE is not available, all MariaDB error codes SHOULD be considered errors.
--



-- $span_db_cassandra_client
-- Spans representing calls to a Cassandra database adhere to the general [Semantic Conventions for Database Client Spans](\/docs\/db\/database-spans.md).
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"cassandra"@ and SHOULD be provided __at span creation time__.
-- 
-- __Span name__ SHOULD follow the general [database span name convention](\/docs\/db\/database-spans.md#name)
--
-- === Attributes
-- - 'db_namespace'
--
--     The keyspace associated with the session.
--
--     Requirement level: conditionally required: If available.
--
-- - 'cassandra_page_size'
--
-- - 'cassandra_consistency_level'
--
-- - 'db_collection_name'
--
--     The name of the Cassandra table that the operation is acting upon.
--
--     ==== Note
--     It is RECOMMENDED to capture the value as provided by the application
--     without attempting to do any case normalization.
--     
--     For batch operations, if the individual operations are known to have the same collection name
--     then that collection name SHOULD be used.
--
-- - 'cassandra_query_idempotent'
--
-- - 'cassandra_speculativeExecution_count'
--
-- - 'cassandra_coordinator_id'
--
-- - 'cassandra_coordinator_dc'
--
-- - 'network_peer_address'
--
--     Peer address of the database node where the operation was performed.
--
--     Requirement level: recommended
--
--     ==== Note
--     If a database operation involved multiple network calls (for example retries), the address of the last contacted node SHOULD be used.
--
-- - 'network_peer_port'
--
--     Requirement level: recommended: if and only if @network.peer.address@ is set.
--
-- - 'db_response_statusCode'
--
--     [Cassandra protocol error code](https:\/\/github.com\/apache\/cassandra\/blob\/cassandra-5.0\/doc\/native_protocol_v5.spec) represented as a string.
--
--     ==== Note
--     All Cassandra protocol error codes SHOULD be considered errors.
--












-- $span_db_hbase_client
-- Spans representing calls to an HBase database adhere to the general [Semantic Conventions for Database Client Spans](\/docs\/db\/database-spans.md).
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"hbase"@ and SHOULD be provided __at span creation time__.
-- 
-- __Span name__ SHOULD follow the general [database span name convention](\/docs\/db\/database-spans.md#name)
--
-- === Attributes
-- - 'db_namespace'
--
--     The HBase namespace.
--
--     Requirement level: conditionally required: If applicable.
--
-- - 'db_collection_name'
--
--     The HBase table name.
--
--     Requirement level: conditionally required: If applicable.
--
--     ==== Note
--     It is RECOMMENDED to capture the value as provided by the application without attempting to do any case normalization. If table name includes the namespace, the @db.collection.name@ SHOULD be set to the full table name.
--
-- - 'db_operation_name'
--
--     Requirement level: required
--
--     ==== Note
--     It is RECOMMENDED to capture the value as provided by the application
--     without attempting to do any case normalization.
--     
--     For batch operations, if the individual operations are known to have the same operation name
--     then that operation name SHOULD be used prepended by @BATCH @,
--     otherwise @db.operation.name@ SHOULD be @BATCH@.
--
-- - 'db_response_statusCode'
--
--     Protocol-specific response code recorded as a string.
--
--     Requirement level: conditionally required: If response was received.
--





-- $span_db_couchdb_client
-- Spans representing calls to CouchDB adhere to the general [Semantic Conventions for Database Client Spans](\/docs\/db\/database-spans.md).
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"couchdb"@ and SHOULD be provided __at span creation time__.
-- 
-- __Span name__ SHOULD follow the general [database span name convention](\/docs\/db\/database-spans.md#name)
--
-- === Attributes
-- - 'db_operation_name'
--
--     The HTTP method + the target REST route.
--
--     Requirement level: conditionally required: If readily available.
--
--     ==== Note
--     In __CouchDB__, @db.operation.name@ should be set to the HTTP method + the target REST route according to the API reference documentation. For example, when retrieving a document, @db.operation.name@ would be set to (literally, i.e., without replacing the placeholders with concrete values): [@GET \/{db}\/{docid}@](https:\/\/docs.couchdb.org\/en\/stable\/api\/document\/common.html#get--db-docid).
--
-- - 'db_namespace'
--
--     Requirement level: conditionally required: If available.
--
--     ==== Note
--     
--
-- - 'db_response_statusCode'
--
--     The HTTP response code returned by the Couch DB recorded as a string.
--
--     Requirement level: conditionally required: If response was received and the HTTP response code is available.
--
--     ==== Note
--     HTTP response codes in the 4xx and 5xx range SHOULD be considered errors.
--




-- $span_db_redis_client
-- Spans representing calls to Redis adhere to the general [Semantic Conventions for Database Client Spans](\/docs\/db\/database-spans.md).
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"redis"@ and SHOULD be provided __at span creation time__.
-- 
-- __Span name__ SHOULD follow the general [database span name convention](\/docs\/db\/database-spans.md#name)
-- except that @db.namespace@ SHOULD NOT be used in the span name since it is a numeric value that ends up
-- looking confusing.
--
-- === Attributes
-- - 'db_namespace'
--
--     The [database index] associated with the connection, represented as a string.
--
--     Requirement level: conditionally required: If and only if it can be captured reliably.
--
--     ==== Note
--     A connection\'s currently associated database index may change during its lifetime, e.g. from executing @SELECT \<index\>@.
--     
--     If instrumentation is unable to capture the connection\'s currently associated database index on each query
--     without triggering an additional query to be executed,
--     then it is RECOMMENDED to fallback and use the database index provided when the connection was established.
--     
--     Instrumentation SHOULD document if @db.namespace@ reflects the database index provided when the connection was established.
--
-- - 'db_operation_name'
--
--     The Redis command name.
--
--     Requirement level: required
--
--     ==== Note
--     It is RECOMMENDED to capture the value as provided by the application without attempting to do any case normalization.
--     For [transactions and pipelined calls](https:\/\/redis.io\/docs\/latest\/develop\/clients\/redis-py\/transpipe\/), if the individual operations are known to have the same command then that command SHOULD be used prepended by @MULTI @ or @PIPELINE @. Otherwise @db.operation.name@ SHOULD be @MULTI@ or @PIPELINE@.
--
-- - 'db_query_text'
--
--     The full syntax of the Redis CLI command.
--
--     Requirement level: recommended
--
--     ==== Note
--     Query text SHOULD NOT be collected by default unless there is sanitization that excludes sensitive data, e.g. by redacting all literal values present in the query text.
--     See [Sanitization of @db.query.text@](\/docs\/db\/database-spans.md#sanitization-of-dbquerytext).
--     The value provided for @db.query.text@ SHOULD correspond to the syntax of the Redis CLI. If, for example, the [@HMSET@ command](https:\/\/redis.io\/docs\/latest\/commands\/hmset) is invoked, @"HMSET myhash field1 ? field2 ?"@ would be a suitable value for @db.query.text@.
--
-- - 'db_storedProcedure_name'
--
--     The name or sha1 digest of a Lua script in the database.
--
--     Requirement level: recommended: If operation applies to a specific Lua script.
--
--     ==== Note
--     See [FCALL](https:\/\/redis.io\/docs\/latest\/commands\/fcall\/) and [EVALSHA](https:\/\/redis.io\/docs\/latest\/commands\/evalsha\/).
--
-- - 'network_peer_address'
--
--     Peer address of the database node where the operation was performed.
--
--     Requirement level: recommended
--
--     ==== Note
--     If a database operation involved multiple network calls (for example retries), the address of the last contacted node SHOULD be used.
--
-- - 'network_peer_port'
--
--     Requirement level: recommended: if and only if @network.peer.address@ is set.
--
-- - 'db_response_statusCode'
--
--     The Redis [simple error](https:\/\/redis.io\/docs\/latest\/develop\/reference\/protocol-spec\/#simple-errors) prefix.
--
--     ==== Note
--     All Redis error prefixes SHOULD be considered errors.
--
-- - 'db_operation_batch_size'
--
-- - 'server_address'
--
-- - 'server_port'
--











-- $span_db_mongodb_client
-- Spans representing calls to MongoDB adhere to the general [Semantic Conventions for Database Client Spans](\/docs\/db\/database-spans.md).
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"mongodb"@ and SHOULD be provided __at span creation time__.
-- __Span name__ SHOULD follow the general [database span name convention](\/docs\/db\/database-spans.md#name)
--
-- === Attributes
-- - 'db_operation_name'
--
--     The name of the [MongoDB command](https:\/\/www.mongodb.com\/docs\/manual\/reference\/command\/) being executed.
--
--     Requirement level: required
--
--     ==== Note
--     
--
-- - 'db_collection_name'
--
--     The MongoDB collection being accessed within the database stated in @db.namespace@.
--
--     Requirement level: required
--
--     ==== Note
--     It is RECOMMENDED to capture the value as provided by the application without attempting to do any case normalization.
--     For batch operations, if the individual operations are known to have the same collection name then that collection name SHOULD be used.
--
-- - 'db_namespace'
--
--     The MongoDB database name.
--
--     Requirement level: conditionally required: If available.
--
--     ==== Note
--     
--
-- - 'db_response_statusCode'
--
--     [MongoDB error code](https:\/\/www.mongodb.com\/docs\/manual\/reference\/error-codes\/) represented as a string.
--
--     Requirement level: conditionally required: If the operation failed and error code is available.
--
--     ==== Note
--     All MongoDB error codes SHOULD be considered errors.
--





-- $span_db_elasticsearch_client
-- Spans representing calls to Elasticsearch adhere to the general [Semantic Conventions for Database Client Spans](\/docs\/db\/database-spans.md).
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"elasticsearch"@ and SHOULD be provided __at span creation time__.
-- 
-- __Span name__ SHOULD follow the general [database span name convention](\/docs\/db\/database-spans.md#name)
-- with the endpoint identifier stored in @db.operation.name@, and the index stored in @db.collection.name@.
--
-- === Attributes
-- - 'http_request_method'
--
--     Requirement level: required
--
-- - 'db_operation_name'
--
--     Requirement level: required
--
--     ==== Note
--     The @db.operation.name@ SHOULD match the endpoint identifier provided in the request (see the [Elasticsearch schema](https:\/\/raw.githubusercontent.com\/elastic\/elasticsearch-specification\/main\/output\/schema\/schema.json)).
--     For batch operations, if the individual operations are known to have the same operation name then that operation name SHOULD be used prepended by @bulk @, otherwise @db.operation.name@ SHOULD be @bulk@.
--
-- - 'url_full'
--
--     Requirement level: required
--
-- - 'db_query_text'
--
--     The request body for a [search-type query](https:\/\/www.elastic.co\/guide\/en\/elasticsearch\/reference\/current\/search.html), as a json string.
--
--     Requirement level: recommended: Should be collected by default for search-type queries and only if there is sanitization that excludes sensitive information.
--
-- - 'db_collection_name'
--
--     The index or data stream against which the query is executed.
--
--     Requirement level: recommended
--
--     ==== Note
--     The query may target multiple indices or data streams, in which case it SHOULD be a comma separated list of those. If the query doesn\'t target a specific index, this field MUST NOT be set.
--
-- - 'db_namespace'
--
--     The name of the Elasticsearch cluster which the client connects to.
--
--     Requirement level: recommended
--
--     ==== Note
--     When communicating with an Elastic Cloud deployment, this should be collected from the "X-Found-Handling-Cluster" HTTP response header.
--
-- - 'elasticsearch_node_name'
--
--     Requirement level: recommended
--
--     ==== Note
--     When communicating with an Elastic Cloud deployment, this should be collected from the "X-Found-Handling-Instance" HTTP response header.
--
-- - 'db_operation_parameter'
--
--     A dynamic value in the url path.
--
--     Stability: development
--
--     Requirement level: conditionally required: when the url has path parameters
--
--     ==== Note
--     Many Elasticsearch url paths allow dynamic values. These SHOULD be recorded in span attributes in the format @db.operation.parameter.\<key\>@, where @\<key\>@ is the path parameter name. The implementation SHOULD reference the [elasticsearch schema](https:\/\/raw.githubusercontent.com\/elastic\/elasticsearch-specification\/main\/output\/schema\/schema.json) in order to map the path parameter values to their names.
--
-- - 'db_response_statusCode'
--
--     The HTTP response code returned by the Elasticsearch cluster.
--
--     Requirement level: conditionally required: If response was received.
--
--     ==== Note
--     HTTP response codes in the 4xx and 5xx range SHOULD be considered errors.
--










-- $span_db_sql_client
-- The SQL databases Semantic Conventions describes how common [Database Semantic Conventions](\/docs\/db\/database-spans.md) apply to SQL databases.
--
-- Stability: stable
--
-- ==== Note
-- The following database systems (defined in the
-- [@db.system.name@](\/docs\/db\/database-spans.md#notes-and-well-known-identifiers-for-dbsystemname) set)
-- are known to use SQL as their primary query language:
-- 
-- - @actian.ingres@
-- - @cockroachdb@
-- - @derby@
-- - @firebirdsql@
-- - @h2database@
-- - @hsqldb@
-- - @ibm.db2@
-- - @mariadb@
-- - @microsoft.sql_server@
-- - @mysql@
-- - @oracle.db@
-- - @other_sql@
-- - @postgresql@
-- - @sap.maxdb@
-- - @sqlite@
-- - @trino@
-- 
-- Many other database systems support SQL and can be accessed via generic database driver such as JDBC or ODBC.
-- Instrumentations applied to generic SQL drivers SHOULD adhere to SQL semantic conventions.
-- 
-- __Span name__ SHOULD follow the general [database span name convention](\/docs\/db\/database-spans.md#name)
--
-- === Attributes
-- - 'db_namespace'
--
--     The database associated with the connection, fully qualified within the server address and port.
--
--     Requirement level: conditionally required: If available without an additional network call.
--
--     ==== Note
--     If a database system has multiple namespace components (e.g. schema name and database name), they SHOULD be concatenated
--     from the most general to the most specific namespace component,
--     using @|@ as a separator between the components.
--     Any missing components (and their associated separators) SHOULD be omitted.
--     
--     Semantic conventions for individual database systems SHOULD document what @db.namespace@
--     means in the context of that system.
--     
--     A connection\'s currently associated database may change during its lifetime, e.g. from executing @USE \<database\>@.
--     
--     If instrumentation is unable to capture the connection\'s currently associated database on each query
--     without triggering an additional query to be executed (e.g. @SELECT DATABASE()@),
--     then it is RECOMMENDED to fallback and use the database provided when the connection was established.
--     
--     Instrumentation SHOULD document if @db.namespace@ reflects the database provided when the connection was established.
--     
--     It is RECOMMENDED to capture the value as provided by the application without attempting to do any case normalization.
--
-- - 'db_response_statusCode'
--
--     Database response code recorded as a string.
--
--     Requirement level: conditionally required: If response has ended with warning or an error.
--
--     ==== Note
--     SQL defines [SQLSTATE](https:\/\/wikipedia.org\/wiki\/SQLSTATE) as a database
--     return code which is adopted by some database systems like PostgreSQL.
--     See [PostgreSQL error codes](https:\/\/www.postgresql.org\/docs\/current\/errcodes-appendix.html)
--     for the details.
--     
--     Other systems like MySQL, Oracle, or MS SQL Server define vendor-specific
--     error codes. Database SQL drivers usually provide access to both properties.
--     For example, in Java, the [@SQLException@](https:\/\/docs.oracle.com\/javase\/8\/docs\/api\/java\/sql\/SQLException.html)
--     class reports them with @getSQLState()@ and @getErrorCode()@ methods.
--     
--     Instrumentations SHOULD populate the @db.response.status_code@ with the
--     the most specific code available to them.
--     
--     Here\'s a non-exhaustive list of databases that report vendor-specific
--     codes with granularity higher than SQLSTATE (or don\'t report SQLSTATE
--     at all):
--     
--     - [DB2 SQL codes](https:\/\/www.ibm.com\/docs\/db2-for-zos\/12?topic=codes-sql).
--     - [Maria DB error codes](https:\/\/mariadb.com\/docs\/server\/reference\/error-codes)
--     - [Microsoft SQL Server errors](https:\/\/docs.microsoft.com\/sql\/relational-databases\/errors-events\/database-engine-events-and-errors)
--     - [MySQL error codes](https:\/\/dev.mysql.com\/doc\/mysql-errors\/9.0\/en\/error-reference-introduction.html)
--     - [Oracle error codes](https:\/\/docs.oracle.com\/cd\/B28359_01\/server.111\/b28278\/toc.htm)
--     - [SQLite result codes](https:\/\/www.sqlite.org\/rescode.html)
--     
--     These systems SHOULD set the @db.response.status_code@ to a
--     known vendor-specific error code. If only SQLSTATE is available,
--     it SHOULD be used.
--     
--     When multiple error codes are available and specificity is unclear,
--     instrumentation SHOULD set the @db.response.status_code@ to the
--     concatenated string of all codes with \'\/\' used as a separator.
--     
--     For example, generic DB instrumentation that detected an error and has
--     SQLSTATE @"42000"@ and vendor-specific @1071@ should set
--     @db.response.status_code@ to @"42000\/1071"@."
--
-- - 'db_storedProcedure_name'
--
--     Requirement level: recommended: If operation applies to a specific stored procedure.
--
-- - 'db_operation_name'
--
--     Requirement level: recommended: If the operation is executed via a higher-level API that does not support multiple operation names.
--
--     ==== Note
--     The operation name SHOULD NOT be extracted from @db.query.text@.
--
-- - 'db_collection_name'
--
--     Requirement level: recommended: If the operation is executed via a higher-level API that does not support multiple collection names.
--
--     ==== Note
--     The collection name SHOULD NOT be extracted from @db.query.text@.
--
-- - 'db_response_returnedRows'
--
--     Requirement level: opt-in
--







-- $span_azure_cosmosdb_client
-- Cosmos DB instrumentations include call-level spans that represent logical database calls and adhere to the general [Semantic Conventions for Database Client Spans](\/docs\/db\/database-spans.md).
--
-- Stability: development
--
-- ==== Note
-- Additional spans representing network calls may also be created depending on the connection mode (Gateway or Direct).
-- Semantic conventions described in this document apply to the call-level spans only.
-- 
-- @db.system.name@ MUST be set to @"azure.cosmosdb"@ and SHOULD be provided __at span creation time__.
-- 
-- __Span name__ SHOULD follow the general [database span name convention](\/docs\/db\/database-spans.md#name)
--
-- === Attributes
-- - 'azure_client_id'
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
-- - 'azure_cosmosdb_connection_mode'
--
--     Requirement level: conditionally required: if not @gateway@ (the default value is assumed to be @gateway@).
--
-- - 'db_collection_name'
--
--     Cosmos DB container name.
--
--     Requirement level: conditionally required: if available
--
--     ==== Note
--     It is RECOMMENDED to capture the value as provided by the application without attempting to do any case normalization.
--
-- - 'azure_cosmosdb_request_body_size'
--
-- - 'db_response_statusCode'
--
--     Cosmos DB status code.
--
--     Requirement level: conditionally required: if response was received
--
--     ==== Note
--     Response codes in the 4xx and 5xx range SHOULD be considered errors.
--
-- - 'db_response_returnedRows'
--
--     Cosmos DB row count in result set.
--
--     Requirement level: conditionally required: if response was received and returned any rows
--
-- - 'azure_cosmosdb_response_subStatusCode'
--
--     Requirement level: conditionally required: when response was received and contained sub-code.
--
-- - 'azure_cosmosdb_operation_requestCharge'
--
--     Requirement level: conditionally required: when available
--
-- - 'db_namespace'
--
--     Requirement level: conditionally required: If available.
--
--     ==== Note
--     
--
-- - 'azure_resourceProvider_namespace'
--
--     ==== Note
--     When @azure.resource_provider.namespace@ attribute is populated, it MUST be set to @Microsoft.DocumentDB@ for all operations performed by Cosmos DB client.
--
-- - 'db_operation_name'
--
--     Requirement level: required
--
--     ==== Note
--     The @db.operation.name@ has the following list of well-known values.
--     If one of them applies, then the respective value MUST be used.
--     
--     Batch operations:
--     
--     - @execute_batch@
--     
--     Bulk operations:
--     
--     - @execute_bulk@ SHOULD be used on spans reported for methods like
--       [@executeBulkOperations@](https:\/\/javadoc.io\/doc\/com.azure\/azure-cosmos\/latest\/com\/azure\/cosmos\/CosmosAsyncContainer.html#executeBulkOperations(reactor.core.publisher.Flux)),
--       which represents a bulk execution of multiple operations.
--     - @bulk_{operation name}@ (@bulk_create_item@, @bulk_upsert_item@, etc) SHOULD be used on spans describing individual operations (when they are reported)
--       within the bulk. This pattern SHOULD be used when instrumentation creates span per each operation, but operations are buffered and then performed in bulk.
--       For example, this applies when [@AllowBulkExecution@](https:\/\/learn.microsoft.com\/dotnet\/api\/microsoft.azure.cosmos.cosmosclientoptions.allowbulkexecution)
--       property is configured on the @Microsoft.Azure.Cosmos@ client.
--     
--     Change feed operations:
--     
--     - @query_change_feed@
--     
--     Conflicts operations:
--     
--     - @delete_conflict@
--     - @query_conflicts@
--     - @read_all_conflicts@
--     - @read_conflict@
--     
--     Container operations:
--     
--     - @create_container@
--     - @create_container_if_not_exists@
--     - @delete_container@
--     - @query_containers@
--     - @read_all_containers@
--     - @read_container@
--     - @read_container_throughput@
--     - @replace_container@
--     - @replace_container_throughput@
--     
--     Database operations:
--     
--     - @create_database@
--     - @create_database_if_not_exists@
--     - @delete_database@
--     - @query_databases@
--     - @read_all_databases@
--     - @read_database@
--     - @read_database_throughput@
--     - @replace_database_throughput@
--     
--     Encryption key operations:
--     
--     - @create_client_encryption_key@
--     - @query_client_encryption_keys@
--     - @read_all_client_encryption_keys@
--     - @read_client_encryption_key@
--     - @replace_client_encryption_key@
--     
--     Item operations:
--     
--     - @create_item@
--     - @delete_all_items_by_partition_key@
--     - @delete_item@
--     - @patch_item@
--     - @query_items@
--     - @read_all_items@
--     - @read_all_items_of_logical_partition@
--     - @read_many_items@
--     - @read_item@
--     - @replace_item@
--     - @upsert_item@
--     
--     Permission operations:
--     
--     - @create_permission@
--     - @delete_permission@
--     - @query_permissions@
--     - @read_all_permissions@
--     - @read_permission@
--     - @replace_permission@
--     - @upsert_permission@
--     
--     Stored procedure operations:
--     
--     - @create_stored_procedure@
--     - @delete_stored_procedure@
--     - @execute_stored_procedure@
--     - @query_stored_procedures@
--     - @read_all_stored_procedures@
--     - @read_stored_procedure@
--     - @replace_stored_procedure@
--     
--     Trigger operations:
--     
--     - @create_trigger@
--     - @delete_trigger@
--     - @query_triggers@
--     - @read_all_triggers@
--     - @read_trigger@
--     - @replace_trigger@
--     
--     User operations:
--     
--     - @create_user@
--     - @delete_user@
--     - @query_users@
--     - @read_all_users@
--     - @read_user@
--     - @replace_user@
--     - @upsert_user@
--     
--     User-defined function operations:
--     
--     - @create_user_defined_function@
--     - @delete_user_defined_function@
--     - @query_user_defined_functions@
--     - @read_all_user_defined_functions@
--     - @read_user_defined_function@
--     
--     If none of them applies, it\'s RECOMMENDED to use language-agnostic representation of
--     client method name in snake_case. Instrumentations SHOULD document
--     additional values when introducing new operations.
--
-- - 'db_storedProcedure_name'
--
--     Requirement level: recommended: If operation applies to a specific stored procedure.
--
-- - 'server_port'
--
--     Requirement level: conditionally required: If not default (443).
--
-- - 'azure_cosmosdb_consistency_level'
--
--     Requirement level: conditionally required: If available.
--
-- - 'azure_cosmosdb_operation_contactedRegions'
--
--     Requirement level: conditionally required: If available.
--
-- - 'db_query_text'
--
-- - 'db_query_parameter'
--
--     Requirement level: opt-in
--



















-- $span_db_oracledb_client
-- Spans representing calls to a Oracle SQL Database adhere to the general [Semantic Conventions for Database Client Spans](database-spans.md).
--
-- Stability: release candidate
--
-- ==== Note
-- @db.system.name@ MUST be set to @"oracle.db"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'db_namespace'
--
--     The unique identifier of the database associated with the connection.
--
--     ==== Note
--     Use the value of @DB_UNIQUE_NAME@ parameter. This defines the database\'s globally unique identifier and must remain unique across the enterprise.
--
-- - 'oracle_db_service'
--
-- - 'oracle_db_instance_name'
--
-- - 'oracle_db_pdb'
--
-- - 'oracle_db_name'
--
-- - 'oracle_db_domain'
--
-- - 'db_response_statusCode'
--
--     [Oracle Database error number](https:\/\/docs.oracle.com\/en\/error-help\/db\/) recorded as a string.
--
--     ==== Note
--     Oracle Database error codes are vendor specific error codes and don\'t follow [SQLSTATE](https:\/\/wikipedia.org\/wiki\/SQLSTATE) conventions. All Oracle Database error codes SHOULD be considered errors.
--
-- - 'db_query_text'
--
--     The database query being executed.
--
--     Requirement level: recommended: Non-parameterized query text SHOULD NOT be collected by default unless explicitly configured and sanitized to exclude sensitive data, e.g. by redacting all literal values present in the query text. See [Sanitization of @db.query.text@](\/docs\/db\/database-spans.md#sanitization-of-dbquerytext). Parameterized query text MUST also NOT be collected by default unless explicitly configured. The query parameter values themselves are opt-in, see [@db.query.parameter.\<key\>@](..\/registry\/attributes\/db.md)).
--
--     ==== Note
--     For sanitization see [Sanitization of @db.query.text@](\/docs\/db\/database-spans.md#sanitization-of-dbquerytext). For batch operations, if the individual operations are known to have the same query text then that query text SHOULD be used, otherwise all of the individual query texts SHOULD be concatenated with separator @; @ or some other database system specific separator if more applicable.
--









-- $attributes_db_client_minimal
-- Database Client attributes
--
-- === Attributes
-- - 'server_address'
--
--     Name of the database host.
--
-- - 'server_port'
--
--     Requirement level: conditionally required: If using a port other than the default port for this DBMS and if @server.address@ is set.
--
-- - 'db_response_statusCode'
--
--     Requirement level: conditionally required: If the operation failed and status code is available.
--
-- - 'error_type'
--
--     Requirement level: conditionally required: If and only if the operation failed.
--
--     ==== Note
--     The @error.type@ SHOULD match the @db.response.status_code@ returned by the database or the client library, or the canonical name of exception that occurred.
--     When using canonical exception type name, instrumentation SHOULD do the best effort to report the most relevant type. For example, if the original exception is wrapped into a generic one, the original exception SHOULD be preferred.
--     Instrumentations SHOULD document how @error.type@ is populated.
--





-- $attributes_azure_cosmosdb_minimal
-- Azure Cosmos DB Client attributes
--
-- Stability: development
--
-- === Attributes
-- - 'db_operation_name'
--
--     Requirement level: required
--
-- - 'db_collection_name'
--
--     Cosmos DB container name.
--
--     Requirement level: conditionally required: If available.
--
-- - 'db_namespace'
--
--     Requirement level: conditionally required: If available.
--
--     ==== Note
--     
--
-- - 'azure_cosmosdb_response_subStatusCode'
--
--     Requirement level: conditionally required: when response was received and contained sub-code.
--
-- - 'azure_cosmosdb_consistency_level'
--
--     Requirement level: conditionally required: If available.
--






-- $attributes_db_client_withQuery
-- This group defines the attributes describing database operations that may have queries.
--
-- === Attributes
-- - 'db_query_text'
--
-- - 'db_query_summary'
--
--     Requirement level: recommended: if available through instrumentation hooks or if the instrumentation supports generating a query summary.
--



-- $attributes_db_client_withQueryAndCollection
-- This group defines the attributes describing database operations that have operation name, collection name and query.
--
-- === Attributes
-- - 'db_operation_name'
--
--     Requirement level: conditionally required: If readily available and if there is a single operation name that describes the database call.
--
-- - 'db_collection_name'
--
--     Requirement level: conditionally required: If readily available and if a database call is performed on a single collection.
--



-- $registry_db
-- This group defines the attributes used to describe telemetry in the context of databases.
--
-- === Attributes
-- - 'db_collection_name'
--
--     Stability: stable
--
-- - 'db_namespace'
--
--     Stability: stable
--
-- - 'db_operation_name'
--
--     Stability: stable
--
-- - 'db_query_text'
--
--     Stability: stable
--
-- - 'db_query_parameter'
--
--     Stability: development
--
-- - 'db_query_summary'
--
--     Stability: stable
--
-- - 'db_storedProcedure_name'
--
--     Stability: stable
--
-- - 'db_operation_parameter'
--
--     Stability: development
--
-- - 'db_operation_batch_size'
--
--     Stability: stable
--
-- - 'db_response_statusCode'
--
--     Stability: stable
--
-- - 'db_response_returnedRows'
--
--     Stability: development
--
-- - 'db_system_name'
--
--     Stability: stable
--
-- - 'db_client_connection_state'
--
--     Stability: development
--
-- - 'db_client_connection_pool_name'
--
--     Stability: development
--

-- |
-- The name of a collection (table, container) within the database.

-- ==== Note
-- It is RECOMMENDED to capture the value as provided by the application
-- without attempting to do any case normalization.
-- 
-- The collection name SHOULD NOT be extracted from @db.query.text@,
-- when the database system supports query text with multiple collections
-- in non-batch operations.
-- 
-- For batch operations, if the individual operations are known to have the same
-- collection name then that collection name SHOULD be used.
db_collection_name :: AttributeKey Text
db_collection_name = AttributeKey "db.collection.name"

-- |
-- The name of the database, fully qualified within the server address and port.

-- ==== Note
-- If a database system has multiple namespace components, they SHOULD be concatenated from the most general to the most specific namespace component, using @|@ as a separator between the components. Any missing components (and their associated separators) SHOULD be omitted.
-- Semantic conventions for individual database systems SHOULD document what @db.namespace@ means in the context of that system.
-- It is RECOMMENDED to capture the value as provided by the application without attempting to do any case normalization.
db_namespace :: AttributeKey Text
db_namespace = AttributeKey "db.namespace"

-- |
-- The name of the operation or command being executed.

-- ==== Note
-- It is RECOMMENDED to capture the value as provided by the application
-- without attempting to do any case normalization.
-- 
-- The operation name SHOULD NOT be extracted from @db.query.text@,
-- when the database system supports query text with multiple operations
-- in non-batch operations.
-- 
-- If spaces can occur in the operation name, multiple consecutive spaces
-- SHOULD be normalized to a single space.
-- 
-- For batch operations, if the individual operations are known to have the same operation name
-- then that operation name SHOULD be used prepended by @BATCH @,
-- otherwise @db.operation.name@ SHOULD be @BATCH@ or some other database
-- system specific term if more applicable.
db_operation_name :: AttributeKey Text
db_operation_name = AttributeKey "db.operation.name"

-- |
-- The database query being executed.

-- ==== Note
-- For sanitization see [Sanitization of @db.query.text@](\/docs\/db\/database-spans.md#sanitization-of-dbquerytext).
-- For batch operations, if the individual operations are known to have the same query text then that query text SHOULD be used, otherwise all of the individual query texts SHOULD be concatenated with separator @; @ or some other database system specific separator if more applicable.
-- Parameterized query text SHOULD NOT be sanitized. Even though parameterized query text can potentially have sensitive data, by using a parameterized query the user is giving a strong signal that any sensitive data will be passed as parameter values, and the benefit to observability of capturing the static part of the query text by default outweighs the risk.
db_query_text :: AttributeKey Text
db_query_text = AttributeKey "db.query.text"

-- |
-- A database query parameter, with @\<key\>@ being the parameter name, and the attribute value being a string representation of the parameter value.

-- ==== Note
-- If a query parameter has no name and instead is referenced only by index,
-- then @\<key\>@ SHOULD be the 0-based index.
-- 
-- @db.query.parameter.\<key\>@ SHOULD match
-- up with the parameterized placeholders present in @db.query.text@.
-- 
-- It is RECOMMENDED to capture the value as provided by the application
-- without attempting to do any case normalization.
-- 
-- @db.query.parameter.\<key\>@ SHOULD NOT be captured on batch operations.
-- 
-- Examples:
-- 
-- - For a query @SELECT * FROM users where username =  %s@ with the parameter @"jdoe"@,
--   the attribute @db.query.parameter.0@ SHOULD be set to @"jdoe"@.
-- 
-- - For a query @"SELECT * FROM users WHERE username = %(userName)s;@ with parameter
--   @userName = "jdoe"@, the attribute @db.query.parameter.userName@ SHOULD be set to @"jdoe"@.
db_query_parameter :: Text -> AttributeKey Text
db_query_parameter = \k -> AttributeKey $ "db.query.parameter." <> k

-- |
-- Low cardinality summary of a database query.

-- ==== Note
-- The query summary describes a class of database queries and is useful
-- as a grouping key, especially when analyzing telemetry for database
-- calls involving complex queries.
-- 
-- Summary may be available to the instrumentation through
-- instrumentation hooks or other means. If it is not available, instrumentations
-- that support query parsing SHOULD generate a summary following
-- [Generating query summary](\/docs\/db\/database-spans.md#generating-a-summary-of-the-query)
-- section.
-- 
-- For batch operations, if the individual operations are known to have the same query summary
-- then that query summary SHOULD be used prepended by @BATCH @,
-- otherwise @db.query.summary@ SHOULD be @BATCH@ or some other database
-- system specific term if more applicable.
db_query_summary :: AttributeKey Text
db_query_summary = AttributeKey "db.query.summary"

-- |
-- The name of a stored procedure within the database.

-- ==== Note
-- It is RECOMMENDED to capture the value as provided by the application
-- without attempting to do any case normalization.
-- 
-- For batch operations, if the individual operations are known to have the same
-- stored procedure name then that stored procedure name SHOULD be used.
db_storedProcedure_name :: AttributeKey Text
db_storedProcedure_name = AttributeKey "db.stored_procedure.name"

-- |
-- A database operation parameter, with @\<key\>@ being the parameter name, and the attribute value being a string representation of the parameter value.

-- ==== Note
-- For example, a client-side maximum number of rows to read from the database
-- MAY be recorded as the @db.operation.parameter.max_rows@ attribute.
-- 
-- @db.query.text@ parameters SHOULD be captured using @db.query.parameter.\<key\>@
-- instead of @db.operation.parameter.\<key\>@.
db_operation_parameter :: Text -> AttributeKey Text
db_operation_parameter = \k -> AttributeKey $ "db.operation.parameter." <> k

-- |
-- The number of queries included in a batch operation.

-- ==== Note
-- Operations are only considered batches when they contain two or more operations, and so @db.operation.batch.size@ SHOULD never be @1@.
db_operation_batch_size :: AttributeKey Int64
db_operation_batch_size = AttributeKey "db.operation.batch.size"

-- |
-- Database response status code.

-- ==== Note
-- The status code returned by the database. Usually it represents an error code, but may also represent partial success, warning, or differentiate between various types of successful outcomes.
-- Semantic conventions for individual database systems SHOULD document what @db.response.status_code@ means in the context of that system.
db_response_statusCode :: AttributeKey Text
db_response_statusCode = AttributeKey "db.response.status_code"

-- |
-- Number of rows returned by the operation.
db_response_returnedRows :: AttributeKey Int64
db_response_returnedRows = AttributeKey "db.response.returned_rows"

-- |
-- The database management system (DBMS) product as identified by the client instrumentation.

-- ==== Note
-- The actual DBMS may differ from the one identified by the client. For example, when using PostgreSQL client libraries to connect to a CockroachDB, the @db.system.name@ is set to @postgresql@ based on the instrumentation\'s best knowledge.
db_system_name :: AttributeKey Text
db_system_name = AttributeKey "db.system.name"

-- |
-- The state of a connection in the pool
db_client_connection_state :: AttributeKey Text
db_client_connection_state = AttributeKey "db.client.connection.state"

-- |
-- The name of the connection pool; unique within the instrumented application. In case the connection pool implementation doesn\'t provide a name, instrumentation SHOULD use a combination of parameters that would make the name unique, for example, combining attributes @server.address@, @server.port@, and @db.namespace@, formatted as @server.address:server.port\/db.namespace@. Instrumentations that generate connection pool name following different patterns SHOULD document it.
db_client_connection_pool_name :: AttributeKey Text
db_client_connection_pool_name = AttributeKey "db.client.connection.pool.name"

-- $metric_db_client_operation_duration
-- Duration of database client operations.
--
-- Stability: stable
--
-- ==== Note
-- Batch operations SHOULD be recorded as a single operation.
--
-- === Attributes
-- - 'db_system_name'
--
--     Requirement level: required
--
-- - 'db_storedProcedure_name'
--
--     Requirement level: recommended: If operation applies to a specific stored procedure.
--
-- - 'network_peer_address'
--
--     Peer address of the database node where the operation was performed.
--
--     Requirement level: recommended: If applicable for this database system.
--
--     ==== Note
--     Semantic conventions for individual database systems SHOULD document whether @network.peer.*@ attributes are applicable. Network peer address and port are useful when the application interacts with individual database nodes directly.
--     If a database operation involved multiple network calls (for example retries), the address of the last contacted node SHOULD be used.
--
-- - 'network_peer_port'
--
--     Requirement level: recommended: If and only if @network.peer.address@ is set.
--
-- - 'db_namespace'
--
--     Requirement level: conditionally required: If available.
--
-- - 'db_query_text'
--
--     Requirement level: opt-in
--







-- $metric_db_client_connection_count
-- The number of connections that are currently in state described by the @state@ attribute.
--
-- Stability: development
--
-- === Attributes
-- - 'db_client_connection_state'
--
--     Requirement level: required
--
-- - 'db_client_connection_pool_name'
--
--     Requirement level: required
--



-- $metric_db_client_connection_idle_max
-- The maximum number of idle open connections allowed.
--
-- Stability: development
--
-- === Attributes
-- - 'db_client_connection_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_connection_idle_min
-- The minimum number of idle open connections allowed.
--
-- Stability: development
--
-- === Attributes
-- - 'db_client_connection_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_connection_max
-- The maximum number of open connections allowed.
--
-- Stability: development
--
-- === Attributes
-- - 'db_client_connection_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_connection_pendingRequests
-- The number of current pending requests for an open connection.
--
-- Stability: development
--
-- === Attributes
-- - 'db_client_connection_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_connection_timeouts
-- The number of connection timeouts that have occurred trying to obtain a connection from the pool.
--
-- Stability: development
--
-- === Attributes
-- - 'db_client_connection_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_connection_createTime
-- The time it took to create a new connection.
--
-- Stability: development
--
-- === Attributes
-- - 'db_client_connection_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_connection_waitTime
-- The time it took to obtain an open connection from the pool.
--
-- Stability: development
--
-- === Attributes
-- - 'db_client_connection_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_connection_useTime
-- The time between borrowing a connection and returning it to the pool.
--
-- Stability: development
--
-- === Attributes
-- - 'db_client_connection_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_response_returnedRows
-- The actual number of records returned by the database operation.
--
-- Stability: development
--
-- === Attributes
-- - 'db_system_name'
--
--     Requirement level: required
--
-- - 'network_peer_address'
--
--     Peer address of the database node where the operation was performed.
--
--     Requirement level: recommended: If applicable for this database system.
--
--     ==== Note
--     Semantic conventions for individual database systems SHOULD document whether @network.peer.*@ attributes are applicable. Network peer address and port are useful when the application interacts with individual database nodes directly.
--     If a database operation involved multiple network calls (for example retries), the address of the last contacted node SHOULD be used.
--
-- - 'network_peer_port'
--
--     Requirement level: recommended: If and only if @network.peer.address@ is set.
--
-- - 'db_namespace'
--
--     Requirement level: conditionally required: If available.
--
-- - 'db_query_text'
--
--     Requirement level: opt-in
--






-- $event_db_client_operation_exception
-- This event represents an exception that occurred during a database client operation, such as connection failures, query errors, timeouts, or other errors that prevent the operation from completing successfully.
--
-- Stability: development
--
-- ==== Note
-- This event SHOULD be recorded when an exception occurs during database client operations.
-- Instrumentations SHOULD set the severity to WARN (severity number 13) when recording this event.
-- Instrumentations MAY provide a configuration option to populate exception events with the attributes captured on the corresponding database client span.
--
-- === Attributes
-- - 'exception_type'
--
--     Requirement level: conditionally required: Required if @exception.message@ is not set, recommended otherwise.
--
-- - 'exception_message'
--
--     Requirement level: conditionally required: Required if @exception.type@ is not set, recommended otherwise.
--
-- - 'exception_stacktrace'
--




-- $registry_db_deprecated
-- Describes deprecated database attributes.
--
-- Stability: development
--
-- === Attributes
-- - 'db_connectionString'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'db_jdbc_driverClassname'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'db_operation'
--
--     Stability: development
--
--     Deprecated: renamed: db.operation.name
--
-- - 'db_user'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'db_statement'
--
--     Stability: development
--
--     Deprecated: renamed: db.query.text
--
-- - 'db_cassandra_table'
--
--     Stability: development
--
--     Deprecated: renamed: db.collection.name
--
-- - 'db_cosmosdb_container'
--
--     Stability: development
--
--     Deprecated: renamed: db.collection.name
--
-- - 'db_mongodb_collection'
--
--     Stability: development
--
--     Deprecated: renamed: db.collection.name
--
-- - 'db_sql_table'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'db_redis_databaseIndex'
--
--     Stability: development
--
--     Deprecated: uncategorized: Use `db.namespace` instead.
--
-- - 'db_name'
--
--     Stability: development
--
--     Deprecated: renamed: db.namespace
--
-- - 'db_mssql_instanceName'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'db_instance_id'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'db_elasticsearch_cluster_name'
--
--     Stability: development
--
--     Deprecated: renamed: db.namespace
--
-- - 'db_cosmosdb_statusCode'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'db_cosmosdb_operationType'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'db_cassandra_coordinator_dc'
--
--     Stability: development
--
--     Deprecated: renamed: cassandra.coordinator.dc
--
-- - 'db_cassandra_coordinator_id'
--
--     Stability: development
--
--     Deprecated: renamed: cassandra.coordinator.id
--
-- - 'db_cassandra_consistencyLevel'
--
--     Stability: development
--
--     Deprecated: renamed: cassandra.consistency.level
--
-- - 'db_cassandra_idempotence'
--
--     Stability: development
--
--     Deprecated: renamed: cassandra.query.idempotent
--
-- - 'db_cassandra_pageSize'
--
--     Stability: development
--
--     Deprecated: renamed: cassandra.page.size
--
-- - 'db_cassandra_speculativeExecutionCount'
--
--     Stability: development
--
--     Deprecated: renamed: cassandra.speculative_execution.count
--
-- - 'db_cosmosdb_clientId'
--
--     Stability: development
--
--     Deprecated: renamed: azure.client.id
--
-- - 'db_cosmosdb_connectionMode'
--
--     Stability: development
--
--     Deprecated: renamed: azure.cosmosdb.connection.mode
--
-- - 'db_cosmosdb_requestCharge'
--
--     Stability: development
--
--     Deprecated: renamed: azure.cosmosdb.operation.request_charge
--
-- - 'db_cosmosdb_requestContentLength'
--
--     Stability: development
--
--     Deprecated: renamed: azure.cosmosdb.request.body.size
--
-- - 'db_cosmosdb_subStatusCode'
--
--     Stability: development
--
--     Deprecated: renamed: azure.cosmosdb.response.sub_status_code
--
-- - 'db_cosmosdb_consistencyLevel'
--
--     Stability: development
--
--     Deprecated: renamed: azure.cosmosdb.consistency.level
--
-- - 'db_cosmosdb_regionsContacted'
--
--     Stability: development
--
--     Deprecated: renamed: azure.cosmosdb.operation.contacted_regions
--
-- - 'db_elasticsearch_node_name'
--
--     Stability: development
--
--     Deprecated: renamed: elasticsearch.node.name
--
-- - 'db_elasticsearch_pathParts'
--
--     Stability: development
--
--     Deprecated: renamed: db.operation.parameter
--
-- - 'db_system'
--
--     Stability: development
--
--     Deprecated: renamed: db.system.name
--

-- |
-- Deprecated, use @server.address@, @server.port@ attributes instead.
db_connectionString :: AttributeKey Text
db_connectionString = AttributeKey "db.connection_string"

-- |
-- Removed, no replacement at this time.
db_jdbc_driverClassname :: AttributeKey Text
db_jdbc_driverClassname = AttributeKey "db.jdbc.driver_classname"

-- |
-- Deprecated, use @db.operation.name@ instead.
db_operation :: AttributeKey Text
db_operation = AttributeKey "db.operation"

-- |
-- Deprecated, no replacement at this time.
db_user :: AttributeKey Text
db_user = AttributeKey "db.user"

-- |
-- The database statement being executed.
db_statement :: AttributeKey Text
db_statement = AttributeKey "db.statement"

-- |
-- Deprecated, use @db.collection.name@ instead.
db_cassandra_table :: AttributeKey Text
db_cassandra_table = AttributeKey "db.cassandra.table"

-- |
-- Deprecated, use @db.collection.name@ instead.
db_cosmosdb_container :: AttributeKey Text
db_cosmosdb_container = AttributeKey "db.cosmosdb.container"

-- |
-- Deprecated, use @db.collection.name@ instead.
db_mongodb_collection :: AttributeKey Text
db_mongodb_collection = AttributeKey "db.mongodb.collection"

-- |
-- Deprecated, use @db.collection.name@ instead.
db_sql_table :: AttributeKey Text
db_sql_table = AttributeKey "db.sql.table"

-- |
-- Deprecated, use @db.namespace@ instead.
db_redis_databaseIndex :: AttributeKey Int64
db_redis_databaseIndex = AttributeKey "db.redis.database_index"

-- |
-- Deprecated, use @db.namespace@ instead.
db_name :: AttributeKey Text
db_name = AttributeKey "db.name"

-- |
-- Deprecated, SQL Server instance is now populated as a part of @db.namespace@ attribute.
db_mssql_instanceName :: AttributeKey Text
db_mssql_instanceName = AttributeKey "db.mssql.instance_name"

-- |
-- Deprecated, no general replacement at this time. For Elasticsearch, use @db.elasticsearch.node.name@ instead.
db_instance_id :: AttributeKey Text
db_instance_id = AttributeKey "db.instance.id"

-- |
-- Deprecated, use @db.namespace@ instead.
db_elasticsearch_cluster_name :: AttributeKey Text
db_elasticsearch_cluster_name = AttributeKey "db.elasticsearch.cluster.name"

-- |
-- Deprecated, use @db.response.status_code@ instead.
db_cosmosdb_statusCode :: AttributeKey Int64
db_cosmosdb_statusCode = AttributeKey "db.cosmosdb.status_code"

-- |
-- Deprecated, no replacement at this time.
db_cosmosdb_operationType :: AttributeKey Text
db_cosmosdb_operationType = AttributeKey "db.cosmosdb.operation_type"

-- |
-- Deprecated, use @cassandra.coordinator.dc@ instead.
db_cassandra_coordinator_dc :: AttributeKey Text
db_cassandra_coordinator_dc = AttributeKey "db.cassandra.coordinator.dc"

-- |
-- Deprecated, use @cassandra.coordinator.id@ instead.
db_cassandra_coordinator_id :: AttributeKey Text
db_cassandra_coordinator_id = AttributeKey "db.cassandra.coordinator.id"

-- |
-- Deprecated, use @cassandra.consistency.level@ instead.
db_cassandra_consistencyLevel :: AttributeKey Text
db_cassandra_consistencyLevel = AttributeKey "db.cassandra.consistency_level"

-- |
-- Deprecated, use @cassandra.query.idempotent@ instead.
db_cassandra_idempotence :: AttributeKey Bool
db_cassandra_idempotence = AttributeKey "db.cassandra.idempotence"

-- |
-- Deprecated, use @cassandra.page.size@ instead.
db_cassandra_pageSize :: AttributeKey Int64
db_cassandra_pageSize = AttributeKey "db.cassandra.page_size"

-- |
-- Deprecated, use @cassandra.speculative_execution.count@ instead.
db_cassandra_speculativeExecutionCount :: AttributeKey Int64
db_cassandra_speculativeExecutionCount = AttributeKey "db.cassandra.speculative_execution_count"

-- |
-- Deprecated, use @azure.client.id@ instead.
db_cosmosdb_clientId :: AttributeKey Text
db_cosmosdb_clientId = AttributeKey "db.cosmosdb.client_id"

-- |
-- Deprecated, use @azure.cosmosdb.connection.mode@ instead.
db_cosmosdb_connectionMode :: AttributeKey Text
db_cosmosdb_connectionMode = AttributeKey "db.cosmosdb.connection_mode"

-- |
-- Deprecated, use @azure.cosmosdb.operation.request_charge@ instead.
db_cosmosdb_requestCharge :: AttributeKey Double
db_cosmosdb_requestCharge = AttributeKey "db.cosmosdb.request_charge"

-- |
-- Deprecated, use @azure.cosmosdb.request.body.size@ instead.
db_cosmosdb_requestContentLength :: AttributeKey Int64
db_cosmosdb_requestContentLength = AttributeKey "db.cosmosdb.request_content_length"

-- |
-- Deprecated, use @azure.cosmosdb.response.sub_status_code@ instead.
db_cosmosdb_subStatusCode :: AttributeKey Int64
db_cosmosdb_subStatusCode = AttributeKey "db.cosmosdb.sub_status_code"

-- |
-- Deprecated, use @cosmosdb.consistency.level@ instead.
db_cosmosdb_consistencyLevel :: AttributeKey Text
db_cosmosdb_consistencyLevel = AttributeKey "db.cosmosdb.consistency_level"

-- |
-- Deprecated, use @azure.cosmosdb.operation.contacted_regions@ instead.
db_cosmosdb_regionsContacted :: AttributeKey [Text]
db_cosmosdb_regionsContacted = AttributeKey "db.cosmosdb.regions_contacted"

-- |
-- Deprecated, use @elasticsearch.node.name@ instead.
db_elasticsearch_node_name :: AttributeKey Text
db_elasticsearch_node_name = AttributeKey "db.elasticsearch.node.name"

-- |
-- Deprecated, use @db.operation.parameter@ instead.
db_elasticsearch_pathParts :: Text -> AttributeKey Text
db_elasticsearch_pathParts = \k -> AttributeKey $ "db.elasticsearch.path_parts." <> k

-- |
-- Deprecated, use @db.system.name@ instead.
db_system :: AttributeKey Text
db_system = AttributeKey "db.system"

-- $registry_db_metrics_deprecated
-- Describes deprecated db metrics attributes.
--
-- Stability: development
--
-- === Attributes
-- - 'state'
--
--     Stability: development
--
--     Deprecated: renamed: db.client.connection.state
--
-- - 'pool_name'
--
--     Stability: development
--
--     Deprecated: renamed: db.client.connection.pool.name
--
-- - 'db_client_connections_state'
--
--     Stability: development
--
--     Deprecated: renamed: db.client.connection.state
--
-- - 'db_client_connections_pool_name'
--
--     Stability: development
--
--     Deprecated: renamed: db.client.connection.pool.name
--

-- |
-- Deprecated, use @db.client.connection.state@ instead.
state :: AttributeKey Text
state = AttributeKey "state"

-- |
-- Deprecated, use @db.client.connection.pool.name@ instead.
pool_name :: AttributeKey Text
pool_name = AttributeKey "pool.name"

-- |
-- Deprecated, use @db.client.connection.state@ instead.
db_client_connections_state :: AttributeKey Text
db_client_connections_state = AttributeKey "db.client.connections.state"

-- |
-- Deprecated, use @db.client.connection.pool.name@ instead.
db_client_connections_pool_name :: AttributeKey Text
db_client_connections_pool_name = AttributeKey "db.client.connections.pool.name"

-- $metric_db_client_connections_usage
-- Deprecated, use @db.client.connection.count@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: db.client.connection.count
--
-- === Attributes
-- - 'db_client_connections_state'
--
--     Requirement level: required
--
-- - 'db_client_connections_pool_name'
--
--     Requirement level: required
--



-- $metric_db_client_connections_idle_max
-- Deprecated, use @db.client.connection.idle.max@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: db.client.connection.idle.max
--
-- === Attributes
-- - 'db_client_connections_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_connections_idle_min
-- Deprecated, use @db.client.connection.idle.min@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: db.client.connection.idle.min
--
-- === Attributes
-- - 'db_client_connections_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_connections_max
-- Deprecated, use @db.client.connection.max@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: db.client.connection.max
--
-- === Attributes
-- - 'db_client_connections_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_connections_pendingRequests
-- Deprecated, use @db.client.connection.pending_requests@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: db.client.connection.pending_requests
--
-- === Attributes
-- - 'db_client_connections_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_connections_timeouts
-- Deprecated, use @db.client.connection.timeouts@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: db.client.connection.timeouts
--
-- === Attributes
-- - 'db_client_connections_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_connections_createTime
-- Deprecated, use @db.client.connection.create_time@ instead. Note: the unit also changed from @ms@ to @s@.
--
-- Stability: development
--
-- Deprecated: uncategorized
--
-- === Attributes
-- - 'db_client_connections_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_connections_waitTime
-- Deprecated, use @db.client.connection.wait_time@ instead. Note: the unit also changed from @ms@ to @s@.
--
-- Stability: development
--
-- Deprecated: uncategorized
--
-- === Attributes
-- - 'db_client_connections_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_connections_useTime
-- Deprecated, use @db.client.connection.use_time@ instead. Note: the unit also changed from @ms@ to @s@.
--
-- Stability: development
--
-- Deprecated: uncategorized
--
-- === Attributes
-- - 'db_client_connections_pool_name'
--
--     Requirement level: required
--


-- $metric_db_client_cosmosdb_operation_requestCharge
-- Deprecated, use @azure.cosmosdb.client.operation.request_charge@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: azure.cosmosdb.client.operation.request_charge
--
-- === Attributes
-- - 'db_operation_name'
--
--     Requirement level: conditionally required: If readily available and if there is a single operation name that describes the database call. The operation name MAY be parsed from the query text, in which case it SHOULD be the single operation name found in the query.
--
-- - 'db_collection_name'
--
--     Cosmos DB container name.
--
--     Requirement level: conditionally required: If available.
--
-- - 'db_namespace'
--
--     Requirement level: conditionally required: If available.
--
--     ==== Note
--     
--
-- - 'db_cosmosdb_subStatusCode'
--
--     Requirement level: conditionally required: when response was received and contained sub-code.
--
-- - 'db_cosmosdb_consistencyLevel'
--
--     Requirement level: conditionally required: If available.
--
-- - 'db_cosmosdb_regionsContacted'
--
--     Requirement level: recommended: If available
--







-- $metric_db_client_cosmosdb_activeInstance_count
-- Deprecated, use @azure.cosmosdb.client.active_instance.count@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: azure.cosmosdb.client.active_instance.count
--
-- === Attributes
-- - 'server_address'
--
--     Name of the database host.
--
-- - 'server_port'
--
--     Requirement level: conditionally required: If using a port other than the default port for this DBMS and if @server.address@ is set.
--



-- $log_record
-- The attributes described in this section are rather generic. They may be used in any Log Record they apply to.
--
-- === Attributes
-- - 'log_record_uid'
--
--     Requirement level: opt-in
--
-- - 'log_record_original'
--
--     Requirement level: opt-in
--



-- $attributes_log
-- Describes Log attributes
--
-- === Attributes
-- - 'log_iostream'
--
--     Requirement level: opt-in
--


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





-- $registry_log
-- This document defines log attributes
--
-- === Attributes
-- - 'log_iostream'
--
--     Stability: development
--

-- |
-- The stream associated with the log. See below for a list of well-known values.
log_iostream :: AttributeKey Text
log_iostream = AttributeKey "log.iostream"

-- $registry_log_file
-- Attributes for a file to which log was emitted.
--
-- === Attributes
-- - 'log_file_name'
--
--     Stability: development
--
-- - 'log_file_path'
--
--     Stability: development
--
-- - 'log_file_nameResolved'
--
--     Stability: development
--
-- - 'log_file_pathResolved'
--
--     Stability: development
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

-- $registry_log_record
-- This document defines the generic attributes that may be used in any Log Record.
--
-- === Attributes
-- - 'log_record_uid'
--
--     Stability: development
--
-- - 'log_record_original'
--
--     Stability: development
--

-- |
-- A unique identifier for the Log Record.

-- ==== Note
-- If an id is provided, other log records with the same id will be considered duplicates and can be removed safely. This means, that two distinguishable log records MUST have different values.
-- The id MAY be an [Universally Unique Lexicographically Sortable Identifier (ULID)](https:\/\/github.com\/ulid\/spec), but other identifiers (e.g. UUID) may be used as needed.
log_record_uid :: AttributeKey Text
log_record_uid = AttributeKey "log.record.uid"

-- |
-- The complete original Log Record.

-- ==== Note
-- This value MAY be added when processing a Log Record which was originally transmitted as a string or equivalent data type AND the Body field of the Log Record does not contain the same value. (e.g. a syslog or a log record read from a file.)
log_record_original :: AttributeKey Text
log_record_original = AttributeKey "log.record.original"

-- $registry_disk
-- These attributes may be used for any disk related operation.
--
-- === Attributes
-- - 'disk_io_direction'
--
--     Stability: development
--

-- |
-- The disk IO operation direction.
disk_io_direction :: AttributeKey Text
disk_io_direction = AttributeKey "disk.io.direction"

-- $registry_artifact
-- This group describes attributes specific to artifacts. Artifacts are files or other immutable objects that are intended for distribution. This definition aligns directly with the [SLSA](https:\/\/slsa.dev\/spec\/v1.0\/terminology#package-model) package model.
--
-- === Attributes
-- - 'artifact_filename'
--
--     Stability: development
--
-- - 'artifact_version'
--
--     Stability: development
--
-- - 'artifact_purl'
--
--     Stability: development
--
-- - 'artifact_hash'
--
--     Stability: development
--
-- - 'artifact_attestation_id'
--
--     Stability: development
--
-- - 'artifact_attestation_filename'
--
--     Stability: development
--
-- - 'artifact_attestation_hash'
--
--     Stability: development
--

-- |
-- The human readable file name of the artifact, typically generated during build and release processes. Often includes the package name and version in the file name.

-- ==== Note
-- This file name can also act as the [Package Name](https:\/\/slsa.dev\/spec\/v1.0\/terminology#package-model)
-- in cases where the package ecosystem maps accordingly.
-- Additionally, the artifact [can be published](https:\/\/slsa.dev\/spec\/v1.0\/terminology#software-supply-chain)
-- for others, but that is not a guarantee.
artifact_filename :: AttributeKey Text
artifact_filename = AttributeKey "artifact.filename"

-- |
-- The version of the artifact.
artifact_version :: AttributeKey Text
artifact_version = AttributeKey "artifact.version"

-- |
-- The [Package URL](https:\/\/github.com\/package-url\/purl-spec) of the [package artifact](https:\/\/slsa.dev\/spec\/v1.0\/terminology#package-model) provides a standard way to identify and locate the packaged artifact.
artifact_purl :: AttributeKey Text
artifact_purl = AttributeKey "artifact.purl"

-- |
-- The full [hash value (see glossary)](https:\/\/nvlpubs.nist.gov\/nistpubs\/FIPS\/NIST.FIPS.186-5.pdf), often found in checksum.txt on a release of the artifact and used to verify package integrity.

-- ==== Note
-- The specific algorithm used to create the cryptographic hash value is
-- not defined. In situations where an artifact has multiple
-- cryptographic hashes, it is up to the implementer to choose which
-- hash value to set here; this should be the most secure hash algorithm
-- that is suitable for the situation and consistent with the
-- corresponding attestation. The implementer can then provide the other
-- hash values through an additional set of attribute extensions as they
-- deem necessary.
artifact_hash :: AttributeKey Text
artifact_hash = AttributeKey "artifact.hash"

-- |
-- The id of the build [software attestation](https:\/\/slsa.dev\/attestation-model).
artifact_attestation_id :: AttributeKey Text
artifact_attestation_id = AttributeKey "artifact.attestation.id"

-- |
-- The provenance filename of the built attestation which directly relates to the build artifact filename. This filename SHOULD accompany the artifact at publish time. See the [SLSA Relationship](https:\/\/slsa.dev\/spec\/v1.0\/distributing-provenance#relationship-between-artifacts-and-attestations) specification for more information.
artifact_attestation_filename :: AttributeKey Text
artifact_attestation_filename = AttributeKey "artifact.attestation.filename"

-- |
-- The full [hash value (see glossary)](https:\/\/nvlpubs.nist.gov\/nistpubs\/FIPS\/NIST.FIPS.186-5.pdf), of the built attestation. Some envelopes in the [software attestation space](https:\/\/github.com\/in-toto\/attestation\/tree\/main\/spec) also refer to this as the __digest__.
artifact_attestation_hash :: AttributeKey Text
artifact_attestation_hash = AttributeKey "artifact.attestation.hash"

-- $entity_device
-- The device on which the process represented by this resource is running.
--
-- Stability: development
--
-- === Attributes
-- - 'device_id'
--
--     Requirement level: opt-in
--
-- - 'device_manufacturer'
--
-- - 'device_model_identifier'
--
-- - 'device_model_name'
--





-- $registry_device
-- Describes device attributes.
--
-- === Attributes
-- - 'device_id'
--
--     Stability: development
--
-- - 'device_manufacturer'
--
--     Stability: development
--
-- - 'device_model_identifier'
--
--     Stability: development
--
-- - 'device_model_name'
--
--     Stability: development
--

-- |
-- A unique identifier representing the device

-- ==== Note
-- Its value SHOULD be identical for all apps on a device and it SHOULD NOT change if an app is uninstalled and re-installed.
-- However, it might be resettable by the user for all apps on a device.
-- Hardware IDs (e.g. vendor-specific serial number, IMEI or MAC address) MAY be used as values.
-- 
-- More information about Android identifier best practices can be found in the [Android user data IDs guide](https:\/\/developer.android.com\/training\/articles\/user-data-ids).
-- 
-- \> [!WARNING]
-- \>
-- \> This attribute may contain sensitive (PII) information. Caution should be taken when storing personal data or anything which can identify a user. GDPR and data protection laws may apply,
-- \> ensure you do your own due diligence.
-- \>
-- \> Due to these reasons, this identifier is not recommended for consumer applications and will likely result in rejection from both Google Play and App Store.
-- \> However, it may be appropriate for specific enterprise scenarios, such as kiosk devices or enterprise-managed devices, with appropriate compliance clearance.
-- \> Any instrumentation providing this identifier MUST implement it as an opt-in feature.
-- \>
-- \> See [@app.installation.id@](\/docs\/registry\/attributes\/app.md#app-installation-id) for a more privacy-preserving alternative.
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

-- $event_device_app_lifecycle
-- This event represents an occurrence of a lifecycle transition on Android or iOS platform.
--
-- Stability: development
--
-- ==== Note
-- The event body fields MUST be used to describe the state of the application at the time of the event.
-- This event is meant to be used in conjunction with @os.name@ [resource semantic convention](\/docs\/resource\/os.md) to identify the mobile operating system (e.g. Android, iOS).
-- The @android.app.state@ and @ios.app.state@ fields are mutually exclusive and MUST NOT be used together, each field MUST be used with its corresponding @os.name@ value.
--
-- === Attributes
-- - 'ios_app_state'
--
--     Requirement level: conditionally required: if and only if @os.name@ is @ios@
--
-- - 'android_app_state'
--
--     Requirement level: conditionally required: if and only if @os.name@ is @android@
--



-- $entity_os
-- The operating system (OS) on which the process represented by this resource is running.
--
-- Stability: development
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
--     ==== Note
--     @build_id@ values SHOULD be obtained from the following sources:
--     
--     | OS | Primary | Fallback |
--     | ------- | ------- | ------- |
--     | Windows | @CurrentBuildNumber@ from registry @HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion@ | - |
--     | MacOS | @ProductBuildVersion@ from @\/System\/Library\/CoreServices\/SystemVersion.plist@ | @ProductBuildVersion@ from @\/System\/Library\/CoreServices\/ServerVersion.plist@ |
--     | Linux | @BUILD_ID@ from @\/etc\/os-release@ | @BUILD_ID@ from @\/usr\/lib\/os-release@; \<br\> contents of @\/proc\/sys\/kernel\/osrelease@ |
--






-- $registry_os
-- The operating system (OS) on which the process represented by this resource is running.
--
-- ==== Note
-- In case of virtualized environments, this is the operating system as it is observed by the process, i.e., the virtualized guest rather than the underlying host.
--
-- === Attributes
-- - 'os_type'
--
--     Stability: development
--
-- - 'os_description'
--
--     Stability: development
--
-- - 'os_name'
--
--     Stability: development
--
-- - 'os_version'
--
--     Stability: development
--
-- - 'os_buildId'
--
--     Stability: development
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

-- $entity_aws_log
-- Entities specific to Amazon Web Services.
--
-- Stability: development
--
-- === Attributes
-- - 'aws_log_group_names'
--
--     Requirement level: recommended
--
-- - 'aws_log_group_arns'
--
--     Requirement level: recommended
--
-- - 'aws_log_stream_names'
--
--     Requirement level: recommended
--
-- - 'aws_log_stream_arns'
--
--     Requirement level: recommended
--





-- $span_aws_client
-- This span describes an AWS SDK client call.
--
-- Stability: development
--
-- ==== Note
-- __Span name__ MUST be of the format @Service.Operation@ as per the
-- AWS HTTP API, e.g., @DynamoDB.GetItem@, @S3.ListBuckets@. This is
-- equivalent to concatenating @rpc.service@ and @rpc.method@ with @.@ and
-- consistent with the naming guidelines for RPC client spans.
-- 
-- AWS SDK span attributes are based on the request or response parameters
-- in AWS SDK API calls. The conventions have been collected over time based
-- on feedback from AWS users of tracing and will continue to increase as new
-- interesting conventions are found.
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
--     ==== Note
--     
--
-- - 'rpc_method'
--
--     The name of the operation corresponding to the request, as returned by the AWS SDK
--
--     ==== Note
--     
--
-- - 'aws_requestId'
--
--     Requirement level: recommended
--
-- - 'aws_extendedRequestId'
--
--     Requirement level: conditionally required: If available.
--
-- - 'cloud_region'
--
--     The AWS Region where the requested service is being accessed.
--
--     Requirement level: recommended
--
--     ==== Note
--     Specifies the AWS Region that the SDK client targets for a given AWS service call. The attribute\'s value should adhere to the AWS Region codes outlined in the [AWS documentation](https:\/\/docs.aws.amazon.com\/global-infrastructure\/latest\/regions\/aws-regions.html#available-regions).
--







-- $span_dynamodb_batchgetitem_client
-- This span represents a @DynamoDB.BatchGetItem@ call.
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"aws.dynamodb"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_consumedCapacity'
--
--     Requirement level: recommended
--



-- $span_dynamodb_batchwriteitem_client
-- This span represents a @DynamoDB.BatchWriteItem@ call.
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"aws.dynamodb"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_consumedCapacity'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_itemCollectionMetrics'
--
--     Requirement level: recommended
--




-- $span_dynamodb_createtable_client
-- This span represents a @DynamoDB.CreateTable@ call.
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"aws.dynamodb"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'aws_dynamodb_globalSecondaryIndexes'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_localSecondaryIndexes'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_consumedCapacity'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_itemCollectionMetrics'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_provisionedReadCapacity'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_provisionedWriteCapacity'
--
--     Requirement level: recommended
--








-- $span_dynamodb_deleteitem_client
-- This span represents a @DynamoDB.DeleteItem@ call.
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"aws.dynamodb"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_consumedCapacity'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_itemCollectionMetrics'
--
--     Requirement level: recommended
--




-- $span_dynamodb_deletetable_client
-- This span represents a @DynamoDB.DeleteTable@ call.
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"aws.dynamodb"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
--     Requirement level: recommended
--


-- $span_dynamodb_describetable_client
-- This span represents a @DynamoDB.DescribeTable@ call.
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"aws.dynamodb"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
--     Requirement level: recommended
--


-- $span_dynamodb_getitem_client
-- This span represents a @DynamoDB.GetItem@ call.
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"aws.dynamodb"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_consumedCapacity'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_consistentRead'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_projection'
--
--     Requirement level: recommended
--





-- $span_dynamodb_listtables_client
-- This span represents a @DynamoDB.ListTables@ call.
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"aws.dynamodb"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'aws_dynamodb_exclusiveStartTable'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_tableCount'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_limit'
--
--     Requirement level: recommended
--




-- $span_dynamodb_putitem_client
-- This span represents a @DynamoDB.PutItem@ call.
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"aws.dynamodb"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_consumedCapacity'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_itemCollectionMetrics'
--
--     Requirement level: recommended
--




-- $span_dynamodb_query_client
-- This span represents a @DynamoDB.Query@ call.
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"aws.dynamodb"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'aws_dynamodb_scanForward'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_consumedCapacity'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_consistentRead'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_limit'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_projection'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_attributesToGet'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_indexName'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_select'
--
--     Requirement level: recommended
--










-- $span_dynamodb_scan_client
-- This span represents a @DynamoDB.Scan@ call.
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"aws.dynamodb"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'aws_dynamodb_segment'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_totalSegments'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_count'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_scannedCount'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_consumedCapacity'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_consistentRead'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_limit'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_projection'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_attributesToGet'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_indexName'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_select'
--
--     Requirement level: recommended
--













-- $span_dynamodb_updateitem_client
-- This span represents a @DynamoDB.UpdateItem@ call.
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"aws.dynamodb"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_consumedCapacity'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_itemCollectionMetrics'
--
--     Requirement level: recommended
--




-- $span_dynamodb_updatetable_client
-- This span represents a @DynamoDB.UpdateTable@ call.
--
-- Stability: development
--
-- ==== Note
-- @db.system.name@ MUST be set to @"aws.dynamodb"@ and SHOULD be provided __at span creation time__.
--
-- === Attributes
-- - 'aws_dynamodb_attributeDefinitions'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_globalSecondaryIndexUpdates'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_tableNames'
--
--     A single-element array with the value of the TableName request parameter.
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_consumedCapacity'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_provisionedReadCapacity'
--
--     Requirement level: recommended
--
-- - 'aws_dynamodb_provisionedWriteCapacity'
--
--     Requirement level: recommended
--







-- $span_aws_s3_client
-- Semantic Conventions for AWS S3 client spans extend the general [AWS SDK Semantic Conventions](\/docs\/cloud-providers\/aws-sdk.md)
--
-- Stability: development
--
-- === Attributes
-- - 'aws_s3_bucket'
--
--     Requirement level: recommended
--
-- - 'aws_s3_key'
--
--     Requirement level: recommended
--
-- - 'aws_s3_copySource'
--
--     Requirement level: recommended
--
-- - 'aws_s3_uploadId'
--
--     Requirement level: recommended
--
-- - 'aws_s3_delete'
--
--     Requirement level: recommended
--
-- - 'aws_s3_partNumber'
--
--     Requirement level: recommended
--







-- $entity_aws_ecs
-- Entities used by AWS Elastic Container Service (ECS).
--
-- Stability: development
--
-- === Attributes
-- - 'aws_ecs_container_arn'
--
--     Requirement level: recommended
--
-- - 'aws_ecs_cluster_arn'
--
--     Requirement level: recommended
--
-- - 'aws_ecs_launchtype'
--
--     Requirement level: recommended
--
-- - 'aws_ecs_task_arn'
--
--     Requirement level: recommended
--
-- - 'aws_ecs_task_family'
--
--     Requirement level: recommended
--
-- - 'aws_ecs_task_id'
--
--     Requirement level: conditionally required: If and only if @task.arn@ is populated.
--
-- - 'aws_ecs_task_revision'
--
--     Requirement level: recommended
--








-- $registry_aws
-- This section defines generic attributes for AWS services.
--
-- === Attributes
-- - 'aws_requestId'
--
--     Stability: development
--
-- - 'aws_extendedRequestId'
--
--     Stability: development
--

-- |
-- The AWS request ID as returned in the response headers @x-amzn-requestid@, @x-amzn-request-id@ or @x-amz-request-id@.
aws_requestId :: AttributeKey Text
aws_requestId = AttributeKey "aws.request_id"

-- |
-- The AWS extended request ID as returned in the response header @x-amz-id-2@.
aws_extendedRequestId :: AttributeKey Text
aws_extendedRequestId = AttributeKey "aws.extended_request_id"

-- $registry_aws_dynamodb
-- This document defines attributes for AWS DynamoDB.
--
-- === Attributes
-- - 'aws_dynamodb_tableNames'
--
--     Stability: development
--
-- - 'aws_dynamodb_consumedCapacity'
--
--     Stability: development
--
-- - 'aws_dynamodb_itemCollectionMetrics'
--
--     Stability: development
--
-- - 'aws_dynamodb_provisionedReadCapacity'
--
--     Stability: development
--
-- - 'aws_dynamodb_provisionedWriteCapacity'
--
--     Stability: development
--
-- - 'aws_dynamodb_consistentRead'
--
--     Stability: development
--
-- - 'aws_dynamodb_projection'
--
--     Stability: development
--
-- - 'aws_dynamodb_limit'
--
--     Stability: development
--
-- - 'aws_dynamodb_attributesToGet'
--
--     Stability: development
--
-- - 'aws_dynamodb_indexName'
--
--     Stability: development
--
-- - 'aws_dynamodb_select'
--
--     Stability: development
--
-- - 'aws_dynamodb_globalSecondaryIndexes'
--
--     Stability: development
--
-- - 'aws_dynamodb_localSecondaryIndexes'
--
--     Stability: development
--
-- - 'aws_dynamodb_exclusiveStartTable'
--
--     Stability: development
--
-- - 'aws_dynamodb_tableCount'
--
--     Stability: development
--
-- - 'aws_dynamodb_scanForward'
--
--     Stability: development
--
-- - 'aws_dynamodb_segment'
--
--     Stability: development
--
-- - 'aws_dynamodb_totalSegments'
--
--     Stability: development
--
-- - 'aws_dynamodb_count'
--
--     Stability: development
--
-- - 'aws_dynamodb_scannedCount'
--
--     Stability: development
--
-- - 'aws_dynamodb_attributeDefinitions'
--
--     Stability: development
--
-- - 'aws_dynamodb_globalSecondaryIndexUpdates'
--
--     Stability: development
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

-- |
-- The JSON-serialized value of each item of the @GlobalSecondaryIndexes@ request field
aws_dynamodb_globalSecondaryIndexes :: AttributeKey [Text]
aws_dynamodb_globalSecondaryIndexes = AttributeKey "aws.dynamodb.global_secondary_indexes"

-- |
-- The JSON-serialized value of each item of the @LocalSecondaryIndexes@ request field.
aws_dynamodb_localSecondaryIndexes :: AttributeKey [Text]
aws_dynamodb_localSecondaryIndexes = AttributeKey "aws.dynamodb.local_secondary_indexes"

-- |
-- The value of the @ExclusiveStartTableName@ request parameter.
aws_dynamodb_exclusiveStartTable :: AttributeKey Text
aws_dynamodb_exclusiveStartTable = AttributeKey "aws.dynamodb.exclusive_start_table"

-- |
-- The number of items in the @TableNames@ response parameter.
aws_dynamodb_tableCount :: AttributeKey Int64
aws_dynamodb_tableCount = AttributeKey "aws.dynamodb.table_count"

-- |
-- The value of the @ScanIndexForward@ request parameter.
aws_dynamodb_scanForward :: AttributeKey Bool
aws_dynamodb_scanForward = AttributeKey "aws.dynamodb.scan_forward"

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

-- |
-- The JSON-serialized value of each item in the @AttributeDefinitions@ request field.
aws_dynamodb_attributeDefinitions :: AttributeKey [Text]
aws_dynamodb_attributeDefinitions = AttributeKey "aws.dynamodb.attribute_definitions"

-- |
-- The JSON-serialized value of each item in the @GlobalSecondaryIndexUpdates@ request field.
aws_dynamodb_globalSecondaryIndexUpdates :: AttributeKey [Text]
aws_dynamodb_globalSecondaryIndexUpdates = AttributeKey "aws.dynamodb.global_secondary_index_updates"

-- $registry_aws_ecs
-- This document defines attributes for AWS Elastic Container Service (ECS).
--
-- === Attributes
-- - 'aws_ecs_container_arn'
--
--     Stability: development
--
-- - 'aws_ecs_cluster_arn'
--
--     Stability: development
--
-- - 'aws_ecs_launchtype'
--
--     Stability: development
--
-- - 'aws_ecs_task_arn'
--
--     Stability: development
--
-- - 'aws_ecs_task_family'
--
--     Stability: development
--
-- - 'aws_ecs_task_id'
--
--     Stability: development
--
-- - 'aws_ecs_task_revision'
--
--     Stability: development
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

-- $registry_aws_eks
-- This document defines attributes for AWS Elastic Kubernetes Service (EKS).
--
-- === Attributes
-- - 'aws_eks_cluster_arn'
--
--     Stability: development
--

-- |
-- The ARN of an EKS cluster.
aws_eks_cluster_arn :: AttributeKey Text
aws_eks_cluster_arn = AttributeKey "aws.eks.cluster.arn"

-- $registry_aws_log
-- This document defines attributes for AWS Logs.
--
-- === Attributes
-- - 'aws_log_group_names'
--
--     Stability: development
--
-- - 'aws_log_group_arns'
--
--     Stability: development
--
-- - 'aws_log_stream_names'
--
--     Stability: development
--
-- - 'aws_log_stream_arns'
--
--     Stability: development
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

-- $registry_aws_lambda
-- This document defines attributes for AWS Lambda.
--
-- === Attributes
-- - 'aws_lambda_invokedArn'
--
--     Stability: development
--
-- - 'aws_lambda_resourceMapping_id'
--
--     Stability: development
--

-- |
-- The full invoked ARN as provided on the @Context@ passed to the function (@Lambda-Runtime-Invoked-Function-Arn@ header on the @\/runtime\/invocation\/next@ applicable).

-- ==== Note
-- This may be different from @cloud.resource_id@ if an alias is involved.
aws_lambda_invokedArn :: AttributeKey Text
aws_lambda_invokedArn = AttributeKey "aws.lambda.invoked_arn"

-- |
-- The UUID of the [AWS Lambda EvenSource Mapping](https:\/\/docs.aws.amazon.com\/AWSCloudFormation\/latest\/UserGuide\/aws-resource-lambda-eventsourcemapping.html). An event source is mapped to a lambda function. It\'s contents are read by Lambda and used to trigger a function. This isn\'t available in the lambda execution context or the lambda runtime environtment. This is going to be populated by the AWS SDK for each language when that UUID is present. Some of these operations are Create\/Delete\/Get\/List\/Update EventSourceMapping.
aws_lambda_resourceMapping_id :: AttributeKey Text
aws_lambda_resourceMapping_id = AttributeKey "aws.lambda.resource_mapping.id"

-- $registry_aws_s3
-- This document defines attributes for AWS S3.
--
-- === Attributes
-- - 'aws_s3_bucket'
--
--     Stability: development
--
-- - 'aws_s3_key'
--
--     Stability: development
--
-- - 'aws_s3_copySource'
--
--     Stability: development
--
-- - 'aws_s3_uploadId'
--
--     Stability: development
--
-- - 'aws_s3_delete'
--
--     Stability: development
--
-- - 'aws_s3_partNumber'
--
--     Stability: development
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

-- $registry_aws_sqs
-- This document defines attributes for AWS SQS.
--
-- === Attributes
-- - 'aws_sqs_queue_url'
--
--     Stability: development
--

-- |
-- The URL of the AWS SQS Queue. It\'s a unique identifier for a queue in Amazon Simple Queue Service (SQS) and is used to access the queue and perform actions on it.
aws_sqs_queue_url :: AttributeKey Text
aws_sqs_queue_url = AttributeKey "aws.sqs.queue.url"

-- $registry_aws_sns
-- This document defines attributes for AWS SNS.
--
-- === Attributes
-- - 'aws_sns_topic_arn'
--
--     Stability: development
--

-- |
-- The ARN of the AWS SNS Topic. An Amazon SNS [topic](https:\/\/docs.aws.amazon.com\/sns\/latest\/dg\/sns-create-topic.html) is a logical access point that acts as a communication channel.
aws_sns_topic_arn :: AttributeKey Text
aws_sns_topic_arn = AttributeKey "aws.sns.topic.arn"

-- $registry_aws_kinesis
-- This document defines attributes for AWS Kinesis.
--
-- === Attributes
-- - 'aws_kinesis_streamName'
--
--     Stability: development
--

-- |
-- The name of the AWS Kinesis [stream](https:\/\/docs.aws.amazon.com\/streams\/latest\/dev\/introduction.html) the request refers to. Corresponds to the @--stream-name@ parameter of the Kinesis [describe-stream](https:\/\/docs.aws.amazon.com\/cli\/latest\/reference\/kinesis\/describe-stream.html) operation.
aws_kinesis_streamName :: AttributeKey Text
aws_kinesis_streamName = AttributeKey "aws.kinesis.stream_name"

-- $registry_aws_stepFunctions
-- This document defines attributes for AWS Step Functions.
--
-- === Attributes
-- - 'aws_stepFunctions_activity_arn'
--
--     Stability: development
--
-- - 'aws_stepFunctions_stateMachine_arn'
--
--     Stability: development
--

-- |
-- The ARN of the AWS Step Functions Activity.
aws_stepFunctions_activity_arn :: AttributeKey Text
aws_stepFunctions_activity_arn = AttributeKey "aws.step_functions.activity.arn"

-- |
-- The ARN of the AWS Step Functions State Machine.
aws_stepFunctions_stateMachine_arn :: AttributeKey Text
aws_stepFunctions_stateMachine_arn = AttributeKey "aws.step_functions.state_machine.arn"

-- $registry_aws_secretsmanager
-- This document defines attributes for AWS Secrets Manager.
--
-- === Attributes
-- - 'aws_secretsmanager_secret_arn'
--
--     Stability: development
--

-- |
-- The ARN of the Secret stored in the Secrets Mangger
aws_secretsmanager_secret_arn :: AttributeKey Text
aws_secretsmanager_secret_arn = AttributeKey "aws.secretsmanager.secret.arn"

-- $registry_aws_bedrock
-- This document defines attributes for AWS Bedrock.
--
-- === Attributes
-- - 'aws_bedrock_guardrail_id'
--
--     Stability: development
--
-- - 'aws_bedrock_knowledgeBase_id'
--
--     Stability: development
--

-- |
-- The unique identifier of the AWS Bedrock Guardrail. A [guardrail](https:\/\/docs.aws.amazon.com\/bedrock\/latest\/userguide\/guardrails.html) helps safeguard and prevent unwanted behavior from model responses or user messages.
aws_bedrock_guardrail_id :: AttributeKey Text
aws_bedrock_guardrail_id = AttributeKey "aws.bedrock.guardrail.id"

-- |
-- The unique identifier of the AWS Bedrock Knowledge base. A [knowledge base](https:\/\/docs.aws.amazon.com\/bedrock\/latest\/userguide\/knowledge-base.html) is a bank of information that can be queried by models to generate more relevant responses and augment prompts.
aws_bedrock_knowledgeBase_id :: AttributeKey Text
aws_bedrock_knowledgeBase_id = AttributeKey "aws.bedrock.knowledge_base.id"

-- $entity_aws_eks
-- Entities used by AWS Elastic Kubernetes Service (EKS).
--
-- Stability: development
--
-- === Attributes
-- - 'aws_eks_cluster_arn'
--
--     Requirement level: recommended
--


-- $span_aws_lambda_server
-- This span represents AWS Lambda invocation.
--
-- Stability: development
--
-- ==== Note
-- Consider setting other attributes of the [@faas@ resource][faasres] and [trace][faas] conventions
-- and the [cloud resource conventions][cloud].
-- 
-- __Span name__ MUST be set to the function name from the Lambda @Context@
-- unless stated otherwise.
-- 
-- __Span kind__ MUST be @SERVER@ unless stated otherwise.
--
-- === Attributes
-- - 'aws_lambda_invokedArn'
--
--     Requirement level: recommended
--
-- - 'aws_lambda_resourceMapping_id'
--
--     Requirement level: recommended
--



-- $attributes_genAi_common_client
-- Common attributes for all GenAI spans.
--
-- Stability: development
--
-- === Attributes
-- - 'genAi_request_model'
--
--     Requirement level: conditionally required: If available.
--
--     ==== Note
--     The name of the GenAI model a request is being made to. If the model is supplied by a vendor, then the value must be the exact name of the model requested. If the model is a fine-tuned custom model, the value should have a more specific name than the base model that\'s been fine-tuned.
--
-- - 'genAi_operation_name'
--
--     Requirement level: required
--
-- - 'server_address'
--
--     GenAI server address.
--
--     Requirement level: recommended
--
-- - 'server_port'
--
--     GenAI server port.
--
--     Requirement level: conditionally required: If @server.address@ is set.
--
-- - 'error_type'
--
--     Requirement level: conditionally required: if the operation ended in an error
--
--     ==== Note
--     The @error.type@ SHOULD match the error code returned by the Generative AI provider or the client library,
--     the canonical name of exception that occurred, or another low-cardinality error identifier.
--     Instrumentations SHOULD document the list of errors they report.
--






-- $attributes_genAi_inference_client
-- Describes GenAI inference attributes.
--
-- Stability: development
--
-- === Attributes
-- - 'genAi_request_maxTokens'
--
--     Requirement level: recommended
--
-- - 'genAi_request_choice_count'
--
--     Requirement level: conditionally required: if available, in the request, and !=1
--
-- - 'genAi_request_temperature'
--
--     Requirement level: recommended
--
-- - 'genAi_request_topP'
--
--     Requirement level: recommended
--
-- - 'genAi_request_stopSequences'
--
--     Requirement level: recommended
--
-- - 'genAi_request_frequencyPenalty'
--
--     Requirement level: recommended
--
-- - 'genAi_request_presencePenalty'
--
--     Requirement level: recommended
--
-- - 'genAi_request_seed'
--
--     Requirement level: conditionally required: if applicable and if the request includes a seed
--
-- - 'genAi_output_type'
--
--     Requirement level: conditionally required: when applicable and if the request includes an output format.
--
-- - 'genAi_response_id'
--
--     Requirement level: recommended
--
-- - 'genAi_response_model'
--
--     Requirement level: recommended
--
--     ==== Note
--     If available. The name of the GenAI model that provided the response. If the model is supplied by a vendor, then the value must be the exact name of the model actually used. If the model is a fine-tuned custom model, the value should have a more specific name than the base model that\'s been fine-tuned.
--
-- - 'genAi_response_finishReasons'
--
--     Requirement level: recommended
--
-- - 'genAi_usage_inputTokens'
--
--     Requirement level: recommended
--
-- - 'genAi_usage_cacheRead_inputTokens'
--
--     Requirement level: recommended
--
-- - 'genAi_usage_cacheCreation_inputTokens'
--
--     Requirement level: recommended
--
-- - 'genAi_usage_outputTokens'
--
--     Requirement level: recommended
--
-- - 'genAi_conversation_id'
--
--     Requirement level: conditionally required: when available
--
--     ==== Note
--     Instrumentations SHOULD populate conversation id when they have it readily available
--     for a given operation, for example:
--     
--     - when client framework being instrumented manages conversation history
--     (see [LlamaIndex chat store](https:\/\/docs.llamaindex.ai\/en\/stable\/module_guides\/storing\/chat_stores\/))
--     - when instrumenting GenAI client libraries that maintain conversation on the backend side
--     (see [AWS Bedrock agent sessions](https:\/\/docs.aws.amazon.com\/bedrock\/latest\/userguide\/agents-session-state.html),
--     [OpenAI Assistant threads](https:\/\/platform.openai.com\/docs\/api-reference\/threads))
--     
--     Application developers that manage conversation history MAY add conversation id to GenAI and other
--     spans or logs using custom span or log record processors or hooks provided by instrumentation
--     libraries.
--
-- - 'genAi_systemInstructions'
--
--     Requirement level: opt-in
--
-- - 'genAi_input_messages'
--
--     Requirement level: opt-in
--
-- - 'genAi_output_messages'
--
--     Requirement level: opt-in
--
-- - 'genAi_tool_definitions'
--
--     Requirement level: opt-in
--






















-- $span_genAi_inference_client
-- This span represents a client call to Generative AI model or service that generates a response or requests a tool call based on the input prompt.
--
-- Stability: development
--
-- ==== Note
-- __Span name__ SHOULD be @{gen_ai.operation.name} {gen_ai.request.model}@.
-- Semantic conventions for individual GenAI systems and frameworks MAY specify different span name format
-- and MUST follow the overall [guidelines for span names](https:\/\/github.com\/open-telemetry\/opentelemetry-specification\/blob\/v1.37.0\/specification\/trace\/api.md#span).
-- 
-- __Span kind__ SHOULD be @CLIENT@ and MAY be set to @INTERNAL@ on spans representing
-- call to models running in the same process. It\'s RECOMMENDED to use @CLIENT@ kind
-- when the GenAI system being instrumented usually runs in a different process than its
-- client or when the GenAI call happens over instrumented protocol such as HTTP.
--
-- === Attributes
-- - 'genAi_provider_name'
--
--     Requirement level: required
--
-- - 'genAi_operation_name'
--
-- - 'server_address'
--
-- - 'server_port'
--
-- - 'genAi_request_model'
--
-- - 'genAi_request_topK'
--
--     Requirement level: recommended
--







-- $attributes_genAi_inference_openaiBased
-- Describes attributes that are common to OpenAI-based Generative AI services.
--
-- Stability: development
--
-- === Attributes
-- - 'genAi_output_type'
--
--     ==== Note
--     This attribute SHOULD be set to the output type requested by the client:
--     
--     - @json@ for structured outputs with defined or undefined schema
--     - @image@ for image output
--     - @speech@ for speech output
--     - @text@ for plain text output
--     
--     The attribute specifies the output modality and not the actual output format.
--     For example, if an image is requested, the actual output could be a
--     URL pointing to an image file.
--     
--     Additional output format details may be recorded in the future in the
--     @gen_ai.output.{type}.*@ attributes.
--
-- - 'server_address'
--
-- - 'server_port'
--
-- - 'genAi_request_model'
--
-- - 'genAi_operation_name'
--






-- $span_openai_inference_client
-- Semantic Conventions for [OpenAI](https:\/\/openai.com\/) client spans extend and override the semantic conventions for [Gen AI Spans](gen-ai-spans.md).
--
-- Stability: development
--
-- ==== Note
-- @gen_ai.provider.name@ MUST be set to @"openai"@ and SHOULD be provided __at span creation time__.
-- 
-- __Span name__ SHOULD be @{gen_ai.operation.name} {gen_ai.request.model}@.
--
-- === Attributes
-- - 'genAi_request_model'
--
--     Requirement level: required
--
-- - 'genAi_usage_inputTokens'
--
--     ==== Note
--     The total input token count is returned by @usage.input_tokens@ or a similar property in the model response.
--
-- - 'genAi_usage_cacheRead_inputTokens'
--
--     ==== Note
--     Corresponds to @usage.input_tokens_details.cached_tokens@ or a similar property in the model response.
--
-- - 'openai_request_serviceTier'
--
--     Requirement level: conditionally required: if the request includes a service_tier and the value is not \'auto\'
--
-- - 'openai_response_serviceTier'
--
--     Requirement level: conditionally required: if the response was received and includes a service_tier
--
-- - 'openai_response_systemFingerprint'
--
--     Requirement level: recommended
--
-- - 'openai_api_type'
--
--     Requirement level: recommended
--








-- $span_azure_ai_inference_client
-- Semantic Conventions for [Azure AI Inference](https:\/\/learn.microsoft.com\/rest\/api\/aifoundry\/modelinference\/) client spans extend and override the semantic conventions for [Gen AI Spans](gen-ai-spans.md).
--
-- Stability: development
--
-- ==== Note
-- @gen_ai.provider.name@ MUST be set to @"azure.ai.inference"@ and SHOULD be provided __at span creation time__.
-- 
-- __Span name__ SHOULD be @{gen_ai.operation.name} {gen_ai.request.model}@ when the
-- model name is available and @{gen_ai.operation.name}@ otherwise.
--
-- === Attributes
-- - 'azure_resourceProvider_namespace'
--
--     ==== Note
--     When @azure.resource_provider.namespace@ attribute is populated, it MUST be set to @Microsoft.CognitiveServices@ for all operations performed by Azure AI Inference clients.
--
-- - 'genAi_usage_inputTokens'
--
--     The number of prompt tokens as reported in the usage prompt_tokens property of the response.
--
-- - 'genAi_usage_outputTokens'
--
--     The number of completion tokens as reported in the usage completion_tokens property of the response.
--
-- - 'server_port'
--
--     Requirement level: conditionally required: If not default (443).
--





-- $span_genAi_embeddings_client
-- Describes GenAI embeddings span - a request to a Generative AI model or service that generates an embeddings based on the input.
-- The @gen_ai.operation.name@ SHOULD be @embeddings@.
-- __Span name__ SHOULD be @{gen_ai.operation.name} {gen_ai.request.model}@.
--
-- Stability: development
--
-- === Attributes
-- - 'genAi_provider_name'
--
--     Requirement level: required
--
-- - 'genAi_operation_name'
--
-- - 'server_address'
--
-- - 'server_port'
--
-- - 'genAi_request_model'
--
-- - 'genAi_request_encodingFormats'
--
--     Requirement level: recommended
--
-- - 'genAi_usage_inputTokens'
--
--     Requirement level: recommended
--
-- - 'genAi_embeddings_dimension_count'
--
--     Requirement level: recommended
--









-- $span_genAi_retrieval_client
-- Describes GenAI retrieval span - a request to a Generative AI service or framework that retrieves relevant information or context from a vector database or search system.
-- The @gen_ai.operation.name@ SHOULD be @retrieval@.
-- __Span name__ SHOULD be @{gen_ai.operation.name} {gen_ai.data_source.id}@. Semantic conventions for individual GenAI providers and retrievers MAY specify different span name format.
--
-- Stability: development
--
-- === Attributes
-- - 'genAi_operation_name'
--
--     Requirement level: required
--
-- - 'genAi_retrieval_query_text'
--
--     Requirement level: opt-in
--
-- - 'genAi_request_topK'
--
--     Requirement level: recommended
--
-- - 'genAi_retrieval_documents'
--
--     Requirement level: opt-in
--
-- - 'genAi_provider_name'
--
--     Requirement level: conditionally required: when applicable
--
-- - 'genAi_dataSource_id'
--
--     Requirement level: conditionally required: when applicable
--
-- - 'error_type'
--
--     Requirement level: conditionally required: if the operation ended in an error
--








-- $span_genAi_createAgent_client
-- Describes GenAI agent creation and is usually applicable when working with remote agent services.
--
-- Stability: development
--
-- ==== Note
-- The @gen_ai.operation.name@ SHOULD be @create_agent@.
-- 
-- __Span name__ SHOULD be @create_agent {gen_ai.agent.name}@.
-- Semantic conventions for individual GenAI systems and frameworks MAY specify different span name format.
--
-- === Attributes
-- - 'genAi_provider_name'
--
--     Requirement level: required
--
-- - 'genAi_operation_name'
--
-- - 'server_address'
--
-- - 'server_port'
--
-- - 'genAi_request_model'
--
-- - 'genAi_agent_id'
--
--     Requirement level: conditionally required: if applicable.
--
-- - 'genAi_agent_name'
--
--     Requirement level: conditionally required: If provided by the application.
--
-- - 'genAi_agent_description'
--
--     Requirement level: conditionally required: If provided by the application.
--
-- - 'genAi_agent_version'
--
--     Requirement level: conditionally required: If provided by the application.
--
-- - 'genAi_systemInstructions'
--
--     Requirement level: opt-in
--
--     ==== Note
--     
--











-- $span_genAi_invokeAgent_client
-- Describes GenAI agent invocation.
--
-- Stability: development
--
-- ==== Note
-- The @gen_ai.operation.name@ SHOULD be @invoke_agent@.
-- 
-- __Span name__ SHOULD be @invoke_agent {gen_ai.agent.name}@ if @gen_ai.agent.name@ is readily available.
-- When @gen_ai.agent.name@ is not available, it SHOULD be @invoke_agent@.
-- Semantic conventions for individual GenAI systems and frameworks MAY specify different span name format.
-- 
-- __Span kind__ SHOULD be @CLIENT@ and MAY be set to @INTERNAL@ on spans representing
-- invocation of agents running in the same process.
-- It\'s RECOMMENDED to use @CLIENT@ kind when the agent being instrumented usually runs
-- in a different process than its caller or when the agent invocation happens over
-- instrumented protocol such as HTTP.
-- 
-- Examples of span kinds for different agent scenarios:
-- 
-- - @CLIENT@: Remote agent services (e.g., OpenAI Assistants API, AWS Bedrock Agents)
-- - @INTERNAL@: In-process agents (e.g., LangChain agents, CrewAI agents)
--
-- === Attributes
-- - 'genAi_provider_name'
--
--     Requirement level: required
--
-- - 'genAi_operation_name'
--
-- - 'genAi_request_model'
--
-- - 'genAi_agent_id'
--
--     Requirement level: conditionally required: if applicable.
--
-- - 'genAi_agent_name'
--
--     Requirement level: conditionally required: when available
--
-- - 'genAi_agent_description'
--
--     Requirement level: conditionally required: when available
--
-- - 'genAi_agent_version'
--
--     Requirement level: conditionally required: when available
--
-- - 'genAi_dataSource_id'
--
--     Requirement level: conditionally required: if applicable.
--
-- - 'server_address'
--
--     Requirement level: recommended: when span kind is @CLIENT@.
--
-- - 'server_port'
--
-- - 'genAi_systemInstructions'
--
--     Requirement level: opt-in
--
-- - 'genAi_input_messages'
--
--     Requirement level: opt-in
--
-- - 'genAi_output_messages'
--
--     Requirement level: opt-in
--














-- $span_genAi_executeTool_internal
-- Describes tool execution span.
--
-- Stability: development
--
-- ==== Note
-- @gen_ai.operation.name@ SHOULD be @execute_tool@.
-- 
-- __Span name__ SHOULD be @execute_tool {gen_ai.tool.name}@.
-- 
-- GenAI instrumentations that can instrument tool execution calls SHOULD do so,
-- unless another instrumentation can reliably cover all supported tool types.
-- MCP tool executions may also be traced by the
-- [corresponding MCP instrumentation](\/docs\/gen-ai\/mcp.md#client).
-- 
-- Tools are often executed directly by application code. Application developers
-- are encouraged to follow this semantic convention for tools invoked by their
-- own code and to manually instrument any tool calls that automatic
-- instrumentations do not cover.
--
-- === Attributes
-- - 'genAi_operation_name'
--
--     Requirement level: required
--
-- - 'genAi_tool_name'
--
--     Requirement level: recommended
--
-- - 'genAi_tool_call_id'
--
--     Requirement level: recommended: if available
--
-- - 'genAi_tool_description'
--
--     Requirement level: recommended: if available
--
-- - 'genAi_tool_type'
--
--     Requirement level: recommended: if available
--
-- - 'genAi_tool_call_arguments'
--
--     Requirement level: opt-in
--
-- - 'genAi_tool_call_result'
--
--     Requirement level: opt-in
--
-- - 'error_type'
--
--     Requirement level: conditionally required: if the operation ended in an error
--
--     ==== Note
--     The @error.type@ SHOULD match the error code returned by the Generative AI provider or the client library,
--     the canonical name of exception that occurred, or another low-cardinality error identifier.
--     Instrumentations SHOULD document the list of errors they report.
--









-- $span_aws_bedrock_client
-- Describes an AWS Bedrock operation span.
--
-- Stability: development
--
-- === Attributes
-- - 'aws_bedrock_guardrail_id'
--
--     Requirement level: required
--
-- - 'aws_bedrock_knowledgeBase_id'
--
--     Requirement level: recommended
--



-- $span_anthropic_inference_client
-- Semantic Conventions for [Anthropic](https:\/\/www.anthropic.com\/) client spans extend and override the semantic conventions for [Gen AI Spans](gen-ai-spans.md).
--
-- Stability: development
--
-- ==== Note
-- @gen_ai.provider.name@ MUST be set to @"anthropic"@ and SHOULD be provided __at span creation time__.
-- 
-- __Span name__ SHOULD be @{gen_ai.operation.name} {gen_ai.request.model}@.
--
-- === Attributes
-- - 'genAi_usage_inputTokens'
--
--     ==== Note
--     Anthropic @input_tokens@ excludes cached tokens. Compute: @gen_ai.usage.input_tokens = input_tokens + cache_read_input_tokens + cache_creation_input_tokens@
--
-- - 'genAi_usage_cacheRead_inputTokens'
--
--     ==== Note
--     Anthropic reports this separately from @input_tokens@. This value MUST be added to the Anthropic @input_tokens@ to compute @gen_ai.usage.input_tokens@.
--
-- - 'genAi_usage_cacheCreation_inputTokens'
--
--     ==== Note
--     Anthropic reports this separately from @input_tokens@. This value MUST be added to the Anthropic @input_tokens@ to compute @gen_ai.usage.input_tokens@.
--




-- $registry_genAi
-- This document defines the attributes used to describe telemetry in the context of Generative Artificial Intelligence (GenAI) Models requests and responses.
--
-- === Attributes
-- - 'genAi_provider_name'
--
--     Stability: development
--
-- - 'genAi_request_model'
--
--     Stability: development
--
-- - 'genAi_request_maxTokens'
--
--     Stability: development
--
-- - 'genAi_request_choice_count'
--
--     Stability: development
--
-- - 'genAi_request_temperature'
--
--     Stability: development
--
-- - 'genAi_request_topP'
--
--     Stability: development
--
-- - 'genAi_request_topK'
--
--     Stability: development
--
-- - 'genAi_request_stopSequences'
--
--     Stability: development
--
-- - 'genAi_request_frequencyPenalty'
--
--     Stability: development
--
-- - 'genAi_request_presencePenalty'
--
--     Stability: development
--
-- - 'genAi_request_encodingFormats'
--
--     Stability: development
--
-- - 'genAi_request_seed'
--
--     Stability: development
--
-- - 'genAi_response_id'
--
--     Stability: development
--
-- - 'genAi_response_model'
--
--     Stability: development
--
-- - 'genAi_response_finishReasons'
--
--     Stability: development
--
-- - 'genAi_usage_inputTokens'
--
--     Stability: development
--
-- - 'genAi_usage_cacheRead_inputTokens'
--
--     Stability: development
--
-- - 'genAi_usage_cacheCreation_inputTokens'
--
--     Stability: development
--
-- - 'genAi_usage_outputTokens'
--
--     Stability: development
--
-- - 'genAi_token_type'
--
--     Stability: development
--
-- - 'genAi_conversation_id'
--
--     Stability: development
--
-- - 'genAi_agent_id'
--
--     Stability: development
--
-- - 'genAi_agent_name'
--
--     Stability: development
--
-- - 'genAi_agent_description'
--
--     Stability: development
--
-- - 'genAi_agent_version'
--
--     Stability: development
--
-- - 'genAi_tool_name'
--
--     Stability: development
--
-- - 'genAi_tool_call_id'
--
--     Stability: development
--
-- - 'genAi_tool_description'
--
--     Stability: development
--
-- - 'genAi_tool_type'
--
--     Stability: development
--
-- - 'genAi_tool_call_arguments'
--
--     Stability: development
--
-- - 'genAi_tool_call_result'
--
--     Stability: development
--
-- - 'genAi_tool_definitions'
--
--     Stability: development
--
-- - 'genAi_dataSource_id'
--
--     Stability: development
--
-- - 'genAi_operation_name'
--
--     Stability: development
--
-- - 'genAi_output_type'
--
--     Stability: development
--
-- - 'genAi_embeddings_dimension_count'
--
--     Stability: development
--
-- - 'genAi_retrieval_documents'
--
--     Stability: development
--
-- - 'genAi_retrieval_query_text'
--
--     Stability: development
--
-- - 'genAi_systemInstructions'
--
--     Stability: development
--
-- - 'genAi_input_messages'
--
--     Stability: development
--
-- - 'genAi_output_messages'
--
--     Stability: development
--
-- - 'genAi_evaluation_name'
--
--     Stability: development
--
-- - 'genAi_evaluation_score_value'
--
--     Stability: development
--
-- - 'genAi_evaluation_score_label'
--
--     Stability: development
--
-- - 'genAi_evaluation_explanation'
--
--     Stability: development
--
-- - 'genAi_prompt_name'
--
--     Stability: development
--

-- |
-- The Generative AI provider as identified by the client or server instrumentation.

-- ==== Note
-- The attribute SHOULD be set based on the instrumentation\'s best
-- knowledge and may differ from the actual model provider.
-- 
-- Multiple providers, including Azure OpenAI, Gemini, and AI hosting platforms
-- are accessible using the OpenAI REST API and corresponding client libraries,
-- but may proxy or host models from different providers.
-- 
-- The @gen_ai.request.model@, @gen_ai.response.model@, and @server.address@
-- attributes may help identify the actual system in use.
-- 
-- The @gen_ai.provider.name@ attribute acts as a discriminator that
-- identifies the GenAI telemetry format flavor specific to that provider
-- within GenAI semantic conventions.
-- It SHOULD be set consistently with provider-specific attributes and signals.
-- For example, GenAI spans, metrics, and events related to AWS Bedrock
-- should have the @gen_ai.provider.name@ set to @aws.bedrock@ and include
-- applicable @aws.bedrock.*@ attributes and are not expected to include
-- @openai.*@ attributes.
genAi_provider_name :: AttributeKey Text
genAi_provider_name = AttributeKey "gen_ai.provider.name"

-- |
-- The name of the GenAI model a request is being made to.
genAi_request_model :: AttributeKey Text
genAi_request_model = AttributeKey "gen_ai.request.model"

-- |
-- The maximum number of tokens the model generates for a request.
genAi_request_maxTokens :: AttributeKey Int64
genAi_request_maxTokens = AttributeKey "gen_ai.request.max_tokens"

-- |
-- The target number of candidate completions to return.
genAi_request_choice_count :: AttributeKey Int64
genAi_request_choice_count = AttributeKey "gen_ai.request.choice.count"

-- |
-- The temperature setting for the GenAI request.
genAi_request_temperature :: AttributeKey Double
genAi_request_temperature = AttributeKey "gen_ai.request.temperature"

-- |
-- The top_p sampling setting for the GenAI request.
genAi_request_topP :: AttributeKey Double
genAi_request_topP = AttributeKey "gen_ai.request.top_p"

-- |
-- The top_k sampling setting for the GenAI request.
genAi_request_topK :: AttributeKey Double
genAi_request_topK = AttributeKey "gen_ai.request.top_k"

-- |
-- List of sequences that the model will use to stop generating further tokens.
genAi_request_stopSequences :: AttributeKey [Text]
genAi_request_stopSequences = AttributeKey "gen_ai.request.stop_sequences"

-- |
-- The frequency penalty setting for the GenAI request.
genAi_request_frequencyPenalty :: AttributeKey Double
genAi_request_frequencyPenalty = AttributeKey "gen_ai.request.frequency_penalty"

-- |
-- The presence penalty setting for the GenAI request.
genAi_request_presencePenalty :: AttributeKey Double
genAi_request_presencePenalty = AttributeKey "gen_ai.request.presence_penalty"

-- |
-- The encoding formats requested in an embeddings operation, if specified.

-- ==== Note
-- In some GenAI systems the encoding formats are called embedding types. Also, some GenAI systems only accept a single format per request.
genAi_request_encodingFormats :: AttributeKey [Text]
genAi_request_encodingFormats = AttributeKey "gen_ai.request.encoding_formats"

-- |
-- Requests with same seed value more likely to return same result.
genAi_request_seed :: AttributeKey Int64
genAi_request_seed = AttributeKey "gen_ai.request.seed"

-- |
-- The unique identifier for the completion.
genAi_response_id :: AttributeKey Text
genAi_response_id = AttributeKey "gen_ai.response.id"

-- |
-- The name of the model that generated the response.
genAi_response_model :: AttributeKey Text
genAi_response_model = AttributeKey "gen_ai.response.model"

-- |
-- Array of reasons the model stopped generating tokens, corresponding to each generation received.
genAi_response_finishReasons :: AttributeKey [Text]
genAi_response_finishReasons = AttributeKey "gen_ai.response.finish_reasons"

-- |
-- The number of tokens used in the GenAI input (prompt).

-- ==== Note
-- This value SHOULD include all types of input tokens, including cached tokens.
-- Instrumentations SHOULD make a best effort to populate this value, using a total
-- provided by the provider when available or, depending on the provider API,
-- by summing different token types parsed from the provider output.
genAi_usage_inputTokens :: AttributeKey Int64
genAi_usage_inputTokens = AttributeKey "gen_ai.usage.input_tokens"

-- |
-- The number of input tokens served from a provider-managed cache.

-- ==== Note
-- The value SHOULD be included in @gen_ai.usage.input_tokens@.
genAi_usage_cacheRead_inputTokens :: AttributeKey Int64
genAi_usage_cacheRead_inputTokens = AttributeKey "gen_ai.usage.cache_read.input_tokens"

-- |
-- The number of input tokens written to a provider-managed cache.

-- ==== Note
-- The value SHOULD be included in @gen_ai.usage.input_tokens@.
genAi_usage_cacheCreation_inputTokens :: AttributeKey Int64
genAi_usage_cacheCreation_inputTokens = AttributeKey "gen_ai.usage.cache_creation.input_tokens"

-- |
-- The number of tokens used in the GenAI response (completion).
genAi_usage_outputTokens :: AttributeKey Int64
genAi_usage_outputTokens = AttributeKey "gen_ai.usage.output_tokens"

-- |
-- The type of token being counted.
genAi_token_type :: AttributeKey Text
genAi_token_type = AttributeKey "gen_ai.token.type"

-- |
-- The unique identifier for a conversation (session, thread), used to store and correlate messages within this conversation.
genAi_conversation_id :: AttributeKey Text
genAi_conversation_id = AttributeKey "gen_ai.conversation.id"

-- |
-- The unique identifier of the GenAI agent.
genAi_agent_id :: AttributeKey Text
genAi_agent_id = AttributeKey "gen_ai.agent.id"

-- |
-- Human-readable name of the GenAI agent provided by the application.
genAi_agent_name :: AttributeKey Text
genAi_agent_name = AttributeKey "gen_ai.agent.name"

-- |
-- Free-form description of the GenAI agent provided by the application.
genAi_agent_description :: AttributeKey Text
genAi_agent_description = AttributeKey "gen_ai.agent.description"

-- |
-- The version of the GenAI agent.
genAi_agent_version :: AttributeKey Text
genAi_agent_version = AttributeKey "gen_ai.agent.version"

-- |
-- Name of the tool utilized by the agent.
genAi_tool_name :: AttributeKey Text
genAi_tool_name = AttributeKey "gen_ai.tool.name"

-- |
-- The tool call identifier.
genAi_tool_call_id :: AttributeKey Text
genAi_tool_call_id = AttributeKey "gen_ai.tool.call.id"

-- |
-- The tool description.
genAi_tool_description :: AttributeKey Text
genAi_tool_description = AttributeKey "gen_ai.tool.description"

-- |
-- Type of the tool utilized by the agent

-- ==== Note
-- Extension: A tool executed on the agent-side to directly call external APIs, bridging the gap between the agent and real-world systems.
--   Agent-side operations involve actions that are performed by the agent on the server or within the agent\'s controlled environment.
-- Function: A tool executed on the client-side, where the agent generates parameters for a predefined function, and the client executes the logic.
--   Client-side operations are actions taken on the user\'s end or within the client application.
-- Datastore: A tool used by the agent to access and query structured or unstructured external data for retrieval-augmented tasks or knowledge updates.
genAi_tool_type :: AttributeKey Text
genAi_tool_type = AttributeKey "gen_ai.tool.type"

-- |
-- Parameters passed to the tool call.

-- ==== Note
-- \> [!WARNING]
-- \> This attribute may contain sensitive information.
-- 
-- It\'s expected to be an object - in case a serialized string is available
-- to the instrumentation, the instrumentation SHOULD do the best effort to
-- deserialize it to an object. When recorded on spans, it MAY be recorded as a JSON string if structured format is not supported and SHOULD be recorded in structured form otherwise.
genAi_tool_call_arguments :: AttributeKey Text
genAi_tool_call_arguments = AttributeKey "gen_ai.tool.call.arguments"

-- |
-- The result returned by the tool call (if any and if execution was successful).

-- ==== Note
-- \> [!WARNING]
-- \> This attribute may contain sensitive information.
-- 
-- It\'s expected to be an object - in case a serialized string is available
-- to the instrumentation, the instrumentation SHOULD do the best effort to
-- deserialize it to an object. When recorded on spans, it MAY be recorded as a JSON string if structured format is not supported and SHOULD be recorded in structured form otherwise.
genAi_tool_call_result :: AttributeKey Text
genAi_tool_call_result = AttributeKey "gen_ai.tool.call.result"

-- |
-- The list of source system tool definitions available to the GenAI agent or model.

-- ==== Note
-- The value of this attribute matches source system tool definition format.
-- 
-- It\'s expected to be an array of objects where each object represents a tool definition. In case a serialized string is available
-- to the instrumentation, the instrumentation SHOULD do the best effort to
-- deserialize it to an array. When recorded on spans, it MAY be recorded as a JSON string if structured format is not supported and SHOULD be recorded in structured form otherwise.
-- 
-- Since this attribute could be large, it\'s NOT RECOMMENDED to populate
-- it by default. Instrumentations MAY provide a way to enable
-- populating this attribute.
genAi_tool_definitions :: AttributeKey Text
genAi_tool_definitions = AttributeKey "gen_ai.tool.definitions"

-- |
-- The data source identifier.

-- ==== Note
-- Data sources are used by AI agents and RAG applications to store grounding data. A data source may be an external database, object store, document collection, website, or any other storage system used by the GenAI agent or application. The @gen_ai.data_source.id@ SHOULD match the identifier used by the GenAI system rather than a name specific to the external storage, such as a database or object store. Semantic conventions referencing @gen_ai.data_source.id@ MAY also leverage additional attributes, such as @db.*@, to further identify and describe the data source.
genAi_dataSource_id :: AttributeKey Text
genAi_dataSource_id = AttributeKey "gen_ai.data_source.id"

-- |
-- The name of the operation being performed.

-- ==== Note
-- If one of the predefined values applies, but specific system uses a different name it\'s RECOMMENDED to document it in the semantic conventions for specific GenAI system and use system-specific name in the instrumentation. If a different name is not documented, instrumentation libraries SHOULD use applicable predefined value.
genAi_operation_name :: AttributeKey Text
genAi_operation_name = AttributeKey "gen_ai.operation.name"

-- |
-- Represents the content type requested by the client.

-- ==== Note
-- This attribute SHOULD be used when the client requests output of a specific type. The model may return zero or more outputs of this type.
-- This attribute specifies the output modality and not the actual output format. For example, if an image is requested, the actual output could be a URL pointing to an image file.
-- Additional output format details may be recorded in the future in the @gen_ai.output.{type}.*@ attributes.
genAi_output_type :: AttributeKey Text
genAi_output_type = AttributeKey "gen_ai.output.type"

-- |
-- The number of dimensions the resulting output embeddings should have.
genAi_embeddings_dimension_count :: AttributeKey Int64
genAi_embeddings_dimension_count = AttributeKey "gen_ai.embeddings.dimension.count"

-- |
-- The documents retrieved.

-- ==== Note
-- Instrumentations MUST follow [Retrieval documents JSON schema](\/docs\/gen-ai\/gen-ai-retrieval-documents.json).
-- When the attribute is recorded on events, it MUST be recorded in structured
-- form. When recorded on spans, it MAY be recorded as a JSON string if structured
-- format is not supported and SHOULD be recorded in structured form otherwise.
-- 
-- Each document object SHOULD contain at least the following properties:
-- @id@ (string): A unique identifier for the document, @score@ (double): The relevance score of the document
genAi_retrieval_documents :: AttributeKey Text
genAi_retrieval_documents = AttributeKey "gen_ai.retrieval.documents"

-- |
-- The query text used for retrieval.

-- ==== Note
-- \> [!Warning]
-- \> This attribute may contain sensitive information.
genAi_retrieval_query_text :: AttributeKey Text
genAi_retrieval_query_text = AttributeKey "gen_ai.retrieval.query.text"

-- |
-- The system message or instructions provided to the GenAI model separately from the chat history.

-- ==== Note
-- This attribute SHOULD be used when the corresponding provider or API
-- allows to provide system instructions or messages separately from the
-- chat history.
-- 
-- Instructions that are part of the chat history SHOULD be recorded in
-- @gen_ai.input.messages@ attribute instead.
-- 
-- Instrumentations MUST follow [System instructions JSON schema](\/docs\/gen-ai\/gen-ai-system-instructions.json).
-- 
-- When recorded on spans, it MAY be recorded as a JSON string if structured
-- format is not supported and SHOULD be recorded in structured form otherwise.
-- 
-- Instrumentations MAY provide a way for users to filter or truncate
-- system instructions.
-- 
-- \> [!Warning]
-- \> This attribute may contain sensitive information.
-- 
-- See [Recording content on attributes](\/docs\/gen-ai\/gen-ai-spans.md#recording-content-on-attributes)
-- section for more details.
genAi_systemInstructions :: AttributeKey Text
genAi_systemInstructions = AttributeKey "gen_ai.system_instructions"

-- |
-- The chat history provided to the model as an input.

-- ==== Note
-- Instrumentations MUST follow [Input messages JSON schema](\/docs\/gen-ai\/gen-ai-input-messages.json).
-- When the attribute is recorded on events, it MUST be recorded in structured
-- form. When recorded on spans, it MAY be recorded as a JSON string if structured
-- format is not supported and SHOULD be recorded in structured form otherwise.
-- 
-- Messages MUST be provided in the order they were sent to the model.
-- Instrumentations MAY provide a way for users to filter or truncate
-- input messages.
-- 
-- \> [!Warning]
-- \> This attribute is likely to contain sensitive information including user\/PII data.
-- 
-- See [Recording content on attributes](\/docs\/gen-ai\/gen-ai-spans.md#recording-content-on-attributes)
-- section for more details.
genAi_input_messages :: AttributeKey Text
genAi_input_messages = AttributeKey "gen_ai.input.messages"

-- |
-- Messages returned by the model where each message represents a specific model response (choice, candidate).

-- ==== Note
-- Instrumentations MUST follow [Output messages JSON schema](\/docs\/gen-ai\/gen-ai-output-messages.json)
-- 
-- Each message represents a single output choice\/candidate generated by
-- the model. Each message corresponds to exactly one generation
-- (choice\/candidate) and vice versa - one choice cannot be split across
-- multiple messages or one message cannot contain parts from multiple choices.
-- 
-- When the attribute is recorded on events, it MUST be recorded in structured
-- form. When recorded on spans, it MAY be recorded as a JSON string if structured
-- format is not supported and SHOULD be recorded in structured form otherwise.
-- 
-- Instrumentations MAY provide a way for users to filter or truncate
-- output messages.
-- 
-- \> [!Warning]
-- \> This attribute is likely to contain sensitive information including user\/PII data.
-- 
-- See [Recording content on attributes](\/docs\/gen-ai\/gen-ai-spans.md#recording-content-on-attributes)
-- section for more details.
genAi_output_messages :: AttributeKey Text
genAi_output_messages = AttributeKey "gen_ai.output.messages"

-- |
-- The name of the evaluation metric used for the GenAI response.
genAi_evaluation_name :: AttributeKey Text
genAi_evaluation_name = AttributeKey "gen_ai.evaluation.name"

-- |
-- The evaluation score returned by the evaluator.
genAi_evaluation_score_value :: AttributeKey Double
genAi_evaluation_score_value = AttributeKey "gen_ai.evaluation.score.value"

-- |
-- Human readable label for evaluation.

-- ==== Note
-- This attribute provides a human-readable interpretation of the evaluation score produced by an evaluator. For example, a score value of 1 could mean "relevant" in one evaluation system and "not relevant" in another, depending on the scoring range and evaluator. The label SHOULD have low cardinality. Possible values depend on the evaluation metric and evaluator used; implementations SHOULD document the possible values.
genAi_evaluation_score_label :: AttributeKey Text
genAi_evaluation_score_label = AttributeKey "gen_ai.evaluation.score.label"

-- |
-- A free-form explanation for the assigned score provided by the evaluator.
genAi_evaluation_explanation :: AttributeKey Text
genAi_evaluation_explanation = AttributeKey "gen_ai.evaluation.explanation"

-- |
-- The name of the prompt that uniquely identifies it.
genAi_prompt_name :: AttributeKey Text
genAi_prompt_name = AttributeKey "gen_ai.prompt.name"

-- $metricAttributes_genAi
-- This group describes GenAI metrics attributes
--
-- === Attributes
-- - 'server_address'
--
--     GenAI server address.
--
--     Requirement level: recommended
--
-- - 'server_port'
--
--     GenAI server port.
--
--     Requirement level: conditionally required: If @server.address@ is set.
--
-- - 'genAi_response_model'
--
--     Requirement level: recommended
--
-- - 'genAi_request_model'
--
--     Requirement level: conditionally required: If available.
--
-- - 'genAi_provider_name'
--
--     Requirement level: required
--
-- - 'genAi_operation_name'
--
--     Requirement level: required
--







-- $metricAttributes_genAi_server
-- This group describes GenAI server metrics attributes
--
-- === Attributes
-- - 'error_type'
--
--     Requirement level: conditionally required: if the operation ended in an error
--
--     ==== Note
--     The @error.type@ SHOULD match the error code returned by the Generative AI service,
--     the canonical name of exception that occurred, or another low-cardinality error identifier.
--     Instrumentations SHOULD document the list of errors they report.
--


-- $metricAttributes_openai
-- This group describes GenAI server metrics attributes
--
-- === Attributes
-- - 'openai_response_serviceTier'
--
--     Requirement level: recommended
--
-- - 'openai_response_systemFingerprint'
--
--     Requirement level: recommended
--



-- $metric_genAi_client_token_usage
-- Number of input and output tokens used.
--
-- Stability: development
--
-- === Attributes
-- - 'genAi_token_type'
--
--     Requirement level: required
--


-- $metric_genAi_client_operation_duration
-- GenAI operation duration.
--
-- Stability: development
--
-- === Attributes
-- - 'error_type'
--
--     Requirement level: conditionally required: if the operation ended in an error
--
--     ==== Note
--     The @error.type@ SHOULD match the error code returned by the Generative AI provider or the client library,
--     the canonical name of exception that occurred, or another low-cardinality error identifier.
--     Instrumentations SHOULD document the list of errors they report.
--


-- $metric_genAi_server_request_duration
-- Generative AI server request duration such as time-to-last byte or last output token.
--
-- Stability: development
--

-- $metric_genAi_server_timePerOutputToken
-- Time per output token generated after the first token for successful responses.
--
-- Stability: development
--

-- $metric_genAi_server_timeToFirstToken
-- Time to generate first token for successful responses.
--
-- Stability: development
--

-- $event_genAi_client_inference_operation_details
-- Describes the details of a GenAI completion request including chat history and parameters.
--
-- Stability: development
--
-- ==== Note
-- This event is opt-in and could be used to store input and output details independently from traces.
--

-- $event_genAi_evaluation_result
-- This event captures the result of evaluating GenAI output for quality, accuracy, or other characteristics. This event SHOULD be parented to GenAI operation span being evaluated when possible or set @gen_ai.response.id@ when span id is not available.
--
-- Stability: development
--
-- === Attributes
-- - 'genAi_evaluation_name'
--
--     Requirement level: required
--
-- - 'genAi_evaluation_score_value'
--
--     Requirement level: conditionally required: if applicable
--
-- - 'genAi_evaluation_score_label'
--
--     Requirement level: conditionally required: if applicable
--
-- - 'genAi_evaluation_explanation'
--
--     Requirement level: recommended
--
-- - 'genAi_response_id'
--
--     Requirement level: recommended: when available
--
--     ==== Note
--     The unique identifier assigned to the specific
--     completion being evaluated. This attribute helps correlate the evaluation
--     event with the corresponding operation when span id is not available.
--
-- - 'error_type'
--
--     Requirement level: conditionally required: if the operation ended in an error
--
--     ==== Note
--     The @error.type@ SHOULD match the error code returned by the Generative AI Evaluation provider or the client library,
--     the canonical name of exception that occurred, or another low-cardinality error identifier.
--     Instrumentations SHOULD document the list of errors they report.
--







-- $genAi_common_event_attributes
-- Describes common Gen AI event attributes.
--
-- Stability: development
--
-- === Attributes
-- - 'genAi_system'
--


-- $registry_genAi_deprecated
-- Describes deprecated @gen_ai@ attributes.
--
-- === Attributes
-- - 'genAi_usage_promptTokens'
--
--     Stability: development
--
--     Deprecated: renamed: gen_ai.usage.input_tokens
--
-- - 'genAi_usage_completionTokens'
--
--     Stability: development
--
--     Deprecated: renamed: gen_ai.usage.output_tokens
--
-- - 'genAi_prompt'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'genAi_completion'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'genAi_system'
--
--     Stability: development
--
--     Deprecated: renamed: gen_ai.provider.name
--

-- |
-- Deprecated, use @gen_ai.usage.input_tokens@ instead.
genAi_usage_promptTokens :: AttributeKey Int64
genAi_usage_promptTokens = AttributeKey "gen_ai.usage.prompt_tokens"

-- |
-- Deprecated, use @gen_ai.usage.output_tokens@ instead.
genAi_usage_completionTokens :: AttributeKey Int64
genAi_usage_completionTokens = AttributeKey "gen_ai.usage.completion_tokens"

-- |
-- Deprecated, use Event API to report prompt contents.
genAi_prompt :: AttributeKey Text
genAi_prompt = AttributeKey "gen_ai.prompt"

-- |
-- Deprecated, use Event API to report completions contents.
genAi_completion :: AttributeKey Text
genAi_completion = AttributeKey "gen_ai.completion"

-- |
-- Deprecated, use @gen_ai.provider.name@ instead.
genAi_system :: AttributeKey Text
genAi_system = AttributeKey "gen_ai.system"

-- $registry_genAi_openai_deprecated
-- Describes deprecated @gen_ai.openai@ attributes.
--
-- === Attributes
-- - 'genAi_openai_request_seed'
--
--     Stability: development
--
--     Deprecated: renamed: gen_ai.request.seed
--
-- - 'genAi_openai_request_responseFormat'
--
--     Stability: development
--
--     Deprecated: renamed: gen_ai.output.type
--
-- - 'genAi_openai_request_serviceTier'
--
--     Stability: development
--
--     Deprecated: renamed: openai.request.service_tier
--
-- - 'genAi_openai_response_serviceTier'
--
--     Stability: development
--
--     Deprecated: renamed: openai.response.service_tier
--
-- - 'genAi_openai_response_systemFingerprint'
--
--     Stability: development
--
--     Deprecated: renamed: openai.response.system_fingerprint
--

-- |
-- Deprecated, use @gen_ai.request.seed@.
genAi_openai_request_seed :: AttributeKey Int64
genAi_openai_request_seed = AttributeKey "gen_ai.openai.request.seed"

-- |
-- Deprecated, use @gen_ai.output.type@.
genAi_openai_request_responseFormat :: AttributeKey Text
genAi_openai_request_responseFormat = AttributeKey "gen_ai.openai.request.response_format"

-- |
-- Deprecated, use @openai.request.service_tier@.
genAi_openai_request_serviceTier :: AttributeKey Text
genAi_openai_request_serviceTier = AttributeKey "gen_ai.openai.request.service_tier"

-- |
-- Deprecated, use @openai.response.service_tier@.
genAi_openai_response_serviceTier :: AttributeKey Text
genAi_openai_response_serviceTier = AttributeKey "gen_ai.openai.response.service_tier"

-- |
-- Deprecated, use @openai.response.system_fingerprint@.
genAi_openai_response_systemFingerprint :: AttributeKey Text
genAi_openai_response_systemFingerprint = AttributeKey "gen_ai.openai.response.system_fingerprint"

-- $genAi_deprecated_event_attributes
-- Describes common Gen AI event attributes.
--
-- Stability: development
--
-- === Attributes
-- - 'genAi_system'
--


-- $event_genAi_system_message
-- This event describes the system instructions passed to the GenAI model.
--
-- Stability: development
--
-- Deprecated: uncategorized
--

-- $event_genAi_user_message
-- This event describes the user message passed to the GenAI model.
--
-- Stability: development
--
-- Deprecated: uncategorized
--

-- $event_genAi_assistant_message
-- This event describes the assistant message passed to GenAI system.
--
-- Stability: development
--
-- Deprecated: uncategorized
--

-- $event_genAi_tool_message
-- This event describes the response from a tool or function call passed to the GenAI model.
--
-- Stability: development
--
-- Deprecated: uncategorized
--

-- $event_genAi_choice
-- This event describes the Gen AI response message.
--
-- Stability: development
--
-- Deprecated: uncategorized
--

-- $entity_telemetry_sdk
-- The telemetry SDK used to capture data recorded by the instrumentation libraries.
--
-- Stability: stable
--
-- === Attributes
-- - 'telemetry_sdk_name'
--
--     Requirement level: required
--
-- - 'telemetry_sdk_language'
--
--     Requirement level: required
--
-- - 'telemetry_sdk_version'
--
--     Requirement level: required
--




-- $entity_telemetry_distro
-- The distribution of telemetry SDK used to capture data recorded by the instrumentation libraries.
--
-- Stability: development
--
-- === Attributes
-- - 'telemetry_distro_name'
--
--     Requirement level: recommended
--
-- - 'telemetry_distro_version'
--
--     Requirement level: recommended
--



-- $registry_telemetry
-- This document defines attributes for telemetry SDK.
--
-- === Attributes
-- - 'telemetry_sdk_name'
--
--     Stability: stable
--
-- - 'telemetry_sdk_language'
--
--     Stability: stable
--
-- - 'telemetry_sdk_version'
--
--     Stability: stable
--
-- - 'telemetry_distro_name'
--
--     Stability: development
--
-- - 'telemetry_distro_version'
--
--     Stability: development
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

-- $registry_mainframe_lpar
-- This document defines attributes of a Mainframe Logical Partition (LPAR).
--
-- === Attributes
-- - 'mainframe_lpar_name'
--
--     Stability: development
--

-- |
-- Name of the logical partition that hosts a systems with a mainframe operating system.
mainframe_lpar_name :: AttributeKey Text
mainframe_lpar_name = AttributeKey "mainframe.lpar.name"

-- $registry_oncRpc
-- This document defines attributes for [ONC RPC (Sun RPC)](https:\/\/datatracker.ietf.org\/doc\/html\/rfc5531)
--
-- === Attributes
-- - 'oncRpc_version'
--
--     Stability: development
--
-- - 'oncRpc_procedure_number'
--
--     Stability: development
--
-- - 'oncRpc_procedure_name'
--
--     Stability: development
--
-- - 'oncRpc_program_name'
--
--     Stability: development
--

-- |
-- ONC\/Sun RPC program version.
oncRpc_version :: AttributeKey Int64
oncRpc_version = AttributeKey "onc_rpc.version"

-- |
-- ONC\/Sun RPC procedure number.
oncRpc_procedure_number :: AttributeKey Int64
oncRpc_procedure_number = AttributeKey "onc_rpc.procedure.number"

-- |
-- ONC\/Sun RPC procedure name.
oncRpc_procedure_name :: AttributeKey Text
oncRpc_procedure_name = AttributeKey "onc_rpc.procedure.name"

-- |
-- ONC\/Sun RPC program name.
oncRpc_program_name :: AttributeKey Text
oncRpc_program_name = AttributeKey "onc_rpc.program.name"

-- $entity_service
-- A logical unit of an application or system that performs a specific function.
--
-- Stability: stable
--
-- ==== Note
-- A service is a logical component used in a system, product or application. Examples include a microservice, a database, a Kubernetes deployment.
--
-- === Attributes
-- - 'service_name'
--
--     Requirement level: required
--
-- - 'service_version'
--
-- - 'service_criticality'
--
--     Requirement level: recommended
--




-- $entity_service_instance
-- A unique instance of a logical service.
--
-- Stability: stable
--
-- ==== Note
-- A @service.instance@ uniquely identifies an instance of a logical service. For example, a container that is part of a Kubernetes deployment that offers a service.
--
-- === Attributes
-- - 'service_instance_id'
--
--     Requirement level: required
--


-- $entity_service_namespace
-- Groups related services that compose a system or application under a common namespace.
--
-- Stability: stable
--
-- ==== Note
-- A @service.namespace@ can be used to logically organize and group related services under a common namespace.
--
-- === Attributes
-- - 'service_namespace'
--
--     Requirement level: required
--


-- $service_peer
-- Operations that access some remote service MAY fill out these attributes to describe that remote service.
--
-- === Attributes
-- - 'service_peer_name'
--
--     Requirement level: opt-in
--
-- - 'service_peer_namespace'
--
--     Requirement level: opt-in
--



-- $registry_service
-- A service instance.
--
-- === Attributes
-- - 'service_name'
--
--     Stability: stable
--
-- - 'service_version'
--
--     Stability: stable
--
-- - 'service_namespace'
--
--     Stability: stable
--
-- - 'service_instance_id'
--
--     Stability: stable
--
-- - 'service_criticality'
--
--     Stability: development
--

-- |
-- Logical name of the service.

-- ==== Note
-- MUST be the same for all instances of horizontally scaled services. If the value was not specified, SDKs MUST fallback to @unknown_service:@ concatenated with [@process.executable.name@](process.md), e.g. @unknown_service:bash@. If @process.executable.name@ is not available, the value MUST be set to @unknown_service@.
service_name :: AttributeKey Text
service_name = AttributeKey "service.name"

-- |
-- The version string of the service component. The format is not defined by these conventions.
service_version :: AttributeKey Text
service_version = AttributeKey "service.version"

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
-- [@\/etc\/machine-id@](https:\/\/www.freedesktop.org\/software\/systemd\/man\/latest\/machine-id.html) file, the underlying
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

-- |
-- The operational criticality of the service.

-- ==== Note
-- Application developers are encouraged to set @service.criticality@ to express the operational importance of their services. Telemetry consumers MAY use this attribute to optimize telemetry collection or improve user experience.
service_criticality :: AttributeKey Text
service_criticality = AttributeKey "service.criticality"

-- $registry_service_peer
-- How to describe the service on the other side of a request.
--
-- === Attributes
-- - 'service_peer_name'
--
--     Stability: development
--
-- - 'service_peer_namespace'
--
--     Stability: development
--

-- |
-- Logical name of the service on the other side of the connection. SHOULD be equal to the actual [@service.name@](\/docs\/resource\/README.md#service) resource attribute of the remote service if any.
service_peer_name :: AttributeKey Text
service_peer_name = AttributeKey "service.peer.name"

-- |
-- Logical namespace of the service on the other side of the connection. SHOULD be equal to the actual [@service.namespace@](\/docs\/resource\/README.md#service) resource attribute of the remote service if any.
service_peer_namespace :: AttributeKey Text
service_peer_namespace = AttributeKey "service.peer.namespace"

-- $rpc
-- This document defines semantic conventions for remote procedure calls.
--
-- === Attributes
-- - 'server_address'
--
-- - 'server_port'
--
-- - 'network_peer_address'
--
--     Requirement level: recommended
--
--     ==== Note
--     If a RPC involved multiple network calls (for example retries), the last contacted address SHOULD be used.
--
-- - 'network_peer_port'
--
--     Requirement level: recommended: If @network.peer.address@ is set.
--
-- - 'rpc_method'
--
--     Requirement level: conditionally required: if available.
--
-- - 'rpc_methodOriginal'
--
--     Requirement level: conditionally required: If and only if it\'s different than @rpc.method@.
--







-- $rpc_server
-- This document defines semantic conventions for remote procedure calls.
--
-- === Attributes
-- - 'client_address'
--
--     Requirement level: recommended
--
-- - 'client_port'
--
--     Requirement level: recommended
--



-- $span_rpc_call_client
-- This span represents an outgoing Remote Procedure Call (RPC).
--
-- Stability: release candidate
--
-- ==== Note
-- RPC client spans SHOULD cover the entire client-side lifecycle of an RPC,
-- starting when the RPC is initiated and ending when the response is received
-- or the RPC is terminated due to an error or cancellation.
-- 
-- For streaming RPCs, the span covers the full lifetime of the request and\/or
-- response streams until they are closed or terminated.
-- 
-- If a transient issue happened and was retried within this RPC, the corresponding
-- span SHOULD cover the duration of the logical call with all retries.
-- 
-- __Span name:__ refer to the [Span Name](\/docs\/rpc\/rpc-spans.md#name) section.
-- 
-- __Span kind__ MUST be @CLIENT@.
-- 
-- __Span status__: refer to the [Recording Errors](\/docs\/general\/recording-errors.md)
-- document for details on how to record span status.
--
-- === Attributes
-- - 'rpc_system_name'
--
--     Requirement level: required
--


-- $span_rpc_call_server
-- This span represents an incoming Remote Procedure Call (RPC).
--
-- Stability: release candidate
--
-- ==== Note
-- RPC server spans SHOULD cover the entire server-side lifecycle of an RPC,
-- starting when the request is received and ending when the response is sent
-- or the RPC is terminated due to an error or cancellation.
-- 
-- For streaming RPCs, the span SHOULD cover the full lifetime of the request
-- and\/or response streams until they are closed or terminated.
-- 
-- __Span name:__ refer to the [Span Name](\/docs\/rpc\/rpc-spans.md#name) section.
-- 
-- __Span kind__ MUST be @SERVER@.
-- 
-- __Span status__: refer to the [Recording Errors](\/docs\/general\/recording-errors.md)
-- document for details on how to record span status.
--
-- === Attributes
-- - 'rpc_system_name'
--
--     Requirement level: required
--


-- $span_rpc_connectRpc_call_client
-- This span represents an outgoing Remote Procedure Call (RPC).
--
-- Stability: development
--
-- ==== Note
-- @rpc.system.name@ MUST be set to @"connectrpc"@ and SHOULD be provided __at span creation time.__
-- 
-- __Span name:__ refer to the [Span Name](\/docs\/rpc\/rpc-spans.md#name) section.
-- 
-- __Span kind__ MUST be @CLIENT@.
-- 
-- __Span status__: refer to the [Recording Errors](\/docs\/general\/recording-errors.md)
-- document for details on how to record span status.
--
-- === Attributes
-- - 'rpc_response_statusCode'
--
--     The [error code](https:\/\/connectrpc.com\/\/docs\/protocol\/#error-codes) of the Connect response.
--
--     Requirement level: conditionally required: if available.
--
--     ==== Note
--     All status codes except @OK@ SHOULD be considered errors.
--
-- - 'rpc_request_metadata'
--
--     Requirement level: opt-in
--
-- - 'rpc_response_metadata'
--
--     Requirement level: opt-in
--
-- - 'server_address'
--
--     The domain name or address of the Connect RPC server.
--
--     Requirement level: required
--
--     ==== Note
--     When an IP address is provided instead of a domain name, instrumentations SHOULD NOT do a reverse proxy lookup to obtain DNS name and SHOULD set @server.address@ to the provided IP address.
--
-- - 'server_port'
--
--     Requirement level: conditionally required: if available.
--






-- $span_rpc_connectRpc_call_server
-- This span represents an incoming Remote Procedure Call (RPC).
--
-- Stability: development
--
-- ==== Note
-- @rpc.system.name@ MUST be set to @"connectrpc"@ and SHOULD be provided __at span creation time.__
-- 
-- __Span name:__ refer to the [Span Name](\/docs\/rpc\/rpc-spans.md#name) section.
-- 
-- __Span kind__ MUST be @SERVER@.
-- 
-- __Span status__: refer to the [Recording Errors](\/docs\/general\/recording-errors.md)
-- document for details on how to record span status.
--
-- === Attributes
-- - 'rpc_response_statusCode'
--
--     The [error code](https:\/\/connectrpc.com\/docs\/protocol\/#error-codes) of the Connect response.
--
--     Requirement level: conditionally required: if available.
--
--     ==== Note
--     The following error codes SHOULD be considered errors:
--     
--     - @unknown@
--     - @deadline_exceeded@
--     - @unimplemented@
--     - @internal@
--     - @unavailable@
--     - @data_loss@
--
-- - 'rpc_request_metadata'
--
--     Requirement level: opt-in
--
-- - 'rpc_response_metadata'
--
--     Requirement level: opt-in
--




-- $span_rpc_grpc_call_client
-- This span represents an outgoing Remote Procedure Call (RPC).
--
-- Stability: release candidate
--
-- ==== Note
-- @rpc.system.name@ MUST be set to @"grpc"@ and SHOULD be provided __at span creation time.__
-- 
-- __Span name:__ refer to the [Span Name](\/docs\/rpc\/rpc-spans.md#name) section.
-- 
-- __Span kind__ MUST be @CLIENT@.
-- 
-- __Span status__: refer to the [Recording Errors](\/docs\/general\/recording-errors.md)
-- document for details on how to record span status. See also @rpc.response.status_code@ attribute
-- for the details on which values classify as errors.
--
-- === Attributes
-- - 'rpc_method'
--
--     Requirement level: required
--
-- - 'rpc_response_statusCode'
--
--     The string representation of the [status code](https:\/\/github.com\/grpc\/grpc\/blob\/v1.75.0\/doc\/statuscodes.md) returned by the server or generated by the client.
--
--     Requirement level: required
--
--     ==== Note
--     All status codes except @OK@ SHOULD be considered errors.
--
-- - 'rpc_request_metadata'
--
--     Requirement level: opt-in
--
-- - 'rpc_response_metadata'
--
--     Requirement level: opt-in
--
-- - 'server_address'
--
--     Requirement level: required
--
--     ==== Note
--     Instrumentations SHOULD populate @server.address@ (along with @server.port@)
--     based on the configuration used when creating the gRPC channel and
--     SHOULD NOT use actual network-level connection information for this purpose
--     to ensure low cardinality.
--     
--     Instrumentations MAY parse address and port from the gRPC target string
--     according to the [gRPC Name Resolution specification](https:\/\/grpc.github.io\/grpc\/core\/md_doc_naming.html),
--     depending on the scheme used. Or, they MAY use gRPC client APIs that
--     provide this information.
--     
--     If the instrumentation cannot determine a server domain name or another
--     suitable low-cardinality identifier for a group of server instances
--     from the target string, it SHOULD set @server.address@ to the entire
--     target string and SHOULD NOT set @server.port@.
--     
--     When the address is an IP address, instrumentations SHOULD NOT do a
--     reverse proxy lookup to obtain a DNS name and SHOULD set @server.address@
--     to the IP address provided.
--     
--     Examples:
--     
--     - Given the target string @grpc.io:50051@, expected attributes:
--       - @server.address@: @"grpc.io"@
--       - @server.port@: @50051@
--     - Given the target string @dns:\/\/1.2.3.4\/grpc.io:50051@, expected attributes:
--       - @server.address@: @"grpc.io"@
--       - @server.port@: @50051@
--     - Given the target string @unix:\/\/\/run\/containerd\/containerd.sock@, expected attributes:
--       - @server.address@: @"\/run\/containerd\/containerd.sock"@
--       - @server.port@: not set
--     - Given the target string @zk:\/\/zookeeper:2181\/my-server@, expected attributes:
--       - @server.address@: @"zk:\/\/zookeeper:2181\/my-server"@
--       - @server.port@: not set
--     - Given the target string @ipv4:198.51.100.123:50051,198.51.100.124:50051@, expected attributes:
--       - @server.address@: @"ipv4:198.51.100.123:50051,198.51.100.124:50051"@
--       - @server.port@: not set
--
-- - 'server_port'
--
--     Requirement level: conditionally required: If and only if the port is available and @server.address@ is set.
--
--     ==== Note
--     See the @server.address@ for details on parsing the target string.
--







-- $span_rpc_grpc_call_server
-- This span represents an incoming Remote Procedure Call (RPC).
--
-- Stability: release candidate
--
-- ==== Note
-- @rpc.system.name@ MUST be set to @"grpc"@ and SHOULD be provided __at span creation time.__
-- 
-- __Span name:__ refer to the [Span Name](\/docs\/rpc\/rpc-spans.md#name) section.
-- 
-- __Span kind__ MUST be @SERVER@.
-- 
-- __Span status__: refer to the [Recording Errors](\/docs\/general\/recording-errors.md)
-- document for details on how to record span status. See also @rpc.response.status_code@ attribute
-- for the details on which values classify as errors.
--
-- === Attributes
-- - 'rpc_response_statusCode'
--
--     The string representation of the [status code](https:\/\/github.com\/grpc\/grpc\/blob\/v1.75.0\/doc\/statuscodes.md) returned by the server.
--
--     Requirement level: required
--
--     ==== Note
--     The following status codes SHOULD be considered errors:
--     
--     - @UNKNOWN@
--     - @DEADLINE_EXCEEDED@
--     - @UNIMPLEMENTED@
--     - @INTERNAL@
--     - @UNAVAILABLE@
--     - @DATA_LOSS@
--
-- - 'rpc_request_metadata'
--
--     Requirement level: opt-in
--
-- - 'rpc_response_metadata'
--
--     Requirement level: opt-in
--




-- $span_rpc_jsonrpc_call_client
-- This span represents an outgoing Remote Procedure Call (RPC).
--
-- Stability: development
--
-- ==== Note
-- @rpc.system.name@ MUST be set to @"jsonrpc"@ and SHOULD be provided __at span creation time.__
-- 
-- __Span name:__ refer to the [Span Name](\/docs\/rpc\/rpc-spans.md#name) section.
-- 
-- __Span kind__ MUST be @CLIENT@.
-- 
-- __Span status__: refer to the [Recording Errors](\/docs\/general\/recording-errors.md)
-- document for details on how to record span status. Responses that include
-- an [@error@ object](https:\/\/www.jsonrpc.org\/specification#error_object)
-- are considered errors.
--
-- === Attributes
-- - 'jsonrpc_protocol_version'
--
--     Requirement level: conditionally required: If other than the default version (@1.0@)
--
-- - 'jsonrpc_request_id'
--
--     Requirement level: recommended
--
-- - 'rpc_method'
--
--     JSON-RPC method name provided in the request.
--
--     Requirement level: opt-in
--
--     ==== Note
--     JSON-RPC supports sending and receiving arbitrary method names without prior registration or definition. As a result, the method name MAY have unbounded cardinality in edge or error cases.
--     General-purpose JSON-RPC instrumentations therefore SHOULD NOT set this attribute by default and SHOULD provide a way to configure the list of recognized RPC methods. When tracing instrumentation converts RPC method to @_OTHER@, it MUST also set @rpc.method_original@ span attribute to the original value.
--
-- - 'rpc_response_statusCode'
--
--     The [@error.code@](https:\/\/www.jsonrpc.org\/specification#error_object) property of response if it is an error response recorded as a string.
--
--     Requirement level: conditionally required: when available
--
--     ==== Note
--     All JSON RPC error codes SHOULD be considered errors.
--
-- - 'server_address'
--
--     Requirement level: recommended: Instrumentations that have access to the transport-level information and can reliably extract domain name or another low-cardinality server address from it SHOULD set this attribute.
--
--     ==== Note
--     
--






-- $span_rpc_jsonrpc_call_server
-- This span represents an incoming Remote Procedure Call (RPC).
--
-- Stability: development
--
-- ==== Note
-- @rpc.system.name@ MUST be set to @"jsonrpc"@ and SHOULD be provided __at span creation time.__
-- 
-- __Span name:__ refer to the [Span Name](\/docs\/rpc\/rpc-spans.md#name) section.
-- 
-- __Span kind__ MUST be @SERVER@.
-- 
-- __Span status__: refer to the [Recording Errors](\/docs\/general\/recording-errors.md)
-- document for details on how to record span status. Responses that include
-- an [@error@ object](https:\/\/www.jsonrpc.org\/specification#error_object)
-- are considered errors.
--
-- === Attributes
-- - 'jsonrpc_protocol_version'
--
--     Requirement level: conditionally required: If other than the default version (@1.0@)
--
-- - 'jsonrpc_request_id'
--
--     Requirement level: recommended
--
-- - 'rpc_method'
--
--     JSON-RPC method name provided in the request.
--
--     Requirement level: opt-in
--
--     ==== Note
--     JSON-RPC supports sending and receiving arbitrary method names without prior registration or definition. As a result, the method name MAY have unbounded cardinality in edge or error cases.
--     General-purpose JSON-RPC instrumentations therefore SHOULD NOT set this attribute by default and SHOULD provide a way to configure the list of recognized RPC methods. When tracing instrumentation converts RPC method to @_OTHER@, it MUST also set @rpc.method_original@ span attribute to the original value.
--
-- - 'rpc_response_statusCode'
--
--     The [@error.code@](https:\/\/www.jsonrpc.org\/specification#error_object) property of response recorded as a string.
--
--     Requirement level: conditionally required: when available
--
--     ==== Note
--     All JSON RPC error codes SHOULD be considered errors.
--





-- $span_rpc_dubbo_call_client
-- This span represents an outgoing Remote Procedure Call (RPC).
--
-- Stability: release candidate
--
-- ==== Note
-- @rpc.system.name@ MUST be set to @"dubbo"@ and SHOULD be provided __at span creation time.__
-- 
-- __Span name:__ refer to the [Span Name](\/docs\/rpc\/rpc-spans.md#name) section.
-- 
-- __Span kind__ MUST be @CLIENT@.
-- 
-- __Span status__ Refer to the [Recording Errors](\/docs\/general\/recording-errors.md)
-- document for details on how to record span status. See also @rpc.response.status_code@ attribute
-- for the details on which values classify as errors.
--
-- === Attributes
-- - 'rpc_method'
--
--     Requirement level: required
--
-- - 'rpc_response_statusCode'
--
--     The string representation of the Dubbo response status code returned by the server or generated by the client.
--
--     Requirement level: required
--
--     ==== Note
--     All status codes except @OK@ SHOULD be considered errors.
--     
--     Status codes reference:
--     
--     - Dubbo2: [Dubbo2 Protocol Status Codes](https:\/\/dubbo.apache.org\/en\/overview\/reference\/protocols\/tcp\/#protocol-specification)
--     - Dubbo3 Triple protocol: [Triple Protocol Error Codes](https:\/\/dubbo.apache.org\/en\/overview\/reference\/protocols\/triple-spec\/#311-request)
--
-- - 'server_address'
--
--     Requirement level: conditionally required: If available.
--
--     ==== Note
--     Instrumentations SHOULD populate @server.address@ (along with @server.port@)
--     based on the configuration used when creating the Dubbo client and
--     SHOULD NOT use actual network-level connection information for this purpose
--     to ensure low cardinality.
--     
--     The Dubbo registry address SHOULD NOT be used as @server.address@. Instead, use
--     the address of the actual server being called.
--     
--     - Given the target URL @dubbo:\/\/192.168.1.100:20880\/com.example.DemoService@, expected attributes:
--       - @server.address@: @"192.168.1.100"@
--       - @server.port@: @20880@
--     - Given the target URL @tri:\/\/api.example.com:50051\/com.example.GreeterService@, expected attributes:
--       - @server.address@: @"api.example.com"@
--       - @server.port@: @50051@
--     - Given the target URL @tri:\/\/api.example.com\/com.example.GreeterService@ (port not specified), expected attributes:
--       - @server.address@: @"api.example.com"@
--       - @server.port@: not set
--     
--     When the address is an IP address, instrumentations SHOULD NOT do a
--     reverse proxy lookup to obtain a DNS name and SHOULD set @server.address@
--     to the IP address provided.
--
-- - 'server_port'
--
--     Requirement level: conditionally required: if @server.address@ is set and if the port is supported by the network transport used for communication.
--
--     ==== Note
--     See the @server.address@ for details on parsing the target string.
--
-- - 'rpc_request_metadata'
--
--     Requirement level: opt-in
--
-- - 'rpc_response_metadata'
--
--     Requirement level: opt-in
--







-- $span_rpc_dubbo_call_server
-- This span represents an incoming Remote Procedure Call (RPC).
--
-- Stability: release candidate
--
-- ==== Note
-- @rpc.system.name@ MUST be set to @"dubbo"@ and SHOULD be provided __at span creation time.__
-- 
-- __Span name:__ refer to the [Span Name](\/docs\/rpc\/rpc-spans.md#name) section.
-- 
-- __Span kind__ MUST be @SERVER@.
-- 
-- __Span status__ Refer to the [Recording Errors](\/docs\/general\/recording-errors.md)
-- document for details on how to record span status. See also @rpc.response.status_code@ attribute
-- for the details on which values classify as errors.
--
-- === Attributes
-- - 'rpc_response_statusCode'
--
--     The string representation of the Dubbo response status code returned by the server.
--
--     Requirement level: required
--
--     ==== Note
--     For Dubbo2, the following status codes SHOULD be considered errors:
--     
--     - @SERVER_ERROR@
--     - @SERVER_THREADPOOL_EXHAUSTED_ERROR@
--     - @SERVER_TIMEOUT@
--     - @SERVICE_ERROR@
--     
--     For Dubbo3 Triple protocol, the following status codes SHOULD be considered errors:
--     
--     - @DATA_LOSS@
--     - @DEADLINE_EXCEEDED@
--     - @INTERNAL@
--     - @UNAVAILABLE@
--     - @UNIMPLEMENTED@
--     - @UNKNOWN@
--     
--     Status codes reference:
--     
--     - Dubbo2: [Dubbo2 Protocol Status Codes](https:\/\/dubbo.apache.org\/en\/overview\/reference\/protocols\/tcp\/#protocol-specification)
--     - Dubbo3 Triple protocol: [Triple Protocol Error Codes](https:\/\/dubbo.apache.org\/en\/overview\/reference\/protocols\/triple-spec\/#311-request)
--
-- - 'server_port'
--
--     Requirement level: conditionally required: if @server.address@ is set and if the port is supported by the network transport used for communication.
--
-- - 'rpc_request_metadata'
--
--     Requirement level: opt-in
--
-- - 'rpc_response_metadata'
--
--     Requirement level: opt-in
--





-- $common_rpc_attributes
-- Common attributes for RPC spans and metrics.
--
-- === Attributes
-- - 'rpc_method'
--
-- - 'server_address'
--
--     A string identifying a group of RPC server instances request is sent to.
--
--     Requirement level: conditionally required: If available.
--
--     ==== Note
--     May contain a DNS name, an endpoint and path in the service registry, local socket name or an IP address.
--     Semantic conventions for individual RPC systems SHOULD document how to populate this attribute.
--     When address is an IP address, instrumentations SHOULD NOT do a reverse DNS lookup to obtain a DNS name and SHOULD set @server.address@ to the provided IP address.
--
-- - 'server_port'
--
--     Requirement level: conditionally required: if applicable and if @server.address@ is set.
--
-- - 'rpc_response_statusCode'
--
--     Requirement level: conditionally required: if available.
--
-- - 'error_type'
--
--     Requirement level: conditionally required: If and only if the operation failed.
--
--     ==== Note
--     If the RPC fails with an error before status code is returned,
--     @error.type@ SHOULD be set to the exception type (its fully-qualified class name, if applicable)
--     or a component-specific, low cardinality error identifier.
--     
--     If a response status code is returned and status indicates an error,
--     @error.type@ SHOULD be set to that status code. Check system-specific conventions
--     for the details on which values of @rpc.response.status_code@ are considered errors.
--     
--     The @error.type@ value SHOULD be predictable and SHOULD have low cardinality.
--     Instrumentations SHOULD document the list of errors they report.
--     
--     If the request has completed successfully, instrumentations SHOULD NOT set
--     @error.type@.
--






-- $registry_rpc
-- This document defines attributes for remote procedure calls.
--
-- === Attributes
-- - 'rpc_response_statusCode'
--
--     Stability: release candidate
--
-- - 'rpc_request_metadata'
--
--     Stability: development
--
-- - 'rpc_response_metadata'
--
--     Stability: development
--
-- - 'rpc_method'
--
--     Stability: release candidate
--
-- - 'rpc_methodOriginal'
--
--     Stability: release candidate
--
-- - 'rpc_system_name'
--
--     Stability: release candidate
--

-- |
-- Status code of the RPC returned by the RPC server or generated by the client

-- ==== Note
-- Usually it represents an error code, but may also represent partial success, warning, or differentiate between various types of successful outcomes.
-- Semantic conventions for individual RPC frameworks SHOULD document what @rpc.response.status_code@ means in the context of that system and which values are considered to represent errors.
rpc_response_statusCode :: AttributeKey Text
rpc_response_statusCode = AttributeKey "rpc.response.status_code"

-- |
-- RPC request metadata, @\<key\>@ being the normalized RPC metadata key (lowercase), the value being the metadata values.

-- ==== Note
-- Instrumentations SHOULD require an explicit configuration of which metadata values are to be captured.
-- Including all request metadata values can be a security risk - explicit configuration helps avoid leaking sensitive information.
-- 
-- For example, a property @my-custom-key@ with value @["1.2.3.4", "1.2.3.5"]@ SHOULD be recorded as
-- @rpc.request.metadata.my-custom-key@ attribute with value @["1.2.3.4", "1.2.3.5"]@
rpc_request_metadata :: Text -> AttributeKey [Text]
rpc_request_metadata = \k -> AttributeKey $ "rpc.request.metadata." <> k

-- |
-- RPC response metadata, @\<key\>@ being the normalized RPC metadata key (lowercase), the value being the metadata values.

-- ==== Note
-- Instrumentations SHOULD require an explicit configuration of which metadata values are to be captured.
-- Including all response metadata values can be a security risk - explicit configuration helps avoid leaking sensitive information.
-- 
-- For example, a property @my-custom-key@ with value @["attribute_value"]@ SHOULD be recorded as
-- the @rpc.response.metadata.my-custom-key@ attribute with value @["attribute_value"]@
rpc_response_metadata :: Text -> AttributeKey [Text]
rpc_response_metadata = \k -> AttributeKey $ "rpc.response.metadata." <> k

-- |
-- The fully-qualified logical name of the method from the RPC interface perspective.

-- ==== Note
-- The method name MAY have unbounded cardinality in edge or error cases.
-- 
-- Some RPC frameworks or libraries provide a fixed set of recognized methods
-- for client stubs and server implementations. Instrumentations for such
-- frameworks MUST set this attribute to the original method name only
-- when the method is recognized by the framework or library.
-- 
-- When the method is not recognized, for example, when the server receives
-- a request for a method that is not predefined on the server, or when
-- instrumentation is not able to reliably detect if the method is predefined,
-- the attribute MUST be set to @_OTHER@. In such cases, tracing
-- instrumentations MUST also set @rpc.method_original@ attribute to
-- the original method value.
-- 
-- If the RPC instrumentation could end up converting valid RPC methods to
-- @_OTHER@, then it SHOULD provide a way to configure the list of recognized
-- RPC methods.
-- 
-- The @rpc.method@ can be different from the name of any implementing
-- method\/function.
-- The @code.function.name@ attribute may be used to record the fully-qualified
-- method actually executing the call on the server side, or the
-- RPC client stub method on the client side.
rpc_method :: AttributeKey Text
rpc_method = AttributeKey "rpc.method"

-- |
-- The original name of the method used by the client.
rpc_methodOriginal :: AttributeKey Text
rpc_methodOriginal = AttributeKey "rpc.method_original"

-- |
-- The Remote Procedure Call (RPC) system.

-- ==== Note
-- The client and server RPC systems may differ for the same RPC interaction. For example, a client may use Apache Dubbo or Connect RPC to communicate with a server that uses gRPC since both protocols provide compatibility with gRPC.
rpc_system_name :: AttributeKey Text
rpc_system_name = AttributeKey "rpc.system.name"

-- $attributes_metrics_rpc_client
-- RPC client metric attributes.
--
-- === Attributes
-- - 'rpc_system_name'
--
--     Requirement level: required
--
-- - 'server_address'
--
-- - 'server_port'
--
-- - 'rpc_method'
--
--     Requirement level: conditionally required: if available.
--





-- $attributes_metrics_rpc_server
-- RPC server metric attributes.
--
-- === Attributes
-- - 'rpc_system_name'
--
--     Requirement level: required
--
-- - 'server_address'
--
--     Requirement level: opt-in
--
--     ==== Note
--     
--
-- - 'server_port'
--
--     Requirement level: opt-in
--
--     ==== Note
--     
--
-- - 'rpc_method'
--
--     Requirement level: conditionally required: if available.
--





-- $metric_rpc_server_call_duration
-- Measures the duration of an incoming Remote Procedure Call (RPC).
--
-- Stability: release candidate
--
-- ==== Note
-- When this metric is reported alongside an RPC server span, the metric value
-- SHOULD be the same as the RPC server span duration.
--

-- $metric_rpc_client_call_duration
-- Measures the duration of an outgoing Remote Procedure Call (RPC).
--
-- Stability: release candidate
--
-- ==== Note
-- When this metric is reported alongside an RPC client span, the metric value
-- SHOULD be the same as the RPC client span duration.
--

-- $event_rpc_client_call_exception
-- This event represents an exception that occurred during an outgoing RPC call, such as network failures, timeouts, serialization errors, or other errors that prevent the call from completing successfully.
--
-- Stability: development
--
-- ==== Note
-- This event SHOULD be recorded when an exception occurs during RPC client call operations.
-- Instrumentations SHOULD set the severity to WARN (severity number 13) when recording this event.
-- Instrumentations MAY provide a configuration option to populate exception events with the attributes captured on the corresponding RPC client span.
--
-- === Attributes
-- - 'exception_type'
--
--     Requirement level: conditionally required: Required if @exception.message@ is not set, recommended otherwise.
--
-- - 'exception_message'
--
--     Requirement level: conditionally required: Required if @exception.type@ is not set, recommended otherwise.
--
-- - 'exception_stacktrace'
--




-- $event_rpc_server_call_exception
-- This event represents an exception that occurred during incoming RPC call processing, such as application errors, internal failures, or other exceptions that prevent the server from successfully handling the call.
--
-- Stability: development
--
-- ==== Note
-- This event SHOULD be recorded when an exception occurs during RPC server call processing.
-- Instrumentations SHOULD set the severity to ERROR (severity number 17) when recording this event.
-- Instrumentations MAY provide a configuration option to populate exception events with the attributes captured on the corresponding RPC server span.
--
-- === Attributes
-- - 'exception_type'
--
--     Requirement level: conditionally required: Required if @exception.message@ is not set, recommended otherwise.
--
-- - 'exception_message'
--
--     Requirement level: conditionally required: Required if @exception.type@ is not set, recommended otherwise.
--
-- - 'exception_stacktrace'
--




-- $registry_rpc_deprecated
-- Deprecated rpc message attributes.
--
-- === Attributes
-- - 'message_type'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'message_id'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'message_compressedSize'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'message_uncompressedSize'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'rpc_connectRpc_request_metadata'
--
--     Stability: development
--
--     Deprecated: renamed: rpc.request.metadata
--
-- - 'rpc_connectRpc_response_metadata'
--
--     Stability: development
--
--     Deprecated: renamed: rpc.response.metadata
--
-- - 'rpc_grpc_request_metadata'
--
--     Stability: development
--
--     Deprecated: renamed: rpc.request.metadata
--
-- - 'rpc_grpc_response_metadata'
--
--     Stability: development
--
--     Deprecated: renamed: rpc.response.metadata
--
-- - 'rpc_grpc_statusCode'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'rpc_connectRpc_errorCode'
--
--     Stability: development
--
--     Deprecated: renamed: rpc.response.status_code
--
-- - 'rpc_jsonrpc_errorCode'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'rpc_jsonrpc_errorMessage'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'rpc_system'
--
--     Stability: development
--
--     Deprecated: renamed: rpc.system.name
--
-- - 'rpc_jsonrpc_requestId'
--
--     Stability: development
--
--     Deprecated: renamed: jsonrpc.request.id
--
-- - 'rpc_jsonrpc_version'
--
--     Stability: development
--
--     Deprecated: renamed: jsonrpc.protocol.version
--
-- - 'rpc_service'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'rpc_message_type'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'rpc_message_id'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'rpc_message_compressedSize'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'rpc_message_uncompressedSize'
--
--     Stability: development
--
--     Deprecated: obsoleted
--

-- |
-- Deprecated, no replacement at this time.
message_type :: AttributeKey Text
message_type = AttributeKey "message.type"

-- |
-- Deprecated, no replacement at this time.
message_id :: AttributeKey Int64
message_id = AttributeKey "message.id"

-- |
-- Deprecated, no replacement at this time.
message_compressedSize :: AttributeKey Int64
message_compressedSize = AttributeKey "message.compressed_size"

-- |
-- Deprecated, no replacement at this time.
message_uncompressedSize :: AttributeKey Int64
message_uncompressedSize = AttributeKey "message.uncompressed_size"

-- |
-- Deprecated, use @rpc.request.metadata@ instead.
rpc_connectRpc_request_metadata :: Text -> AttributeKey [Text]
rpc_connectRpc_request_metadata = \k -> AttributeKey $ "rpc.connect_rpc.request.metadata." <> k

-- |
-- Deprecated, use @rpc.response.metadata@ instead.
rpc_connectRpc_response_metadata :: Text -> AttributeKey [Text]
rpc_connectRpc_response_metadata = \k -> AttributeKey $ "rpc.connect_rpc.response.metadata." <> k

-- |
-- Deprecated, use @rpc.request.metadata@ instead.
rpc_grpc_request_metadata :: Text -> AttributeKey [Text]
rpc_grpc_request_metadata = \k -> AttributeKey $ "rpc.grpc.request.metadata." <> k

-- |
-- Deprecated, use @rpc.response.metadata@ instead.
rpc_grpc_response_metadata :: Text -> AttributeKey [Text]
rpc_grpc_response_metadata = \k -> AttributeKey $ "rpc.grpc.response.metadata." <> k

-- |
-- Deprecated, use string representation on the @rpc.response.status_code@ attribute instead.
rpc_grpc_statusCode :: AttributeKey Text
rpc_grpc_statusCode = AttributeKey "rpc.grpc.status_code"

-- |
-- Deprecated, use @rpc.response.status_code@ attribute instead.
rpc_connectRpc_errorCode :: AttributeKey Text
rpc_connectRpc_errorCode = AttributeKey "rpc.connect_rpc.error_code"

-- |
-- Deprecated, use string representation on the @rpc.response.status_code@ attribute instead.
rpc_jsonrpc_errorCode :: AttributeKey Int64
rpc_jsonrpc_errorCode = AttributeKey "rpc.jsonrpc.error_code"

-- |
-- Deprecated, use the span status description when reporting JSON-RPC spans.
rpc_jsonrpc_errorMessage :: AttributeKey Text
rpc_jsonrpc_errorMessage = AttributeKey "rpc.jsonrpc.error_message"

-- |
-- Deprecated, use @rpc.system.name@ attribute instead.
rpc_system :: AttributeKey Text
rpc_system = AttributeKey "rpc.system"

-- |
-- Deprecated, use @jsonrpc.request.id@ instead.
rpc_jsonrpc_requestId :: AttributeKey Text
rpc_jsonrpc_requestId = AttributeKey "rpc.jsonrpc.request_id"

-- |
-- Deprecated, use @jsonrpc.protocol.version@ instead.
rpc_jsonrpc_version :: AttributeKey Text
rpc_jsonrpc_version = AttributeKey "rpc.jsonrpc.version"

-- |
-- Deprecated, use fully-qualified @rpc.method@ instead.
rpc_service :: AttributeKey Text
rpc_service = AttributeKey "rpc.service"

-- |
-- Whether this is a received or sent message.
rpc_message_type :: AttributeKey Text
rpc_message_type = AttributeKey "rpc.message.type"

-- |
-- MUST be calculated as two different counters starting from @1@ one for sent messages and one for received message.

-- ==== Note
-- This way we guarantee that the values will be consistent between different implementations.
rpc_message_id :: AttributeKey Int64
rpc_message_id = AttributeKey "rpc.message.id"

-- |
-- Compressed size of the message in bytes.
rpc_message_compressedSize :: AttributeKey Int64
rpc_message_compressedSize = AttributeKey "rpc.message.compressed_size"

-- |
-- Uncompressed size of the message in bytes.
rpc_message_uncompressedSize :: AttributeKey Int64
rpc_message_uncompressedSize = AttributeKey "rpc.message.uncompressed_size"

-- $event_rpc_message
-- Describes a message sent or received within the context of an RPC call.
--
-- Stability: development
--
-- Deprecated: obsoleted
--
-- ==== Note
-- In the lifetime of an RPC stream, an event for each message sent\/received on client and server spans SHOULD be created. In case of unary calls message events SHOULD NOT be recorded.
--
-- === Attributes
-- - 'rpc_message_type'
--
--     Requirement level: recommended
--
-- - 'rpc_message_id'
--
--     Requirement level: recommended
--
-- - 'rpc_message_compressedSize'
--
--     Requirement level: recommended
--
-- - 'rpc_message_uncompressedSize'
--
--     Requirement level: recommended
--





-- $metric_rpc_client_requestsPerRpc
-- Measures the number of messages received per RPC.
--
-- Stability: development
--
-- Deprecated: obsoleted
--
-- ==== Note
-- Should be 1 for all non-streaming RPCs.
-- 
-- __Streaming__: This metric is required for server and client streaming RPCs
--

-- $metric_rpc_client_responsesPerRpc
-- Measures the number of messages sent per RPC.
--
-- Stability: development
--
-- Deprecated: obsoleted
--
-- ==== Note
-- Should be 1 for all non-streaming RPCs.
-- 
-- __Streaming__: This metric is required for server and client streaming RPCs
--

-- $metric_rpc_server_requestsPerRpc
-- Measures the number of messages received per RPC.
--
-- Stability: development
--
-- Deprecated: obsoleted
--
-- ==== Note
-- Should be 1 for all non-streaming RPCs.
-- 
-- __Streaming__ : This metric is required for server and client streaming RPCs
--

-- $metric_rpc_server_responsesPerRpc
-- Measures the number of messages sent per RPC.
--
-- Stability: development
--
-- Deprecated: obsoleted
--
-- ==== Note
-- Should be 1 for all non-streaming RPCs.
-- 
-- __Streaming__: This metric is required for server and client streaming RPCs
--

-- $metric_rpc_server_duration
-- Deprecated, use @rpc.server.call.duration@ instead. Note: the unit also changed from @ms@ to @s@.
--
-- Stability: development
--
-- Deprecated: uncategorized
--
-- ==== Note
-- While streaming RPCs may record this metric as start-of-batch
-- to end-of-batch, it\'s hard to interpret in practice.
-- 
-- __Streaming__: N\/A.
--

-- $metric_rpc_client_duration
-- Deprecated, use @rpc.client.call.duration@ instead. Note: the unit also changed from @ms@ to @s@.
--
-- Stability: development
--
-- Deprecated: uncategorized
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
-- Stability: development
--
-- Deprecated: obsoleted
--
-- ==== Note
-- __Streaming__: Recorded per message in a streaming batch
--

-- $metric_rpc_server_response_size
-- Measures the size of RPC response messages (uncompressed).
--
-- Stability: development
--
-- Deprecated: obsoleted
--
-- ==== Note
-- __Streaming__: Recorded per response in a streaming batch
--

-- $metric_rpc_client_request_size
-- Measures the size of RPC request messages (uncompressed).
--
-- Stability: development
--
-- Deprecated: obsoleted
--
-- ==== Note
-- __Streaming__: Recorded per message in a streaming batch
--

-- $metric_rpc_client_response_size
-- Measures the size of RPC response messages (uncompressed).
--
-- Stability: development
--
-- Deprecated: obsoleted
--
-- ==== Note
-- __Streaming__: Recorded per response in a streaming batch
--

-- $registry_dns
-- This document defines the shared attributes used to report a DNS query.
--
-- === Attributes
-- - 'dns_question_name'
--
--     Stability: development
--
-- - 'dns_answers'
--
--     Stability: development
--

-- |
-- The name being queried.

-- ==== Note
-- The name represents the queried domain name as it appears in the DNS query without any additional normalization.
dns_question_name :: AttributeKey Text
dns_question_name = AttributeKey "dns.question.name"

-- |
-- The list of IPv4 or IPv6 addresses resolved during DNS lookup.
dns_answers :: AttributeKey [Text]
dns_answers = AttributeKey "dns.answers"

-- $metric_dns_lookup_duration
-- Measures the time taken to perform a DNS lookup.
--
-- Stability: development
--
-- === Attributes
-- - 'dns_question_name'
--
--     Requirement level: required
--
-- - 'error_type'
--
--     Describes the error the DNS lookup failed with.
--
--     Requirement level: conditionally required: if and only if an error has occurred.
--
--     ==== Note
--     Instrumentations SHOULD use error code such as one of errors reported by @getaddrinfo@([Linux or other POSIX systems](https:\/\/man7.org\/linux\/man-pages\/man3\/getaddrinfo.3.html) \/ [Windows](https:\/\/learn.microsoft.com\/windows\/win32\/api\/ws2tcpip\/nf-ws2tcpip-getaddrinfo)) or one reported by the runtime or client library. If error code is not available, the full name of exception type SHOULD be used.
--



-- $thread
-- These attributes may be used for any operation to store information about a thread that started a span.
--
-- === Attributes
-- - 'thread_id'
--
-- - 'thread_name'
--



-- $registry_thread
-- These attributes may be used for any operation to store information about a thread that started a span.
--
-- === Attributes
-- - 'thread_id'
--
--     Stability: development
--
-- - 'thread_name'
--
--     Stability: development
--

-- |
-- Current "managed" thread ID (as opposed to OS thread ID).

-- ==== Note
-- 
-- Examples of where the value can be extracted from:
-- 
-- | Language or platform | Source |
-- | --- | --- |
-- | JVM | @Thread.currentThread().threadId()@ |
-- | .NET | @Thread.CurrentThread.ManagedThreadId@ |
-- | Python | @threading.current_thread().ident@ |
-- | Ruby | @Thread.current.object_id@ |
-- | C++ | @std::this_thread::get_id()@ |
-- | Erlang | @erlang:self()@ |
thread_id :: AttributeKey Int64
thread_id = AttributeKey "thread.id"

-- |
-- Current thread name.

-- ==== Note
-- 
-- Examples of where the value can be extracted from:
-- 
-- | Language or platform | Source |
-- | --- | --- |
-- | JVM | @Thread.currentThread().getName()@ |
-- | .NET | @Thread.CurrentThread.Name@ |
-- | Python | @threading.current_thread().name@ |
-- | Ruby | @Thread.current.name@ |
-- | Erlang | @erlang:process_info(self(), registered_name)@ |
thread_name :: AttributeKey Text
thread_name = AttributeKey "thread.name"

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
-- The @error.type@ SHOULD be predictable, and SHOULD have low cardinality.
-- 
-- When @error.type@ is set to a type (e.g., an exception type), its
-- canonical class name identifying the type within the artifact SHOULD be used.
-- 
-- Instrumentations SHOULD document the list of errors they report.
-- 
-- The cardinality of @error.type@ within one instrumentation library SHOULD be low.
-- Telemetry consumers that aggregate data from multiple instrumentation libraries and applications
-- should be prepared for @error.type@ to have high cardinality at query time when no
-- additional filters are applied.
-- 
-- If the operation has completed successfully, instrumentations SHOULD NOT set @error.type@.
-- 
-- If a specific domain defines its own set of error identifiers (such as HTTP or RPC status codes),
-- it\'s RECOMMENDED to:
-- 
-- - Use a domain-specific attribute
-- - Set @error.type@ to capture all errors, regardless of whether they are defined within the domain-specific set or not.
error_type :: AttributeKey Text
error_type = AttributeKey "error.type"

-- $registry_error_deprecated
-- This document defines deprecated attributes used to report an error.
--
-- === Attributes
-- - 'error_message'
--
--     Stability: development
--
--     Deprecated: obsoleted
--

-- |
-- A message providing more detail about an error in human-readable form.

-- ==== Note
-- @error.message@ should provide additional context and detail about an error.
-- It is NOT RECOMMENDED to duplicate the value of @error.type@ in @error.message@.
-- It is also NOT RECOMMENDED to duplicate the value of @exception.message@ in @error.message@.
-- 
-- @error.message@ is NOT RECOMMENDED for metrics or spans due to its unbounded cardinality and overlap with span status.
error_message :: AttributeKey Text
error_message = AttributeKey "error.message"

-- $attributes_messaging_trace_minimal
-- Defines minimal set of attributes used by all messaging systems.
--
-- Stability: development
--
-- === Attributes
-- - 'messaging_operation_name'
--
--     Requirement level: required
--
-- - 'messaging_operation_type'
--
--     Requirement level: conditionally required: If applicable.
--
-- - 'messaging_destination_name'
--
--     Requirement level: conditionally required: If span describes operation on a single message or if the value applies to all messages in the batch.
--
-- - 'messaging_message_id'
--
--     Requirement level: recommended: If span describes operation on a single message.
--
-- - 'server_address'
--
-- - 'server_port'
--







-- $messaging_attributes
-- Defines a full set of attributes used in messaging systems.
--
-- Stability: development
--
-- === Attributes
-- - 'messaging_system'
--
--     Requirement level: required
--
-- - 'messaging_client_id'
--
--     Requirement level: recommended
--
-- - 'messaging_destination_partition_id'
--
--     Requirement level: recommended: When applicable.
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
-- - 'messaging_consumer_group_name'
--
--     Requirement level: conditionally required: If applicable.
--
-- - 'messaging_destination_subscription_name'
--
--     Requirement level: conditionally required: If applicable.
--
-- - 'messaging_message_conversationId'
--
-- - 'messaging_message_envelope_size'
--
--     Requirement level: opt-in
--
-- - 'messaging_message_body_size'
--
--     Requirement level: opt-in
--
-- - 'messaging_batch_messageCount'
--
--     Requirement level: conditionally required: If the span describes an operation on a batch of messages.
--
-- - 'network_peer_address'
--
--     Peer address of the messaging intermediary node where the operation was performed.
--
--     Requirement level: recommended: If applicable for this messaging system.
--
--     ==== Note
--     Semantic conventions for individual messaging systems SHOULD document whether @network.peer.*@ attributes are applicable.
--     Network peer address and port are important when the application interacts with individual intermediary nodes directly,
--     If a messaging operation involved multiple network calls (for example retries), the address of the last contacted node SHOULD be used.
--
-- - 'network_peer_port'
--
--     Peer port of the messaging intermediary node where the operation was performed.
--
--     Requirement level: recommended: if and only if @network.peer.address@ is set.
--















-- $messaging_network_attributes
-- Attributes that describe messaging operation along with network information.
--
-- Stability: development
--
-- === Attributes
-- - 'network_peer_address'
--
--     Requirement level: recommended
--
--     ==== Note
--     If an operation involved multiple network calls (for example retries), the address of the last contacted node SHOULD be used.
--
-- - 'network_peer_port'
--
--     Requirement level: recommended
--



-- $messaging_rabbitmq
-- Attributes for RabbitMQ
--
-- Stability: development
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
-- - 'messaging_message_conversationId'
--
--     Message [correlation Id](https:\/\/www.rabbitmq.com\/tutorials\/tutorial-six-java#correlation-id) property.
--
-- - 'messaging_message_body_size'
--
--     Requirement level: opt-in
--
-- - 'messaging_destination_name'
--
--     Requirement level: required
--
--     ==== Note
--     In RabbitMQ, the destination is defined by an *exchange*, a *routing key* and for consumers, a *queue*.
--     
--     @messaging.destination.name@ SHOULD be set to:
--     
--     - __On the producer side__: @{exchange}:{routing key}@ when both values are present and non-empty.
--     When only one is available, only that value SHOULD be used. E.g., @{exchange}@ or @{routing key}@.
--     Otherwise: @amq.default@ when the default exchange is used and no routing key is provided
--     
--     - __On the consumer side__: @{exchange}:{routing key}:{queue}@ when all values are present and non-empty.
--     If any has an empty value (e.g., the default exchange is used) it SHOULD be omitted.
--     For cases when @{routing key}@ and @{queue}@ are equal, only one of them SHOULD
--     be used, e.g., @{exchange}:{routing key}@.
--






-- $messaging_kafka
-- Attributes for Apache Kafka
--
-- Stability: development
--
-- === Attributes
-- - 'messaging_consumer_group_name'
--
--     Kafka [consumer group id](https:\/\/docs.confluent.io\/platform\/current\/clients\/consumer.html).
--
--     ==== Note
--     
--
-- - 'messaging_destination_partition_id'
--
--     String representation of the partition id the message (or batch) is sent to or received from.
--
--     Requirement level: recommended
--
-- - 'messaging_kafka_message_key'
--
--     Requirement level: recommended: If span describes operation on a single message.
--
-- - 'messaging_kafka_offset'
--
--     Requirement level: recommended: If span describes operation on a single message.
--
-- - 'messaging_kafka_message_tombstone'
--
--     Requirement level: conditionally required: If value is @true@. When missing, the value is assumed to be @false@.
--
-- - 'messaging_batch_messageCount'
--
--     Requirement level: conditionally required: If the span describes an operation on a batch of messages.
--
-- - 'messaging_client_id'
--
-- - 'messaging_message_body_size'
--
--     The size of the message body in bytes. Only applicable for spans describing single message operations.
--
--     Requirement level: opt-in
--









-- $messaging_rocketmq
-- Attributes for Apache RocketMQ
--
-- Stability: development
--
-- === Attributes
-- - 'messaging_consumer_group_name'
--
--     RocketMQ [consumer group name](https:\/\/rocketmq.apache.org\/docs\/domainModel\/07consumergroup).
--
--     Requirement level: required
--
--     ==== Note
--     
--
-- - 'messaging_rocketmq_namespace'
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
-- - 'messaging_client_id'
--
-- - 'messaging_message_body_size'
--
--     Requirement level: opt-in
--
-- - 'messaging_batch_messageCount'
--
--     Requirement level: conditionally required: If the span describes an operation on a batch of messages.
--













-- $messaging_gcpPubsub
-- Attributes for Google Cloud Pub\/Sub
--
-- Stability: development
--
-- === Attributes
-- - 'messaging_destination_subscription_name'
--
--     Google Pub\/Sub [subscription name](https:\/\/cloud.google.com\/pubsub\/docs\/subscription-overview).
--
--     ==== Note
--     
--
-- - 'messaging_gcpPubsub_message_orderingKey'
--
--     Requirement level: conditionally required: If the message type has an ordering key set.
--
-- - 'messaging_gcpPubsub_message_deliveryAttempt'
--
-- - 'messaging_gcpPubsub_message_ackDeadline'
--
-- - 'messaging_gcpPubsub_message_ackId'
--
-- - 'messaging_batch_messageCount'
--
--     Requirement level: conditionally required: If the span describes an operation on a batch of messages.
--
-- - 'messaging_operation_name'
--
--     ==== Note
--     The @messaging.operation.name@ has the following list of well-known values in the context of Google Pub\/Sub.
--     If one of them applies, then the respective value MUST be used; otherwise, a custom value MAY be used.
--     
--     - @ack@ and @nack@ for settlement operations
--     - @send@ for publishing operations
--     - @modack@ for extending the lease for a single message or batch of messages
--     - @subscribe@ for operations that represent the time from after the message was received to when the message is acknowledged, negatively acknowledged, or expired.
--     - @create@ and @receive@ for [common messaging operations](\/docs\/messaging\/messaging-spans.md#operation-types)
--








-- $messaging_servicebus
-- Attributes for Azure Service Bus
--
-- Stability: development
--
-- === Attributes
-- - 'messaging_destination_subscription_name'
--
--     Azure Service Bus [subscription name](https:\/\/learn.microsoft.com\/azure\/service-bus-messaging\/service-bus-queues-topics-subscriptions#topics-and-subscriptions).
--
--     Requirement level: conditionally required: If messages are received from the subscription.
--
--     ==== Note
--     
--
-- - 'messaging_servicebus_message_deliveryCount'
--
--     Requirement level: conditionally required: If delivery count is available and is bigger than 0.
--
-- - 'messaging_servicebus_message_enqueuedTime'
--
-- - 'messaging_servicebus_dispositionStatus'
--
--     Requirement level: conditionally required: if and only if @messaging.operation@ is @settle@.
--
-- - 'messaging_message_conversationId'
--
--     Message [correlation Id](https:\/\/learn.microsoft.com\/azure\/service-bus-messaging\/service-bus-messages-payloads#message-routing-and-correlation) property.
--
-- - 'messaging_batch_messageCount'
--
--     Requirement level: conditionally required: If the span describes an operation on a batch of messages.
--
-- - 'messaging_operation_name'
--
--     Azure Service Bus operation name.
--
--     ==== Note
--     The operation name SHOULD match one of the following values:
--     
--     - sender operations: @send@, @schedule@, @cancel_scheduled@
--     - transaction operations: @create_transaction@, @commit_transaction@, @rollback_transaction@
--     - receiver operation: @receive@, @peek@, @receive_deferred@, @renew_message_lock@
--     - settlement operations: @abandon@, @complete@, @defer@, @dead_letter@, @delete@
--     - session operations: @accept_session@, @get_session_state@, @set_session_state@, @renew_session_lock@
--     
--     If none of the above operation names apply, the attribute SHOULD be set
--     to the name of the client method in snake_case.
--








-- $messaging_eventhubs
-- Attributes for Azure Event Hubs
--
-- Stability: development
--
-- === Attributes
-- - 'messaging_consumer_group_name'
--
--     Azure Event Hubs [consumer group name](https:\/\/learn.microsoft.com\/azure\/event-hubs\/event-hubs-features#consumer-groups).
--
--     Requirement level: conditionally required: On consumer spans.
--
--     ==== Note
--     
--
-- - 'messaging_destination_partition_id'
--
--     String representation of the partition id messages are sent to or received from, unique within the Event Hub.
--
--     Requirement level: conditionally required: If available.
--
-- - 'messaging_eventhubs_message_enqueuedTime'
--
-- - 'messaging_batch_messageCount'
--
--     Requirement level: conditionally required: If the span describes an operation on a batch of messages.
--
-- - 'messaging_operation_name'
--
--     Azure Event Hubs operation name.
--
--     ==== Note
--     The operation name SHOULD match one of the following values:
--     
--     - @send@
--     - @receive@
--     - @process@
--     - @checkpoint@
--     - @get_partition_properties@
--     - @get_event_hub_properties@
--     
--     If none of the above operation names apply, the attribute SHOULD be set
--     to the name of the client method in snake_case.
--






-- $messaging_aws_sqs
-- Attributes that exist for SQS request types.
--
-- Stability: development
--
-- === Attributes
-- - 'aws_sqs_queue_url'
--
--     Requirement level: recommended
--
-- - 'aws_requestId'
--
--     Requirement level: recommended
--



-- $messaging_aws_sns
-- Attributes that exist for SNS request types.
--
-- Stability: development
--
-- === Attributes
-- - 'aws_sns_topic_arn'
--
--     Requirement level: recommended
--
-- - 'aws_requestId'
--
--     Requirement level: recommended
--



-- $attributes_messaging_common_minimal
-- Common cross-signal messaging attributes.
--
-- Stability: development
--
-- === Attributes
-- - 'error_type'
--
--     Requirement level: conditionally required: If and only if the messaging operation has failed.
--
-- - 'server_address'
--
--     Requirement level: conditionally required: If available.
--
--     ==== Note
--     Server domain name of the broker if available without reverse DNS lookup; otherwise, IP address or Unix domain socket name.
--
-- - 'server_port'
--
-- - 'messaging_operation_name'
--
--     Requirement level: required
--





-- $registry_messaging
-- Attributes describing telemetry around messaging systems and messaging activities.
--
-- Stability: development
--
-- === Attributes
-- - 'messaging_batch_messageCount'
--
--     Stability: development
--
-- - 'messaging_client_id'
--
--     Stability: development
--
-- - 'messaging_consumer_group_name'
--
--     Stability: development
--
-- - 'messaging_destination_name'
--
--     Stability: development
--
-- - 'messaging_destination_subscription_name'
--
--     Stability: development
--
-- - 'messaging_destination_template'
--
--     Stability: development
--
-- - 'messaging_destination_anonymous'
--
--     Stability: development
--
-- - 'messaging_destination_temporary'
--
--     Stability: development
--
-- - 'messaging_destination_partition_id'
--
--     Stability: development
--
-- - 'messaging_message_conversationId'
--
--     Stability: development
--
-- - 'messaging_message_envelope_size'
--
--     Stability: development
--
-- - 'messaging_message_id'
--
--     Stability: development
--
-- - 'messaging_message_body_size'
--
--     Stability: development
--
-- - 'messaging_operation_type'
--
--     Stability: development
--
-- - 'messaging_operation_name'
--
--     Stability: development
--
-- - 'messaging_system'
--
--     Stability: development
--

-- |
-- The number of messages sent, received, or processed in the scope of the batching operation.

-- ==== Note
-- Instrumentations SHOULD NOT set @messaging.batch.message_count@ on spans that operate with a single message. When a messaging client library supports both batch and single-message API for the same operation, instrumentations SHOULD use @messaging.batch.message_count@ for batching APIs and SHOULD NOT use it for single-message APIs.
messaging_batch_messageCount :: AttributeKey Int64
messaging_batch_messageCount = AttributeKey "messaging.batch.message_count"

-- |
-- A unique identifier for the client that consumes or produces a message.
messaging_client_id :: AttributeKey Text
messaging_client_id = AttributeKey "messaging.client.id"

-- |
-- The name of the consumer group with which a consumer is associated.

-- ==== Note
-- Semantic conventions for individual messaging systems SHOULD document whether @messaging.consumer.group.name@ is applicable and what it means in the context of that system.
messaging_consumer_group_name :: AttributeKey Text
messaging_consumer_group_name = AttributeKey "messaging.consumer.group.name"

-- |
-- The message destination name

-- ==== Note
-- Destination name SHOULD uniquely identify a specific queue, topic or other entity within the broker. If
-- the broker doesn\'t have such notion, the destination name SHOULD uniquely identify the broker.
messaging_destination_name :: AttributeKey Text
messaging_destination_name = AttributeKey "messaging.destination.name"

-- |
-- The name of the destination subscription from which a message is consumed.

-- ==== Note
-- Semantic conventions for individual messaging systems SHOULD document whether @messaging.destination.subscription.name@ is applicable and what it means in the context of that system.
messaging_destination_subscription_name :: AttributeKey Text
messaging_destination_subscription_name = AttributeKey "messaging.destination.subscription.name"

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
-- The identifier of the partition messages are sent to or received from, unique within the @messaging.destination.name@.
messaging_destination_partition_id :: AttributeKey Text
messaging_destination_partition_id = AttributeKey "messaging.destination.partition.id"

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
-- A string identifying the type of the messaging operation.

-- ==== Note
-- If a custom value is used, it MUST be of low cardinality.
messaging_operation_type :: AttributeKey Text
messaging_operation_type = AttributeKey "messaging.operation.type"

-- |
-- The system-specific name of the messaging operation.
messaging_operation_name :: AttributeKey Text
messaging_operation_name = AttributeKey "messaging.operation.name"

-- |
-- The messaging system as identified by the client instrumentation.

-- ==== Note
-- The actual messaging system may differ from the one known by the client. For example, when using Kafka client libraries to communicate with Azure Event Hubs, the @messaging.system@ is set to @kafka@ based on the instrumentation\'s best knowledge.
messaging_system :: AttributeKey Text
messaging_system = AttributeKey "messaging.system"

-- $registry_messaging_kafka
-- This group describes attributes specific to Apache Kafka.
--
-- === Attributes
-- - 'messaging_kafka_message_key'
--
--     Stability: development
--
-- - 'messaging_kafka_offset'
--
--     Stability: development
--
-- - 'messaging_kafka_message_tombstone'
--
--     Stability: development
--

-- |
-- Message keys in Kafka are used for grouping alike messages to ensure they\'re processed on the same partition. They differ from @messaging.message.id@ in that they\'re not unique. If the key is @null@, the attribute MUST NOT be set.

-- ==== Note
-- If the key type is not string, it\'s string representation has to be supplied for the attribute. If the key has no unambiguous, canonical string form, don\'t include its value.
messaging_kafka_message_key :: AttributeKey Text
messaging_kafka_message_key = AttributeKey "messaging.kafka.message.key"

-- |
-- The offset of a record in the corresponding Kafka partition.
messaging_kafka_offset :: AttributeKey Int64
messaging_kafka_offset = AttributeKey "messaging.kafka.offset"

-- |
-- A boolean that is true if the message is a tombstone.
messaging_kafka_message_tombstone :: AttributeKey Bool
messaging_kafka_message_tombstone = AttributeKey "messaging.kafka.message.tombstone"

-- $registry_messaging_rabbitmq
-- This group describes attributes specific to RabbitMQ.
--
-- === Attributes
-- - 'messaging_rabbitmq_destination_routingKey'
--
--     Stability: development
--
-- - 'messaging_rabbitmq_message_deliveryTag'
--
--     Stability: development
--

-- |
-- RabbitMQ message routing key.
messaging_rabbitmq_destination_routingKey :: AttributeKey Text
messaging_rabbitmq_destination_routingKey = AttributeKey "messaging.rabbitmq.destination.routing_key"

-- |
-- RabbitMQ message delivery tag
messaging_rabbitmq_message_deliveryTag :: AttributeKey Int64
messaging_rabbitmq_message_deliveryTag = AttributeKey "messaging.rabbitmq.message.delivery_tag"

-- $registry_messaging_rocketmq
-- This group describes attributes specific to RocketMQ.
--
-- === Attributes
-- - 'messaging_rocketmq_consumptionModel'
--
--     Stability: development
--
-- - 'messaging_rocketmq_message_delayTimeLevel'
--
--     Stability: development
--
-- - 'messaging_rocketmq_message_deliveryTimestamp'
--
--     Stability: development
--
-- - 'messaging_rocketmq_message_group'
--
--     Stability: development
--
-- - 'messaging_rocketmq_message_keys'
--
--     Stability: development
--
-- - 'messaging_rocketmq_message_tag'
--
--     Stability: development
--
-- - 'messaging_rocketmq_message_type'
--
--     Stability: development
--
-- - 'messaging_rocketmq_namespace'
--
--     Stability: development
--

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

-- $registry_messaging_gcpPubsub
-- This group describes attributes specific to GCP Pub\/Sub.
--
-- === Attributes
-- - 'messaging_gcpPubsub_message_orderingKey'
--
--     Stability: development
--
-- - 'messaging_gcpPubsub_message_ackId'
--
--     Stability: development
--
-- - 'messaging_gcpPubsub_message_ackDeadline'
--
--     Stability: development
--
-- - 'messaging_gcpPubsub_message_deliveryAttempt'
--
--     Stability: development
--

-- |
-- The ordering key for a given message. If the attribute is not present, the message does not have an ordering key.
messaging_gcpPubsub_message_orderingKey :: AttributeKey Text
messaging_gcpPubsub_message_orderingKey = AttributeKey "messaging.gcp_pubsub.message.ordering_key"

-- |
-- The ack id for a given message.
messaging_gcpPubsub_message_ackId :: AttributeKey Text
messaging_gcpPubsub_message_ackId = AttributeKey "messaging.gcp_pubsub.message.ack_id"

-- |
-- The ack deadline in seconds set for the modify ack deadline request.
messaging_gcpPubsub_message_ackDeadline :: AttributeKey Int64
messaging_gcpPubsub_message_ackDeadline = AttributeKey "messaging.gcp_pubsub.message.ack_deadline"

-- |
-- The delivery attempt for a given message.
messaging_gcpPubsub_message_deliveryAttempt :: AttributeKey Int64
messaging_gcpPubsub_message_deliveryAttempt = AttributeKey "messaging.gcp_pubsub.message.delivery_attempt"

-- $registry_messaging_servicebus
-- This group describes attributes specific to Azure Service Bus.
--
-- === Attributes
-- - 'messaging_servicebus_message_deliveryCount'
--
--     Stability: development
--
-- - 'messaging_servicebus_message_enqueuedTime'
--
--     Stability: development
--
-- - 'messaging_servicebus_dispositionStatus'
--
--     Stability: development
--

-- |
-- Number of deliveries that have been attempted for this message.
messaging_servicebus_message_deliveryCount :: AttributeKey Int64
messaging_servicebus_message_deliveryCount = AttributeKey "messaging.servicebus.message.delivery_count"

-- |
-- The UTC epoch seconds at which the message has been accepted and stored in the entity.
messaging_servicebus_message_enqueuedTime :: AttributeKey Int64
messaging_servicebus_message_enqueuedTime = AttributeKey "messaging.servicebus.message.enqueued_time"

-- |
-- Describes the [settlement type](https:\/\/learn.microsoft.com\/azure\/service-bus-messaging\/message-transfers-locks-settlement#peeklock).
messaging_servicebus_dispositionStatus :: AttributeKey Text
messaging_servicebus_dispositionStatus = AttributeKey "messaging.servicebus.disposition_status"

-- $registry_messaging_eventhubs
-- This group describes attributes specific to Azure Event Hubs.
--
-- === Attributes
-- - 'messaging_eventhubs_message_enqueuedTime'
--
--     Stability: development
--

-- |
-- The UTC epoch seconds at which the message has been accepted and stored in the entity.
messaging_eventhubs_message_enqueuedTime :: AttributeKey Int64
messaging_eventhubs_message_enqueuedTime = AttributeKey "messaging.eventhubs.message.enqueued_time"

-- $metric_messaging_attributes
-- Common messaging metrics attributes.
--
-- Stability: development
--
-- === Attributes
-- - 'messaging_system'
--
--     Requirement level: required
--
-- - 'messaging_destination_partition_id'
--
-- - 'messaging_destination_name'
--
--     Requirement level: conditionally required: if and only if @messaging.destination.name@ is known to have low cardinality. Otherwise, @messaging.destination.template@ MAY be populated.
--
-- - 'messaging_destination_template'
--
--     Requirement level: conditionally required: if available.
--





-- $metric_messaging_consumer_attributes
-- Messaging consumer metrics attributes.
--
-- Stability: development
--
-- === Attributes
-- - 'messaging_consumer_group_name'
--
--     Requirement level: conditionally required: if applicable.
--
-- - 'messaging_destination_subscription_name'
--
--     Requirement level: conditionally required: if applicable.
--



-- $metric_messaging_client_operation_duration
-- Duration of messaging operation initiated by a producer or consumer client.
--
-- Stability: development
--
-- ==== Note
-- This metric SHOULD NOT be used to report processing duration - processing duration is reported in @messaging.process.duration@ metric.
--
-- === Attributes
-- - 'messaging_operation_type'
--
--     Requirement level: conditionally required: If applicable.
--
-- - 'messaging_operation_name'
--



-- $metric_messaging_process_duration
-- Duration of processing operation.
--
-- Stability: development
--
-- ==== Note
-- This metric MUST be reported for operations with @messaging.operation.type@ that matches @process@.
--
-- === Attributes
-- - 'messaging_operation_name'
--


-- $metric_messaging_client_sent_messages
-- Number of messages producer attempted to send to the broker.
--
-- Stability: development
--
-- ==== Note
-- This metric MUST NOT count messages that were created but haven\'t yet been sent.
--
-- === Attributes
-- - 'messaging_operation_name'
--


-- $metric_messaging_client_consumed_messages
-- Number of messages that were delivered to the application.
--
-- Stability: development
--
-- ==== Note
-- Records the number of messages pulled from the broker or number of messages dispatched to the application in push-based scenarios.
-- The metric SHOULD be reported once per message delivery. For example, if receiving and processing operations are both instrumented for a single message delivery, this counter is incremented when the message is received and not reported when it is processed.
--
-- === Attributes
-- - 'messaging_operation_name'
--


-- $registry_messaging_deprecated
-- Describes deprecated messaging attributes.
--
-- Stability: development
--
-- === Attributes
-- - 'messaging_kafka_destination_partition'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'messaging_operation'
--
--     Stability: development
--
--     Deprecated: renamed: messaging.operation.type
--
-- - 'messaging_clientId'
--
--     Stability: development
--
--     Deprecated: renamed: messaging.client.id
--
-- - 'messaging_kafka_consumer_group'
--
--     Stability: development
--
--     Deprecated: renamed: messaging.consumer.group.name
--
-- - 'messaging_rocketmq_clientGroup'
--
--     Stability: development
--
--     Deprecated: uncategorized
--
-- - 'messaging_eventhubs_consumer_group'
--
--     Stability: development
--
--     Deprecated: renamed: messaging.consumer.group.name
--
-- - 'messaging_servicebus_destination_subscriptionName'
--
--     Stability: development
--
--     Deprecated: renamed: messaging.destination.subscription.name
--
-- - 'messaging_kafka_message_offset'
--
--     Stability: development
--
--     Deprecated: renamed: messaging.kafka.offset
--
-- - 'messaging_destinationPublish_anonymous'
--
--     Stability: development
--
--     Deprecated: obsoleted
--
-- - 'messaging_destinationPublish_name'
--
--     Stability: development
--
--     Deprecated: obsoleted
--

-- |
-- Deprecated, use @messaging.destination.partition.id@ instead.
messaging_kafka_destination_partition :: AttributeKey Int64
messaging_kafka_destination_partition = AttributeKey "messaging.kafka.destination.partition"

-- |
-- Deprecated, use @messaging.operation.type@ instead.
messaging_operation :: AttributeKey Text
messaging_operation = AttributeKey "messaging.operation"

-- |
-- Deprecated, use @messaging.client.id@ instead.
messaging_clientId :: AttributeKey Text
messaging_clientId = AttributeKey "messaging.client_id"

-- |
-- Deprecated, use @messaging.consumer.group.name@ instead.
messaging_kafka_consumer_group :: AttributeKey Text
messaging_kafka_consumer_group = AttributeKey "messaging.kafka.consumer.group"

-- |
-- Deprecated, use @messaging.consumer.group.name@ instead.
messaging_rocketmq_clientGroup :: AttributeKey Text
messaging_rocketmq_clientGroup = AttributeKey "messaging.rocketmq.client_group"

-- |
-- Deprecated, use @messaging.consumer.group.name@ instead.
messaging_eventhubs_consumer_group :: AttributeKey Text
messaging_eventhubs_consumer_group = AttributeKey "messaging.eventhubs.consumer.group"

-- |
-- Deprecated, use @messaging.destination.subscription.name@ instead.
messaging_servicebus_destination_subscriptionName :: AttributeKey Text
messaging_servicebus_destination_subscriptionName = AttributeKey "messaging.servicebus.destination.subscription_name"

-- |
-- Deprecated, use @messaging.kafka.offset@ instead.
messaging_kafka_message_offset :: AttributeKey Int64
messaging_kafka_message_offset = AttributeKey "messaging.kafka.message.offset"

-- |
-- Deprecated, no replacement at this time.
messaging_destinationPublish_anonymous :: AttributeKey Bool
messaging_destinationPublish_anonymous = AttributeKey "messaging.destination_publish.anonymous"

-- |
-- Deprecated, no replacement at this time.
messaging_destinationPublish_name :: AttributeKey Text
messaging_destinationPublish_name = AttributeKey "messaging.destination_publish.name"

-- $metric_messaging_publish_duration
-- Deprecated. Use @messaging.client.operation.duration@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: messaging.client.operation.duration
--

-- $metric_messaging_receive_duration
-- Deprecated. Use @messaging.client.operation.duration@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: messaging.client.operation.duration
--

-- $metric_messaging_process_messages
-- Deprecated. Use @messaging.client.consumed.messages@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: messaging.client.consumed.messages
--

-- $metric_messaging_publish_messages
-- Deprecated. Use @messaging.client.sent.messages@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: messaging.client.sent.messages
--

-- $metric_messaging_receive_messages
-- Deprecated. Use @messaging.client.consumed.messages@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: messaging.client.consumed.messages
--

-- $metric_messaging_client_published_messages
-- Deprecated. Use @messaging.client.sent.messages@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: messaging.client.sent.messages
--

-- $registry_event_deprecated
-- Attributes for Events represented using Log Records.
--
-- === Attributes
-- - 'event_name'
--
--     Stability: development
--
--     Deprecated: uncategorized
--

-- |
-- Identifies the class \/ type of event.
event_name :: AttributeKey Text
event_name = AttributeKey "event.name"

-- $client
-- General client attributes.
--
-- === Attributes
-- - 'client_address'
--
-- - 'client_port'
--



-- $registry_client
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

-- $registry_oracledb
-- This section defines attributes for Oracle Database.
--
-- === Attributes
-- - 'oracle_db_name'
--
--     Stability: development
--
-- - 'oracle_db_domain'
--
--     Stability: development
--
-- - 'oracle_db_instance_name'
--
--     Stability: development
--
-- - 'oracle_db_pdb'
--
--     Stability: development
--
-- - 'oracle_db_service'
--
--     Stability: development
--

-- |
-- The database name associated with the connection.

-- ==== Note
-- This attribute SHOULD be set to the value of the parameter @DB_NAME@ exposed in @v$parameter@.
oracle_db_name :: AttributeKey Text
oracle_db_name = AttributeKey "oracle.db.name"

-- |
-- The database domain associated with the connection.

-- ==== Note
-- This attribute SHOULD be set to the value of the @DB_DOMAIN@ initialization parameter,
-- as exposed in @v$parameter@. @DB_DOMAIN@ defines the domain portion of the global
-- database name and SHOULD be configured when a database is, or may become, part of a
-- distributed environment. Its value consists of one or more valid identifiers
-- (alphanumeric ASCII characters) separated by periods.
oracle_db_domain :: AttributeKey Text
oracle_db_domain = AttributeKey "oracle.db.domain"

-- |
-- The instance name associated with the connection in an Oracle Real Application Clusters environment.

-- ==== Note
-- There can be multiple instances associated with a single database service. It indicates the
-- unique instance name to which the connection is currently bound. For non-RAC databases, this value
-- defaults to the @oracle.db.name@.
oracle_db_instance_name :: AttributeKey Text
oracle_db_instance_name = AttributeKey "oracle.db.instance.name"

-- |
-- The pluggable database (PDB) name associated with the connection.

-- ==== Note
-- This attribute SHOULD reflect the PDB that the session is currently connected to.
-- If instrumentation cannot reliably obtain the active PDB name for each operation
-- without issuing an additional query (such as @SELECT SYS_CONTEXT@), it is
-- RECOMMENDED to fall back to the PDB name specified at connection establishment.
oracle_db_pdb :: AttributeKey Text
oracle_db_pdb = AttributeKey "oracle.db.pdb"

-- |
-- The service name currently associated with the database connection.

-- ==== Note
-- The effective service name for a connection can change during its lifetime,
-- for example after executing sql, @ALTER SESSION@. If an instrumentation cannot reliably
-- obtain the current service name for each operation without issuing an additional
-- query (such as @SELECT SYS_CONTEXT@), it is RECOMMENDED to fall back to the
-- service name originally provided at connection establishment.
oracle_db_service :: AttributeKey Text
oracle_db_service = AttributeKey "oracle.db.service"

-- $registry_elasticsearch
-- This section defines attributes for Elasticsearch.
--
-- === Attributes
-- - 'elasticsearch_node_name'
--
--     Stability: development
--

-- |
-- Represents the human-readable identifier of the node\/instance to which a request was routed.
elasticsearch_node_name :: AttributeKey Text
elasticsearch_node_name = AttributeKey "elasticsearch.node.name"

-- $registry_openai
-- This group defines attributes for OpenAI.
--
-- === Attributes
-- - 'openai_request_serviceTier'
--
--     Stability: development
--
-- - 'openai_api_type'
--
--     Stability: development
--
-- - 'openai_response_serviceTier'
--
--     Stability: development
--
-- - 'openai_response_systemFingerprint'
--
--     Stability: development
--

-- |
-- The service tier requested. May be a specific tier, default, or auto.
openai_request_serviceTier :: AttributeKey Text
openai_request_serviceTier = AttributeKey "openai.request.service_tier"

-- |
-- The type of OpenAI API being used.
openai_api_type :: AttributeKey Text
openai_api_type = AttributeKey "openai.api.type"

-- |
-- The service tier used for the response.
openai_response_serviceTier :: AttributeKey Text
openai_response_serviceTier = AttributeKey "openai.response.service_tier"

-- |
-- A fingerprint to track any eventual change in the Generative AI environment.
openai_response_systemFingerprint :: AttributeKey Text
openai_response_systemFingerprint = AttributeKey "openai.response.system_fingerprint"

-- $entity_process
-- An operating system process.
--
-- Stability: development
--
-- === Attributes
-- - 'process_pid'
--
-- - 'process_parentPid'
--
-- - 'process_executable_name'
--
--     Requirement level: conditionally required: See [Selecting process attributes](\/docs\/resource\/process.md#selecting-process-attributes) for details.
--
-- - 'process_executable_path'
--
--     Requirement level: conditionally required: See [Selecting process attributes](\/docs\/resource\/process.md#selecting-process-attributes) for details.
--
-- - 'process_command'
--
--     Requirement level: conditionally required: See [Selecting process attributes](\/docs\/resource\/process.md#selecting-process-attributes) for details.
--
-- - 'process_commandLine'
--
--     Requirement level: conditionally required: See [Selecting process attributes](\/docs\/resource\/process.md#selecting-process-attributes) for details.
--
-- - 'process_commandArgs'
--
--     Requirement level: conditionally required: See [Selecting process attributes](\/docs\/resource\/process.md#selecting-process-attributes) for details.
--
-- - 'process_argsCount'
--
--     Requirement level: conditionally required: See [Selecting process attributes](\/docs\/resource\/process.md#selecting-process-attributes) for details.
--
-- - 'process_creation_time'
--
-- - 'process_interactive'
--
-- - 'process_title'
--
-- - 'process_workingDirectory'
--
-- - 'process_owner'
--
-- - 'process_linux_cgroup'
--















-- $entity_process_runtime
-- The single (language) runtime instance which is monitored.
--
-- Stability: development
--
-- === Attributes
-- - 'process_runtime_name'
--
-- - 'process_runtime_version'
--
-- - 'process_runtime_description'
--




-- $registry_process
-- An operating system process.
--
-- === Attributes
-- - 'process_pid'
--
--     Stability: development
--
-- - 'process_parentPid'
--
--     Stability: development
--
-- - 'process_vpid'
--
--     Stability: development
--
-- - 'process_sessionLeader_pid'
--
--     Stability: development
--
-- - 'process_groupLeader_pid'
--
--     Stability: development
--
-- - 'process_executable_buildId_gnu'
--
--     Stability: development
--
-- - 'process_executable_buildId_go'
--
--     Stability: development
--
-- - 'process_executable_buildId_htlhash'
--
--     Stability: development
--
-- - 'process_executable_name'
--
--     Stability: development
--
-- - 'process_executable_path'
--
--     Stability: development
--
-- - 'process_command'
--
--     Stability: development
--
-- - 'process_commandLine'
--
--     Stability: development
--
-- - 'process_commandArgs'
--
--     Stability: development
--
-- - 'process_argsCount'
--
--     Stability: development
--
-- - 'process_owner'
--
--     Stability: development
--
-- - 'process_user_id'
--
--     Stability: development
--
-- - 'process_user_name'
--
--     Stability: development
--
-- - 'process_realUser_id'
--
--     Stability: development
--
-- - 'process_realUser_name'
--
--     Stability: development
--
-- - 'process_savedUser_id'
--
--     Stability: development
--
-- - 'process_savedUser_name'
--
--     Stability: development
--
-- - 'process_runtime_name'
--
--     Stability: development
--
-- - 'process_runtime_version'
--
--     Stability: development
--
-- - 'process_runtime_description'
--
--     Stability: development
--
-- - 'process_title'
--
--     Stability: development
--
-- - 'process_creation_time'
--
--     Stability: development
--
-- - 'process_exit_time'
--
--     Stability: development
--
-- - 'process_exit_code'
--
--     Stability: development
--
-- - 'process_interactive'
--
--     Stability: development
--
-- - 'process_workingDirectory'
--
--     Stability: development
--
-- - 'process_contextSwitch_type'
--
--     Stability: development
--
-- - 'process_environmentVariable'
--
--     Stability: development
--
-- - 'process_state'
--
--     Stability: development
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
-- Virtual process identifier.

-- ==== Note
-- The process ID within a PID namespace. This is not necessarily unique across all processes on the host but it is unique within the process namespace that the process exists within.
process_vpid :: AttributeKey Int64
process_vpid = AttributeKey "process.vpid"

-- |
-- The PID of the process\'s session leader. This is also the session ID (SID) of the process.
process_sessionLeader_pid :: AttributeKey Int64
process_sessionLeader_pid = AttributeKey "process.session_leader.pid"

-- |
-- The PID of the process\'s group leader. This is also the process group ID (PGID) of the process.
process_groupLeader_pid :: AttributeKey Int64
process_groupLeader_pid = AttributeKey "process.group_leader.pid"

-- |
-- The GNU build ID as found in the @.note.gnu.build-id@ ELF section (hex string).
process_executable_buildId_gnu :: AttributeKey Text
process_executable_buildId_gnu = AttributeKey "process.executable.build_id.gnu"

-- |
-- The Go build ID as retrieved by @go tool buildid \<go executable\>@.
process_executable_buildId_go :: AttributeKey Text
process_executable_buildId_go = AttributeKey "process.executable.build_id.go"

-- |
-- Profiling specific build ID for executables. See the OTel specification for Profiles for more information.
process_executable_buildId_htlhash :: AttributeKey Text
process_executable_buildId_htlhash = AttributeKey "process.executable.build_id.htlhash"

-- |
-- The name of the process executable. On Linux based systems, this SHOULD be set to the base name of the target of @\/proc\/[pid]\/exe@. On Windows, this SHOULD be set to the base name of @GetProcessImageFileNameW@.
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
-- The full command used to launch the process as a single string representing the full command. On Windows, can be set to the result of @GetCommandLineW@. Do not set this if you have to assemble it just for monitoring; use @process.command_args@ instead. SHOULD NOT be collected by default unless there is sanitization that excludes sensitive data.
process_commandLine :: AttributeKey Text
process_commandLine = AttributeKey "process.command_line"

-- |
-- All the command arguments (including the command\/executable itself) as received by the process. On Linux-based systems (and some other Unixoid systems supporting procfs), can be set according to the list of null-delimited strings extracted from @proc\/[pid]\/cmdline@. For libc-based executables, this would be the full argv vector passed to @main@. SHOULD NOT be collected by default unless there is sanitization that excludes sensitive data.
process_commandArgs :: AttributeKey [Text]
process_commandArgs = AttributeKey "process.command_args"

-- |
-- Length of the process.command_args array

-- ==== Note
-- This field can be useful for querying or performing bucket analysis on how many arguments were provided to start a process. More arguments may be an indication of suspicious activity.
process_argsCount :: AttributeKey Int64
process_argsCount = AttributeKey "process.args_count"

-- |
-- The username of the user that owns the process.
process_owner :: AttributeKey Text
process_owner = AttributeKey "process.owner"

-- |
-- The effective user ID (EUID) of the process.
process_user_id :: AttributeKey Int64
process_user_id = AttributeKey "process.user.id"

-- |
-- The username of the effective user of the process.
process_user_name :: AttributeKey Text
process_user_name = AttributeKey "process.user.name"

-- |
-- The real user ID (RUID) of the process.
process_realUser_id :: AttributeKey Int64
process_realUser_id = AttributeKey "process.real_user.id"

-- |
-- The username of the real user of the process.
process_realUser_name :: AttributeKey Text
process_realUser_name = AttributeKey "process.real_user.name"

-- |
-- The saved user ID (SUID) of the process.
process_savedUser_id :: AttributeKey Int64
process_savedUser_id = AttributeKey "process.saved_user.id"

-- |
-- The username of the saved user.
process_savedUser_name :: AttributeKey Text
process_savedUser_name = AttributeKey "process.saved_user.name"

-- |
-- The name of the runtime of this process.
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

-- |
-- Process title (proctitle)

-- ==== Note
-- In many Unix-like systems, process title (proctitle), is the string that represents the name or command line of a running process, displayed by system monitoring tools like ps, top, and htop.
process_title :: AttributeKey Text
process_title = AttributeKey "process.title"

-- |
-- The date and time the process was created, in ISO 8601 format.
process_creation_time :: AttributeKey Text
process_creation_time = AttributeKey "process.creation.time"

-- |
-- The date and time the process exited, in ISO 8601 format.
process_exit_time :: AttributeKey Text
process_exit_time = AttributeKey "process.exit.time"

-- |
-- The exit code of the process.
process_exit_code :: AttributeKey Int64
process_exit_code = AttributeKey "process.exit.code"

-- |
-- Whether the process is connected to an interactive shell.
process_interactive :: AttributeKey Bool
process_interactive = AttributeKey "process.interactive"

-- |
-- The working directory of the process.
process_workingDirectory :: AttributeKey Text
process_workingDirectory = AttributeKey "process.working_directory"

-- |
-- Specifies whether the context switches for this data point were voluntary or involuntary.
process_contextSwitch_type :: AttributeKey Text
process_contextSwitch_type = AttributeKey "process.context_switch.type"

-- |
-- Process environment variables, @\<key\>@ being the environment variable name, the value being the environment variable value.

-- ==== Note
-- Examples:
-- 
-- - an environment variable @USER@ with value @"ubuntu"@ SHOULD be recorded
-- as the @process.environment_variable.USER@ attribute with value @"ubuntu"@.
-- 
-- - an environment variable @PATH@ with value @"\/usr\/local\/bin:\/usr\/bin"@
-- SHOULD be recorded as the @process.environment_variable.PATH@ attribute
-- with value @"\/usr\/local\/bin:\/usr\/bin"@.
process_environmentVariable :: Text -> AttributeKey Text
process_environmentVariable = \k -> AttributeKey $ "process.environment_variable." <> k

-- |
-- The process state, e.g., [Linux Process State Codes](https:\/\/man7.org\/linux\/man-pages\/man1\/ps.1.html#PROCESS_STATE_CODES)
process_state :: AttributeKey Text
process_state = AttributeKey "process.state"

-- $registry_process_linux
-- Describes Linux Process attributes
--
-- === Attributes
-- - 'process_linux_cgroup'
--
--     Stability: development
--

-- |
-- The control group associated with the process.

-- ==== Note
-- Control groups (cgroups) are a kernel feature used to organize and manage process resources. This attribute provides the path(s) to the cgroup(s) associated with the process, which should match the contents of the [\/proc\/\[PID\]\/cgroup](https:\/\/man7.org\/linux\/man-pages\/man7\/cgroups.7.html) file.
process_linux_cgroup :: AttributeKey Text
process_linux_cgroup = AttributeKey "process.linux.cgroup"

-- $metric_process_cpu_time
-- Total CPU seconds broken down by different states.
--
-- Stability: development
--
-- === Attributes
-- - 'cpu_mode'
--
--     A process SHOULD be characterized _either_ by data points with no @mode@ labels, _or only_ data points with @mode@ labels.
--
--     ==== Note
--     Following states SHOULD be used: @user@, @system@, @wait@
--


-- $metric_process_cpu_utilization
-- Difference in process.cpu.time since the last measurement, divided by the elapsed time and number of CPUs available to the process.
--
-- Stability: development
--
-- === Attributes
-- - 'cpu_mode'
--
--     A process SHOULD be characterized _either_ by data points with no @mode@ labels, _or only_ data points with @mode@ labels.
--
--     ==== Note
--     Following states SHOULD be used: @user@, @system@, @wait@
--


-- $metric_process_memory_usage
-- The amount of physical memory in use.
--
-- Stability: development
--

-- $metric_process_memory_virtual
-- The amount of committed virtual memory.
--
-- Stability: development
--

-- $metric_process_disk_io
-- Disk bytes transferred.
--
-- Stability: development
--
-- === Attributes
-- - 'disk_io_direction'
--


-- $metric_process_network_io
-- Network bytes transferred.
--
-- Stability: development
--
-- === Attributes
-- - 'network_io_direction'
--


-- $metric_process_thread_count
-- Process threads count.
--
-- Stability: development
--

-- $metric_process_unix_fileDescriptor_count
-- Number of unix file descriptors in use by the process.
--
-- Stability: development
--

-- $metric_process_windows_handle_count
-- Number of handles held by the process.
--
-- Stability: development
--

-- $metric_process_contextSwitches
-- Number of times the process has been context switched.
--
-- Stability: development
--
-- === Attributes
-- - 'process_contextSwitch_type'
--


-- $metric_process_paging_faults
-- Number of page faults the process has made.
--
-- Stability: development
--
-- === Attributes
-- - 'system_paging_fault_type'
--


-- $metric_process_uptime
-- The time the process has been running.
--
-- Stability: development
--
-- ==== Note
-- Instrumentations SHOULD use a gauge with type @double@ and measure uptime in seconds as a floating point number with the highest precision available.
-- The actual accuracy would depend on the instrumentation and operating system.
--

-- $registry_process_deprecated
-- Deprecated process attributes.
--
-- === Attributes
-- - 'process_cpu_state'
--
--     Stability: development
--
--     Deprecated: renamed: cpu.mode
--
-- - 'process_executable_buildId_profiling'
--
--     Stability: development
--
--     Deprecated: renamed: process.executable.build_id.htlhash
--
-- - 'process_contextSwitchType'
--
--     Stability: development
--
--     Deprecated: renamed: process.context_switch.type
--
-- - 'process_paging_faultType'
--
--     Stability: development
--
--     Deprecated: renamed: system.paging.fault.type
--

-- |
-- Deprecated, use @cpu.mode@ instead.
process_cpu_state :: AttributeKey Text
process_cpu_state = AttributeKey "process.cpu.state"

-- |
-- "Deprecated, use @process.executable.build_id.htlhash@ instead."
process_executable_buildId_profiling :: AttributeKey Text
process_executable_buildId_profiling = AttributeKey "process.executable.build_id.profiling"

-- |
-- "Deprecated, use @process.context_switch.type@ instead."
process_contextSwitchType :: AttributeKey Text
process_contextSwitchType = AttributeKey "process.context_switch_type"

-- |
-- Deprecated, use @system.paging.fault.type@ instead.
process_paging_faultType :: AttributeKey Text
process_paging_faultType = AttributeKey "process.paging.fault_type"

-- $metric_process_openFileDescriptor_count
-- Deprecated, use @process.unix.file_descriptor.count@ instead.
--
-- Stability: development
--
-- Deprecated: renamed: process.unix.file_descriptor.count
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



-- $registry_session
-- Session is defined as the period of time encompassing all activities performed by the application and the actions executed by the end user.
-- Consequently, a Session is represented as a collection of Logs, Events, and Spans emitted by the Client Application throughout the Session\'s duration. Each Session is assigned a unique identifier, which is included as an attribute in the Logs, Events, and Spans generated during the Session\'s lifecycle.
-- When a session reaches end of life, typically due to user inactivity or session timeout, a new session identifier will be assigned. The previous session identifier may be provided by the instrumentation so that telemetry backends can link the two sessions.
--
-- === Attributes
-- - 'session_id'
--
--     Stability: development
--
-- - 'session_previousId'
--
--     Stability: development
--

-- |
-- A unique id to identify a session.
session_id :: AttributeKey Text
session_id = AttributeKey "session.id"

-- |
-- The previous @session.id@ for this user, when known.
session_previousId :: AttributeKey Text
session_previousId = AttributeKey "session.previous_id"

-- $event_session_start
-- Indicates that a new session has been started, optionally linking to the prior session.
--
-- Stability: development
--
-- ==== Note
-- For instrumentation that tracks user behavior during user sessions, a @session.start@ event MUST be emitted every time a session is created. When a new session is created as a continuation of a prior session, the @session.previous_id@ SHOULD be included in the event. The values of @session.id@ and @session.previous_id@ MUST be different.
-- When the @session.start@ event contains both @session.id@ and @session.previous_id@ fields, the event indicates that the previous session has ended. If the session ID in @session.previous_id@ has not yet ended via explicit @session.end@ event, then the consumer SHOULD treat this continuation event as semantically equivalent to @session.end(session.previous_id)@ and @session.start(session.id)@.
--
-- === Attributes
-- - 'session_id'
--
--     The ID of the new session being started.
--
--     Requirement level: required
--
-- - 'session_previousId'
--
--     The previous @session.id@ for this user, when known.
--
--     Requirement level: conditionally required: If the new session is being created as a continuation of a previous session, the @session.previous_id@ SHOULD be included in the event. The @session.id@ and @session.previous_id@ attributes MUST have different values.
--



-- $event_session_end
-- Indicates that a session has ended.
--
-- Stability: development
--
-- ==== Note
-- For instrumentation that tracks user behavior during user sessions, a @session.end@ event SHOULD be emitted every time a session ends. When a session ends and continues as a new session, this event SHOULD be emitted prior to the @session.start@ event.
--
-- === Attributes
-- - 'session_id'
--
--     The ID of the session being ended.
--
--     Requirement level: required
--


