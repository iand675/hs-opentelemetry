# Metric catalogue

Generated from OpenTelemetry Semantic Conventions **1.45.0** with Weaver **0.28.0**.
This catalogue covers **566 metrics**, including development and
deprecated definitions. Regenerate it with the Haskell constructors.

Every constructor takes a Meter and AdvisoryParameters. Observable constructors
also take a list of callbacks. Supply measurements in the listed unit, the
attributes required by the metric, and appropriate advisory settings. Histogram
bucket recommendations in upstream prose remain a caller choice.

Numeric annotations select Int64 or Double constructors. Where upstream leaves
the numeric type unspecified, both variants are available. The existing Haskell
Histogram API always records Double, including metrics whose upstream numeric
annotation is integer. Both synchronous and observable variants are supplied for
other instruments; choose the style appropriate to the measurement.

## aspnetcore.authentication.authenticate.duration

The authentication duration for a request.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_aspnetcore_authentication_authenticate_duration`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.authentication.result | required |
| aspnetcore.authentication.scheme | Conditionally required: if a scheme is specified during authentication. |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Authentication`; Added in: ASP.NET Core 10.0


## aspnetcore.authentication.challenges

The total number of times a scheme is challenged.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {challenge} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_authentication_challenges_int64`
- `create_observable_aspnetcore_authentication_challenges_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.authentication.scheme | Conditionally required: if a scheme is specified during authentication. |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Authentication`; Added in: ASP.NET Core 10.0


## aspnetcore.authentication.forbids

The total number of times an authenticated user attempts to access a resource they are not permitted to access.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {forbid} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_authentication_forbids_int64`
- `create_observable_aspnetcore_authentication_forbids_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.authentication.scheme | Conditionally required: if a scheme is specified during authentication. |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Authentication`; Added in: ASP.NET Core 10.0


## aspnetcore.authentication.sign_ins

The total number of times a principal is signed in with a scheme.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {sign_in} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_authentication_signIns_int64`
- `create_observable_aspnetcore_authentication_signIns_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.authentication.scheme | Conditionally required: if a scheme is specified during authentication. |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Authentication`; Added in: ASP.NET Core 10.0


## aspnetcore.authentication.sign_outs

The total number of times a principal is signed out with a scheme.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {sign_out} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_authentication_signOuts_int64`
- `create_observable_aspnetcore_authentication_signOuts_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.authentication.scheme | Conditionally required: if a scheme is specified during authentication. |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Authentication`; Added in: ASP.NET Core 10.0


## aspnetcore.authorization.attempts

The total number of authorization attempts.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {attempt} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_authorization_attempts_int64`
- `create_observable_aspnetcore_authorization_attempts_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.authorization.policy | Conditionally required: if a policy is specified. |
| aspnetcore.authorization.result | Conditionally required: if no exception was thrown. |
| aspnetcore.user.is_authenticated | required |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Authorization`; Added in: ASP.NET Core 10.0


## aspnetcore.diagnostics.exceptions

Number of exceptions caught by exception handling middleware.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {exception} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_aspnetcore_diagnostics_exceptions_int64`
- `create_observable_aspnetcore_diagnostics_exceptions_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.diagnostics.exception.result | required |
| aspnetcore.diagnostics.handler.type | Conditionally required: if and only if the exception was handled by this handler. |
| error.type | required |

Meter name: `Microsoft.AspNetCore.Diagnostics`; Added in: ASP.NET Core 8.0


## aspnetcore.identity.sign_in.authenticate.duration

The duration of authenticate attempts. The authenticate metrics is recorded by sign in methods such as PasswordSignInAsync and TwoFactorSignInAsync.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_identity_signIn_authenticate_duration`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.authentication.scheme | required |
| aspnetcore.identity.sign_in.result | Conditionally required: if no exception was thrown. |
| aspnetcore.identity.sign_in.type | required |
| aspnetcore.identity.user_type | required |
| aspnetcore.sign_in.is_persistent | Conditionally required: if no exception was thrown. |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Identity`; Added in: ASP.NET Core 10.0


## aspnetcore.identity.sign_in.check_password_attempts

The total number of check password attempts. Checks that the account is in a state that can log in and that the password is valid using the UserManager.CheckPasswordAsync method.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {attempt} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_identity_signIn_checkPasswordAttempts_int64`
- `create_observable_aspnetcore_identity_signIn_checkPasswordAttempts_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.identity.sign_in.result | Conditionally required: if no exception was thrown. |
| aspnetcore.identity.user_type | required |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Identity`; Added in: ASP.NET Core 10.0


## aspnetcore.identity.sign_in.sign_ins

The total number of calls to sign in user principals.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {sign_in} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_identity_signIn_signIns_int64`
- `create_observable_aspnetcore_identity_signIn_signIns_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.authentication.scheme | required |
| aspnetcore.identity.user_type | required |
| aspnetcore.sign_in.is_persistent | Conditionally required: if no exception was thrown. |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Identity`; Added in: ASP.NET Core 10.0


## aspnetcore.identity.sign_in.sign_outs

The total number of calls to sign out user principals.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {sign_out} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_identity_signIn_signOuts_int64`
- `create_observable_aspnetcore_identity_signIn_signOuts_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.authentication.scheme | required |
| aspnetcore.identity.user_type | required |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Identity`; Added in: ASP.NET Core 10.0


## aspnetcore.identity.sign_in.two_factor_clients_forgotten

The total number of two factor clients forgotten.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {client} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_identity_signIn_twoFactorClientsForgotten_int64`
- `create_observable_aspnetcore_identity_signIn_twoFactorClientsForgotten_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.authentication.scheme | required |
| aspnetcore.identity.user_type | required |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Identity`; Added in: ASP.NET Core 10.0


## aspnetcore.identity.sign_in.two_factor_clients_remembered

The total number of two factor clients remembered.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {client} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_identity_signIn_twoFactorClientsRemembered_int64`
- `create_observable_aspnetcore_identity_signIn_twoFactorClientsRemembered_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.authentication.scheme | required |
| aspnetcore.identity.user_type | required |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Identity`; Added in: ASP.NET Core 10.0


## aspnetcore.identity.user.check_password_attempts

The number of check password attempts. Only checks whether the password is valid and not whether the user account is in a state that can log in.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {attempt} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_identity_user_checkPasswordAttempts_int64`
- `create_observable_aspnetcore_identity_user_checkPasswordAttempts_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.identity.password_check_result | Conditionally required: if no exception was thrown. |
| aspnetcore.identity.user_type | required |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Identity`; Added in: ASP.NET Core 10.0


## aspnetcore.identity.user.create.duration

The duration of user creation operations.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_identity_user_create_duration`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.identity.error_code | Conditionally required: if an error was set on a failed identity result. |
| aspnetcore.identity.result | Conditionally required: if no exception was thrown. |
| aspnetcore.identity.user_type | required |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Identity`; Added in: ASP.NET Core 10.0


## aspnetcore.identity.user.delete.duration

The duration of user deletion operations.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_identity_user_delete_duration`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.identity.error_code | Conditionally required: if an error was set on a failed identity result. |
| aspnetcore.identity.result | Conditionally required: if no exception was thrown. |
| aspnetcore.identity.user_type | required |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Identity`; Added in: ASP.NET Core 10.0


## aspnetcore.identity.user.generated_tokens

The total number of token generations.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {count} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_identity_user_generatedTokens_int64`
- `create_observable_aspnetcore_identity_user_generatedTokens_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.identity.token_purpose | required |
| aspnetcore.identity.user_type | required |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Identity`; Added in: ASP.NET Core 10.0


## aspnetcore.identity.user.update.duration

The duration of user update operations.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_identity_user_update_duration`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.identity.error_code | Conditionally required: if an error was set on a failed identity result. |
| aspnetcore.identity.result | Conditionally required: if no exception was thrown. |
| aspnetcore.identity.user.update_type | required |
| aspnetcore.identity.user_type | required |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Identity`; Added in: ASP.NET Core 10.0


## aspnetcore.identity.user.verify_token_attempts

The total number of token verification attempts.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {attempt} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_identity_user_verifyTokenAttempts_int64`
- `create_observable_aspnetcore_identity_user_verifyTokenAttempts_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.identity.token_purpose | required |
| aspnetcore.identity.token_verified | Conditionally required: if no exception was thrown. |
| aspnetcore.identity.user_type | required |
| error.type | Conditionally required: if and only if an error has occurred. |

Meter name: `Microsoft.AspNetCore.Identity`; Added in: ASP.NET Core 10.0


## aspnetcore.memory_pool.allocated

Total number of bytes allocated by the memory pool. Allocation occurs when a memory rental request exceeds the available pooled memory.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_memoryPool_allocated_int64`
- `create_observable_aspnetcore_memoryPool_allocated_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.memory_pool.owner | Conditionally required: if owner is specified when the memory pool is created. |

Meter name: `Microsoft.AspNetCore.MemoryPool`; Added in: ASP.NET Core 10.0


## aspnetcore.memory_pool.evicted

Total number of bytes evicted from the memory pool. Eviction occurs when idle pooled memory is reclaimed.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_memoryPool_evicted_int64`
- `create_observable_aspnetcore_memoryPool_evicted_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.memory_pool.owner | Conditionally required: if owner is specified when the memory pool is created. |

Meter name: `Microsoft.AspNetCore.MemoryPool`; Added in: ASP.NET Core 10.0


## aspnetcore.memory_pool.pooled

Number of bytes currently pooled and available for reuse.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_memoryPool_pooled_int64`
- `create_observable_aspnetcore_memoryPool_pooled_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.memory_pool.owner | Conditionally required: if owner is specified when the memory pool is created. |

Meter name: `Microsoft.AspNetCore.MemoryPool`; Added in: ASP.NET Core 10.0


## aspnetcore.memory_pool.rented

Total number of bytes rented from the memory pool.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_aspnetcore_memoryPool_rented_int64`
- `create_observable_aspnetcore_memoryPool_rented_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.memory_pool.owner | Conditionally required: if owner is specified when the memory pool is created. |

Meter name: `Microsoft.AspNetCore.MemoryPool`; Added in: ASP.NET Core 10.0


## aspnetcore.rate_limiting.active_request_leases

Number of requests that are currently active on the server that hold a rate limiting lease.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {request} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_aspnetcore_rateLimiting_activeRequestLeases_int64`
- `create_observable_aspnetcore_rateLimiting_activeRequestLeases_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.rate_limiting.policy | Conditionally required: if the matched endpoint for the request had a rate-limiting policy. |

Meter name: `Microsoft.AspNetCore.RateLimiting`; Added in: ASP.NET Core 8.0


## aspnetcore.rate_limiting.queued_requests

Number of requests that are currently queued, waiting to acquire a rate limiting lease.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {request} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_aspnetcore_rateLimiting_queuedRequests_int64`
- `create_observable_aspnetcore_rateLimiting_queuedRequests_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.rate_limiting.policy | Conditionally required: if the matched endpoint for the request had a rate-limiting policy. |

Meter name: `Microsoft.AspNetCore.RateLimiting`; Added in: ASP.NET Core 8.0


## aspnetcore.rate_limiting.request.time_in_queue

The time the request spent in a queue waiting to acquire a rate limiting lease.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_aspnetcore_rateLimiting_request_timeInQueue`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.rate_limiting.policy | Conditionally required: if the matched endpoint for the request had a rate-limiting policy. |
| aspnetcore.rate_limiting.result | required |

Meter name: `Microsoft.AspNetCore.RateLimiting`; Added in: ASP.NET Core 8.0


## aspnetcore.rate_limiting.request_lease.duration

The duration of rate limiting lease held by requests on the server.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_aspnetcore_rateLimiting_requestLease_duration`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.rate_limiting.policy | Conditionally required: if the matched endpoint for the request had a rate-limiting policy. |

Meter name: `Microsoft.AspNetCore.RateLimiting`; Added in: ASP.NET Core 8.0


## aspnetcore.rate_limiting.requests

Number of requests that tried to acquire a rate limiting lease.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {request} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_aspnetcore_rateLimiting_requests_int64`
- `create_observable_aspnetcore_rateLimiting_requests_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.rate_limiting.policy | Conditionally required: if the matched endpoint for the request had a rate-limiting policy. |
| aspnetcore.rate_limiting.result | required |

Requests could be:

* Rejected by global or endpoint rate limiting policies
* Canceled while waiting for the lease.

Meter name: `Microsoft.AspNetCore.RateLimiting`; Added in: ASP.NET Core 8.0


## aspnetcore.routing.match_attempts

Number of requests that were attempted to be matched to an endpoint.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/aspnetcore/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {match_attempt} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_aspnetcore_routing_matchAttempts_int64`
- `create_observable_aspnetcore_routing_matchAttempts_int64`

| Attribute | Requirement |
| --- | --- |
| aspnetcore.routing.is_fallback | Conditionally required: if and only if a route was successfully matched. |
| aspnetcore.routing.match_status | required |
| http.route | Conditionally required: if and only if a route was successfully matched. |

Meter name: `Microsoft.AspNetCore.Routing`; Added in: ASP.NET Core 8.0


## azure.cosmosdb.client.active_instance.count

Number of active client instances.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/azure/cosmosdb-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {instance} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_azure_cosmosdb_client_activeInstance_count_int64`
- `create_observable_azure_cosmosdb_client_activeInstance_count_int64`

| Attribute | Requirement |
| --- | --- |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set and the client is configured with a single database server endpoint that uses a non-default port.  |


## azure.cosmosdb.client.operation.request_charge

[Request units](https://learn.microsoft.com/azure/cosmos-db/request-units) consumed by the operation.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/azure/cosmosdb-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | {request_unit} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_azure_cosmosdb_client_operation_requestCharge`

| Attribute | Requirement |
| --- | --- |
| azure.cosmosdb.consistency.level | Conditionally required: If available. |
| azure.cosmosdb.operation.contacted_regions | Recommended: If available |
| azure.cosmosdb.response.sub_status_code | Conditionally required: when response was received and contained sub-code. |
| db.collection.name | Conditionally required: If available. |
| db.namespace | Conditionally required: If available. |
| db.operation.name | required |
| db.response.status_code | Conditionally required: If the operation failed and status code is available. |
| error.type | Conditionally required: If and only if the operation failed. |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set and the client is configured with a single database server endpoint that uses a non-default port.  |


## cicd.pipeline.run.active

The number of pipeline runs currently active in the system by state.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/cicd/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {run} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_cicd_pipeline_run_active_int64`
- `create_observable_cicd_pipeline_run_active_int64`

| Attribute | Requirement |
| --- | --- |
| cicd.pipeline.name | required |
| cicd.pipeline.run.state | required |


## cicd.pipeline.run.duration

Duration of a pipeline run grouped by pipeline, state and result.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/cicd/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | release candidate |


Constructors:

- `create_cicd_pipeline_run_duration`

| Attribute | Requirement |
| --- | --- |
| cicd.pipeline.name | required |
| cicd.pipeline.result | Conditionally required: If and only if the pipeline run result has been set during that state. |
| cicd.pipeline.run.state | required |
| error.type | Conditionally required: If and only if the pipeline run failed. |


## cicd.pipeline.run.errors

The number of errors encountered in pipeline runs (eg. compile, test failures).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/cicd/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {error} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_cicd_pipeline_run_errors_int64`
- `create_observable_cicd_pipeline_run_errors_int64`

| Attribute | Requirement |
| --- | --- |
| cicd.pipeline.name | required |
| error.type | required |

There might be errors in a pipeline run that are non fatal (eg. they are suppressed) or in a parallel stage multiple stages could have a fatal error.
This means that this error count might not be the same as the count of metric `cicd.pipeline.run.duration` with run result `failure`.


## cicd.system.errors

The number of errors in a component of the CI/CD system (eg. controller, scheduler, agent).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/cicd/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {error} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_cicd_system_errors_int64`
- `create_observable_cicd_system_errors_int64`

| Attribute | Requirement |
| --- | --- |
| cicd.system.component | required |
| error.type | required |

Errors in pipeline run execution are explicitly excluded. Ie a test failure is not counted in this metric.

## cicd.worker.count

The number of workers on the CI/CD system by state.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/cicd/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {worker} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_cicd_worker_count_int64`
- `create_observable_cicd_worker_count_int64`

| Attribute | Requirement |
| --- | --- |
| cicd.worker.state | required |


## container.cpu.time

Total CPU time consumed.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/container/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | s |
| Numeric annotation | double |
| Stability | release candidate |


Constructors:

- `create_container_cpu_time_double`
- `create_observable_container_cpu_time_double`

| Attribute | Requirement |
| --- | --- |
| cpu.mode | Conditionally required: Required if mode is available, i.e. metrics coming from the Docker Stats API, containerd stats or cAdvisor.  |

CPU time consumed by the specific container on all available CPU cores


## container.cpu.usage

Container's CPU usage, measured in CPUs. Range from 0 to the number of allocatable CPUs.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/container/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | release candidate |


Constructors:

- `create_container_cpu_usage_double`
- `create_observable_container_cpu_usage_double`

| Attribute | Requirement |
| --- | --- |
| cpu.mode | Conditionally required: Required if mode is available, i.e. metrics coming from the Docker Stats API, containerd stats or cAdvisor.  |

CPU usage of the specific container on all available CPU cores. It is calculated as the change in cumulative CPU time (container.cpu.time) over a measurement interval, divided by the elapsed time: usageCores = (cpuTimeEnd - cpuTimeStart) / elapsedSeconds


## container.disk.io

Disk bytes for the container.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/container/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_container_disk_io_int64`
- `create_observable_container_disk_io_int64`

| Attribute | Requirement |
| --- | --- |
| disk.io.direction | recommended |
| system.device.name | recommended |

The total number of bytes read/written successfully (aggregated from all disks).


## container.filesystem.available

Container filesystem available bytes.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/container/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_container_filesystem_available_int64`
- `create_observable_container_filesystem_available_int64`


Available filesystem space for the container's `rootfs`.
In K8s, this metric is derived from the [FsStats.AvailableBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#FsStats) field of the [ContainerStats.Rootfs](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#ContainerStats) of the Kubelet's stats API.


## container.filesystem.capacity

Container filesystem capacity.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/container/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_container_filesystem_capacity_int64`
- `create_observable_container_filesystem_capacity_int64`


Total filesystem capacity for the container's `rootfs`.
In general, this metric can be derived from [cadvisor](https://github.com/google/cadvisor/blob/v0.53.0/docs/storage/prometheus.md#prometheus-container-metrics) and specifically the `container_fs_limit_bytes` metric for the container's `rootfs` device.
In K8s, this metric is derived from the [FsStats.CapacityBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#FsStats) field of the [ContainerStats.Rootfs](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#ContainerStats) of the Kubelet's stats API.


## container.filesystem.usage

Container filesystem usage.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/container/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_container_filesystem_usage_int64`
- `create_observable_container_filesystem_usage_int64`


Filesystem space used by the container's `rootfs`.
In general, this metric can be derived from [cadvisor](https://github.com/google/cadvisor/blob/v0.53.0/docs/storage/prometheus.md#prometheus-container-metrics) and specifically the `container_fs_usage_bytes` metric for the container's `rootfs` device.
In K8s, this metric is derived from the [FsStats.UsedBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#FsStats) field of the [ContainerStats.Rootfs](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#ContainerStats) of the Kubelet's stats API.
Capacity and available are reported for the backing filesystem, which may be shared with other workloads; therefore, usage may not equal `capacity - available`.


## container.memory.available

Container memory available.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/container/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_container_memory_available_int64`
- `create_observable_container_memory_available_int64`


Available memory for use.  This is defined as the memory limit - workingSetBytes. If memory limit is undefined, the available bytes is omitted.
In general, this metric can be derived from [cadvisor](https://github.com/google/cadvisor/blob/v0.53.0/docs/storage/prometheus.md#prometheus-container-metrics) and by subtracting the `container_memory_working_set_bytes` metric from the `container_spec_memory_limit_bytes` metric.
In K8s, this metric is derived from the [MemoryStats.AvailableBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [ContainerStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#ContainerStats) of the Kubelet's stats API.


## container.memory.paging.faults

Deprecated, use `container.paging.faults` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/container/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {fault} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `container.paging.faults`.
Replacement: container.paging.faults.

Constructors:

- `create_container_memory_paging_faults_int64`
- `create_observable_container_memory_paging_faults_int64`

| Attribute | Requirement |
| --- | --- |
| system.paging.fault.type | recommended |

In general, this metric can be derived from [cadvisor](https://github.com/google/cadvisor/blob/v0.53.0/docs/storage/prometheus.md#prometheus-container-metrics) and specifically the `container_memory_failures_total{failure_type=pgfault, scope=container}` and `container_memory_failures_total{failure_type=pgmajfault, scope=container}`metric.
In K8s, this metric is derived from the [MemoryStats.PageFaults](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) and [MemoryStats.MajorPageFaults](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [PodStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats) of the Kubelet's stats API.


## container.memory.rss

Container memory RSS.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/container/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_container_memory_rss_int64`
- `create_observable_container_memory_rss_int64`


In general, this metric can be derived from [cadvisor](https://github.com/google/cadvisor/blob/v0.53.0/docs/storage/prometheus.md#prometheus-container-metrics) and specifically the `container_memory_rss` metric.
In K8s, this metric is derived from the [MemoryStats.RSSBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [ContainerStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#ContainerStats) of the Kubelet's stats API.


## container.memory.usage

Memory usage of the container.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/container/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_container_memory_usage_int64`
- `create_observable_container_memory_usage_int64`


Current memory usage, including all memory regardless of when it was accessed.
In general, this metric can be derived from [cadvisor](https://github.com/google/cadvisor/blob/v0.53.0/docs/storage/prometheus.md#prometheus-container-metrics) and specifically the `container_memory_usage_bytes` metric.
In K8s, this metric is derived from the [MemoryStats.UsageBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [ContainerStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#ContainerStats) of the Kubelet's stats API.


## container.memory.working_set

Container memory working set.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/container/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_container_memory_workingSet_int64`
- `create_observable_container_memory_workingSet_int64`


In general, this metric can be derived from [cadvisor](https://github.com/google/cadvisor/blob/v0.53.0/docs/storage/prometheus.md#prometheus-container-metrics) and specifically the `container_memory_working_set_bytes` metric. When derived from cAdvisor on Linux, the working set is calculated by excluding inactive file-backed memory from memory usage (`inactive_file` on cgroup v2, `total_inactive_file` on cgroup v1), so active file-backed memory remains included.
In K8s, this metric is derived from the [MemoryStats.WorkingSetBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [ContainerStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#ContainerStats) of the Kubelet's stats API.


## container.network.io

Network bytes for the container.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/container/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_container_network_io_int64`
- `create_observable_container_network_io_int64`

| Attribute | Requirement |
| --- | --- |
| network.interface.name | recommended |
| network.io.direction | recommended |

The number of bytes sent/received on all network interfaces by the container.


## container.paging.faults

Container memory paging faults.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/container/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {fault} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_container_paging_faults_int64`
- `create_observable_container_paging_faults_int64`

| Attribute | Requirement |
| --- | --- |
| system.paging.fault.type | recommended |

In general, this metric can be derived from [cadvisor](https://github.com/google/cadvisor/blob/v0.53.0/docs/storage/prometheus.md#prometheus-container-metrics). The `container_memory_failures_total{failure_type=pgfault, scope=container}` counter reports the total page faults (minor + major), while `container_memory_failures_total{failure_type=pgmajfault, scope=container}` reports only major faults. The minor page faults MUST be derived as the difference between the two.
In K8s, this metric is derived from the [MemoryStats.PageFaults](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) and [MemoryStats.MajorPageFaults](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) fields of the [ContainerStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#ContainerStats) of the Kubelet's stats API. `MemoryStats.PageFaults` reports the total number of page faults (equivalent to `pgfault` in the cgroup `memory.stat`), with minor and major combined. The minor page faults MUST therefore be derived as `MemoryStats.PageFaults - MemoryStats.MajorPageFaults`, so that summing the metric over `system.paging.fault.type` yields the total number of page faults.


## container.uptime

The time the container has been running.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/container/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | release candidate |


Constructors:

- `create_container_uptime_double`
- `create_observable_container_uptime_double`


Instrumentations SHOULD use a gauge with type `double` and measure uptime in seconds as a floating point number with the highest precision available. The actual accuracy would depend on the instrumentation and operating system.
In K8s environments, this metric can be derived from Kubelet's stats API and specifically from the [ContainerStats.StartTime](https://github.com/kubernetes/kubelet/blob/v0.35.2/pkg/apis/stats/v1alpha1/types.go#L161) field, where `StartTime` represents the container creation time as [noted in the Kubelet source](https://github.com/kubernetes/kubernetes/blob/v1.36.3/pkg/kubelet/stats/cri_stats_provider.go#L776). This value resets on every container restart and aligns with [ContainerStateRunning.startedAt](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#ContainerStateRunning) from the K8s API.


## cpu.frequency

Deprecated. Use `system.cpu.frequency` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/cpu/deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | {Hz} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `system.cpu.frequency`.
Replacement: system.cpu.frequency.

Constructors:

- `create_cpu_frequency_int64`
- `create_observable_cpu_frequency_int64`



## cpu.time

Deprecated. Use `system.cpu.time` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/cpu/deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | s |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Replaced by `system.cpu.time`.
Replacement: system.cpu.time.

Constructors:

- `create_cpu_time_double`
- `create_observable_cpu_time_double`

| Attribute | Requirement |
| --- | --- |
| cpu.logical_number | recommended |
| cpu.mode | recommended |


## cpu.utilization

Deprecated. Use `system.cpu.utilization` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/cpu/deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Replaced by `system.cpu.utilization`.
Replacement: system.cpu.utilization.

Constructors:

- `create_cpu_utilization_double`
- `create_observable_cpu_utilization_double`

| Attribute | Requirement |
| --- | --- |
| cpu.logical_number | recommended |
| cpu.mode | recommended |


## cpython.gc.collected_objects

The total number of objects collected inside a generation since interpreter start.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/cpython/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {object} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_cpython_gc_collectedObjects_int64`
- `create_observable_cpython_gc_collectedObjects_int64`

| Attribute | Requirement |
| --- | --- |
| cpython.gc.generation | required |

This metric reports data from [`gc.stats()`](https://docs.python.org/3/library/gc.html#gc.get_stats).


## cpython.gc.collections

The number of times a generation was collected since interpreter start.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/cpython/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {collection} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_cpython_gc_collections_int64`
- `create_observable_cpython_gc_collections_int64`

| Attribute | Requirement |
| --- | --- |
| cpython.gc.generation | required |

This metric reports data from [`gc.stats()`](https://docs.python.org/3/library/gc.html#gc.get_stats).


## cpython.gc.uncollectable_objects

The total number of objects which were found to be uncollectable inside a generation since interpreter start.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/cpython/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {object} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_cpython_gc_uncollectableObjects_int64`
- `create_observable_cpython_gc_uncollectableObjects_int64`

| Attribute | Requirement |
| --- | --- |
| cpython.gc.generation | required |

This metric reports data from [`gc.stats()`](https://docs.python.org/3/library/gc.html#gc.get_stats).


## db.client.connection.count

The number of connections that are currently in state described by the `state` attribute.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_db_client_connection_count_int64`
- `create_observable_db_client_connection_count_int64`

| Attribute | Requirement |
| --- | --- |
| db.client.connection.pool.name | required |
| db.client.connection.state | required |
| db.namespace | Conditionally required: If available. |
| db.system.name | Conditionally required: If available. |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set and the client is configured with a single database server endpoint that uses a non-default port.  |


## db.client.connection.create_time

The time it took to create a new connection.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_db_client_connection_createTime`

| Attribute | Requirement |
| --- | --- |
| db.client.connection.pool.name | required |
| db.namespace | Conditionally required: If available. |
| db.system.name | Conditionally required: If available. |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set and the client is configured with a single database server endpoint that uses a non-default port.  |


## db.client.connection.idle.max

The maximum number of idle open connections allowed.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_db_client_connection_idle_max_int64`
- `create_observable_db_client_connection_idle_max_int64`

| Attribute | Requirement |
| --- | --- |
| db.client.connection.pool.name | required |
| db.namespace | Conditionally required: If available. |
| db.system.name | Conditionally required: If available. |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set and the client is configured with a single database server endpoint that uses a non-default port.  |


## db.client.connection.idle.min

The minimum number of idle open connections allowed.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_db_client_connection_idle_min_int64`
- `create_observable_db_client_connection_idle_min_int64`

| Attribute | Requirement |
| --- | --- |
| db.client.connection.pool.name | required |
| db.namespace | Conditionally required: If available. |
| db.system.name | Conditionally required: If available. |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set and the client is configured with a single database server endpoint that uses a non-default port.  |


## db.client.connection.limit

The maximum number of open connections allowed.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_db_client_connection_limit_int64`
- `create_observable_db_client_connection_limit_int64`

| Attribute | Requirement |
| --- | --- |
| db.client.connection.pool.name | required |
| db.namespace | Conditionally required: If available. |
| db.system.name | Conditionally required: If available. |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set and the client is configured with a single database server endpoint that uses a non-default port.  |


## db.client.connection.max

Deprecated, use `db.client.connection.limit` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `db.client.connection.limit`.
Replacement: db.client.connection.limit.

Constructors:

- `create_db_client_connection_max_int64`
- `create_observable_db_client_connection_max_int64`

| Attribute | Requirement |
| --- | --- |
| db.client.connection.pool.name | required |


## db.client.connection.pending_requests

The number of current pending requests for an open connection.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {request} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_db_client_connection_pendingRequests_int64`
- `create_observable_db_client_connection_pendingRequests_int64`

| Attribute | Requirement |
| --- | --- |
| db.client.connection.pool.name | required |
| db.namespace | Conditionally required: If available. |
| db.system.name | Conditionally required: If available. |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set and the client is configured with a single database server endpoint that uses a non-default port.  |


## db.client.connection.timeouts

The number of connection timeouts that have occurred trying to obtain a connection from the pool.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {timeout} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_db_client_connection_timeouts_int64`
- `create_observable_db_client_connection_timeouts_int64`

| Attribute | Requirement |
| --- | --- |
| db.client.connection.pool.name | required |
| db.namespace | Conditionally required: If available. |
| db.system.name | Conditionally required: If available. |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set and the client is configured with a single database server endpoint that uses a non-default port.  |


## db.client.connection.use_time

The time between borrowing a connection and returning it to the pool.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_db_client_connection_useTime`

| Attribute | Requirement |
| --- | --- |
| db.client.connection.pool.name | required |
| db.namespace | Conditionally required: If available. |
| db.system.name | Conditionally required: If available. |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set and the client is configured with a single database server endpoint that uses a non-default port.  |


## db.client.connection.wait_time

The time it took to obtain an open connection from the pool.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_db_client_connection_waitTime`

| Attribute | Requirement |
| --- | --- |
| db.client.connection.pool.name | required |
| db.namespace | Conditionally required: If available. |
| db.system.name | Conditionally required: If available. |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set and the client is configured with a single database server endpoint that uses a non-default port.  |


## db.client.connections.create_time

Deprecated, use `db.client.connection.create_time` instead. Note: the unit also changed from `ms` to `s`.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | ms |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Replaced by `db.client.connection.create_time` with unit `s`.

Constructors:

- `create_db_client_connections_createTime`

| Attribute | Requirement |
| --- | --- |
| db.client.connections.pool.name | required |


## db.client.connections.idle.max

Deprecated, use `db.client.connection.idle.max` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `db.client.connection.idle.max`.
Replacement: db.client.connection.idle.max.

Constructors:

- `create_db_client_connections_idle_max_int64`
- `create_observable_db_client_connections_idle_max_int64`

| Attribute | Requirement |
| --- | --- |
| db.client.connections.pool.name | required |


## db.client.connections.idle.min

Deprecated, use `db.client.connection.idle.min` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `db.client.connection.idle.min`.
Replacement: db.client.connection.idle.min.

Constructors:

- `create_db_client_connections_idle_min_int64`
- `create_observable_db_client_connections_idle_min_int64`

| Attribute | Requirement |
| --- | --- |
| db.client.connections.pool.name | required |


## db.client.connections.max

Deprecated, use `db.client.connection.limit` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `db.client.connection.limit`.
Replacement: db.client.connection.limit.

Constructors:

- `create_db_client_connections_max_int64`
- `create_observable_db_client_connections_max_int64`

| Attribute | Requirement |
| --- | --- |
| db.client.connections.pool.name | required |


## db.client.connections.pending_requests

Deprecated, use `db.client.connection.pending_requests` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {request} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `db.client.connection.pending_requests`.
Replacement: db.client.connection.pending_requests.

Constructors:

- `create_db_client_connections_pendingRequests_int64`
- `create_observable_db_client_connections_pendingRequests_int64`

| Attribute | Requirement |
| --- | --- |
| db.client.connections.pool.name | required |


## db.client.connections.timeouts

Deprecated, use `db.client.connection.timeouts` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {timeout} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `db.client.connection.timeouts`.
Replacement: db.client.connection.timeouts.

Constructors:

- `create_db_client_connections_timeouts_int64`
- `create_observable_db_client_connections_timeouts_int64`

| Attribute | Requirement |
| --- | --- |
| db.client.connections.pool.name | required |


## db.client.connections.usage

Deprecated, use `db.client.connection.count` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `db.client.connection.count`.
Replacement: db.client.connection.count.

Constructors:

- `create_db_client_connections_usage_int64`
- `create_observable_db_client_connections_usage_int64`

| Attribute | Requirement |
| --- | --- |
| db.client.connections.pool.name | required |
| db.client.connections.state | required |


## db.client.connections.use_time

Deprecated, use `db.client.connection.use_time` instead. Note: the unit also changed from `ms` to `s`.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | ms |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Replaced by `db.client.connection.use_time` with unit `s`.

Constructors:

- `create_db_client_connections_useTime`

| Attribute | Requirement |
| --- | --- |
| db.client.connections.pool.name | required |


## db.client.connections.wait_time

Deprecated, use `db.client.connection.wait_time` instead. Note: the unit also changed from `ms` to `s`.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | ms |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Replaced by `db.client.connection.wait_time` with unit `s`.

Constructors:

- `create_db_client_connections_waitTime`

| Attribute | Requirement |
| --- | --- |
| db.client.connections.pool.name | required |


## db.client.cosmosdb.active_instance.count

Deprecated, use `azure.cosmosdb.client.active_instance.count` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {instance} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `azure.cosmosdb.client.active_instance.count`.
Replacement: azure.cosmosdb.client.active_instance.count.

Constructors:

- `create_db_client_cosmosdb_activeInstance_count_int64`
- `create_observable_db_client_cosmosdb_activeInstance_count_int64`

| Attribute | Requirement |
| --- | --- |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set and the client is configured with a single database server endpoint that uses a non-default port.  |


## db.client.cosmosdb.operation.request_charge

Deprecated, use `azure.cosmosdb.client.operation.request_charge` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | {request_unit} |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Replaced by `azure.cosmosdb.client.operation.request_charge`.
Replacement: azure.cosmosdb.client.operation.request_charge.

Constructors:

- `create_db_client_cosmosdb_operation_requestCharge`

| Attribute | Requirement |
| --- | --- |
| db.collection.name | Conditionally required: If available. |
| db.cosmosdb.consistency_level | Conditionally required: If available. |
| db.cosmosdb.regions_contacted | Recommended: If available |
| db.cosmosdb.sub_status_code | Conditionally required: when response was received and contained sub-code. |
| db.namespace | Conditionally required: If available. |
| db.operation.name | Conditionally required: If readily available and if there is a single operation name that describes the database call. The operation name MAY be parsed from the query text, in which case it SHOULD be the single operation name found in the query.  |


## db.client.operation.duration

Duration of database client operations.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_db_client_operation_duration`

| Attribute | Requirement |
| --- | --- |
| db.collection.name | Conditionally required: If readily available and if a database call is performed on a single collection. |
| db.namespace | Conditionally required: If available. |
| db.operation.name | Conditionally required: If readily available and if there is a single operation name that describes the database call.  |
| db.query.summary | Recommended: if available through instrumentation hooks or if the instrumentation supports generating a query summary. |
| db.query.text | opt in |
| db.response.status_code | Conditionally required: If the operation failed and status code is available. |
| db.stored_procedure.name | Recommended: If operation applies to a specific stored procedure. |
| db.system.name | required |
| error.type | Conditionally required: If and only if the operation failed. |
| network.peer.address | Recommended: If applicable for this database system. |
| network.peer.port | Recommended: If and only if `network.peer.address` is set. |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set and the client is configured with a single database server endpoint that uses a non-default port.  |

Batch operations SHOULD be recorded as a single operation.


## db.client.response.returned_rows

The actual number of records returned by the database operation.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/db/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | {row} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_db_client_response_returnedRows`

| Attribute | Requirement |
| --- | --- |
| db.collection.name | Conditionally required: If readily available and if a database call is performed on a single collection. |
| db.namespace | Conditionally required: If available. |
| db.operation.name | Conditionally required: If readily available and if there is a single operation name that describes the database call.  |
| db.query.summary | Recommended: if available through instrumentation hooks or if the instrumentation supports generating a query summary. |
| db.query.text | opt in |
| db.response.status_code | Conditionally required: If the operation failed and status code is available. |
| db.system.name | required |
| error.type | Conditionally required: If and only if the operation failed. |
| network.peer.address | Recommended: If applicable for this database system. |
| network.peer.port | Recommended: If and only if `network.peer.address` is set. |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set and the client is configured with a single database server endpoint that uses a non-default port.  |


## dns.lookup.duration

Measures the time taken to perform a DNS lookup.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dns/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_dns_lookup_duration`

| Attribute | Requirement |
| --- | --- |
| dns.question.name | required |
| error.type | Conditionally required: if and only if an error has occurred. |


## dotnet.assembly.count

The number of .NET assemblies that are currently loaded.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {assembly} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_assembly_count_int64`
- `create_observable_dotnet_assembly_count_int64`


Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as calling [`AppDomain.CurrentDomain.GetAssemblies().Length`](https://learn.microsoft.com/dotnet/api/system.appdomain.getassemblies).


## dotnet.exceptions

The number of exceptions that have been thrown in managed code.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {exception} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_exceptions_int64`
- `create_observable_dotnet_exceptions_int64`

| Attribute | Requirement |
| --- | --- |
| error.type | required |

Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as counting calls to [`AppDomain.CurrentDomain.FirstChanceException`](https://learn.microsoft.com/dotnet/api/system.appdomain.firstchanceexception).


## dotnet.gc.collections

The number of garbage collections that have occurred since the process has started.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {collection} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_gc_collections_int64`
- `create_observable_dotnet_gc_collections_int64`

| Attribute | Requirement |
| --- | --- |
| dotnet.gc.heap.generation | required |

Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric uses the [`GC.CollectionCount(int generation)`](https://learn.microsoft.com/dotnet/api/system.gc.collectioncount) API to calculate exclusive collections per generation.


## dotnet.gc.heap.total_allocated

The _approximate_ number of bytes allocated on the managed GC heap since the process has started. The returned value does not include any native allocations.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_gc_heap_totalAllocated_int64`
- `create_observable_dotnet_gc_heap_totalAllocated_int64`


Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as calling [`GC.GetTotalAllocatedBytes()`](https://learn.microsoft.com/dotnet/api/system.gc.gettotalallocatedbytes).


## dotnet.gc.last_collection.heap.fragmentation.size

The heap fragmentation, as observed during the latest garbage collection.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_gc_lastCollection_heap_fragmentation_size_int64`
- `create_observable_dotnet_gc_lastCollection_heap_fragmentation_size_int64`

| Attribute | Requirement |
| --- | --- |
| dotnet.gc.heap.generation | required |

Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as calling [`GC.GetGCMemoryInfo().GenerationInfo.FragmentationAfterBytes`](https://learn.microsoft.com/dotnet/api/system.gcgenerationinfo.fragmentationafterbytes).


## dotnet.gc.last_collection.heap.size

The managed GC heap size (including fragmentation), as observed during the latest garbage collection.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_gc_lastCollection_heap_size_int64`
- `create_observable_dotnet_gc_lastCollection_heap_size_int64`

| Attribute | Requirement |
| --- | --- |
| dotnet.gc.heap.generation | required |

Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as calling [`GC.GetGCMemoryInfo().GenerationInfo.SizeAfterBytes`](https://learn.microsoft.com/dotnet/api/system.gcgenerationinfo.sizeafterbytes).


## dotnet.gc.last_collection.memory.committed_size

The amount of committed virtual memory in use by the .NET GC, as observed during the latest garbage collection.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_gc_lastCollection_memory_committedSize_int64`
- `create_observable_dotnet_gc_lastCollection_memory_committedSize_int64`


Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as calling [`GC.GetGCMemoryInfo().TotalCommittedBytes`](https://learn.microsoft.com/dotnet/api/system.gcmemoryinfo.totalcommittedbytes). Committed virtual memory may be larger than the heap size because it includes both memory for storing existing objects (the heap size) and some extra memory that is ready to handle newly allocated objects in the future.


## dotnet.gc.pause.time

The total amount of time paused in GC since the process has started.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | s |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_dotnet_gc_pause_time_double`
- `create_observable_dotnet_gc_pause_time_double`


Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as calling [`GC.GetTotalPauseDuration()`](https://learn.microsoft.com/dotnet/api/system.gc.gettotalpauseduration).


## dotnet.jit.compilation.time

The amount of time the JIT compiler has spent compiling methods since the process has started.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | s |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_dotnet_jit_compilation_time_double`
- `create_observable_dotnet_jit_compilation_time_double`


Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as calling [`JitInfo.GetCompilationTime()`](https://learn.microsoft.com/dotnet/api/system.runtime.jitinfo.getcompilationtime).


## dotnet.jit.compiled_il.size

Count of bytes of intermediate language that have been compiled since the process has started.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_jit_compiledIl_size_int64`
- `create_observable_dotnet_jit_compiledIl_size_int64`


Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as calling [`JitInfo.GetCompiledILBytes()`](https://learn.microsoft.com/dotnet/api/system.runtime.jitinfo.getcompiledilbytes).


## dotnet.jit.compiled_methods

The number of times the JIT compiler (re)compiled methods since the process has started.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {method} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_jit_compiledMethods_int64`
- `create_observable_dotnet_jit_compiledMethods_int64`


Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as calling [`JitInfo.GetCompiledMethodCount()`](https://learn.microsoft.com/dotnet/api/system.runtime.jitinfo.getcompiledmethodcount).


## dotnet.monitor.lock_contentions

The number of times there was contention when trying to acquire a monitor lock since the process has started.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {contention} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_monitor_lockContentions_int64`
- `create_observable_dotnet_monitor_lockContentions_int64`


Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as calling [`Monitor.LockContentionCount`](https://learn.microsoft.com/dotnet/api/system.threading.monitor.lockcontentioncount).


## dotnet.process.cpu.count

The number of processors available to the process.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_process_cpu_count_int64`
- `create_observable_dotnet_process_cpu_count_int64`


Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as accessing [`Environment.ProcessorCount`](https://learn.microsoft.com/dotnet/api/system.environment.processorcount).


## dotnet.process.cpu.time

CPU time used by the process.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | s |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_dotnet_process_cpu_time_double`
- `create_observable_dotnet_process_cpu_time_double`

| Attribute | Requirement |
| --- | --- |
| cpu.mode | required |

Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as accessing the corresponding processor time properties on [`System.Diagnostics.Process`](https://learn.microsoft.com/dotnet/api/system.diagnostics.process).


## dotnet.process.memory.working_set

The number of bytes of physical memory mapped to the process context.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_process_memory_workingSet_int64`
- `create_observable_dotnet_process_memory_workingSet_int64`


Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as calling [`Environment.WorkingSet`](https://learn.microsoft.com/dotnet/api/system.environment.workingset).


## dotnet.thread_pool.queue.length

The number of work items that are currently queued to be processed by the thread pool.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {work_item} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_threadPool_queue_length_int64`
- `create_observable_dotnet_threadPool_queue_length_int64`


Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as calling [`ThreadPool.PendingWorkItemCount`](https://learn.microsoft.com/dotnet/api/system.threading.threadpool.pendingworkitemcount).


## dotnet.thread_pool.thread.count

The number of thread pool threads that currently exist.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {thread} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_threadPool_thread_count_int64`
- `create_observable_dotnet_threadPool_thread_count_int64`


Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as calling [`ThreadPool.ThreadCount`](https://learn.microsoft.com/dotnet/api/system.threading.threadpool.threadcount).


## dotnet.thread_pool.work_item.count

The number of work items that the thread pool has completed since the process has started.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {work_item} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_threadPool_workItem_count_int64`
- `create_observable_dotnet_threadPool_workItem_count_int64`


Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as calling [`ThreadPool.CompletedWorkItemCount`](https://learn.microsoft.com/dotnet/api/system.threading.threadpool.completedworkitemcount).


## dotnet.timer.count

The number of timer instances that are currently active.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/dotnet/runtime-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {timer} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_dotnet_timer_count_int64`
- `create_observable_dotnet_timer_count_int64`


Meter name: `System.Runtime`; Added in: .NET 9.0.
This metric reports the same values as calling [`Timer.ActiveCount`](https://learn.microsoft.com/dotnet/api/system.threading.timer.activecount).


## faas.coldstarts

Number of invocation cold starts.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/faas/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {coldstart} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_faas_coldstarts_int64`
- `create_observable_faas_coldstarts_int64`

| Attribute | Requirement |
| --- | --- |
| faas.trigger | recommended |


## faas.cpu_usage

Distribution of CPU usage per invocation.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/faas/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_faas_cpuUsage`

| Attribute | Requirement |
| --- | --- |
| faas.trigger | recommended |


## faas.errors

Number of invocation errors.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/faas/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {error} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_faas_errors_int64`
- `create_observable_faas_errors_int64`

| Attribute | Requirement |
| --- | --- |
| faas.trigger | recommended |


## faas.init_duration

Measures the duration of the function's initialization, such as a cold start.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/faas/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_faas_initDuration`

| Attribute | Requirement |
| --- | --- |
| faas.trigger | recommended |


## faas.invocations

Number of successful invocations.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/faas/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {invocation} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_faas_invocations_int64`
- `create_observable_faas_invocations_int64`

| Attribute | Requirement |
| --- | --- |
| faas.trigger | recommended |


## faas.invoke_duration

Measures the duration of the function's logic execution.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/faas/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_faas_invokeDuration`

| Attribute | Requirement |
| --- | --- |
| faas.trigger | recommended |


## faas.mem_usage

Distribution of max memory usage per invocation.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/faas/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_faas_memUsage`

| Attribute | Requirement |
| --- | --- |
| faas.trigger | recommended |


## faas.net_io

Distribution of net I/O usage per invocation.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/faas/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_faas_netIo`

| Attribute | Requirement |
| --- | --- |
| faas.trigger | recommended |


## faas.timeouts

Number of invocation timeouts.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/faas/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {timeout} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_faas_timeouts_int64`
- `create_observable_faas_timeouts_int64`

| Attribute | Requirement |
| --- | --- |
| faas.trigger | recommended |


## gen_ai.client.operation.duration

GenAI operation duration.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/gen-ai/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Moved to the [OpenTelemetry GenAI semantic conventions repository](https://github.com/open-telemetry/semantic-conventions-genai).


Constructors:

- `create_genAi_client_operation_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: if the operation ended in an error |
| gen_ai.operation.name | required |
| gen_ai.provider.name | required |
| gen_ai.request.model | Conditionally required: If available. |
| gen_ai.response.model | recommended |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set. |


## gen_ai.client.operation.time_per_output_chunk

Time per output chunk, recorded for each chunk received after the first one, measured as the time elapsed from the end of the previous chunk to the end of the current chunk.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/gen-ai/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Moved to the [OpenTelemetry GenAI semantic conventions repository](https://github.com/open-telemetry/semantic-conventions-genai).


Constructors:

- `create_genAi_client_operation_timePerOutputChunk`

| Attribute | Requirement |
| --- | --- |
| gen_ai.operation.name | required |
| gen_ai.provider.name | required |
| gen_ai.request.model | Conditionally required: If available. |
| gen_ai.response.model | recommended |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set. |

This metrics SHOULD be reported for streaming calls and SHOULD NOT be reported otherwise.


## gen_ai.client.operation.time_to_first_chunk

Time to receive the first chunk, measured from when the client issues the generation request to when the first chunk is received in the response stream.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/gen-ai/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Moved to the [OpenTelemetry GenAI semantic conventions repository](https://github.com/open-telemetry/semantic-conventions-genai).


Constructors:

- `create_genAi_client_operation_timeToFirstChunk`

| Attribute | Requirement |
| --- | --- |
| gen_ai.operation.name | required |
| gen_ai.provider.name | required |
| gen_ai.request.model | Conditionally required: If available. |
| gen_ai.response.model | recommended |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set. |

This metrics SHOULD be reported for streaming calls and SHOULD NOT be reported otherwise.


## gen_ai.client.token.usage

Number of input and output tokens used.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/gen-ai/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | {token} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Moved to the [OpenTelemetry GenAI semantic conventions repository](https://github.com/open-telemetry/semantic-conventions-genai).


Constructors:

- `create_genAi_client_token_usage`

| Attribute | Requirement |
| --- | --- |
| gen_ai.operation.name | required |
| gen_ai.provider.name | required |
| gen_ai.request.model | Conditionally required: If available. |
| gen_ai.response.model | recommended |
| gen_ai.token.type | required |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set. |


## gen_ai.server.request.duration

Generative AI server request duration such as time-to-last byte or last output token.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/gen-ai/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Moved to the [OpenTelemetry GenAI semantic conventions repository](https://github.com/open-telemetry/semantic-conventions-genai).


Constructors:

- `create_genAi_server_request_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: if the operation ended in an error |
| gen_ai.operation.name | required |
| gen_ai.provider.name | required |
| gen_ai.request.model | Conditionally required: If available. |
| gen_ai.response.model | recommended |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set. |


## gen_ai.server.time_per_output_token

Time per output token generated after the first token for successful responses.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/gen-ai/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Moved to the [OpenTelemetry GenAI semantic conventions repository](https://github.com/open-telemetry/semantic-conventions-genai).


Constructors:

- `create_genAi_server_timePerOutputToken`

| Attribute | Requirement |
| --- | --- |
| gen_ai.operation.name | required |
| gen_ai.provider.name | required |
| gen_ai.request.model | Conditionally required: If available. |
| gen_ai.response.model | recommended |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set. |


## gen_ai.server.time_to_first_token

Time to generate first token for successful responses.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/gen-ai/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Moved to the [OpenTelemetry GenAI semantic conventions repository](https://github.com/open-telemetry/semantic-conventions-genai).


Constructors:

- `create_genAi_server_timeToFirstToken`

| Attribute | Requirement |
| --- | --- |
| gen_ai.operation.name | required |
| gen_ai.provider.name | required |
| gen_ai.request.model | Conditionally required: If available. |
| gen_ai.response.model | recommended |
| server.address | recommended |
| server.port | Conditionally required: If `server.address` is set. |


## go.config.gogc

Heap size target percentage configured by the user, otherwise 100.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/go/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | % |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_go_config_gogc_double`
- `create_observable_go_config_gogc_double`


The value range is [0.0,100.0]. Computed from `/gc/gogc:percent`.


## go.cpu.time

Estimated CPU time spent by the Go runtime.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/go/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_go_cpu_time_double`
- `create_observable_go_cpu_time_double`

| Attribute | Requirement |
| --- | --- |
| go.cpu.detailed_state | opt in |
| go.cpu.state | required |

Computed from `/cpu/classes/...` metrics. This metric is an overestimate, and not directly comparable to system CPU time measurements. Compare only with other `go.cpu.time` metrics.


## go.goroutine.count

Count of live goroutines.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/go/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {goroutine} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_go_goroutine_count_int64`
- `create_observable_go_goroutine_count_int64`


Computed from `/sched/goroutines:goroutines`.


## go.memory.allocated

Memory allocated to the heap by the application.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/go/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_go_memory_allocated_int64`
- `create_observable_go_memory_allocated_int64`


Computed from `/gc/heap/allocs:bytes`.


## go.memory.allocations

Count of allocations to the heap by the application.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/go/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {allocation} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_go_memory_allocations_int64`
- `create_observable_go_memory_allocations_int64`


Computed from `/gc/heap/allocs:objects`.


## go.memory.gc.cycles

Number of completed GC cycles.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/go/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {gc_cycle} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_go_memory_gc_cycles_int64`
- `create_observable_go_memory_gc_cycles_int64`


Computed from `/gc/cycles/total:gc-cycles`.


## go.memory.gc.goal

Heap size target for the end of the GC cycle.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/go/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_go_memory_gc_goal_int64`
- `create_observable_go_memory_gc_goal_int64`


Computed from `/gc/heap/goal:bytes`.


## go.memory.gc.pause.duration

Distribution of individual GC-related stop-the-world pause latencies. This is the time from deciding to stop the world until the world is started again.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/go/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_go_memory_gc_pause_duration`


Computed from `/sched/pauses/total/gc:seconds`. Bucket boundaries are provided by the runtime, and are subject to change.


## go.memory.limit

Go runtime memory limit configured by the user, if a limit exists.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/go/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_go_memory_limit_int64`
- `create_observable_go_memory_limit_int64`


Computed from `/gc/gomemlimit:bytes`. This metric is excluded if the limit obtained from the Go runtime is math.MaxInt64.


## go.memory.used

Memory used by the Go runtime.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/go/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_go_memory_used_int64`
- `create_observable_go_memory_used_int64`

| Attribute | Requirement |
| --- | --- |
| go.memory.detailed_type | opt in |
| go.memory.type | recommended |

Computed from `(/memory/classes/total:bytes - /memory/classes/heap/released:bytes)`.


## go.processor.limit

The number of OS threads that can execute user-level Go code simultaneously.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/go/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {thread} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_go_processor_limit_int64`
- `create_observable_go_processor_limit_int64`


Computed from `/sched/gomaxprocs:threads`.


## go.schedule.duration

The time goroutines have spent in the scheduler in a runnable state before actually running.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/go/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_go_schedule_duration`


Computed from `/sched/latencies:seconds`. Bucket boundaries are provided by the runtime, and are subject to change.


## http.client.active_requests

Number of active HTTP requests.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/http/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {request} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_http_client_activeRequests_int64`
- `create_observable_http_client_activeRequests_int64`

| Attribute | Requirement |
| --- | --- |
| http.request.method | recommended |
| server.address | required |
| server.port | required |
| url.scheme | opt in |
| url.template | Conditionally required: If available. |


## http.client.connection.duration

The duration of the successfully established outbound HTTP connections.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/http/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_http_client_connection_duration`

| Attribute | Requirement |
| --- | --- |
| network.peer.address | opt in |
| network.protocol.version | recommended |
| server.address | required |
| server.port | required |
| url.scheme | opt in |


## http.client.open_connections

Number of outbound HTTP connections that are currently active or idle on the client.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/http/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_http_client_openConnections_int64`
- `create_observable_http_client_openConnections_int64`

| Attribute | Requirement |
| --- | --- |
| http.connection.state | required |
| network.peer.address | opt in |
| network.protocol.version | recommended |
| server.address | required |
| server.port | required |
| url.scheme | opt in |


## http.client.request.body.size

Size of HTTP client request bodies.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/http/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_http_client_request_body_size`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If request has ended with an error. |
| http.request.method | required |
| http.response.status_code | Conditionally required: If and only if one was received/sent. |
| network.protocol.name | Conditionally required: If not `http` and `network.protocol.version` is set. |
| network.protocol.version | recommended |
| server.address | required |
| server.port | required |
| url.scheme | opt in |
| url.template | Conditionally required: If available. |

The size of the request payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https://www.rfc-editor.org/rfc/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.


## http.client.request.duration

Duration of HTTP client requests.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/http/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_http_client_request_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If request has ended with an error. |
| http.request.method | required |
| http.response.status_code | Conditionally required: If and only if one was received/sent. |
| network.protocol.name | Conditionally required: If not `http` and `network.protocol.version` is set. |
| network.protocol.version | recommended |
| server.address | required |
| server.port | required |
| url.scheme | opt in |
| url.template | opt in |


## http.client.response.body.size

Size of HTTP client response bodies.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/http/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_http_client_response_body_size`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If request has ended with an error. |
| http.request.method | required |
| http.response.status_code | Conditionally required: If and only if one was received/sent. |
| network.protocol.name | Conditionally required: If not `http` and `network.protocol.version` is set. |
| network.protocol.version | recommended |
| server.address | required |
| server.port | required |
| url.scheme | opt in |
| url.template | Conditionally required: If available. |

The size of the response payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https://www.rfc-editor.org/rfc/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.


## http.server.active_requests

Number of active HTTP server requests.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/http/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {request} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_http_server_activeRequests_int64`
- `create_observable_http_server_activeRequests_int64`

| Attribute | Requirement |
| --- | --- |
| http.request.method | required |
| server.address | opt in |
| server.port | opt in |
| url.scheme | required |


## http.server.request.body.size

Size of HTTP server request bodies.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/http/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_http_server_request_body_size`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If request has ended with an error. |
| http.request.method | required |
| http.response.status_code | Conditionally required: If and only if one was received/sent. |
| http.route | Conditionally required: If and only if it's available |
| network.protocol.name | Conditionally required: If not `http` and `network.protocol.version` is set. |
| network.protocol.version | recommended |
| server.address | opt in |
| server.port | opt in |
| url.scheme | required |
| user_agent.synthetic.type | opt in |

The size of the request payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https://www.rfc-editor.org/rfc/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.


## http.server.request.duration

Duration of HTTP server requests.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/http/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_http_server_request_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If request has ended with an error. |
| http.request.method | required |
| http.response.status_code | Conditionally required: If and only if one was received/sent. |
| http.route | Conditionally required: If and only if it's available |
| network.protocol.name | Conditionally required: If not `http` and `network.protocol.version` is set. |
| network.protocol.version | recommended |
| server.address | opt in |
| server.port | opt in |
| url.scheme | required |
| user_agent.synthetic.type | opt in |


## http.server.response.body.size

Size of HTTP server response bodies.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/http/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_http_server_response_body_size`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If request has ended with an error. |
| http.request.method | required |
| http.response.status_code | Conditionally required: If and only if one was received/sent. |
| http.route | Conditionally required: If and only if it's available |
| network.protocol.name | Conditionally required: If not `http` and `network.protocol.version` is set. |
| network.protocol.version | recommended |
| server.address | opt in |
| server.port | opt in |
| url.scheme | required |
| user_agent.synthetic.type | opt in |

The size of the response payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https://www.rfc-editor.org/rfc/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.


## hw.battery.charge

Remaining fraction of battery charge.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/battery-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_battery_charge_double`
- `create_observable_hw_battery_charge_double`

| Attribute | Requirement |
| --- | --- |
| hw.battery.capacity | recommended |
| hw.battery.chemistry | recommended |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.vendor | recommended |


## hw.battery.charge.limit

Lower limit of battery charge fraction to ensure proper operation.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/battery-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_battery_charge_limit_double`
- `create_observable_hw_battery_charge_limit_double`

| Attribute | Requirement |
| --- | --- |
| hw.battery.capacity | recommended |
| hw.battery.chemistry | recommended |
| hw.id | required |
| hw.limit_type | recommended |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.vendor | recommended |


## hw.battery.time_left

Time left before battery is completely charged or discharged.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/battery-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_battery_timeLeft_double`
- `create_observable_hw_battery_timeLeft_double`

| Attribute | Requirement |
| --- | --- |
| hw.battery.capacity | recommended |
| hw.battery.chemistry | recommended |
| hw.battery.state | Conditionally required: If the battery is charging or discharging |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.state | required |
| hw.vendor | recommended |


## hw.cpu.speed

CPU current frequency.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/cpu-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | Hz |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_cpu_speed_int64`
- `create_observable_hw_cpu_speed_int64`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.vendor | recommended |


## hw.cpu.speed.limit

CPU maximum frequency.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/cpu-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | Hz |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_cpu_speed_limit_int64`
- `create_observable_hw_cpu_speed_limit_int64`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.limit_type | recommended |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.vendor | recommended |


## hw.energy

Energy consumed by the component.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/common-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | J |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_energy_double`
- `create_observable_hw_energy_double`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.name | recommended |
| hw.parent | recommended |
| hw.type | required |


## hw.errors

Number of errors encountered by the component.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/common-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {error} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_errors_int64`
- `create_observable_hw_errors_int64`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: if and only if an error has occurred |
| hw.id | required |
| hw.name | recommended |
| hw.parent | recommended |
| hw.type | required |


## hw.fan.speed

Fan speed in revolutions per minute.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/fan-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | rpm |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_fan_speed_int64`
- `create_observable_hw_fan_speed_int64`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.name | recommended |
| hw.parent | recommended |
| hw.sensor_location | recommended |


## hw.fan.speed.limit

Speed limit in rpm.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/fan-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | rpm |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_fan_speed_limit_int64`
- `create_observable_hw_fan_speed_limit_int64`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.limit_type | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.sensor_location | recommended |


## hw.fan.speed_ratio

Fan speed expressed as a fraction of its maximum speed.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/fan-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_fan_speedRatio_double`
- `create_observable_hw_fan_speedRatio_double`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.name | recommended |
| hw.parent | recommended |
| hw.sensor_location | recommended |


## hw.gpu.io

Received and transmitted bytes by the GPU.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/gpu-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_gpu_io_int64`
- `create_observable_hw_gpu_io_int64`

| Attribute | Requirement |
| --- | --- |
| hw.driver_version | recommended |
| hw.firmware_version | recommended |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |
| network.io.direction | required |


## hw.gpu.memory.limit

Size of the GPU memory.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/gpu-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_gpu_memory_limit_int64`
- `create_observable_hw_gpu_memory_limit_int64`

| Attribute | Requirement |
| --- | --- |
| hw.driver_version | recommended |
| hw.firmware_version | recommended |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |


## hw.gpu.memory.usage

GPU memory used.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/gpu-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_gpu_memory_usage_int64`
- `create_observable_hw_gpu_memory_usage_int64`

| Attribute | Requirement |
| --- | --- |
| hw.driver_version | recommended |
| hw.firmware_version | recommended |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |


## hw.gpu.memory.utilization

Fraction of GPU memory used.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/gpu-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_gpu_memory_utilization_double`
- `create_observable_hw_gpu_memory_utilization_double`

| Attribute | Requirement |
| --- | --- |
| hw.driver_version | recommended |
| hw.firmware_version | recommended |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |


## hw.gpu.utilization

Fraction of time spent in a specific task.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/gpu-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_gpu_utilization_double`
- `create_observable_hw_gpu_utilization_double`

| Attribute | Requirement |
| --- | --- |
| hw.driver_version | recommended |
| hw.firmware_version | recommended |
| hw.gpu.task | recommended |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |


## hw.host.ambient_temperature

Ambient (external) temperature of the physical host.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/host-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | Cel |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_host_ambientTemperature_double`
- `create_observable_hw_host_ambientTemperature_double`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.name | recommended |
| hw.parent | recommended |


## hw.host.energy

Total energy consumed by the entire physical host, in joules.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/host-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | J |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_host_energy_int64`
- `create_observable_hw_host_energy_int64`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.name | recommended |
| hw.parent | recommended |

The overall energy usage of a host MUST be reported using the specific `hw.host.energy` and `hw.host.power` metrics **only**, instead of the generic `hw.energy` and `hw.power` described in the previous section, to prevent summing up overlapping values.


## hw.host.heating_margin

By how many degrees Celsius the temperature of the physical host can be increased, before reaching a warning threshold on one of the internal sensors.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/host-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | Cel |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_host_heatingMargin_double`
- `create_observable_hw_host_heatingMargin_double`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.name | recommended |
| hw.parent | recommended |


## hw.host.power

Instantaneous power consumed by the entire physical host in Watts (`hw.host.energy` is preferred).


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/host-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | W |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_host_power_double`
- `create_observable_hw_host_power_double`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.name | recommended |
| hw.parent | recommended |

The overall energy usage of a host MUST be reported using the specific `hw.host.energy` and `hw.host.power` metrics **only**, instead of the generic `hw.energy` and `hw.power` described in the previous section, to prevent summing up overlapping values.


## hw.logical_disk.limit

Size of the logical disk.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/logical-disk-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_logicalDisk_limit_int64`
- `create_observable_hw_logicalDisk_limit_int64`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.logical_disk.raid_level | recommended |
| hw.name | recommended |
| hw.parent | recommended |


## hw.logical_disk.usage

Logical disk space usage.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/logical-disk-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_logicalDisk_usage_int64`
- `create_observable_hw_logicalDisk_usage_int64`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.logical_disk.raid_level | recommended |
| hw.logical_disk.state | required |
| hw.name | recommended |
| hw.parent | recommended |


## hw.logical_disk.utilization

Logical disk space utilization as a fraction.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/logical-disk-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_logicalDisk_utilization_double`
- `create_observable_hw_logicalDisk_utilization_double`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.logical_disk.raid_level | recommended |
| hw.logical_disk.state | required |
| hw.name | recommended |
| hw.parent | recommended |


## hw.memory.size

Size of the memory module.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/memory-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_memory_size_int64`
- `create_observable_hw_memory_size_int64`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.memory.type | recommended |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |


## hw.network.bandwidth.limit

Link speed.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/network-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By/s |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_network_bandwidth_limit_int64`
- `create_observable_hw_network_bandwidth_limit_int64`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.network.logical_addresses | recommended |
| hw.network.physical_address | recommended |
| hw.parent | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |


## hw.network.bandwidth.utilization

Utilization of the network bandwidth as a fraction.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/network-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_network_bandwidth_utilization_double`
- `create_observable_hw_network_bandwidth_utilization_double`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.network.logical_addresses | recommended |
| hw.network.physical_address | recommended |
| hw.parent | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |


## hw.network.io

Received and transmitted network traffic in bytes.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/network-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_network_io_int64`
- `create_observable_hw_network_io_int64`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.network.logical_addresses | recommended |
| hw.network.physical_address | recommended |
| hw.parent | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |
| network.io.direction | required |


## hw.network.packets

Received and transmitted network traffic in packets (or frames).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/network-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {packet} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_network_packets_int64`
- `create_observable_hw_network_packets_int64`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.network.logical_addresses | recommended |
| hw.network.physical_address | recommended |
| hw.parent | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |
| network.io.direction | required |


## hw.network.up

Link status: `1` (up) or `0` (down).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/network-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | 1 |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_network_up_int64`
- `create_observable_hw_network_up_int64`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.network.logical_addresses | recommended |
| hw.network.physical_address | recommended |
| hw.parent | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |


## hw.physical_disk.endurance_utilization

Endurance remaining for this SSD disk.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/physical-disk-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_physicalDisk_enduranceUtilization_double`
- `create_observable_hw_physicalDisk_enduranceUtilization_double`

| Attribute | Requirement |
| --- | --- |
| hw.firmware_version | recommended |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.physical_disk.state | required |
| hw.physical_disk.type | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |


## hw.physical_disk.size

Size of the disk.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/physical-disk-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_physicalDisk_size_int64`
- `create_observable_hw_physicalDisk_size_int64`

| Attribute | Requirement |
| --- | --- |
| hw.firmware_version | recommended |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.physical_disk.type | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |


## hw.physical_disk.smart

Value of the corresponding [S.M.A.R.T.](https://wikipedia.org/wiki/S.M.A.R.T.) (Self-Monitoring, Analysis, and Reporting Technology) attribute.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/physical-disk-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_physicalDisk_smart_int64`
- `create_observable_hw_physicalDisk_smart_int64`

| Attribute | Requirement |
| --- | --- |
| hw.firmware_version | recommended |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.physical_disk.smart_attribute | recommended |
| hw.physical_disk.type | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |


## hw.power

Instantaneous power consumed by the component.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/common-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | W |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_power_double`
- `create_observable_hw_power_double`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.name | recommended |
| hw.parent | recommended |
| hw.type | required |

It is recommended to report `hw.energy` instead of `hw.power` when possible.


## hw.power_supply.limit

Maximum power output of the power supply.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/power-supply-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | W |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_powerSupply_limit_int64`
- `create_observable_hw_powerSupply_limit_int64`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.limit_type | recommended |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |


## hw.power_supply.usage

Current power output of the power supply.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/power-supply-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | W |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_powerSupply_usage_double`
- `create_observable_hw_powerSupply_usage_double`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |


## hw.power_supply.utilization

Utilization of the power supply as a fraction of its maximum output.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/power-supply-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_powerSupply_utilization_double`
- `create_observable_hw_powerSupply_utilization_double`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.serial_number | recommended |
| hw.vendor | recommended |


## hw.status

Operational status: `1` (true) or `0` (false) for each of the possible states.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/common-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | 1 |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_status_int64`
- `create_observable_hw_status_int64`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.name | recommended |
| hw.parent | recommended |
| hw.state | required |
| hw.type | required |

`hw.status` is currently specified as an *UpDownCounter* but would ideally be represented using a [*StateSet* as defined in OpenMetrics](https://github.com/prometheus/OpenMetrics/blob/v1.0.0/specification/OpenMetrics.md#stateset). This semantic convention will be updated once *StateSet* is specified in OpenTelemetry. This planned change is not expected to have any consequence on the way users query their timeseries backend to retrieve the values of `hw.status` over time.


## hw.tape_drive.operations

Operations performed by the tape drive.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/tape-drive-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {operation} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_hw_tapeDrive_operations_int64`
- `create_observable_hw_tapeDrive_operations_int64`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.model | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.serial_number | recommended |
| hw.tape_drive.operation_type | recommended |
| hw.vendor | recommended |


## hw.temperature

Temperature in degrees Celsius.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/temperature-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | Cel |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_temperature_double`
- `create_observable_hw_temperature_double`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.name | recommended |
| hw.parent | recommended |
| hw.sensor_location | recommended |


## hw.temperature.limit

Temperature limit in degrees Celsius.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/temperature-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | Cel |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_temperature_limit_double`
- `create_observable_hw_temperature_limit_double`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.limit_type | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.sensor_location | recommended |


## hw.voltage

Voltage measured by the sensor.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/voltage-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | V |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_voltage_double`
- `create_observable_hw_voltage_double`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.name | recommended |
| hw.parent | recommended |
| hw.sensor_location | recommended |


## hw.voltage.limit

Voltage limit in Volts.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/voltage-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | V |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_voltage_limit_double`
- `create_observable_hw_voltage_limit_double`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.limit_type | recommended |
| hw.name | recommended |
| hw.parent | recommended |
| hw.sensor_location | recommended |


## hw.voltage.nominal

Nominal (expected) voltage.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/hardware/voltage-metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | V |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_hw_voltage_nominal_double`
- `create_observable_hw_voltage_nominal_double`

| Attribute | Requirement |
| --- | --- |
| hw.id | required |
| hw.name | recommended |
| hw.parent | recommended |
| hw.sensor_location | recommended |


## jvm.buffer.count

Number of buffers in the pool.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics-experimental.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {buffer} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_jvm_buffer_count_int64`
- `create_observable_jvm_buffer_count_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.buffer.pool.name | recommended |


## jvm.buffer.memory.limit

Measure of total memory capacity of buffers.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics-experimental.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_jvm_buffer_memory_limit_int64`
- `create_observable_jvm_buffer_memory_limit_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.buffer.pool.name | recommended |


## jvm.buffer.memory.usage

Deprecated, use `jvm.buffer.memory.used` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `jvm.buffer.memory.used`.
Replacement: jvm.buffer.memory.used.

Constructors:

- `create_jvm_buffer_memory_usage_int64`
- `create_observable_jvm_buffer_memory_usage_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.buffer.pool.name | recommended |


## jvm.buffer.memory.used

Measure of memory used by buffers.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics-experimental.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_jvm_buffer_memory_used_int64`
- `create_observable_jvm_buffer_memory_used_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.buffer.pool.name | recommended |


## jvm.class.count

Number of classes currently loaded.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {class} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_jvm_class_count_int64`
- `create_observable_jvm_class_count_int64`



## jvm.class.loaded

Number of classes loaded since JVM start.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {class} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_jvm_class_loaded_int64`
- `create_observable_jvm_class_loaded_int64`



## jvm.class.unloaded

Number of classes unloaded since JVM start.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {class} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_jvm_class_unloaded_int64`
- `create_observable_jvm_class_unloaded_int64`



## jvm.cpu.count

Number of processors available to the Java virtual machine.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_jvm_cpu_count_int64`
- `create_observable_jvm_cpu_count_int64`



## jvm.cpu.recent_utilization

Recent CPU utilization for the process as reported by the JVM.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_jvm_cpu_recentUtilization_double`
- `create_observable_jvm_cpu_recentUtilization_double`


The value range is [0.0,1.0]. This utilization is not defined as being for the specific interval since last measurement (unlike `system.cpu.utilization`). [Reference](https://docs.oracle.com/en/java/javase/17/docs/api/jdk.management/com/sun/management/OperatingSystemMXBean.html#getProcessCpuLoad()).


## jvm.cpu.time

CPU time used by the process as reported by the JVM.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | s |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_jvm_cpu_time_double`
- `create_observable_jvm_cpu_time_double`



## jvm.executor.queue.capacity

The maximum number of tasks the executor queue can hold.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics-experimental.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {task} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_jvm_executor_queue_capacity_int64`
- `create_observable_jvm_executor_queue_capacity_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.executor.name | required |
| jvm.executor.owner.name | recommended |
| jvm.executor.type | required |

Instrumentations SHOULD emit this metric only when the queue has a finite capacity that represents a meaningful operational limit. This metric SHOULD NOT be emitted for unbounded or effectively unbounded queues.


## jvm.executor.queue.size

The number of tasks currently queued for execution.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics-experimental.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {task} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_jvm_executor_queue_size_int64`
- `create_observable_jvm_executor_queue_size_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.executor.name | required |
| jvm.executor.owner.name | recommended |
| jvm.executor.type | required |


## jvm.executor.task.completed

The number of tasks completed by the executor.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics-experimental.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {task} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_jvm_executor_task_completed_int64`
- `create_observable_jvm_executor_task_completed_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.executor.name | required |
| jvm.executor.owner.name | recommended |
| jvm.executor.type | required |

A task SHOULD be counted as completed when the executor has finished processing it, regardless of whether it returns normally, terminates with an exception, or is canceled. Cancellation during processing does not complete the task until processing ends. A task that never begins processing on the executor SHOULD NOT be counted. A task initially rejected but subsequently resubmitted to and processed by the executor SHOULD be counted when processing ends.


## jvm.executor.task.rejected

The number of task submissions rejected by the executor.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics-experimental.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {task} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_jvm_executor_task_rejected_int64`
- `create_observable_jvm_executor_task_rejected_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.executor.name | required |
| jvm.executor.owner.name | recommended |
| jvm.executor.type | required |

A task submission SHOULD be counted as rejected when the executor invokes its rejection handler, regardless of whether the handler subsequently executes the task in the caller (for example, `CallerRunsPolicy`) or discards or replaces a queued task (for example, `DiscardOldestPolicy`). This metric counts rejected submissions, not tasks ultimately discarded from the queue.


## jvm.executor.thread.core

The number of core threads configured for the executor.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics-experimental.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {thread} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_jvm_executor_thread_core_int64`
- `create_observable_jvm_executor_thread_core_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.executor.name | required |
| jvm.executor.owner.name | recommended |
| jvm.executor.type | required |


## jvm.executor.thread.count

The number of executor threads that are currently in the state described by the `jvm.executor.thread.state` attribute.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics-experimental.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {thread} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_jvm_executor_thread_count_int64`
- `create_observable_jvm_executor_thread_count_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.executor.name | required |
| jvm.executor.owner.name | recommended |
| jvm.executor.thread.state | required |
| jvm.executor.type | required |


## jvm.executor.thread.limit

The maximum number of threads allowed for the executor.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics-experimental.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {thread} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_jvm_executor_thread_limit_int64`
- `create_observable_jvm_executor_thread_limit_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.executor.name | required |
| jvm.executor.owner.name | recommended |
| jvm.executor.type | required |

Instrumentations SHOULD emit this metric only when the maximum thread count is finite and represents a meaningful operational limit. This metric SHOULD NOT be emitted for unbounded or effectively unbounded executors. For example, an executor with a maximum thread count of `Integer.MAX_VALUE` is effectively unbounded.


## jvm.file_descriptor.count

Number of open file descriptors as reported by the JVM.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {file_descriptor} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_jvm_fileDescriptor_count_int64`
- `create_observable_jvm_fileDescriptor_count_int64`



## jvm.file_descriptor.limit

Measure of max open file descriptors as reported by the JVM.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {file_descriptor} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_jvm_fileDescriptor_limit_int64`
- `create_observable_jvm_fileDescriptor_limit_int64`



## jvm.gc.duration

Duration of JVM garbage collection actions.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_jvm_gc_duration`

| Attribute | Requirement |
| --- | --- |
| jvm.gc.action | recommended |
| jvm.gc.cause | opt in |
| jvm.gc.name | recommended |


## jvm.memory.committed

Measure of memory committed.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_jvm_memory_committed_int64`
- `create_observable_jvm_memory_committed_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.memory.pool.name | recommended |
| jvm.memory.type | recommended |


## jvm.memory.init

Measure of initial memory requested.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics-experimental.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_jvm_memory_init_int64`
- `create_observable_jvm_memory_init_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.memory.pool.name | recommended |
| jvm.memory.type | recommended |


## jvm.memory.limit

Measure of max obtainable memory.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_jvm_memory_limit_int64`
- `create_observable_jvm_memory_limit_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.memory.pool.name | recommended |
| jvm.memory.type | recommended |


## jvm.memory.used

Measure of memory used.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_jvm_memory_used_int64`
- `create_observable_jvm_memory_used_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.memory.pool.name | recommended |
| jvm.memory.type | recommended |


## jvm.memory.used_after_last_gc

Measure of memory used, as measured after the most recent garbage collection event on this pool.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_jvm_memory_usedAfterLastGc_int64`
- `create_observable_jvm_memory_usedAfterLastGc_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.memory.pool.name | recommended |
| jvm.memory.type | recommended |


## jvm.system.cpu.load_1m

Average CPU load of the whole system for the last minute as reported by the JVM.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics-experimental.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | {run_queue_item} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_jvm_system_cpu_load1m_double`
- `create_observable_jvm_system_cpu_load1m_double`


The value range is [0,n], where n is the number of CPU cores - or a negative number if the value is not available. This utilization is not defined as being for the specific interval since last measurement (unlike `system.cpu.utilization`). [Reference](https://docs.oracle.com/en/java/javase/17/docs/api/java.management/java/lang/management/OperatingSystemMXBean.html#getSystemLoadAverage()).


## jvm.system.cpu.utilization

Recent CPU utilization for the whole system as reported by the JVM.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics-experimental.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_jvm_system_cpu_utilization_double`
- `create_observable_jvm_system_cpu_utilization_double`


The value range is [0.0,1.0]. This utilization is not defined as being for the specific interval since last measurement (unlike `system.cpu.utilization`). [Reference](https://docs.oracle.com/en/java/javase/17/docs/api/jdk.management/com/sun/management/OperatingSystemMXBean.html#getCpuLoad()).


## jvm.thread.count

Number of executing platform threads.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/jvm/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {thread} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_jvm_thread_count_int64`
- `create_observable_jvm_thread_count_int64`

| Attribute | Requirement |
| --- | --- |
| jvm.thread.daemon | recommended |
| jvm.thread.state | recommended |


## k8s.container.cpu.limit

Deprecated, use `k8s.container.cpu.limit.desired` and `k8s.container.cpu.limit.current` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Replaced by `k8s.container.cpu.limit.desired`.
Replacement: k8s.container.cpu.limit.desired.

Constructors:

- `create_k8s_container_cpu_limit_double`
- `create_observable_k8s_container_cpu_limit_double`



## k8s.container.cpu.limit.current

Maximum CPU resource limit currently configured for a running container.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_container_cpu_limit_current_double`
- `create_observable_k8s_container_cpu_limit_current_double`


This metric aligns with the limit in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcerequirements-v1-core) field of
[K8s ContainerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#containerstatus-v1-core)
(status.containerStatuses[*].resources). Also see `Actual Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/> for more details.


## k8s.container.cpu.limit.desired

Maximum CPU resource limit as defined by the container spec.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_container_cpu_limit_desired_double`
- `create_observable_k8s_container_cpu_limit_desired_double`


This metric aligns with the limit in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcerequirements-v1-core) field of
[K8s Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#container-v1-core)
(spec.containers[*].resources). Also see `Desired Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/> for more details.


## k8s.container.cpu.limit.utilization

The ratio of container CPU usage to its current CPU limit.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_container_cpu_limit_utilization_double`
- `create_observable_k8s_container_cpu_limit_utilization_double`


The current CPU limit reflects the actual resources applied to the container, as reported by
[ContainerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#containerstatus-v1-core).
The value range is [0.0,1.0]. A value of 1.0 means the container is using 100% of its actual CPU limit.
If the CPU limit is not set, this metric SHOULD NOT be emitted for that container.


## k8s.container.cpu.limit_utilization

Deprecated, use `k8s.container.cpu.limit.utilization` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Replaced by `k8s.container.cpu.limit.utilization`.
Replacement: k8s.container.cpu.limit.utilization.

Constructors:

- `create_k8s_container_cpu_limitUtilization_double`
- `create_observable_k8s_container_cpu_limitUtilization_double`



## k8s.container.cpu.request

Deprecated, use `k8s.container.cpu.request.desired` and `k8s.container.cpu.request.current` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Replaced by `k8s.container.cpu.request.desired`.
Replacement: k8s.container.cpu.request.desired.

Constructors:

- `create_k8s_container_cpu_request_double`
- `create_observable_k8s_container_cpu_request_double`



## k8s.container.cpu.request.current

CPU resource requested currently configured for a running container.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_container_cpu_request_current_double`
- `create_observable_k8s_container_cpu_request_current_double`


This metric aligns with the request in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcerequirements-v1-core) field of
[K8s ContainerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#containerstatus-v1-core)
(status.containerStatuses[*].resources). Also see `Actual Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/> for more details.


## k8s.container.cpu.request.desired

CPU resource requested as defined by the container spec.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_container_cpu_request_desired_double`
- `create_observable_k8s_container_cpu_request_desired_double`


This metric aligns with the request in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcerequirements-v1-core) field of
[K8s Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#container-v1-core)
(spec.containers[*].resources). Also see `Desired Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/> for more details.


## k8s.container.cpu.request.utilization

The ratio of container CPU usage to its current CPU request.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_container_cpu_request_utilization_double`
- `create_observable_k8s_container_cpu_request_utilization_double`


The current CPU request reflects the request applied to the running container, as reported by
[ContainerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#containerstatus-v1-core).
A value of 1.0 means the container is using exactly its CPU request. Since a CPU request is a scheduling
reservation and not a hard cap, values above 1.0 are possible and indicate the container is using more CPU
than requested. If the CPU request is not set, this metric SHOULD NOT be emitted for that container.


## k8s.container.cpu.request_utilization

Deprecated, use `k8s.container.cpu.request.utilization` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Replaced by `k8s.container.cpu.request.utilization`.
Replacement: k8s.container.cpu.request.utilization.

Constructors:

- `create_k8s_container_cpu_requestUtilization_double`
- `create_observable_k8s_container_cpu_requestUtilization_double`



## k8s.container.ephemeral_storage.limit

Maximum ephemeral storage resource limit set for the container.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_container_ephemeralStorage_limit_int64`
- `create_observable_k8s_container_ephemeralStorage_limit_int64`


See the [Kubernetes ResourceRequirements API](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcerequirements-v1-core) for details.


## k8s.container.ephemeral_storage.request

Ephemeral storage resource requested for the container.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_container_ephemeralStorage_request_int64`
- `create_observable_k8s_container_ephemeralStorage_request_int64`


See the [Kubernetes ResourceRequirements API](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcerequirements-v1-core) for details.


## k8s.container.ephemeral_storage.usage

The ephemeral storage used by a container.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_container_ephemeralStorage_usage_int64`
- `create_observable_k8s_container_ephemeralStorage_usage_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.container.ephemeral_storage.fs_type | required |

The value for this metric can be compared against `metric.k8s.container.ephemeral_storage.request` and `metric.k8s.container.ephemeral_storage.limit`.


## k8s.container.memory.limit

Deprecated, use `k8s.container.memory.limit.desired` and `k8s.container.memory.limit.current` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.container.memory.limit.desired`.
Replacement: k8s.container.memory.limit.desired.

Constructors:

- `create_k8s_container_memory_limit_int64`
- `create_observable_k8s_container_memory_limit_int64`



## k8s.container.memory.limit.current

Maximum memory resource limit currently configured for a running container.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_container_memory_limit_current_int64`
- `create_observable_k8s_container_memory_limit_current_int64`


This metric aligns with the limit in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcerequirements-v1-core) field of
[K8s ContainerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#containerstatus-v1-core)
(status.containerStatuses[*].resources). Also see `Actual Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/> for more details.


## k8s.container.memory.limit.desired

Maximum memory resource limit as defined by the container spec.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_container_memory_limit_desired_int64`
- `create_observable_k8s_container_memory_limit_desired_int64`


This metric aligns with the limit in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcerequirements-v1-core) field of
[K8s Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#container-v1-core)
(spec.containers[*].resources). Also see `Desired Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/> for more details.


## k8s.container.memory.limit.utilization

The ratio of container memory working set to its current memory limit.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_container_memory_limit_utilization_double`
- `create_observable_k8s_container_memory_limit_utilization_double`


The numerator is the container memory working set, as reported by `container.memory.working_set`. The current memory limit
reflects the actual resources applied to the container, as reported by
[ContainerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#containerstatus-v1-core).
A value of 1.0 means the container is using 100% of its actual memory limit. Values above 1.0 can occur transiently, since memory usage can briefly exceed the limit.
If the memory limit is not set, this metric SHOULD NOT be emitted for that container.


## k8s.container.memory.request

Deprecated, use `k8s.container.memory.request.desired` and `k8s.container.memory.request.current` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.container.memory.request.desired`.
Replacement: k8s.container.memory.request.desired.

Constructors:

- `create_k8s_container_memory_request_int64`
- `create_observable_k8s_container_memory_request_int64`



## k8s.container.memory.request.current

Memory resource request currently configured for a running container.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_container_memory_request_current_int64`
- `create_observable_k8s_container_memory_request_current_int64`


This metric aligns with the request in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcerequirements-v1-core) field of
[K8s ContainerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#containerstatus-v1-core)
(status.containerStatuses[*].resources). Also see `Actual Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/> for more details.


## k8s.container.memory.request.desired

Memory resource requested as defined by the container spec.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_container_memory_request_desired_int64`
- `create_observable_k8s_container_memory_request_desired_int64`


This metric aligns with the request in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcerequirements-v1-core) field of
[K8s Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#container-v1-core)
(spec.containers[*].resources). Also see `Desired Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/> for more details.


## k8s.container.memory.request.utilization

The ratio of container memory working set to its current memory request.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_container_memory_request_utilization_double`
- `create_observable_k8s_container_memory_request_utilization_double`


The numerator is the container memory working set, as reported by `container.memory.working_set`. The current memory request
reflects the request applied to the running container, as reported by
[ContainerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#containerstatus-v1-core).
A value of 1.0 means the container is using exactly its memory request. Since a memory request is a
scheduling reservation and not a hard cap, values above 1.0 are possible and indicate the container is
using more memory than requested. If the memory request is not set, this metric SHOULD NOT be emitted for
that container.


## k8s.container.ready

Indicates whether the container is currently marked as ready to accept traffic, based on its readiness probe (1 = ready, 0 = not ready).


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {container} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_container_ready_int64`
- `create_observable_k8s_container_ready_int64`


This metric SHOULD reflect the value of the `ready` field in the
[K8s ContainerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#containerstatus-v1-core).


## k8s.container.restart.count

Describes how many times the container has restarted (since the last counter reset).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {restart} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_container_restart_count_int64`
- `create_observable_k8s_container_restart_count_int64`


This value is pulled directly from the K8s API and the value can go indefinitely high and be reset to 0
at any time depending on how your kubelet is configured to prune dead containers.
It is best to not depend too much on the exact value but rather look at it as
either == 0, in which case you can conclude there were no restarts in the recent past, or > 0, in which case
you can conclude there were restarts in the recent past, and not try and analyze the value beyond that.


## k8s.container.status.reason

Describes the number of K8s containers that are currently in a state for a given reason.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {container} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_container_status_reason_int64`
- `create_observable_k8s_container_status_reason_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.container.status.reason | required |

All possible container state reasons will be reported at each time interval to avoid missing metrics.
Only the value corresponding to the current state reason will be non-zero.


## k8s.container.status.state

Describes the number of K8s containers that are currently in a given state.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {container} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_container_status_state_int64`
- `create_observable_k8s_container_status_state_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.container.status.state | required |

All possible container states will be reported at each time interval to avoid missing metrics.
Only the value corresponding to the current state will be non-zero.


## k8s.container.storage.limit

Maximum storage resource limit set for the container.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_container_storage_limit_int64`
- `create_observable_k8s_container_storage_limit_int64`


See the [Kubernetes ResourceRequirements API](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcerequirements-v1-core) for details.


## k8s.container.storage.request

Storage resource requested for the container.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_container_storage_request_int64`
- `create_observable_k8s_container_storage_request_int64`


See the [Kubernetes ResourceRequirements API](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcerequirements-v1-core) for details.


## k8s.cronjob.active_jobs

Deprecated, use `k8s.cronjob.job.active` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {job} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.cronjob.job.active`.
Replacement: k8s.cronjob.job.active.

Constructors:

- `create_k8s_cronjob_activeJobs_int64`
- `create_observable_k8s_cronjob_activeJobs_int64`


This metric aligns with the `active` field of the
[K8s CronJobStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#cronjobstatus-v1-batch).


## k8s.cronjob.job.active

The number of actively running jobs for a cronjob.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {job} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_cronjob_job_active_int64`
- `create_observable_k8s_cronjob_job_active_int64`


This metric aligns with the `active` field of the
[K8s CronJobStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#cronjobstatus-v1-batch).


## k8s.daemonset.current_scheduled_nodes

Deprecated, use `k8s.daemonset.node.current_scheduled` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {node} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.daemonset.node.current_scheduled`.
Replacement: k8s.daemonset.node.current_scheduled.

Constructors:

- `create_k8s_daemonset_currentScheduledNodes_int64`
- `create_observable_k8s_daemonset_currentScheduledNodes_int64`


This metric aligns with the `currentNumberScheduled` field of the
[K8s DaemonSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#daemonsetstatus-v1-apps).


## k8s.daemonset.desired_scheduled_nodes

Deprecated, use `k8s.daemonset.node.desired_scheduled` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {node} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.daemonset.node.desired_scheduled`.
Replacement: k8s.daemonset.node.desired_scheduled.

Constructors:

- `create_k8s_daemonset_desiredScheduledNodes_int64`
- `create_observable_k8s_daemonset_desiredScheduledNodes_int64`


This metric aligns with the `desiredNumberScheduled` field of the
[K8s DaemonSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#daemonsetstatus-v1-apps).


## k8s.daemonset.misscheduled_nodes

Deprecated, use `k8s.daemonset.node.misscheduled` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {node} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.daemonset.node.misscheduled`.
Replacement: k8s.daemonset.node.misscheduled.

Constructors:

- `create_k8s_daemonset_misscheduledNodes_int64`
- `create_observable_k8s_daemonset_misscheduledNodes_int64`


This metric aligns with the `numberMisscheduled` field of the
[K8s DaemonSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#daemonsetstatus-v1-apps).


## k8s.daemonset.node.current_scheduled

Number of nodes that are running at least 1 daemon pod and are supposed to run the daemon pod.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {node} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_daemonset_node_currentScheduled_int64`
- `create_observable_k8s_daemonset_node_currentScheduled_int64`


This metric aligns with the `currentNumberScheduled` field of the
[K8s DaemonSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#daemonsetstatus-v1-apps).


## k8s.daemonset.node.desired_scheduled

Number of nodes that should be running the daemon pod (including nodes currently running the daemon pod).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {node} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_daemonset_node_desiredScheduled_int64`
- `create_observable_k8s_daemonset_node_desiredScheduled_int64`


This metric aligns with the `desiredNumberScheduled` field of the
[K8s DaemonSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#daemonsetstatus-v1-apps).


## k8s.daemonset.node.misscheduled

Number of nodes that are running the daemon pod, but are not supposed to run the daemon pod.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {node} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_daemonset_node_misscheduled_int64`
- `create_observable_k8s_daemonset_node_misscheduled_int64`


This metric aligns with the `numberMisscheduled` field of the
[K8s DaemonSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#daemonsetstatus-v1-apps).


## k8s.daemonset.node.ready

Number of nodes that should be running the daemon pod and have one or more of the daemon pod running and ready.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {node} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_daemonset_node_ready_int64`
- `create_observable_k8s_daemonset_node_ready_int64`


This metric aligns with the `numberReady` field of the
[K8s DaemonSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#daemonsetstatus-v1-apps).


## k8s.daemonset.ready_nodes

Deprecated, use `k8s.daemonset.node.ready` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {node} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.daemonset.node.ready`.
Replacement: k8s.daemonset.node.ready.

Constructors:

- `create_k8s_daemonset_readyNodes_int64`
- `create_observable_k8s_daemonset_readyNodes_int64`


This metric aligns with the `numberReady` field of the
[K8s DaemonSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#daemonsetstatus-v1-apps).


## k8s.deployment.available_pods

Deprecated, use `k8s.deployment.pod.available` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.deployment.pod.available`.
Replacement: k8s.deployment.pod.available.

Constructors:

- `create_k8s_deployment_availablePods_int64`
- `create_observable_k8s_deployment_availablePods_int64`


This metric aligns with the `availableReplicas` field of the
[K8s DeploymentStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#deploymentstatus-v1-apps).


## k8s.deployment.desired_pods

Deprecated, use `k8s.deployment.pod.desired` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.deployment.pod.desired`.
Replacement: k8s.deployment.pod.desired.

Constructors:

- `create_k8s_deployment_desiredPods_int64`
- `create_observable_k8s_deployment_desiredPods_int64`


This metric aligns with the `replicas` field of the
[K8s DeploymentSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#deploymentspec-v1-apps).


## k8s.deployment.pod.available

Total number of available replica pods (ready for at least minReadySeconds) targeted by this deployment.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_deployment_pod_available_int64`
- `create_observable_k8s_deployment_pod_available_int64`


This metric aligns with the `availableReplicas` field of the
[K8s DeploymentStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#deploymentstatus-v1-apps).


## k8s.deployment.pod.desired

Number of desired replica pods in this deployment.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_deployment_pod_desired_int64`
- `create_observable_k8s_deployment_pod_desired_int64`


This metric aligns with the `replicas` field of the
[K8s DeploymentSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#deploymentspec-v1-apps).


## k8s.hpa.current_pods

Deprecated, use `k8s.hpa.pod.current` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.hpa.pod.current`.
Replacement: k8s.hpa.pod.current.

Constructors:

- `create_k8s_hpa_currentPods_int64`
- `create_observable_k8s_hpa_currentPods_int64`


This metric aligns with the `currentReplicas` field of the
[K8s HorizontalPodAutoscalerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#horizontalpodautoscalerstatus-v2-autoscaling)


## k8s.hpa.desired_pods

Deprecated, use `k8s.hpa.pod.desired` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.hpa.pod.desired`.
Replacement: k8s.hpa.pod.desired.

Constructors:

- `create_k8s_hpa_desiredPods_int64`
- `create_observable_k8s_hpa_desiredPods_int64`


This metric aligns with the `desiredReplicas` field of the
[K8s HorizontalPodAutoscalerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#horizontalpodautoscalerstatus-v2-autoscaling)


## k8s.hpa.max_pods

Deprecated, use `k8s.hpa.pod.max` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.hpa.pod.max`.
Replacement: k8s.hpa.pod.max.

Constructors:

- `create_k8s_hpa_maxPods_int64`
- `create_observable_k8s_hpa_maxPods_int64`


This metric aligns with the `maxReplicas` field of the
[K8s HorizontalPodAutoscalerSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#horizontalpodautoscalerspec-v2-autoscaling)


## k8s.hpa.metric.target.cpu.average_utilization

Target average utilization, in percentage, for CPU resource in HPA config.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_k8s_hpa_metric_target_cpu_averageUtilization_int64`
- `create_observable_k8s_hpa_metric_target_cpu_averageUtilization_int64`
- `create_k8s_hpa_metric_target_cpu_averageUtilization_double`
- `create_observable_k8s_hpa_metric_target_cpu_averageUtilization_double`

| Attribute | Requirement |
| --- | --- |
| k8s.container.name | Conditionally required: if and only if k8s.hpa.metric.type is ContainerResource. |
| k8s.hpa.metric.type | recommended |

This metric aligns with the `averageUtilization` field of the
[K8s HPA MetricTarget](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#metrictarget-v2-autoscaling).
If the type of the metric is [`ContainerResource`](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-metrics-apis),
the `k8s.container.name` attribute MUST be set to identify the specific container within the pod to which the metric applies.


## k8s.hpa.metric.target.cpu.average_value

Target average value for CPU resource in HPA config.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | {cpu} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_k8s_hpa_metric_target_cpu_averageValue_int64`
- `create_observable_k8s_hpa_metric_target_cpu_averageValue_int64`
- `create_k8s_hpa_metric_target_cpu_averageValue_double`
- `create_observable_k8s_hpa_metric_target_cpu_averageValue_double`

| Attribute | Requirement |
| --- | --- |
| k8s.container.name | Conditionally required: if and only if k8s.hpa.metric.type is ContainerResource |
| k8s.hpa.metric.type | recommended |

This metric aligns with the `averageValue` field of the
[K8s HPA MetricTarget](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#metrictarget-v2-autoscaling).
If the type of the metric is [`ContainerResource`](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-metrics-apis),
the `k8s.container.name` attribute MUST be set to identify the specific container within the pod to which the metric applies.


## k8s.hpa.metric.target.cpu.value

Target value for CPU resource in HPA config.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | {cpu} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_k8s_hpa_metric_target_cpu_value_int64`
- `create_observable_k8s_hpa_metric_target_cpu_value_int64`
- `create_k8s_hpa_metric_target_cpu_value_double`
- `create_observable_k8s_hpa_metric_target_cpu_value_double`

| Attribute | Requirement |
| --- | --- |
| k8s.container.name | Conditionally required: if and only if k8s.hpa.metric.type is ContainerResource |
| k8s.hpa.metric.type | recommended |

This metric aligns with the `value` field of the
[K8s HPA MetricTarget](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#metrictarget-v2-autoscaling).
If the type of the metric is [`ContainerResource`](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-metrics-apis),
the `k8s.container.name` attribute MUST be set to identify the specific container within the pod to which the metric applies.


## k8s.hpa.min_pods

Deprecated, use `k8s.hpa.pod.min` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.hpa.pod.min`.
Replacement: k8s.hpa.pod.min.

Constructors:

- `create_k8s_hpa_minPods_int64`
- `create_observable_k8s_hpa_minPods_int64`


This metric aligns with the `minReplicas` field of the
[K8s HorizontalPodAutoscalerSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#horizontalpodautoscalerspec-v2-autoscaling)


## k8s.hpa.pod.current

Current number of replica pods managed by this horizontal pod autoscaler, as last seen by the autoscaler.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_hpa_pod_current_int64`
- `create_observable_k8s_hpa_pod_current_int64`


This metric aligns with the `currentReplicas` field of the
[K8s HorizontalPodAutoscalerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#horizontalpodautoscalerstatus-v2-autoscaling)


## k8s.hpa.pod.desired

Desired number of replica pods managed by this horizontal pod autoscaler, as last calculated by the autoscaler.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_hpa_pod_desired_int64`
- `create_observable_k8s_hpa_pod_desired_int64`


This metric aligns with the `desiredReplicas` field of the
[K8s HorizontalPodAutoscalerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#horizontalpodautoscalerstatus-v2-autoscaling)


## k8s.hpa.pod.max

The upper limit for the number of replica pods to which the autoscaler can scale up.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_hpa_pod_max_int64`
- `create_observable_k8s_hpa_pod_max_int64`


This metric aligns with the `maxReplicas` field of the
[K8s HorizontalPodAutoscalerSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#horizontalpodautoscalerspec-v2-autoscaling)


## k8s.hpa.pod.min

The lower limit for the number of replica pods to which the autoscaler can scale down.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_hpa_pod_min_int64`
- `create_observable_k8s_hpa_pod_min_int64`


This metric aligns with the `minReplicas` field of the
[K8s HorizontalPodAutoscalerSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#horizontalpodautoscalerspec-v2-autoscaling)


## k8s.job.active_pods

Deprecated, use `k8s.job.pod.active` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.job.pod.active`.
Replacement: k8s.job.pod.active.

Constructors:

- `create_k8s_job_activePods_int64`
- `create_observable_k8s_job_activePods_int64`


This metric aligns with the `active` field of the
[K8s JobStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#jobstatus-v1-batch).


## k8s.job.desired_successful_pods

Deprecated, use `k8s.job.pod.desired_successful` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.job.pod.desired_successful`.
Replacement: k8s.job.pod.desired_successful.

Constructors:

- `create_k8s_job_desiredSuccessfulPods_int64`
- `create_observable_k8s_job_desiredSuccessfulPods_int64`


This metric aligns with the `completions` field of the
[K8s JobSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#jobspec-v1-batch)..


## k8s.job.failed_pods

Deprecated, use `k8s.job.pod.failed` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.job.pod.failed`.
Replacement: k8s.job.pod.failed.

Constructors:

- `create_k8s_job_failedPods_int64`
- `create_observable_k8s_job_failedPods_int64`


This metric aligns with the `failed` field of the
[K8s JobStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#jobstatus-v1-batch).


## k8s.job.max_parallel_pods

Deprecated, use `k8s.job.pod.max_parallel` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.job.pod.max_parallel`.
Replacement: k8s.job.pod.max_parallel.

Constructors:

- `create_k8s_job_maxParallelPods_int64`
- `create_observable_k8s_job_maxParallelPods_int64`


This metric aligns with the `parallelism` field of the
[K8s JobSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#jobspec-v1-batch).


## k8s.job.pod.active

The number of pending and actively running pods for a job.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_job_pod_active_int64`
- `create_observable_k8s_job_pod_active_int64`


This metric aligns with the `active` field of the
[K8s JobStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#jobstatus-v1-batch).


## k8s.job.pod.desired_successful

The desired number of successfully finished pods the job should be run with.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_job_pod_desiredSuccessful_int64`
- `create_observable_k8s_job_pod_desiredSuccessful_int64`


This metric aligns with the `completions` field of the
[K8s JobSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#jobspec-v1-batch)..


## k8s.job.pod.failed

The number of pods which reached phase Failed for a job.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_job_pod_failed_int64`
- `create_observable_k8s_job_pod_failed_int64`


This metric aligns with the `failed` field of the
[K8s JobStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#jobstatus-v1-batch).


## k8s.job.pod.max_parallel

The max desired number of pods the job should run at any given time.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_job_pod_maxParallel_int64`
- `create_observable_k8s_job_pod_maxParallel_int64`


This metric aligns with the `parallelism` field of the
[K8s JobSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#jobspec-v1-batch).


## k8s.job.pod.successful

The number of pods which reached phase Succeeded for a job.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_job_pod_successful_int64`
- `create_observable_k8s_job_pod_successful_int64`


This metric aligns with the `succeeded` field of the
[K8s JobStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#jobstatus-v1-batch).


## k8s.job.successful_pods

Deprecated, use `k8s.job.pod.successful` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.job.pod.successful`.
Replacement: k8s.job.pod.successful.

Constructors:

- `create_k8s_job_successfulPods_int64`
- `create_observable_k8s_job_successfulPods_int64`


This metric aligns with the `succeeded` field of the
[K8s JobStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#jobstatus-v1-batch).


## k8s.namespace.phase

Describes number of K8s namespaces that are currently in a given phase.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {namespace} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_namespace_phase_int64`
- `create_observable_k8s_namespace_phase_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.namespace.phase | required |


## k8s.node.allocatable.cpu

Deprecated, use `k8s.node.cpu.allocatable` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Replaced by `k8s.node.cpu.allocatable`.
Replacement: k8s.node.cpu.allocatable.

Constructors:

- `create_k8s_node_allocatable_cpu_double`
- `create_observable_k8s_node_allocatable_cpu_double`



## k8s.node.allocatable.ephemeral_storage

Deprecated, use `k8s.node.ephemeral_storage.allocatable` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.node.ephemeral_storage.allocatable`.
Replacement: k8s.node.ephemeral_storage.allocatable.

Constructors:

- `create_k8s_node_allocatable_ephemeralStorage_int64`
- `create_observable_k8s_node_allocatable_ephemeralStorage_int64`



## k8s.node.allocatable.memory

Deprecated, use `k8s.node.memory.allocatable` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.node.memory.allocatable`.
Replacement: k8s.node.memory.allocatable.

Constructors:

- `create_k8s_node_allocatable_memory_int64`
- `create_observable_k8s_node_allocatable_memory_int64`



## k8s.node.allocatable.pods

Deprecated, use `k8s.node.pod.allocatable` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.node.pod.allocatable`.
Replacement: k8s.node.pod.allocatable.

Constructors:

- `create_k8s_node_allocatable_pods_int64`
- `create_observable_k8s_node_allocatable_pods_int64`



## k8s.node.condition.status

Describes the condition of a particular Node.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {node} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_node_condition_status_int64`
- `create_observable_k8s_node_condition_status_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.node.condition.status | required |
| k8s.node.condition.type | required |

All possible node condition pairs (type and status) will be reported at each time interval to avoid missing metrics. Condition pairs corresponding to the current conditions' statuses will be non-zero.


## k8s.node.cpu.allocatable

Amount of CPU allocatable on the node.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_node_cpu_allocatable_double`
- `create_observable_k8s_node_cpu_allocatable_double`



## k8s.node.cpu.time

Total CPU time consumed.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | s |
| Numeric annotation | double |
| Stability | release candidate |


Constructors:

- `create_k8s_node_cpu_time_double`
- `create_observable_k8s_node_cpu_time_double`


Total CPU time consumed by the specific Node on all available CPU cores


## k8s.node.cpu.usage

Node's CPU usage, measured in CPUs. Range from 0 to the number of allocatable CPUs.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | release candidate |


Constructors:

- `create_k8s_node_cpu_usage_double`
- `create_observable_k8s_node_cpu_usage_double`


CPU usage of the specific Node on all available CPU cores. It is calculated as the change in cumulative CPU time (k8s.node.cpu.time) over a measurement interval, divided by the elapsed time: usageCores = (cpuTimeEnd - cpuTimeStart) / elapsedSeconds


## k8s.node.ephemeral_storage.allocatable

Amount of ephemeral-storage allocatable on the node.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_node_ephemeralStorage_allocatable_int64`
- `create_observable_k8s_node_ephemeralStorage_allocatable_int64`



## k8s.node.filesystem.available

Node filesystem available bytes.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_node_filesystem_available_int64`
- `create_observable_k8s_node_filesystem_available_int64`


This metric is derived from the
[FsStats.AvailableBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#FsStats) field
of the [NodeStats.Fs](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#NodeStats)
of the Kubelet's stats API.


## k8s.node.filesystem.capacity

Node filesystem capacity.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_node_filesystem_capacity_int64`
- `create_observable_k8s_node_filesystem_capacity_int64`


This metric is derived from the
[FsStats.CapacityBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#FsStats) field
of the [NodeStats.Fs](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#NodeStats)
of the Kubelet's stats API.


## k8s.node.filesystem.inode.count

The total inodes in the node's root filesystem.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {inode} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_node_filesystem_inode_count_int64`
- `create_observable_k8s_node_filesystem_inode_count_int64`


This metric is derived from the
[FsStats.Inodes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#FsStats) field
of the [NodeStats.Fs](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#NodeStats)
of the Kubelet's stats API.


## k8s.node.filesystem.inode.free

The free inodes in the node's root filesystem.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {inode} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_node_filesystem_inode_free_int64`
- `create_observable_k8s_node_filesystem_inode_free_int64`


This metric is derived from the
[FsStats.InodesFree](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#FsStats) field
of the [NodeStats.Fs](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#NodeStats)
of the Kubelet's stats API.


## k8s.node.filesystem.usage

Node filesystem usage.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_node_filesystem_usage_int64`
- `create_observable_k8s_node_filesystem_usage_int64`


This metric is derived from the
[FsStats.UsedBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#FsStats) field
of the [NodeStats.Fs](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#NodeStats)
of the Kubelet's stats API.

Capacity and available are reported for the backing filesystem,
which may be shared with other workloads; therefore,
usage may not equal `capacity - available`.


## k8s.node.memory.allocatable

Amount of memory allocatable on the node.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_node_memory_allocatable_int64`
- `create_observable_k8s_node_memory_allocatable_int64`



## k8s.node.memory.available

Node memory available.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_node_memory_available_int64`
- `create_observable_k8s_node_memory_available_int64`


Available memory for use.  This is defined as the memory limit - workingSetBytes. If memory limit is undefined, the available bytes is omitted.
This metric is derived from the [MemoryStats.AvailableBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [NodeStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#NodeStats) of the Kubelet's stats API.


## k8s.node.memory.paging.faults

Deprecated, use `k8s.node.paging.faults` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {fault} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.node.paging.faults`.
Replacement: k8s.node.paging.faults.

Constructors:

- `create_k8s_node_memory_paging_faults_int64`
- `create_observable_k8s_node_memory_paging_faults_int64`

| Attribute | Requirement |
| --- | --- |
| system.paging.fault.type | recommended |

Cumulative number of major/minor page faults.
This metric is derived from the [MemoryStats.PageFaults](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) and [MemoryStats.MajorPageFaults](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) fields of the [NodeStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#NodeStats) of the Kubelet's stats API.


## k8s.node.memory.rss

Node memory RSS.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_node_memory_rss_int64`
- `create_observable_k8s_node_memory_rss_int64`


The amount of anonymous and swap cache memory (includes transparent hugepages).
This metric is derived from the [MemoryStats.RSSBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [NodeStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#NodeStats) of the Kubelet's stats API.


## k8s.node.memory.usage

Memory usage of the Node.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_node_memory_usage_int64`
- `create_observable_k8s_node_memory_usage_int64`


Total memory in use. This includes all memory regardless of when it was accessed.
This metric is derived from the [MemoryStats.UsageBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [NodeStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#NodeStats) of the Kubelet's stats API.


## k8s.node.memory.working_set

Node memory working set.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_node_memory_workingSet_int64`
- `create_observable_k8s_node_memory_workingSet_int64`


The amount of working set memory. This includes recently accessed memory, dirty memory, and kernel memory. On Linux, the working set is calculated by excluding inactive file-backed memory from memory usage (`inactive_file` on cgroup v2, `total_inactive_file` on cgroup v1), so active file-backed memory remains included. On Linux, the kubelet uses the node working set when determining memory availability for the `memory.available` eviction signal. `WorkingSetBytes` is less than or equal to `UsageBytes`.
This metric is derived from the [MemoryStats.WorkingSetBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [NodeStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#NodeStats) of the Kubelet's stats API.


## k8s.node.network.errors

Node network errors.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {error} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_node_network_errors_int64`
- `create_observable_k8s_node_network_errors_int64`

| Attribute | Requirement |
| --- | --- |
| network.interface.name | recommended |
| network.io.direction | recommended |


## k8s.node.network.io

Network bytes for the Node.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_node_network_io_int64`
- `create_observable_k8s_node_network_io_int64`

| Attribute | Requirement |
| --- | --- |
| network.interface.name | recommended |
| network.io.direction | recommended |


## k8s.node.paging.faults

Node memory paging faults.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {fault} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_node_paging_faults_int64`
- `create_observable_k8s_node_paging_faults_int64`

| Attribute | Requirement |
| --- | --- |
| system.paging.fault.type | recommended |

Cumulative number of major and minor page faults.
The [MemoryStats.MajorPageFaults](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [NodeStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#NodeStats) of the Kubelet's stats API maps directly to `system.paging.fault.type=major`.
The [MemoryStats.PageFaults](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field reports the total number of page faults (equivalent to `pgfault` in the cgroup `memory.stat`), with minor and major combined. The minor page faults MUST therefore be derived as `MemoryStats.PageFaults - MemoryStats.MajorPageFaults`, so that summing the metric over `system.paging.fault.type` yields the total number of page faults.


## k8s.node.pid.limit

Total number of processes/threads allowed by the operating system on the node.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {thread} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_node_pid_limit_int64`
- `create_observable_k8s_node_pid_limit_int64`


Derived from the Kubelet Summary API
([RlimitStats.MaxPID](https://pkg.go.dev/k8s.io/kubelet@v0.33.0/pkg/apis/stats/v1alpha1#RlimitStats))
field of the [NodeStats.Rlimit](https://pkg.go.dev/k8s.io/kubelet@v0.33.0/pkg/apis/stats/v1alpha1#NodeStats),
representing the system-wide task limit (the lower of `kernel.pid_max` and `kernel.threads-max`).


## k8s.node.pid.usage

Total number of existing processes and threads on the node.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {thread} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_node_pid_usage_int64`
- `create_observable_k8s_node_pid_usage_int64`


Derived from the Kubelet Summary API
([RlimitStats.NumOfRunningProcesses](https://pkg.go.dev/k8s.io/kubelet@v0.33.0/pkg/apis/stats/v1alpha1#RlimitStats))
field of the [NodeStats.Rlimit](https://pkg.go.dev/k8s.io/kubelet@v0.33.0/pkg/apis/stats/v1alpha1#NodeStats),
which reads the total count of scheduling entities (threads/processes across all states) from `/proc/loadavg`.


## k8s.node.pod.allocatable

Amount of pods allocatable on the node.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_node_pod_allocatable_int64`
- `create_observable_k8s_node_pod_allocatable_int64`



## k8s.node.system_container.cpu.time

Node's system container CPU time.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_node_systemContainer_cpu_time_double`
- `create_observable_k8s_node_systemContainer_cpu_time_double`


This metric is derived from the [CPUStats.UsageCoreNanoSeconds](https://github.com/kubernetes/kubelet/blob/v0.35.2/pkg/apis/stats/v1alpha1/types.go#L236) field of the [ContainerStats](https://github.com/kubernetes/kubelet/blob/v0.35.2/pkg/apis/stats/v1alpha1/types.go#L157C6-L157C20) of [Node.SystemContainers](https://github.com/kubernetes/kubelet/blob/v0.35.2/pkg/apis/stats/v1alpha1/types.go#L40) of the Kubelet's stats API.


## k8s.node.system_container.cpu.usage

Node's system container CPU usage, measured in CPUs.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_node_systemContainer_cpu_usage_double`
- `create_observable_k8s_node_systemContainer_cpu_usage_double`


CPU usage of the specific System Container on all available CPU cores. It is calculated as the change in cumulative CPU time (k8s.node.system_container.cpu.time) over a measurement interval, divided by the elapsed time: usageCores = (cpuTimeEnd - cpuTimeStart) / elapsedSeconds


## k8s.node.system_container.memory.usage

Node's system container memory usage.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_node_systemContainer_memory_usage_int64`
- `create_observable_k8s_node_systemContainer_memory_usage_int64`


This metric is derived from the [MemoryStats.UsageBytes](https://github.com/kubernetes/kubelet/blob/v0.35.2/pkg/apis/stats/v1alpha1/types.go#L252) field of the [ContainerStats](https://github.com/kubernetes/kubelet/blob/v0.35.2/pkg/apis/stats/v1alpha1/types.go#L157C6-L157C20) of [Node.SystemContainers](https://github.com/kubernetes/kubelet/blob/v0.35.2/pkg/apis/stats/v1alpha1/types.go#L40) of the Kubelet's stats API.


## k8s.node.system_container.memory.working_set

The amount of working set memory.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_node_systemContainer_memory_workingSet_int64`
- `create_observable_k8s_node_systemContainer_memory_workingSet_int64`


This metric is derived from the [MemoryStats.WorkingSetBytes](https://github.com/kubernetes/kubelet/blob/v0.35.2/pkg/apis/stats/v1alpha1/types.go#L256) field of the [ContainerStats](https://github.com/kubernetes/kubelet/blob/v0.35.2/pkg/apis/stats/v1alpha1/types.go#L157C6-L157C20) of [Node.SystemContainers](https://github.com/kubernetes/kubelet/blob/v0.35.2/pkg/apis/stats/v1alpha1/types.go#L40) of the Kubelet's stats API.


## k8s.node.uptime

The time the Node has been running.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | release candidate |


Constructors:

- `create_k8s_node_uptime_double`
- `create_observable_k8s_node_uptime_double`


Instrumentations SHOULD use a gauge with type `double` and measure uptime in seconds as a floating point number with the highest precision available. The actual accuracy would depend on the instrumentation and operating system.
This metric is derived from the [NodeStats.StartTime](https://github.com/kubernetes/kubelet/blob/v0.35.2/pkg/apis/stats/v1alpha1/types.go#L42) field of Kubelet's stats API, which is set to the [system boot time](https://github.com/kubernetes/kubernetes/blob/v1.36.3/pkg/kubelet/server/stats/summary.go#L113). This value resets when the node reboots.


## k8s.persistentvolume.status.phase

Number of PersistentVolumes in a given phase.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {persistentvolume} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_persistentvolume_status_phase_int64`
- `create_observable_k8s_persistentvolume_status_phase_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.persistentvolume.status.phase | required |

All possible phases should be reported at each interval to avoid gaps in the time series.
This metric is derived from the `.status.phase` field of the
[K8s PersistentVolumeStatus](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/persistent-volume-v1/#PersistentVolumeStatus).


## k8s.persistentvolume.storage.capacity

The storage capacity of the PersistentVolume.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_persistentvolume_storage_capacity_int64`
- `create_observable_k8s_persistentvolume_storage_capacity_int64`


This metric is derived from the `.spec.capacity.storage` field of the [K8s PersistentVolumeSpec](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/persistent-volume-v1/#PersistentVolumeSpec).


## k8s.persistentvolumeclaim.status.phase

Number of PersistentVolumeClaims in a given phase.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {persistentvolumeclaim} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_persistentvolumeclaim_status_phase_int64`
- `create_observable_k8s_persistentvolumeclaim_status_phase_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.persistentvolumeclaim.status.phase | required |

All possible phases should be reported at each interval to avoid gaps in the time series.
This metric is derived from the `.status.phase` field of the
[K8s PersistentVolumeClaimStatus](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/persistent-volume-claim-v1/#PersistentVolumeClaimStatus).


## k8s.persistentvolumeclaim.storage.capacity

The actual storage capacity provisioned for the PersistentVolumeClaim.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_persistentvolumeclaim_storage_capacity_int64`
- `create_observable_k8s_persistentvolumeclaim_storage_capacity_int64`


Only available when the PVC is bound. May differ from the requested capacity due to provisioner rounding.
This metric is derived from the `.status.capacity.storage` field of the
[K8s PersistentVolumeClaimStatus](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/persistent-volume-claim-v1/#PersistentVolumeClaimStatus).


## k8s.persistentvolumeclaim.storage.request

The storage requested by the PersistentVolumeClaim.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_persistentvolumeclaim_storage_request_int64`
- `create_observable_k8s_persistentvolumeclaim_storage_request_int64`


This metric is derived from the `.spec.resources.requests.storage` field of the [K8s PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/persistent-volume-claim-v1/#PersistentVolumeClaimSpec).


## k8s.pod.cpu.limit.current

Maximum CPU resource limit currently configured for a running Pod.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_pod_cpu_limit_current_double`
- `create_observable_k8s_pod_cpu_limit_current_double`


This metric aligns with the limit in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#resourcerequirements-v1-core) field of
[K8s PodStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#podstatus-v1-core)
(status.resources). Also see `Actual Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/> for more details.


## k8s.pod.cpu.limit.desired

Maximum CPU resource limit as defined by the Pod spec.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_pod_cpu_limit_desired_double`
- `create_observable_k8s_pod_cpu_limit_desired_double`


This metric aligns with the limit in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#resourcerequirements-v1-core) field of
[K8s PodSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#podspec-v1-core)
(spec.resources). See
<https://kubernetes.io/docs/tasks/configure-pod-container/assign-pod-level-resources/>
for more details on Pod level resources. Note that Kubernetes can default unset Pod level limits
based on the aggregated limits of the Pod's containers. Also see `Desired Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/>.


## k8s.pod.cpu.limit.utilization

The ratio of Pod CPU usage to its current CPU limit.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_pod_cpu_limit_utilization_double`
- `create_observable_k8s_pod_cpu_limit_utilization_double`


The current CPU limit reflects the actual resources applied at the Pod level, as reported by
[PodStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#podstatus-v1-core).
The value range is [0.0,1.0]. A value of 1.0 means the Pod is using 100% of its actual CPU limit.
If the CPU limit is not set, this metric SHOULD NOT be emitted for that Pod.


## k8s.pod.cpu.request.current

CPU resource requested currently configured for a running Pod.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_pod_cpu_request_current_double`
- `create_observable_k8s_pod_cpu_request_current_double`


This metric aligns with the request in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#resourcerequirements-v1-core) field of
[K8s PodStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#podstatus-v1-core)
(status.resources). Also see `Actual Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/> for more details.


## k8s.pod.cpu.request.desired

CPU resource requested as defined by the Pod spec.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_pod_cpu_request_desired_double`
- `create_observable_k8s_pod_cpu_request_desired_double`


This metric aligns with the request in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#resourcerequirements-v1-core) field of
[K8s PodSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#podspec-v1-core)
(spec.resources). See
<https://kubernetes.io/docs/tasks/configure-pod-container/assign-pod-level-resources/>
for more details on Pod level resources. Note that Kubernetes can default unset Pod level requests
based on the aggregated requests of the Pod's containers. Also see `Desired Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/>.


## k8s.pod.cpu.request.utilization

The ratio of Pod CPU usage to its current CPU request.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_pod_cpu_request_utilization_double`
- `create_observable_k8s_pod_cpu_request_utilization_double`


The current CPU request reflects the request applied at the Pod level, as reported by
[PodStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#podstatus-v1-core).
A value of 1.0 means the Pod is using exactly its CPU request. Since a CPU request is a scheduling
reservation and not a hard cap, values above 1.0 are possible and indicate the Pod is using more CPU
than requested. If the CPU request is not set, this metric SHOULD NOT be emitted for that Pod.


## k8s.pod.cpu.time

Total CPU time consumed.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | s |
| Numeric annotation | double |
| Stability | release candidate |


Constructors:

- `create_k8s_pod_cpu_time_double`
- `create_observable_k8s_pod_cpu_time_double`


Total CPU time consumed by the specific Pod on all available CPU cores


## k8s.pod.cpu.usage

Pod's CPU usage, measured in CPUs. Range from 0 to the number of allocatable CPUs.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | release candidate |


Constructors:

- `create_k8s_pod_cpu_usage_double`
- `create_observable_k8s_pod_cpu_usage_double`


CPU usage of the specific Pod on all available CPU cores. It is calculated as the change in cumulative CPU time (k8s.pod.cpu.time) over a measurement interval, divided by the elapsed time: usageCores = (cpuTimeEnd - cpuTimeStart) / elapsedSeconds


## k8s.pod.filesystem.available

Pod filesystem available bytes.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_pod_filesystem_available_int64`
- `create_observable_k8s_pod_filesystem_available_int64`


This metric is derived from the
[FsStats.AvailableBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#FsStats) field
of the [PodStats.EphemeralStorage](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats)
of the Kubelet's stats API.


## k8s.pod.filesystem.capacity

Pod filesystem capacity.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_pod_filesystem_capacity_int64`
- `create_observable_k8s_pod_filesystem_capacity_int64`


This metric is derived from the
[FsStats.CapacityBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#FsStats) field
of the [PodStats.EphemeralStorage](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats)
of the Kubelet's stats API.


## k8s.pod.filesystem.usage

Pod filesystem usage.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_pod_filesystem_usage_int64`
- `create_observable_k8s_pod_filesystem_usage_int64`


This metric is derived from the
[FsStats.UsedBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#FsStats) field
of the [PodStats.EphemeralStorage](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats)
of the Kubelet's stats API.

Capacity and available are reported for the backing filesystem, which may be shared
with other workloads; therefore, usage may not equal `capacity - available`.


## k8s.pod.memory.available

Pod memory available.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_pod_memory_available_int64`
- `create_observable_k8s_pod_memory_available_int64`


Available memory for use.  This is defined as the memory limit - workingSetBytes. If memory limit is undefined, the available bytes is omitted.
This metric is derived from the [MemoryStats.AvailableBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [PodStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats) of the Kubelet's stats API.


## k8s.pod.memory.limit.current

Maximum memory resource limit currently configured for a running Pod.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_pod_memory_limit_current_int64`
- `create_observable_k8s_pod_memory_limit_current_int64`


This metric aligns with the limit in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#resourcerequirements-v1-core) field of
[K8s PodStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#podstatus-v1-core)
(status.resources). Also see `Actual Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/> for more details.


## k8s.pod.memory.limit.desired

Maximum memory resource limit as defined by the Pod spec.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_pod_memory_limit_desired_int64`
- `create_observable_k8s_pod_memory_limit_desired_int64`


This metric aligns with the limit in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#resourcerequirements-v1-core) field of
[K8s PodSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#podspec-v1-core)
(spec.resources). See
<https://kubernetes.io/docs/tasks/configure-pod-container/assign-pod-level-resources/>
for more details on Pod level resources. Note that Kubernetes can default unset Pod level limits
based on the aggregated limits of the Pod's containers. Also see `Desired Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/>.


## k8s.pod.memory.limit.utilization

The ratio of Pod memory working set to its current memory limit.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_pod_memory_limit_utilization_double`
- `create_observable_k8s_pod_memory_limit_utilization_double`


The numerator is the Pod memory working set, as reported by `k8s.pod.memory.working_set`. The current memory limit
reflects the actual resources applied at the Pod level, as reported by
[PodStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#podstatus-v1-core).
A value of 1.0 means the Pod is using 100% of its actual memory limit. Values above 1.0 can occur transiently, since memory usage can briefly exceed the limit.
If the memory limit is not set, this metric SHOULD NOT be emitted for that Pod.


## k8s.pod.memory.paging.faults

Deprecated, use `k8s.pod.paging.faults` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {fault} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.pod.paging.faults`.
Replacement: k8s.pod.paging.faults.

Constructors:

- `create_k8s_pod_memory_paging_faults_int64`
- `create_observable_k8s_pod_memory_paging_faults_int64`

| Attribute | Requirement |
| --- | --- |
| system.paging.fault.type | recommended |

Cumulative number of major/minor page faults.
This metric is derived from the [MemoryStats.PageFaults](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) and [MemoryStats.MajorPageFaults](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [PodStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats) of the Kubelet's stats API.


## k8s.pod.memory.request.current

Memory resource request currently configured for a running Pod.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_pod_memory_request_current_int64`
- `create_observable_k8s_pod_memory_request_current_int64`


This metric aligns with the request in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#resourcerequirements-v1-core) field of
[K8s PodStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#podstatus-v1-core)
(status.resources). Also see `Actual Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/> for more details.


## k8s.pod.memory.request.desired

Memory resource requested as defined by the Pod spec.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_pod_memory_request_desired_int64`
- `create_observable_k8s_pod_memory_request_desired_int64`


This metric aligns with the request in the
[`resources`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#resourcerequirements-v1-core) field of
[K8s PodSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#podspec-v1-core)
(spec.resources). See
<https://kubernetes.io/docs/tasks/configure-pod-container/assign-pod-level-resources/>
for more details on Pod level resources. Note that Kubernetes can default unset Pod level requests
based on the aggregated requests of the Pod's containers. Also see `Desired Resources` in
<https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/>.


## k8s.pod.memory.request.utilization

The ratio of Pod memory working set to its current memory request.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_pod_memory_request_utilization_double`
- `create_observable_k8s_pod_memory_request_utilization_double`


The numerator is the Pod memory working set, as reported by `k8s.pod.memory.working_set`. The current memory request
reflects the request applied at the Pod level, as reported by
[PodStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.35/#podstatus-v1-core).
A value of 1.0 means the Pod is using exactly its memory request. Since a memory request is a
scheduling reservation and not a hard cap, values above 1.0 are possible and indicate the Pod is using
more memory than requested. If the memory request is not set, this metric SHOULD NOT be emitted for that Pod.


## k8s.pod.memory.rss

Pod memory RSS.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_pod_memory_rss_int64`
- `create_observable_k8s_pod_memory_rss_int64`


The amount of anonymous and swap cache memory (includes transparent hugepages).
This metric is derived from the [MemoryStats.RSSBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [PodStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats) of the Kubelet's stats API.


## k8s.pod.memory.usage

Memory usage of the Pod.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_pod_memory_usage_int64`
- `create_observable_k8s_pod_memory_usage_int64`


Total memory in use. This includes all memory regardless of when it was accessed.
This metric is derived from the [MemoryStats.UsageBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [PodStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats) of the Kubelet's stats API.


## k8s.pod.memory.working_set

Pod memory working set.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_pod_memory_workingSet_int64`
- `create_observable_k8s_pod_memory_workingSet_int64`


The amount of working set memory. This includes recently accessed memory, dirty memory, and kernel memory. On Linux, the working set is calculated by excluding inactive file-backed memory from memory usage (`inactive_file` on cgroup v2, `total_inactive_file` on cgroup v1), so active file-backed memory remains included. The kubelet uses the Pod working set when ranking Pods for eviction under memory pressure. `WorkingSetBytes` is less than or equal to `UsageBytes`.
This metric is derived from the [MemoryStats.WorkingSetBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [PodStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats) of the Kubelet's stats API.


## k8s.pod.network.errors

Pod network errors.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {error} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_pod_network_errors_int64`
- `create_observable_k8s_pod_network_errors_int64`

| Attribute | Requirement |
| --- | --- |
| network.interface.name | recommended |
| network.io.direction | recommended |


## k8s.pod.network.io

Network bytes for the Pod.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_pod_network_io_int64`
- `create_observable_k8s_pod_network_io_int64`

| Attribute | Requirement |
| --- | --- |
| network.interface.name | recommended |
| network.io.direction | recommended |


## k8s.pod.paging.faults

Pod memory paging faults.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {fault} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_k8s_pod_paging_faults_int64`
- `create_observable_k8s_pod_paging_faults_int64`

| Attribute | Requirement |
| --- | --- |
| system.paging.fault.type | recommended |

Cumulative number of major and minor page faults.
The [MemoryStats.MajorPageFaults](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field of the [PodStats.Memory](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats) of the Kubelet's stats API maps directly to `system.paging.fault.type=major`.
The [MemoryStats.PageFaults](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#MemoryStats) field reports the total number of page faults (equivalent to `pgfault` in the cgroup `memory.stat`), with minor and major combined. The minor page faults MUST therefore be derived as `MemoryStats.PageFaults - MemoryStats.MajorPageFaults`, so that summing the metric over `system.paging.fault.type` yields the total number of page faults.


## k8s.pod.status.phase

Describes number of K8s Pods that are currently in a given phase.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_pod_status_phase_int64`
- `create_observable_k8s_pod_status_phase_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.pod.status.phase | required |

All possible pod phases will be reported at each time interval to avoid missing metrics.
Only the value corresponding to the current phase will be non-zero.


## k8s.pod.status.reason

Describes the number of K8s Pods that are currently in a state for a given reason.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_pod_status_reason_int64`
- `create_observable_k8s_pod_status_reason_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.pod.status.reason | required |

All possible pod status reasons will be reported at each time interval to avoid missing metrics.
Only the value corresponding to the current reason will be non-zero.


## k8s.pod.uptime

The time the Pod has been running.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | release candidate |


Constructors:

- `create_k8s_pod_uptime_double`
- `create_observable_k8s_pod_uptime_double`


Instrumentations SHOULD use a gauge with type `double` and measure uptime in seconds as a floating point number with the highest precision available. The actual accuracy would depend on the instrumentation and operating system.
This metric is derived from the [PodStats.StartTime](https://github.com/kubernetes/kubelet/blob/v0.35.2/pkg/apis/stats/v1alpha1/types.go#L122) field of Kubelet's stats API, where `StartTime` represents the pod sandbox creation time as [noted in the Kubelet source](https://github.com/kubernetes/kubernetes/blob/v1.36.3/pkg/kubelet/stats/cri_stats_provider.go#L299). This value resets when the node restarts, as the pod sandbox is recreated.


## k8s.pod.volume.available

Pod volume storage space available.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_pod_volume_available_int64`
- `create_observable_k8s_pod_volume_available_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.volume.name | required |
| k8s.volume.type | recommended |

This metric is derived from the
[VolumeStats.AvailableBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#VolumeStats) field
of the [PodStats](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats) of the
Kubelet's stats API.


## k8s.pod.volume.capacity

Pod volume total capacity.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_pod_volume_capacity_int64`
- `create_observable_k8s_pod_volume_capacity_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.volume.name | required |
| k8s.volume.type | recommended |

This metric is derived from the
[VolumeStats.CapacityBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#VolumeStats) field
of the [PodStats](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats) of the
Kubelet's stats API.


## k8s.pod.volume.inode.count

The total inodes in the filesystem of the Pod's volume.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {inode} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_pod_volume_inode_count_int64`
- `create_observable_k8s_pod_volume_inode_count_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.volume.name | required |
| k8s.volume.type | recommended |

This metric is derived from the
[VolumeStats.Inodes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#VolumeStats) field
of the [PodStats](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats) of the
Kubelet's stats API.


## k8s.pod.volume.inode.free

The free inodes in the filesystem of the Pod's volume.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {inode} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_pod_volume_inode_free_int64`
- `create_observable_k8s_pod_volume_inode_free_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.volume.name | required |
| k8s.volume.type | recommended |

This metric is derived from the
[VolumeStats.InodesFree](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#VolumeStats) field
of the [PodStats](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats) of the
Kubelet's stats API.


## k8s.pod.volume.inode.used

The inodes used by the filesystem of the Pod's volume.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {inode} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_pod_volume_inode_used_int64`
- `create_observable_k8s_pod_volume_inode_used_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.volume.name | required |
| k8s.volume.type | recommended |

This metric is derived from the
[VolumeStats.InodesUsed](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#VolumeStats) field
of the [PodStats](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats) of the
Kubelet's stats API.

This may not be equal to `inodes - free` because filesystem may share inodes with other filesystems.


## k8s.pod.volume.usage

Pod volume usage.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_pod_volume_usage_int64`
- `create_observable_k8s_pod_volume_usage_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.volume.name | required |
| k8s.volume.type | recommended |

This may not equal capacity - available.

This metric is derived from the
[VolumeStats.UsedBytes](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#VolumeStats) field
of the [PodStats](https://pkg.go.dev/k8s.io/kubelet@v0.34.0/pkg/apis/stats/v1alpha1#PodStats) of the
Kubelet's stats API.


## k8s.replicaset.available_pods

Deprecated, use `k8s.replicaset.pod.available` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.replicaset.pod.available`.
Replacement: k8s.replicaset.pod.available.

Constructors:

- `create_k8s_replicaset_availablePods_int64`
- `create_observable_k8s_replicaset_availablePods_int64`


This metric aligns with the `availableReplicas` field of the
[K8s ReplicaSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#replicasetstatus-v1-apps).


## k8s.replicaset.desired_pods

Deprecated, use `k8s.replicaset.pod.desired` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.replicaset.pod.desired`.
Replacement: k8s.replicaset.pod.desired.

Constructors:

- `create_k8s_replicaset_desiredPods_int64`
- `create_observable_k8s_replicaset_desiredPods_int64`


This metric aligns with the `replicas` field of the
[K8s ReplicaSetSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#replicasetspec-v1-apps).


## k8s.replicaset.pod.available

Total number of available replica pods (ready for at least minReadySeconds) targeted by this replicaset.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_replicaset_pod_available_int64`
- `create_observable_k8s_replicaset_pod_available_int64`


This metric aligns with the `availableReplicas` field of the
[K8s ReplicaSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#replicasetstatus-v1-apps).


## k8s.replicaset.pod.desired

Number of desired replica pods in this replicaset.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_replicaset_pod_desired_int64`
- `create_observable_k8s_replicaset_pod_desired_int64`


This metric aligns with the `replicas` field of the
[K8s ReplicaSetSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#replicasetspec-v1-apps).


## k8s.replication_controller.available_pods

Deprecated, use `k8s.replicationcontroller.pod.available` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.replicationcontroller.pod.available`.
Replacement: k8s.replicationcontroller.pod.available.

Constructors:

- `create_k8s_replicationController_availablePods_int64`
- `create_observable_k8s_replicationController_availablePods_int64`



## k8s.replication_controller.desired_pods

Deprecated, use `k8s.replicationcontroller.pod.desired` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.replicationcontroller.pod.desired`.
Replacement: k8s.replicationcontroller.pod.desired.

Constructors:

- `create_k8s_replicationController_desiredPods_int64`
- `create_observable_k8s_replicationController_desiredPods_int64`



## k8s.replicationcontroller.available_pods

Deprecated, use `k8s.replicationcontroller.pod.available` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.replicationcontroller.pod.available`.
Replacement: k8s.replicationcontroller.pod.available.

Constructors:

- `create_k8s_replicationcontroller_availablePods_int64`
- `create_observable_k8s_replicationcontroller_availablePods_int64`



## k8s.replicationcontroller.desired_pods

Deprecated, use `k8s.replicationcontroller.pod.desired` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.replicationcontroller.pod.desired`.
Replacement: k8s.replicationcontroller.pod.desired.

Constructors:

- `create_k8s_replicationcontroller_desiredPods_int64`
- `create_observable_k8s_replicationcontroller_desiredPods_int64`



## k8s.replicationcontroller.pod.available

Total number of available replica pods (ready for at least minReadySeconds) targeted by this replication controller.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_replicationcontroller_pod_available_int64`
- `create_observable_k8s_replicationcontroller_pod_available_int64`


This metric aligns with the `availableReplicas` field of the
[K8s ReplicationControllerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#replicationcontrollerstatus-v1-core)


## k8s.replicationcontroller.pod.desired

Number of desired replica pods in this replication controller.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_replicationcontroller_pod_desired_int64`
- `create_observable_k8s_replicationcontroller_pod_desired_int64`


This metric aligns with the `replicas` field of the
[K8s ReplicationControllerSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#replicationcontrollerspec-v1-core)


## k8s.resourcequota.cpu.limit.hard

The CPU limits in a specific namespace.
The value represents the configured quota limit of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_cpu_limit_hard_double`
- `create_observable_k8s_resourcequota_cpu_limit_hard_double`


This metric is retrieved from the `hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.cpu.limit.used

The CPU limits in a specific namespace.
The value represents the current observed total usage of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_cpu_limit_used_double`
- `create_observable_k8s_resourcequota_cpu_limit_used_double`


This metric is retrieved from the `used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.cpu.request.hard

The CPU requests in a specific namespace.
The value represents the configured quota limit of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_cpu_request_hard_double`
- `create_observable_k8s_resourcequota_cpu_request_hard_double`


This metric is retrieved from the `hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.cpu.request.used

The CPU requests in a specific namespace.
The value represents the current observed total usage of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_cpu_request_used_double`
- `create_observable_k8s_resourcequota_cpu_request_used_double`


This metric is retrieved from the `used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.ephemeral_storage.limit.hard

The sum of local ephemeral storage limits in the namespace.
The value represents the configured quota limit of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_ephemeralStorage_limit_hard_int64`
- `create_observable_k8s_resourcequota_ephemeralStorage_limit_hard_int64`


This metric is retrieved from the `hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.ephemeral_storage.limit.used

The sum of local ephemeral storage limits in the namespace.
The value represents the current observed total usage of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_ephemeralStorage_limit_used_int64`
- `create_observable_k8s_resourcequota_ephemeralStorage_limit_used_int64`


This metric is retrieved from the `used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.ephemeral_storage.request.hard

The sum of local ephemeral storage requests in the namespace.
The value represents the configured quota limit of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_ephemeralStorage_request_hard_int64`
- `create_observable_k8s_resourcequota_ephemeralStorage_request_hard_int64`


This metric is retrieved from the `hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.ephemeral_storage.request.used

The sum of local ephemeral storage requests in the namespace.
The value represents the current observed total usage of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_ephemeralStorage_request_used_int64`
- `create_observable_k8s_resourcequota_ephemeralStorage_request_used_int64`


This metric is retrieved from the `used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.hugepage_count.request.hard

The huge page requests in a specific namespace.
The value represents the configured quota limit of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {hugepage} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_hugepageCount_request_hard_int64`
- `create_observable_k8s_resourcequota_hugepageCount_request_hard_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.hugepage.size | required |

This metric is retrieved from the `hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.hugepage_count.request.used

The huge page requests in a specific namespace.
The value represents the current observed total usage of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {hugepage} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_hugepageCount_request_used_int64`
- `create_observable_k8s_resourcequota_hugepageCount_request_used_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.hugepage.size | required |

This metric is retrieved from the `used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.memory.limit.hard

The memory limits in a specific namespace.
The value represents the configured quota limit of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_memory_limit_hard_int64`
- `create_observable_k8s_resourcequota_memory_limit_hard_int64`


This metric is retrieved from the `hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.memory.limit.used

The memory limits in a specific namespace.
The value represents the current observed total usage of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_memory_limit_used_int64`
- `create_observable_k8s_resourcequota_memory_limit_used_int64`


This metric is retrieved from the `used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.memory.request.hard

The memory requests in a specific namespace.
The value represents the configured quota limit of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_memory_request_hard_int64`
- `create_observable_k8s_resourcequota_memory_request_hard_int64`


This metric is retrieved from the `hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.memory.request.used

The memory requests in a specific namespace.
The value represents the current observed total usage of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_memory_request_used_int64`
- `create_observable_k8s_resourcequota_memory_request_used_int64`


This metric is retrieved from the `used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.object_count.hard

The object count limits in a specific namespace.
The value represents the configured quota limit of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {object} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_objectCount_hard_int64`
- `create_observable_k8s_resourcequota_objectCount_hard_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.resourcequota.resource_name | required |

This metric is retrieved from the `hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.object_count.used

The object count limits in a specific namespace.
The value represents the current observed total usage of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {object} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_objectCount_used_int64`
- `create_observable_k8s_resourcequota_objectCount_used_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.resourcequota.resource_name | required |

This metric is retrieved from the `used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).


## k8s.resourcequota.persistentvolumeclaim_count.hard

The total number of PersistentVolumeClaims that can exist in the namespace.
The value represents the configured quota limit of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {persistentvolumeclaim} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_persistentvolumeclaimCount_hard_int64`
- `create_observable_k8s_resourcequota_persistentvolumeclaimCount_hard_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.storageclass.name | Conditionally required: The `k8s.storageclass.name` should be required when a resource quota is defined for a specific storage class.  |

This metric is retrieved from the `hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).

The `k8s.storageclass.name` should be required when a resource quota is defined for a specific
storage class.


## k8s.resourcequota.persistentvolumeclaim_count.used

The total number of PersistentVolumeClaims that can exist in the namespace.
The value represents the current observed total usage of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {persistentvolumeclaim} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_persistentvolumeclaimCount_used_int64`
- `create_observable_k8s_resourcequota_persistentvolumeclaimCount_used_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.storageclass.name | Conditionally required: The `k8s.storageclass.name` should be required when a resource quota is defined for a specific storage class.  |

This metric is retrieved from the `used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).

The `k8s.storageclass.name` should be required when a resource quota is defined for a specific
storage class.


## k8s.resourcequota.storage.request.hard

The storage requests in a specific namespace.
The value represents the configured quota limit of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_storage_request_hard_int64`
- `create_observable_k8s_resourcequota_storage_request_hard_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.storageclass.name | Conditionally required: The `k8s.storageclass.name` should be required when a resource quota is defined for a specific storage class.  |

This metric is retrieved from the `hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).

The `k8s.storageclass.name` should be required when a resource quota is defined for a specific
storage class.


## k8s.resourcequota.storage.request.used

The storage requests in a specific namespace.
The value represents the current observed total usage of the resource in the namespace.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_resourcequota_storage_request_used_int64`
- `create_observable_k8s_resourcequota_storage_request_used_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.storageclass.name | Conditionally required: The `k8s.storageclass.name` should be required when a resource quota is defined for a specific storage class.  |

This metric is retrieved from the `used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core).

The `k8s.storageclass.name` should be required when a resource quota is defined for a specific
storage class.


## k8s.service.endpoint.count

Number of endpoints for a service by condition and address type.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | {endpoint} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_service_endpoint_count_int64`
- `create_observable_k8s_service_endpoint_count_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.service.endpoint.address_type | required |
| k8s.service.endpoint.condition | required |
| k8s.service.endpoint.zone | recommended |

This metric is derived from the Kubernetes [EndpointSlice API](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/endpoint-slice-v1/).
It reports the number of network endpoints backing a Service, broken down by their condition and address type.

In dual-stack or multi-protocol clusters, separate counts are reported for each address family (`IPv4`, `IPv6`, `FQDN`).

When the optional `zone` attribute is enabled, counts are further broken down by availability zone for zone-aware monitoring.

An endpoint may be reported under multiple conditions simultaneously (e.g., both `serving` and `terminating` during a graceful shutdown).
See [K8s EndpointConditions](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/endpoint-slice-v1/) for more details.

The conditions represent:

- `ready`: Endpoints capable of receiving new connections.
- `serving`: Endpoints currently handling traffic.
- `terminating`: Endpoints that are being phased out but may still be handling existing connections.

For Services with `publishNotReadyAddresses` enabled (common for headless StatefulSets),
this metric will include endpoints that are published despite not being ready.
The `k8s.service.publish_not_ready_addresses` resource attribute indicates this setting.


## k8s.service.load_balancer.ingress.count

Number of load balancer ingress points (external IPs/hostnames) assigned to the service.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | {ingress} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_service_loadBalancer_ingress_count_int64`
- `create_observable_k8s_service_loadBalancer_ingress_count_int64`


This metric reports the number of external ingress points (IP addresses or hostnames)
assigned to a LoadBalancer Service.

It is only emitted for Services of type `LoadBalancer` and reflects the assignments
made by the underlying infrastructure's load balancer controller in the
[.status.loadBalancer.ingress](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/#ServiceStatus) field.

A value of `0` indicates that no ingress points have been assigned yet (e.g., during provisioning).
A value greater than `1` may occur when multiple IPs or hostnames are assigned (e.g., dual-stack configurations).

This metric signals that external endpoints have been assigned by the load balancer controller, but it does not
guarantee that the load balancer is healthy.


## k8s.statefulset.current_pods

Deprecated, use `k8s.statefulset.pod.current` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.statefulset.pod.current`.
Replacement: k8s.statefulset.pod.current.

Constructors:

- `create_k8s_statefulset_currentPods_int64`
- `create_observable_k8s_statefulset_currentPods_int64`


This metric aligns with the `currentReplicas` field of the
[K8s StatefulSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#statefulsetstatus-v1-apps).


## k8s.statefulset.desired_pods

Deprecated, use `k8s.statefulset.pod.desired` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.statefulset.pod.desired`.
Replacement: k8s.statefulset.pod.desired.

Constructors:

- `create_k8s_statefulset_desiredPods_int64`
- `create_observable_k8s_statefulset_desiredPods_int64`


This metric aligns with the `replicas` field of the
[K8s StatefulSetSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#statefulsetspec-v1-apps).


## k8s.statefulset.pod.available

Total number of available replica pods (ready for at least minReadySeconds) targeted by this statefulset.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_statefulset_pod_available_int64`
- `create_observable_k8s_statefulset_pod_available_int64`


This metric aligns with the `availableReplicas` field of the
[K8s StatefulSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#statefulsetstatus-v1-apps).


## k8s.statefulset.pod.current

The number of replica pods created by the statefulset controller from the statefulset version indicated by currentRevision.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_statefulset_pod_current_int64`
- `create_observable_k8s_statefulset_pod_current_int64`


This metric aligns with the `currentReplicas` field of the
[K8s StatefulSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#statefulsetstatus-v1-apps).


## k8s.statefulset.pod.desired

Number of desired replica pods in this statefulset.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_statefulset_pod_desired_int64`
- `create_observable_k8s_statefulset_pod_desired_int64`


This metric aligns with the `replicas` field of the
[K8s StatefulSetSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#statefulsetspec-v1-apps).


## k8s.statefulset.pod.ready

The number of replica pods created for this statefulset with a Ready Condition.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_statefulset_pod_ready_int64`
- `create_observable_k8s_statefulset_pod_ready_int64`


This metric aligns with the `readyReplicas` field of the
[K8s StatefulSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#statefulsetstatus-v1-apps).


## k8s.statefulset.pod.updated

Number of replica pods created by the statefulset controller from the statefulset version indicated by updateRevision.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_k8s_statefulset_pod_updated_int64`
- `create_observable_k8s_statefulset_pod_updated_int64`


This metric aligns with the `updatedReplicas` field of the
[K8s StatefulSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#statefulsetstatus-v1-apps).


## k8s.statefulset.ready_pods

Deprecated, use `k8s.statefulset.pod.ready` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.statefulset.pod.ready`.
Replacement: k8s.statefulset.pod.ready.

Constructors:

- `create_k8s_statefulset_readyPods_int64`
- `create_observable_k8s_statefulset_readyPods_int64`


This metric aligns with the `readyReplicas` field of the
[K8s StatefulSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#statefulsetstatus-v1-apps).


## k8s.statefulset.updated_pods

Deprecated, use `k8s.statefulset.pod.updated` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/k8s/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {pod} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `k8s.statefulset.pod.updated`.
Replacement: k8s.statefulset.pod.updated.

Constructors:

- `create_k8s_statefulset_updatedPods_int64`
- `create_observable_k8s_statefulset_updatedPods_int64`


This metric aligns with the `updatedReplicas` field of the
[K8s StatefulSetStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#statefulsetstatus-v1-apps).


## kestrel.active_connections

Number of connections that are currently active on the server.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/kestrel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_kestrel_activeConnections_int64`
- `create_observable_kestrel_activeConnections_int64`

| Attribute | Requirement |
| --- | --- |
| network.transport | recommended |
| network.type | Recommended: if the transport is `tcp` or `udp` |
| server.address | recommended |
| server.port | recommended |

Meter name: `Microsoft.AspNetCore.Server.Kestrel`; Added in: ASP.NET Core 8.0


## kestrel.active_tls_handshakes

Number of TLS handshakes that are currently in progress on the server.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/kestrel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {handshake} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_kestrel_activeTlsHandshakes_int64`
- `create_observable_kestrel_activeTlsHandshakes_int64`

| Attribute | Requirement |
| --- | --- |
| network.transport | recommended |
| network.type | Recommended: if the transport is `tcp` or `udp` |
| server.address | recommended |
| server.port | recommended |

Meter name: `Microsoft.AspNetCore.Server.Kestrel`; Added in: ASP.NET Core 8.0


## kestrel.connection.duration

The duration of connections on the server.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/kestrel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_kestrel_connection_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: if and only if an error has occurred. |
| network.protocol.name | recommended |
| network.protocol.version | recommended |
| network.transport | recommended |
| network.type | Recommended: if the transport is `tcp` or `udp` |
| server.address | recommended |
| server.port | recommended |
| tls.protocol.version | recommended |

Meter name: `Microsoft.AspNetCore.Server.Kestrel`; Added in: ASP.NET Core 8.0


## kestrel.queued_connections

Number of connections that are currently queued and are waiting to start.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/kestrel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_kestrel_queuedConnections_int64`
- `create_observable_kestrel_queuedConnections_int64`

| Attribute | Requirement |
| --- | --- |
| network.transport | recommended |
| network.type | Recommended: if the transport is `tcp` or `udp` |
| server.address | recommended |
| server.port | recommended |

Meter name: `Microsoft.AspNetCore.Server.Kestrel`; Added in: ASP.NET Core 8.0


## kestrel.queued_requests

Number of HTTP requests on multiplexed connections (HTTP/2 and HTTP/3) that are currently queued and are waiting to start.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/kestrel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {request} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_kestrel_queuedRequests_int64`
- `create_observable_kestrel_queuedRequests_int64`

| Attribute | Requirement |
| --- | --- |
| network.protocol.name | recommended |
| network.protocol.version | recommended |
| network.transport | recommended |
| network.type | Recommended: if the transport is `tcp` or `udp` |
| server.address | recommended |
| server.port | recommended |

Meter name: `Microsoft.AspNetCore.Server.Kestrel`; Added in: ASP.NET Core 8.0


## kestrel.rejected_connections

Number of connections rejected by the server.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/kestrel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_kestrel_rejectedConnections_int64`
- `create_observable_kestrel_rejectedConnections_int64`

| Attribute | Requirement |
| --- | --- |
| network.transport | recommended |
| network.type | Recommended: if the transport is `tcp` or `udp` |
| server.address | recommended |
| server.port | recommended |

Connections are rejected when the currently active count exceeds the value configured with `MaxConcurrentConnections`.
Meter name: `Microsoft.AspNetCore.Server.Kestrel`; Added in: ASP.NET Core 8.0


## kestrel.tls_handshake.duration

The duration of TLS handshakes on the server.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/kestrel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_kestrel_tlsHandshake_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: if and only if an error has occurred. |
| network.transport | recommended |
| network.type | Recommended: if the transport is `tcp` or `udp` |
| server.address | recommended |
| server.port | recommended |
| tls.protocol.version | recommended |

Meter name: `Microsoft.AspNetCore.Server.Kestrel`; Added in: ASP.NET Core 8.0


## kestrel.upgraded_connections

Number of connections that are currently upgraded (WebSockets). .

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/kestrel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_kestrel_upgradedConnections_int64`
- `create_observable_kestrel_upgradedConnections_int64`

| Attribute | Requirement |
| --- | --- |
| network.transport | recommended |
| network.type | Recommended: if the transport is `tcp` or `udp` |
| server.address | recommended |
| server.port | recommended |

The counter only tracks HTTP/1.1 connections.

Meter name: `Microsoft.AspNetCore.Server.Kestrel`; Added in: ASP.NET Core 8.0


## mcp.client.operation.duration

The duration of the MCP request or notification as observed on the sender from the time it was sent until the response or ack is received.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/mcp/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | unspecified |
| Stability | development |

**Deprecated:** Moved to the [OpenTelemetry GenAI semantic conventions repository](https://github.com/open-telemetry/semantic-conventions-genai).


Constructors:

- `create_mcp_client_operation_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the operation fails. |
| gen_ai.operation.name | Recommended: SHOULD be set to `execute_tool` when the operation describes a tool call and SHOULD NOT be set otherwise.  |
| gen_ai.prompt.name | Conditionally required: When operation is related to a specific prompt. |
| gen_ai.tool.name | Conditionally required: When operation is related to a specific tool. |
| jsonrpc.protocol.version | Recommended: when it's not `2.0`. |
| mcp.method.name | required |
| mcp.protocol.version | recommended |
| mcp.resource.uri | opt in |
| network.protocol.name | Recommended: When applicable. |
| network.protocol.version | Recommended: When applicable. |
| network.transport | recommended |
| rpc.response.status_code | Conditionally required: If response contains an error code. |
| server.address | Recommended: If applicable |
| server.port | Recommended: When `server.address` is set |


## mcp.client.session.duration

The duration of the MCP session as observed on the MCP client.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/mcp/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | unspecified |
| Stability | development |

**Deprecated:** Moved to the [OpenTelemetry GenAI semantic conventions repository](https://github.com/open-telemetry/semantic-conventions-genai).


Constructors:

- `create_mcp_client_session_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if session ends with an error. |
| jsonrpc.protocol.version | Recommended: when it's not `2.0`. |
| mcp.protocol.version | recommended |
| network.protocol.name | Recommended: When applicable. |
| network.protocol.version | Recommended: When applicable. |
| network.transport | recommended |
| server.address | Recommended: If applicable |
| server.port | Recommended: When `server.address` is set |


## mcp.server.operation.duration

MCP request or notification duration as observed on the receiver from the time it was received until the result or ack is sent.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/mcp/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | unspecified |
| Stability | development |

**Deprecated:** Moved to the [OpenTelemetry GenAI semantic conventions repository](https://github.com/open-telemetry/semantic-conventions-genai).


Constructors:

- `create_mcp_server_operation_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the operation fails. |
| gen_ai.operation.name | Recommended: SHOULD be set to `execute_tool` when the operation describes a tool call and SHOULD NOT be set otherwise.  |
| gen_ai.prompt.name | Conditionally required: When operation is related to a specific prompt. |
| gen_ai.tool.name | Conditionally required: When operation is related to a specific tool. |
| jsonrpc.protocol.version | Recommended: when it's not `2.0`. |
| mcp.method.name | required |
| mcp.protocol.version | recommended |
| mcp.resource.uri | opt in |
| network.protocol.name | Recommended: When applicable. |
| network.protocol.version | Recommended: When applicable. |
| network.transport | recommended |
| rpc.response.status_code | Conditionally required: If response contains an error code. |


## mcp.server.session.duration

The duration of the MCP session as observed on the MCP server.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/mcp/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | unspecified |
| Stability | development |

**Deprecated:** Moved to the [OpenTelemetry GenAI semantic conventions repository](https://github.com/open-telemetry/semantic-conventions-genai).


Constructors:

- `create_mcp_server_session_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if session ends with an error. |
| jsonrpc.protocol.version | Recommended: when it's not `2.0`. |
| mcp.protocol.version | recommended |
| network.protocol.name | Recommended: When applicable. |
| network.protocol.version | Recommended: When applicable. |
| network.transport | recommended |


## messaging.client.consumed.messages

Number of messages that were delivered to the application.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/messaging/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {message} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_messaging_client_consumed_messages_int64`
- `create_observable_messaging_client_consumed_messages_int64`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the messaging operation has failed. |
| messaging.consumer.group.name | Conditionally required: if applicable. |
| messaging.destination.name | Conditionally required: if and only if `messaging.destination.name` is known to have low cardinality. Otherwise, `messaging.destination.template` MAY be populated. |
| messaging.destination.partition.id | recommended |
| messaging.destination.subscription.name | Conditionally required: if applicable. |
| messaging.destination.template | Conditionally required: if available. |
| messaging.operation.name | required |
| messaging.system.name | required |
| server.address | Conditionally required: If available. |
| server.port | recommended |

Records the number of messages pulled from the broker or number of messages dispatched to the application in push-based scenarios.
The metric SHOULD be reported once per message delivery. For example, if receiving and processing operations are both instrumented for a single message delivery, this counter is incremented when the message is received and not reported when it is processed.


## messaging.client.operation.duration

Duration of messaging operation initiated by a producer or consumer client.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/messaging/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_messaging_client_operation_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the messaging operation has failed. |
| messaging.consumer.group.name | Conditionally required: if applicable. |
| messaging.destination.name | Conditionally required: if and only if `messaging.destination.name` is known to have low cardinality. Otherwise, `messaging.destination.template` MAY be populated. |
| messaging.destination.partition.id | recommended |
| messaging.destination.subscription.name | Conditionally required: if applicable. |
| messaging.destination.template | Conditionally required: if available. |
| messaging.operation.name | required |
| messaging.operation.type | Conditionally required: If applicable. |
| messaging.system.name | required |
| server.address | Conditionally required: If available. |
| server.port | recommended |

This metric SHOULD NOT be used to report processing duration - processing duration is reported in `messaging.process.duration` metric.


## messaging.client.published.messages

Deprecated. Use `messaging.client.sent.messages` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/messaging/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {message} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `messaging.client.sent.messages`.
Replacement: messaging.client.sent.messages.

Constructors:

- `create_messaging_client_published_messages_int64`
- `create_observable_messaging_client_published_messages_int64`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the messaging operation has failed. |
| messaging.destination.name | Conditionally required: if and only if `messaging.destination.name` is known to have low cardinality. Otherwise, `messaging.destination.template` MAY be populated. |
| messaging.destination.partition.id | recommended |
| messaging.destination.template | Conditionally required: if available. |
| messaging.operation.name | required |
| messaging.system.name | required |
| server.address | Conditionally required: If available. |
| server.port | recommended |


## messaging.client.sent.messages

Number of messages producer attempted to send to the broker.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/messaging/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {message} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_messaging_client_sent_messages_int64`
- `create_observable_messaging_client_sent_messages_int64`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the messaging operation has failed. |
| messaging.destination.name | Conditionally required: if and only if `messaging.destination.name` is known to have low cardinality. Otherwise, `messaging.destination.template` MAY be populated. |
| messaging.destination.partition.id | recommended |
| messaging.destination.template | Conditionally required: if available. |
| messaging.operation.name | required |
| messaging.system.name | required |
| server.address | Conditionally required: If available. |
| server.port | recommended |

This metric MUST NOT count messages that were created but haven't yet been sent.


## messaging.process.duration

Duration of processing operation.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/messaging/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_messaging_process_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the messaging operation has failed. |
| messaging.consumer.group.name | Conditionally required: if applicable. |
| messaging.destination.name | Conditionally required: if and only if `messaging.destination.name` is known to have low cardinality. Otherwise, `messaging.destination.template` MAY be populated. |
| messaging.destination.partition.id | recommended |
| messaging.destination.subscription.name | Conditionally required: if applicable. |
| messaging.destination.template | Conditionally required: if available. |
| messaging.operation.name | required |
| messaging.system.name | required |
| server.address | Conditionally required: If available. |
| server.port | recommended |

This metric MUST be reported for operations with `messaging.operation.type` that matches `process`.


## messaging.process.messages

Deprecated. Use `messaging.client.consumed.messages` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/messaging/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {message} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `messaging.client.consumed.messages`.
Replacement: messaging.client.consumed.messages.

Constructors:

- `create_messaging_process_messages_int64`
- `create_observable_messaging_process_messages_int64`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the messaging operation has failed. |
| messaging.operation.name | required |
| server.address | Conditionally required: If available. |
| server.port | recommended |


## messaging.publish.duration

Deprecated. Use `messaging.client.operation.duration` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/messaging/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Replaced by `messaging.client.operation.duration`.
Replacement: messaging.client.operation.duration.

Constructors:

- `create_messaging_publish_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the messaging operation has failed. |
| messaging.operation.name | required |
| server.address | Conditionally required: If available. |
| server.port | recommended |


## messaging.publish.messages

Deprecated. Use `messaging.client.sent.messages` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/messaging/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {message} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `messaging.client.sent.messages`.
Replacement: messaging.client.sent.messages.

Constructors:

- `create_messaging_publish_messages_int64`
- `create_observable_messaging_publish_messages_int64`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the messaging operation has failed. |
| messaging.operation.name | required |
| server.address | Conditionally required: If available. |
| server.port | recommended |


## messaging.receive.duration

Deprecated. Use `messaging.client.operation.duration` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/messaging/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Replaced by `messaging.client.operation.duration`.
Replacement: messaging.client.operation.duration.

Constructors:

- `create_messaging_receive_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the messaging operation has failed. |
| messaging.operation.name | required |
| server.address | Conditionally required: If available. |
| server.port | recommended |


## messaging.receive.messages

Deprecated. Use `messaging.client.consumed.messages` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/messaging/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {message} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `messaging.client.consumed.messages`.
Replacement: messaging.client.consumed.messages.

Constructors:

- `create_messaging_receive_messages_int64`
- `create_observable_messaging_receive_messages_int64`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the messaging operation has failed. |
| messaging.operation.name | required |
| server.address | Conditionally required: If available. |
| server.port | recommended |


## nfs.client.net.count

Reports the count of kernel NFS client TCP segments and UDP datagrams handled.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {record} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_client_net_count_int64`
- `create_observable_nfs_client_net_count_int64`
- `create_nfs_client_net_count_double`
- `create_observable_nfs_client_net_count_double`

| Attribute | Requirement |
| --- | --- |
| network.transport | recommended |

Linux: this metric is taken from the Linux kernel's svc_stat.netudpcnt and svc_stat.nettcpcnt


## nfs.client.net.tcp.connection.accepted

Reports the count of kernel NFS client TCP connections accepted.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {connection} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_client_net_tcp_connection_accepted_int64`
- `create_observable_nfs_client_net_tcp_connection_accepted_int64`
- `create_nfs_client_net_tcp_connection_accepted_double`
- `create_observable_nfs_client_net_tcp_connection_accepted_double`


Linux: this metric is taken from the Linux kernel's svc_stat.nettcpconn


## nfs.client.operation.count

Reports the count of kernel NFSv4+ client operations.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {operation} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_client_operation_count_int64`
- `create_observable_nfs_client_operation_count_int64`
- `create_nfs_client_operation_count_double`
- `create_observable_nfs_client_operation_count_double`

| Attribute | Requirement |
| --- | --- |
| nfs.operation.name | recommended |
| onc_rpc.version | recommended |


## nfs.client.procedure.count

Reports the count of kernel NFS client procedures.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {procedure} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_client_procedure_count_int64`
- `create_observable_nfs_client_procedure_count_int64`
- `create_nfs_client_procedure_count_double`
- `create_observable_nfs_client_procedure_count_double`

| Attribute | Requirement |
| --- | --- |
| onc_rpc.procedure.name | recommended |
| onc_rpc.version | recommended |


## nfs.client.rpc.authrefresh.count

Reports the count of kernel NFS client RPC authentication refreshes.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {authrefresh} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_client_rpc_authrefresh_count_int64`
- `create_observable_nfs_client_rpc_authrefresh_count_int64`
- `create_nfs_client_rpc_authrefresh_count_double`
- `create_observable_nfs_client_rpc_authrefresh_count_double`


Linux: this metric is taken from the Linux kernel's svc_stat.rpcauthrefresh


## nfs.client.rpc.count

Reports the count of kernel NFS client RPCs sent, regardless of whether they're accepted/rejected by the server.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {request} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_client_rpc_count_int64`
- `create_observable_nfs_client_rpc_count_int64`
- `create_nfs_client_rpc_count_double`
- `create_observable_nfs_client_rpc_count_double`


Linux: this metric is taken from the Linux kernel's svc_stat.rpccnt


## nfs.client.rpc.retransmit.count

Reports the count of kernel NFS client RPC retransmits.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {retransmit} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_client_rpc_retransmit_count_int64`
- `create_observable_nfs_client_rpc_retransmit_count_int64`
- `create_nfs_client_rpc_retransmit_count_double`
- `create_observable_nfs_client_rpc_retransmit_count_double`


Linux: this metric is taken from the Linux kernel's svc_stat.rpcretrans


## nfs.server.fh.stale.count

Reports the count of kernel NFS server stale file handles.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {fh} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_server_fh_stale_count_int64`
- `create_observable_nfs_server_fh_stale_count_int64`
- `create_nfs_server_fh_stale_count_double`
- `create_observable_nfs_server_fh_stale_count_double`


Linux: this metric is taken from the Linux kernel NFSD_STATS_FH_STALE counter in the nfsd_net struct


## nfs.server.io

Reports the count of kernel NFS server bytes returned to receive and transmit (read and write) requests.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_server_io_int64`
- `create_observable_nfs_server_io_int64`
- `create_nfs_server_io_double`
- `create_observable_nfs_server_io_double`

| Attribute | Requirement |
| --- | --- |
| network.io.direction | recommended |

Linux: this metric is taken from the Linux kernel NFSD_STATS_IO_READ and NFSD_STATS_IO_WRITE counters in the nfsd_net struct


## nfs.server.net.count

Reports the count of kernel NFS server TCP segments and UDP datagrams handled.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {record} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_server_net_count_int64`
- `create_observable_nfs_server_net_count_int64`
- `create_nfs_server_net_count_double`
- `create_observable_nfs_server_net_count_double`

| Attribute | Requirement |
| --- | --- |
| network.transport | recommended |

Linux: this metric is taken from the Linux kernel's svc_stat.nettcpcnt and svc_stat.netudpcnt


## nfs.server.net.tcp.connection.accepted

Reports the count of kernel NFS server TCP connections accepted.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {connection} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_server_net_tcp_connection_accepted_int64`
- `create_observable_nfs_server_net_tcp_connection_accepted_int64`
- `create_nfs_server_net_tcp_connection_accepted_double`
- `create_observable_nfs_server_net_tcp_connection_accepted_double`


Linux: this metric is taken from the Linux kernel's svc_stat.nettcpconn


## nfs.server.operation.count

Reports the count of kernel NFSv4+ server operations.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {operation} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_server_operation_count_int64`
- `create_observable_nfs_server_operation_count_int64`
- `create_nfs_server_operation_count_double`
- `create_observable_nfs_server_operation_count_double`

| Attribute | Requirement |
| --- | --- |
| nfs.operation.name | recommended |
| onc_rpc.version | recommended |


## nfs.server.procedure.count

Reports the count of kernel NFS server procedures.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {procedure} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_server_procedure_count_int64`
- `create_observable_nfs_server_procedure_count_int64`
- `create_nfs_server_procedure_count_double`
- `create_observable_nfs_server_procedure_count_double`

| Attribute | Requirement |
| --- | --- |
| onc_rpc.procedure.name | recommended |
| onc_rpc.version | recommended |


## nfs.server.repcache.requests

Reports the kernel NFS server reply cache request count by cache hit status.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {request} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_server_repcache_requests_int64`
- `create_observable_nfs_server_repcache_requests_int64`
- `create_nfs_server_repcache_requests_double`
- `create_observable_nfs_server_repcache_requests_double`

| Attribute | Requirement |
| --- | --- |
| nfs.server.repcache.status | recommended |


## nfs.server.rpc.count

Reports the count of kernel NFS server RPCs handled.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {request} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_server_rpc_count_int64`
- `create_observable_nfs_server_rpc_count_int64`
- `create_nfs_server_rpc_count_double`
- `create_observable_nfs_server_rpc_count_double`

| Attribute | Requirement |
| --- | --- |
| error.type | recommended |

Linux: this metric is taken from the Linux kernel's svc_stat.rpccnt, the count of good RPCs. This metric can have
an error.type of "format", "auth", or "client" for svc_stat.badfmt, svc_stat.badauth, and svc_stat.badclnt.


## nfs.server.thread.count

Reports the count of kernel NFS server available threads.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nfs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {thread} |
| Numeric annotation | unspecified |
| Stability | development |


Constructors:

- `create_nfs_server_thread_count_int64`
- `create_observable_nfs_server_thread_count_int64`
- `create_nfs_server_thread_count_double`
- `create_observable_nfs_server_thread_count_double`


Linux: this metric is taken from the Linux kernel nfsd_th_cnt variable


## nodejs.eventloop.delay.max

Event loop maximum delay.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nodejs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_nodejs_eventloop_delay_max_double`
- `create_observable_nodejs_eventloop_delay_max_double`


Value can be retrieved from value `histogram.max` of [`perf_hooks.monitorEventLoopDelay([options])`](https://nodejs.org/api/perf_hooks.html#perf_hooksmonitoreventloopdelayoptions)


## nodejs.eventloop.delay.mean

Event loop mean delay.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nodejs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_nodejs_eventloop_delay_mean_double`
- `create_observable_nodejs_eventloop_delay_mean_double`


Value can be retrieved from value `histogram.mean` of [`perf_hooks.monitorEventLoopDelay([options])`](https://nodejs.org/api/perf_hooks.html#perf_hooksmonitoreventloopdelayoptions)


## nodejs.eventloop.delay.min

Event loop minimum delay.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nodejs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_nodejs_eventloop_delay_min_double`
- `create_observable_nodejs_eventloop_delay_min_double`


Value can be retrieved from value `histogram.min` of [`perf_hooks.monitorEventLoopDelay([options])`](https://nodejs.org/api/perf_hooks.html#perf_hooksmonitoreventloopdelayoptions)


## nodejs.eventloop.delay.p50

Event loop 50 percentile delay.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nodejs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_nodejs_eventloop_delay_p50_double`
- `create_observable_nodejs_eventloop_delay_p50_double`


Value can be retrieved from value `histogram.percentile(50)` of [`perf_hooks.monitorEventLoopDelay([options])`](https://nodejs.org/api/perf_hooks.html#perf_hooksmonitoreventloopdelayoptions)


## nodejs.eventloop.delay.p90

Event loop 90 percentile delay.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nodejs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_nodejs_eventloop_delay_p90_double`
- `create_observable_nodejs_eventloop_delay_p90_double`


Value can be retrieved from value `histogram.percentile(90)` of [`perf_hooks.monitorEventLoopDelay([options])`](https://nodejs.org/api/perf_hooks.html#perf_hooksmonitoreventloopdelayoptions)


## nodejs.eventloop.delay.p99

Event loop 99 percentile delay.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nodejs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_nodejs_eventloop_delay_p99_double`
- `create_observable_nodejs_eventloop_delay_p99_double`


Value can be retrieved from value `histogram.percentile(99)` of [`perf_hooks.monitorEventLoopDelay([options])`](https://nodejs.org/api/perf_hooks.html#perf_hooksmonitoreventloopdelayoptions)


## nodejs.eventloop.delay.stddev

Event loop standard deviation delay.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nodejs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_nodejs_eventloop_delay_stddev_double`
- `create_observable_nodejs_eventloop_delay_stddev_double`


Value can be retrieved from value `histogram.stddev` of [`perf_hooks.monitorEventLoopDelay([options])`](https://nodejs.org/api/perf_hooks.html#perf_hooksmonitoreventloopdelayoptions)


## nodejs.eventloop.time

Cumulative duration of time the event loop has been in each state.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nodejs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_nodejs_eventloop_time_double`
- `create_observable_nodejs_eventloop_time_double`

| Attribute | Requirement |
| --- | --- |
| nodejs.eventloop.state | required |

Value can be retrieved from [`performance.eventLoopUtilization([utilization1[, utilization2]])`](https://nodejs.org/api/perf_hooks.html#performanceeventlooputilizationutilization1-utilization2)


## nodejs.eventloop.utilization

Event loop utilization.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/nodejs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_nodejs_eventloop_utilization_double`
- `create_observable_nodejs_eventloop_utilization_double`


The value range is [0.0, 1.0] and can be retrieved from [`performance.eventLoopUtilization([utilization1[, utilization2]])`](https://nodejs.org/api/perf_hooks.html#performanceeventlooputilizationutilization1-utilization2)


## openshift.clusterquota.cpu.limit.hard

The enforced hard limit of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_cpu_limit_hard_double`
- `create_observable_openshift_clusterquota_cpu_limit_hard_double`


This metric is retrieved from the `Status.Total.Hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.cpu.limit.used

The current observed total usage of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_cpu_limit_used_double`
- `create_observable_openshift_clusterquota_cpu_limit_used_double`


This metric is retrieved from the `Status.Total.Used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.cpu.request.hard

The enforced hard limit of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_cpu_request_hard_double`
- `create_observable_openshift_clusterquota_cpu_request_hard_double`


This metric is retrieved from the `Status.Total.Hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.cpu.request.used

The current observed total usage of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_cpu_request_used_double`
- `create_observable_openshift_clusterquota_cpu_request_used_double`


This metric is retrieved from the `Status.Total.Used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.ephemeral_storage.limit.hard

The enforced hard limit of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_ephemeralStorage_limit_hard_int64`
- `create_observable_openshift_clusterquota_ephemeralStorage_limit_hard_int64`


This metric is retrieved from the `Status.Total.Hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.ephemeral_storage.limit.used

The current observed total usage of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_ephemeralStorage_limit_used_int64`
- `create_observable_openshift_clusterquota_ephemeralStorage_limit_used_int64`


This metric is retrieved from the `Status.Total.Used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.ephemeral_storage.request.hard

The enforced hard limit of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_ephemeralStorage_request_hard_int64`
- `create_observable_openshift_clusterquota_ephemeralStorage_request_hard_int64`


This metric is retrieved from the `Status.Total.Hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.ephemeral_storage.request.used

The current observed total usage of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_ephemeralStorage_request_used_int64`
- `create_observable_openshift_clusterquota_ephemeralStorage_request_used_int64`


This metric is retrieved from the `Status.Total.Used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.hugepage_count.request.hard

The enforced hard limit of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {hugepage} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_hugepageCount_request_hard_int64`
- `create_observable_openshift_clusterquota_hugepageCount_request_hard_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.hugepage.size | required |

This metric is retrieved from the `Status.Total.Hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.hugepage_count.request.used

The current observed total usage of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {hugepage} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_hugepageCount_request_used_int64`
- `create_observable_openshift_clusterquota_hugepageCount_request_used_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.hugepage.size | required |

This metric is retrieved from the `Status.Total.Used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.memory.limit.hard

The enforced hard limit of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_memory_limit_hard_int64`
- `create_observable_openshift_clusterquota_memory_limit_hard_int64`


This metric is retrieved from the `Status.Total.Hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.memory.limit.used

The current observed total usage of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_memory_limit_used_int64`
- `create_observable_openshift_clusterquota_memory_limit_used_int64`


This metric is retrieved from the `Status.Total.Used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.memory.request.hard

The enforced hard limit of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_memory_request_hard_int64`
- `create_observable_openshift_clusterquota_memory_request_hard_int64`


This metric is retrieved from the `Status.Total.Hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.memory.request.used

The current observed total usage of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_memory_request_used_int64`
- `create_observable_openshift_clusterquota_memory_request_used_int64`


This metric is retrieved from the `Status.Total.Used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.object_count.hard

The enforced hard limit of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {object} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_objectCount_hard_int64`
- `create_observable_openshift_clusterquota_objectCount_hard_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.resourcequota.resource_name | required |

This metric is retrieved from the `Status.Total.Hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.object_count.used

The current observed total usage of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {object} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_objectCount_used_int64`
- `create_observable_openshift_clusterquota_objectCount_used_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.resourcequota.resource_name | required |

This metric is retrieved from the `Status.Total.Used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).


## openshift.clusterquota.persistentvolumeclaim_count.hard

The enforced hard limit of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {persistentvolumeclaim} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_persistentvolumeclaimCount_hard_int64`
- `create_observable_openshift_clusterquota_persistentvolumeclaimCount_hard_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.storageclass.name | Conditionally required: The `k8s.storageclass.name` should be required when a resource quota is defined for a specific storage class.  |

This metric is retrieved from the `Status.Total.Hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).

The `k8s.storageclass.name` should be required when a resource quota is defined for a specific
storage class.


## openshift.clusterquota.persistentvolumeclaim_count.used

The current observed total usage of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {persistentvolumeclaim} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_persistentvolumeclaimCount_used_int64`
- `create_observable_openshift_clusterquota_persistentvolumeclaimCount_used_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.storageclass.name | Conditionally required: The `k8s.storageclass.name` should be required when a resource quota is defined for a specific storage class.  |

This metric is retrieved from the `Status.Total.Used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).

The `k8s.storageclass.name` should be required when a resource quota is defined for a specific
storage class.


## openshift.clusterquota.storage.request.hard

The enforced hard limit of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_storage_request_hard_int64`
- `create_observable_openshift_clusterquota_storage_request_hard_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.storageclass.name | Conditionally required: The `k8s.storageclass.name` should be required when a resource quota is defined for a specific storage class.  |

This metric is retrieved from the `Status.Total.Hard` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).

The `k8s.storageclass.name` should be required when a resource quota is defined for a specific
storage class.


## openshift.clusterquota.storage.request.used

The current observed total usage of the resource across all projects.


[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/openshift/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_openshift_clusterquota_storage_request_used_int64`
- `create_observable_openshift_clusterquota_storage_request_used_int64`

| Attribute | Requirement |
| --- | --- |
| k8s.storageclass.name | Conditionally required: The `k8s.storageclass.name` should be required when a resource quota is defined for a specific storage class.  |

This metric is retrieved from the `Status.Total.Used` field of the
[K8s ResourceQuotaStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/#resourcequotastatus-v1-core)
of the
[ClusterResourceQuota](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/schedule_and_quota_apis/clusterresourcequota-quota-openshift-io-v1#status-total).

The `k8s.storageclass.name` should be required when a resource quota is defined for a specific
storage class.


## otel.sdk.exporter.log.exported

The number of log records for which the export has finished, either successful or failed.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {log_record} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_otel_sdk_exporter_log_exported_int64`
- `create_observable_otel_sdk_exporter_log_exported_int64`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: if and only if an error has occurred. |
| otel.component.name | recommended |
| otel.component.type | recommended |
| server.address | Recommended: when applicable |
| server.port | Recommended: when applicable |

For successful exports, `error.type` MUST NOT be set. For failed exports, `error.type` MUST contain the failure cause.
For exporters with partial success semantics (e.g. OTLP with `rejected_log_records`), rejected log records MUST count as failed and only non-rejected log records count as success.
If no rejection reason is available, `rejected` SHOULD be used as value for `error.type`.
If the exporter retries failed export attempts, the export operation is considered finished only after the final attempt has concluded.
Each log record MUST be counted exactly once per export operation: intermediate failed attempts that are followed by a retry MUST NOT increment the counter,
and `error.type` reflects the cause of the final attempt.


## otel.sdk.exporter.log.inflight

The number of log records which were passed to the exporter, but that have not been exported yet (neither successful, nor failed).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {log_record} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_otel_sdk_exporter_log_inflight_int64`
- `create_observable_otel_sdk_exporter_log_inflight_int64`

| Attribute | Requirement |
| --- | --- |
| otel.component.name | recommended |
| otel.component.type | recommended |
| server.address | Recommended: when applicable |
| server.port | Recommended: when applicable |

Log records are counted as inflight from when they are passed to the exporter until the export operation has concluded.
If the exporter retries failed export attempts, log records remain inflight across all retry attempts and any backoff between them.


## otel.sdk.exporter.metric_data_point.exported

The number of metric data points for which the export has finished, either successful or failed.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {data_point} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_otel_sdk_exporter_metricDataPoint_exported_int64`
- `create_observable_otel_sdk_exporter_metricDataPoint_exported_int64`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: if and only if an error has occurred. |
| otel.component.name | recommended |
| otel.component.type | recommended |
| server.address | Recommended: when applicable |
| server.port | Recommended: when applicable |

For successful exports, `error.type` MUST NOT be set. For failed exports, `error.type` MUST contain the failure cause.
For exporters with partial success semantics (e.g. OTLP with `rejected_data_points`), rejected data points MUST count as failed and only non-rejected data points count as success.
If no rejection reason is available, `rejected` SHOULD be used as value for `error.type`.
If the exporter retries failed export attempts, the export operation is considered finished only after the final attempt has concluded.
Each metric data point MUST be counted exactly once per export operation: intermediate failed attempts that are followed by a retry MUST NOT increment the counter,
and `error.type` reflects the cause of the final attempt.


## otel.sdk.exporter.metric_data_point.inflight

The number of metric data points which were passed to the exporter, but that have not been exported yet (neither successful, nor failed).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {data_point} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_otel_sdk_exporter_metricDataPoint_inflight_int64`
- `create_observable_otel_sdk_exporter_metricDataPoint_inflight_int64`

| Attribute | Requirement |
| --- | --- |
| otel.component.name | recommended |
| otel.component.type | recommended |
| server.address | Recommended: when applicable |
| server.port | Recommended: when applicable |

Metric data points are counted as inflight from when they are passed to the exporter until the export operation has concluded.
If the exporter retries failed export attempts, metric data points remain inflight across all retry attempts and any backoff between them.


## otel.sdk.exporter.operation.duration

The duration of exporting a batch of telemetry records.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_otel_sdk_exporter_operation_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If operation has ended with an error |
| http.response.status_code | Recommended: when applicable |
| otel.component.name | recommended |
| otel.component.type | recommended |
| rpc.status_code | Recommended: when applicable |
| server.address | Recommended: when applicable |
| server.port | Recommended: when applicable |

This metric defines successful operations using the full success definitions for [HTTP](https://github.com/open-telemetry/opentelemetry-proto/blob/v1.5.0/docs/specification.md#full-success-1)
and [gRPC](https://github.com/open-telemetry/opentelemetry-proto/blob/v1.5.0/docs/specification.md#full-success). Anything else is defined as an unsuccessful operation. For successful
operations, `error.type` MUST NOT be set. For unsuccessful export operations, `error.type` MUST contain a relevant failure cause.
If the exporter retries failed export attempts, exactly one observation MUST be recorded per export operation,
covering the wall-clock duration from the start of the first attempt through the conclusion of the final attempt (including any backoff between attempts).
`error.type` reflects the cause of the final attempt.


## otel.sdk.exporter.span.exported

The number of spans for which the export has finished, either successful or failed.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {span} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_otel_sdk_exporter_span_exported_int64`
- `create_observable_otel_sdk_exporter_span_exported_int64`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: if and only if an error has occurred. |
| otel.component.name | recommended |
| otel.component.type | recommended |
| server.address | Recommended: when applicable |
| server.port | Recommended: when applicable |

For successful exports, `error.type` MUST NOT be set. For failed exports, `error.type` MUST contain the failure cause.
For exporters with partial success semantics (e.g. OTLP with `rejected_spans`), rejected spans MUST count as failed and only non-rejected spans count as success.
If no rejection reason is available, `rejected` SHOULD be used as value for `error.type`.
If the exporter retries failed export attempts, the export operation is considered finished only after the final attempt has concluded.
Each span MUST be counted exactly once per export operation: intermediate failed attempts that are followed by a retry MUST NOT increment the counter,
and `error.type` reflects the cause of the final attempt.


## otel.sdk.exporter.span.exported.count

Deprecated, use `otel.sdk.exporter.span.exported` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {span} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `otel.sdk.exporter.span.exported`.
Replacement: otel.sdk.exporter.span.exported.

Constructors:

- `create_otel_sdk_exporter_span_exported_count_int64`
- `create_observable_otel_sdk_exporter_span_exported_count_int64`



## otel.sdk.exporter.span.inflight

The number of spans which were passed to the exporter, but that have not been exported yet (neither successful, nor failed).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {span} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_otel_sdk_exporter_span_inflight_int64`
- `create_observable_otel_sdk_exporter_span_inflight_int64`

| Attribute | Requirement |
| --- | --- |
| otel.component.name | recommended |
| otel.component.type | recommended |
| server.address | Recommended: when applicable |
| server.port | Recommended: when applicable |

Spans are counted as inflight from when they are passed to the exporter until the export operation has concluded.
If the exporter retries failed export attempts, spans remain inflight across all retry attempts and any backoff between them.


## otel.sdk.exporter.span.inflight.count

Deprecated, use `otel.sdk.exporter.span.inflight` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {span} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `otel.sdk.exporter.span.inflight`.
Replacement: otel.sdk.exporter.span.inflight.

Constructors:

- `create_otel_sdk_exporter_span_inflight_count_int64`
- `create_observable_otel_sdk_exporter_span_inflight_count_int64`



## otel.sdk.log.created

The number of log records submitted to an enabled `Logger`.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {log_record} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_otel_sdk_log_created_int64`
- `create_observable_otel_sdk_log_created_int64`


In OpenTelemetry SDKs a `Logger` is enabled by default, and can be disabled via configuration i.e. `LoggerConfig.enabled` = `false` when supported;
a disabled `Logger` is a No-op: emitting to it has no effect, so its records are not counted.
Every log record submitted to an enabled `Logger` is counted, even if it is later filtered or dropped within the SDK
(e.g. by minimum severity or trace-based rules, or by a processor or the export pipeline), making this metric the top of the log delivery funnel.
Records not submitted to the SDK are not counted (e.g. a caller that skips calling `Emit()` based on an `Enabled()` check, or an upstream logging library that filters first).


## otel.sdk.metric_reader.collection.duration

The duration of the collect operation of the metric reader.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_otel_sdk_metricReader_collection_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | recommended |
| otel.component.name | recommended |
| otel.component.type | recommended |

For successful collections, `error.type` MUST NOT be set. For failed collections, `error.type` SHOULD contain the failure cause.
It can happen that metrics collection is successful for some MetricProducers, while others fail. In that case `error.type` SHOULD be set to any of the failure causes.


## otel.sdk.processor.log.processed

The number of log records for which the processing has finished, either successful or failed.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {log_record} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_otel_sdk_processor_log_processed_int64`
- `create_observable_otel_sdk_processor_log_processed_int64`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: if and only if an error has occurred. |
| otel.component.name | recommended |
| otel.component.type | recommended |

For successful processing, `error.type` MUST NOT be set. For failed processing, `error.type` MUST contain the failure cause.
SDK Batching Log Record Processors MUST use `queue_full` as the value of `error.type` for log records dropped due to a full queue.
If a processor reports a log record dropped because it has already been shut down, `error.type` MUST be `already_shutdown`.
Whether and when a processor drops such log records is governed by the SDK specification, not by this metric.
For the SDK Simple and Batching Log Record Processors, a log record MUST be counted as successfully processed at the point the
processor invokes the export operation. For batching processors, all log records in the batch passed to the exporter are counted
at that point; log records accepted into the processor's queue but not yet passed to the exporter have not been processed.
Implementations MUST NOT delay this count until the export operation concludes, and the outcome of the export operation,
including an immediate failure of the invocation itself, MUST NOT affect this metric.
Export outcomes are reported by `otel.sdk.exporter.log.exported`.


## otel.sdk.processor.log.queue.capacity

The maximum number of log records the queue of a given instance of an SDK Log Record processor can hold.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {log_record} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_otel_sdk_processor_log_queue_capacity_int64`
- `create_observable_otel_sdk_processor_log_queue_capacity_int64`

| Attribute | Requirement |
| --- | --- |
| otel.component.name | recommended |
| otel.component.type | recommended |

Only applies to Log Record processors which use a queue, e.g. the SDK Batching Log Record Processor.


## otel.sdk.processor.log.queue.size

The number of log records in the queue of a given instance of an SDK log processor.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {log_record} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_otel_sdk_processor_log_queue_size_int64`
- `create_observable_otel_sdk_processor_log_queue_size_int64`

| Attribute | Requirement |
| --- | --- |
| otel.component.name | recommended |
| otel.component.type | recommended |

Only applies to log record processors which use a queue, e.g. the SDK Batching Log Record Processor.


## otel.sdk.processor.span.processed

The number of spans for which the processing has finished, either successful or failed.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {span} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_otel_sdk_processor_span_processed_int64`
- `create_observable_otel_sdk_processor_span_processed_int64`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: if and only if an error has occurred. |
| otel.component.name | recommended |
| otel.component.type | recommended |

For successful processing, `error.type` MUST NOT be set. For failed processing, `error.type` MUST contain the failure cause.
SDK Batching Span Processors MUST use `queue_full` as the value of `error.type` for spans dropped due to a full queue.
If a processor reports a span dropped because it has already been shut down, `error.type` MUST be `already_shutdown`.
Whether and when a processor drops such spans is governed by the SDK specification, not by this metric.
For the SDK Simple and Batching Span Processors, a span MUST be counted as successfully processed at the point the processor
invokes the export operation. For batching processors, all spans in the batch passed to the exporter are counted at that point;
spans accepted into the processor's queue but not yet passed to the exporter have not been processed.
Implementations MUST NOT delay this count until the export operation concludes, and the outcome of the export operation,
including an immediate failure of the invocation itself, MUST NOT affect this metric.
Export outcomes are reported by `otel.sdk.exporter.span.exported`.


## otel.sdk.processor.span.processed.count

Deprecated, use `otel.sdk.processor.span.processed` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {span} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `otel.sdk.processor.span.processed`.
Replacement: otel.sdk.processor.span.processed.

Constructors:

- `create_otel_sdk_processor_span_processed_count_int64`
- `create_observable_otel_sdk_processor_span_processed_count_int64`



## otel.sdk.processor.span.queue.capacity

The maximum number of spans the queue of a given instance of an SDK span processor can hold.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {span} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_otel_sdk_processor_span_queue_capacity_int64`
- `create_observable_otel_sdk_processor_span_queue_capacity_int64`

| Attribute | Requirement |
| --- | --- |
| otel.component.name | recommended |
| otel.component.type | recommended |

Only applies to span processors which use a queue, e.g. the SDK Batching Span Processor.


## otel.sdk.processor.span.queue.size

The number of spans in the queue of a given instance of an SDK span processor.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {span} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_otel_sdk_processor_span_queue_size_int64`
- `create_observable_otel_sdk_processor_span_queue_size_int64`

| Attribute | Requirement |
| --- | --- |
| otel.component.name | recommended |
| otel.component.type | recommended |

Only applies to span processors which use a queue, e.g. the SDK Batching Span Processor.


## otel.sdk.span.ended

Use `otel.sdk.span.started` minus `otel.sdk.span.live` to derive this value.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {span} |
| Numeric annotation | unspecified |
| Stability | development |

**Deprecated:** Obsoleted.

Constructors:

- `create_otel_sdk_span_ended_int64`
- `create_observable_otel_sdk_span_ended_int64`
- `create_otel_sdk_span_ended_double`
- `create_observable_otel_sdk_span_ended_double`



## otel.sdk.span.ended.count

Use `otel.sdk.span.started` minus `otel.sdk.span.live` to derive this value.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {span} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Obsoleted.

Constructors:

- `create_otel_sdk_span_ended_count_int64`
- `create_observable_otel_sdk_span_ended_count_int64`



## otel.sdk.span.live

The number of created spans with `recording=true` for which the end operation has not been called yet.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {span} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_otel_sdk_span_live_int64`
- `create_observable_otel_sdk_span_live_int64`

| Attribute | Requirement |
| --- | --- |
| otel.span.sampling_result | recommended |

Non-recording spans are not counted, hence `otel.span.sampling_result` can only take values `RECORD_ONLY` and `RECORD_AND_SAMPLE`, not `DROP`.


## otel.sdk.span.live.count

Deprecated, use `otel.sdk.span.live` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {span} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `otel.sdk.span.live`.
Replacement: otel.sdk.span.live.

Constructors:

- `create_otel_sdk_span_live_count_int64`
- `create_observable_otel_sdk_span_live_count_int64`



## otel.sdk.span.started

The number of created spans.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/otel/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {span} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_otel_sdk_span_started_int64`
- `create_observable_otel_sdk_span_started_int64`

| Attribute | Requirement |
| --- | --- |
| otel.span.parent.origin | recommended |
| otel.span.sampling_result | recommended |

Implementations MUST record this metric for all spans, even for non-recording ones.


## process.context_switches

Number of times the process has been context switched.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {context_switch} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_process_contextSwitches_int64`
- `create_observable_process_contextSwitches_int64`

| Attribute | Requirement |
| --- | --- |
| process.context_switch.type | required |


## process.cpu.time

Total CPU seconds broken down by different CPU modes.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | s |
| Numeric annotation | double |
| Stability | release candidate |


Constructors:

- `create_process_cpu_time_double`
- `create_observable_process_cpu_time_double`

| Attribute | Requirement |
| --- | --- |
| cpu.mode | required |


## process.cpu.utilization

Difference in process.cpu.time since the last measurement, divided by the elapsed time and number of CPUs available to the process.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | release candidate |


Constructors:

- `create_process_cpu_utilization_double`
- `create_observable_process_cpu_utilization_double`

| Attribute | Requirement |
| --- | --- |
| cpu.mode | required |


## process.disk.io

Disk bytes transferred.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_process_disk_io_int64`
- `create_observable_process_disk_io_int64`

| Attribute | Requirement |
| --- | --- |
| disk.io.direction | required |


## process.disk.operations

Number of disk operations performed by the process.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {operation} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_process_disk_operations_int64`
- `create_observable_process_disk_operations_int64`

| Attribute | Requirement |
| --- | --- |
| disk.io.direction | required |


## process.memory.usage

The amount of physical memory in use.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_process_memory_usage_int64`
- `create_observable_process_memory_usage_int64`



## process.memory.utilization

Percentage of total physical memory that is used by the process.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_process_memory_utilization_double`
- `create_observable_process_memory_utilization_double`



## process.memory.virtual

The amount of committed virtual memory.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_process_memory_virtual_int64`
- `create_observable_process_memory_virtual_int64`



## process.network.io

Network bytes transferred.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_process_network_io_int64`
- `create_observable_process_network_io_int64`

| Attribute | Requirement |
| --- | --- |
| network.io.direction | required |


## process.open_file_descriptor.count

Deprecated, use `process.unix.file_descriptor.count` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {file_descriptor} |
| Numeric annotation | unspecified |
| Stability | development |

**Deprecated:** Replaced by `process.unix.file_descriptor.count`.
Replacement: process.unix.file_descriptor.count.

Constructors:

- `create_process_openFileDescriptor_count_int64`
- `create_observable_process_openFileDescriptor_count_int64`
- `create_process_openFileDescriptor_count_double`
- `create_observable_process_openFileDescriptor_count_double`



## process.paging.faults

Number of page faults the process has made.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {fault} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_process_paging_faults_int64`
- `create_observable_process_paging_faults_int64`

| Attribute | Requirement |
| --- | --- |
| system.paging.fault.type | recommended |


## process.signals_pending

Number of pending signals for the process.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {signal} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_process_signalsPending_int64`
- `create_observable_process_signalsPending_int64`



## process.thread.count

Process threads count.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {thread} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_process_thread_count_int64`
- `create_observable_process_thread_count_int64`



## process.unix.file_descriptor.count

Number of UNIX file descriptors in use by the process.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {file_descriptor} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_process_unix_fileDescriptor_count_int64`
- `create_observable_process_unix_fileDescriptor_count_int64`



## process.uptime

The time the process has been running.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | release candidate |


Constructors:

- `create_process_uptime_double`
- `create_observable_process_uptime_double`


Instrumentations SHOULD use a gauge with type `double` and measure uptime in seconds as a floating point number with the highest precision available.
The actual accuracy would depend on the instrumentation and operating system.


## process.windows.handle.count

Number of handles held by the process.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/process/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {handle} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_process_windows_handle_count_int64`
- `create_observable_process_windows_handle_count_int64`



## rpc.client.call.duration

Measures the duration of an outgoing Remote Procedure Call (RPC).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/rpc/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_rpc_client_call_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the operation failed. |
| rpc.method | Conditionally required: if available. |
| rpc.status_code | Conditionally required: if available. |
| rpc.system.name | required |
| server.address | Conditionally required: If available. |
| server.port | Conditionally required: if applicable and if `server.address` is set. |

When this metric is reported alongside an RPC client span, the metric value
SHOULD be the same as the RPC client span duration.


## rpc.client.duration

Deprecated, use `rpc.client.call.duration` instead. Note: the unit also changed from `ms` to `s`.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/rpc/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | ms |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Replaced by `rpc.client.call.duration` with unit `s`.

Constructors:

- `create_rpc_client_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the operation failed. |
| rpc.method | Conditionally required: if available. |
| rpc.status_code | Conditionally required: if available. |
| rpc.system.name | required |
| server.address | Conditionally required: If available. |
| server.port | Conditionally required: if applicable and if `server.address` is set. |

While streaming RPCs may record this metric as start-of-batch
to end-of-batch, it's hard to interpret in practice.

**Streaming**: N/A.


## rpc.client.request.size

Measures the size of RPC request messages (uncompressed).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/rpc/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | By |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Removed, no replacement at this time.

Constructors:

- `create_rpc_client_request_size`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the operation failed. |
| rpc.method | Conditionally required: if available. |
| rpc.status_code | Conditionally required: if available. |
| rpc.system.name | required |
| server.address | Conditionally required: If available. |
| server.port | Conditionally required: if applicable and if `server.address` is set. |

**Streaming**: Recorded per message in a streaming batch


## rpc.client.requests_per_rpc

Measures the number of messages received per RPC.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/rpc/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | {count} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Removed, no replacement at this time.

Constructors:

- `create_rpc_client_requestsPerRpc`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the operation failed. |
| rpc.method | Conditionally required: if available. |
| rpc.status_code | Conditionally required: if available. |
| rpc.system.name | required |
| server.address | Conditionally required: If available. |
| server.port | Conditionally required: if applicable and if `server.address` is set. |

Should be 1 for all non-streaming RPCs.

**Streaming**: This metric is required for server and client streaming RPCs


## rpc.client.response.size

Measures the size of RPC response messages (uncompressed).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/rpc/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | By |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Removed, no replacement at this time.

Constructors:

- `create_rpc_client_response_size`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the operation failed. |
| rpc.method | Conditionally required: if available. |
| rpc.status_code | Conditionally required: if available. |
| rpc.system.name | required |
| server.address | Conditionally required: If available. |
| server.port | Conditionally required: if applicable and if `server.address` is set. |

**Streaming**: Recorded per response in a streaming batch


## rpc.client.responses_per_rpc

Measures the number of messages sent per RPC.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/rpc/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | {count} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Removed, no replacement at this time.

Constructors:

- `create_rpc_client_responsesPerRpc`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the operation failed. |
| rpc.method | Conditionally required: if available. |
| rpc.status_code | Conditionally required: if available. |
| rpc.system.name | required |
| server.address | Conditionally required: If available. |
| server.port | Conditionally required: if applicable and if `server.address` is set. |

Should be 1 for all non-streaming RPCs.

**Streaming**: This metric is required for server and client streaming RPCs


## rpc.server.call.duration

Measures the duration of an incoming Remote Procedure Call (RPC).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/rpc/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_rpc_server_call_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the operation failed. |
| rpc.method | Conditionally required: if available. |
| rpc.status_code | Conditionally required: if available. |
| rpc.system.name | required |
| server.address | opt in |
| server.port | opt in |

When this metric is reported alongside an RPC server span, the metric value
SHOULD be the same as the RPC server span duration.


## rpc.server.duration

Deprecated, use `rpc.server.call.duration` instead. Note: the unit also changed from `ms` to `s`.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/rpc/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | ms |
| Numeric annotation | double |
| Stability | development |

**Deprecated:** Replaced by `rpc.server.call.duration` with unit `s`.

Constructors:

- `create_rpc_server_duration`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the operation failed. |
| rpc.method | Conditionally required: if available. |
| rpc.status_code | Conditionally required: if available. |
| rpc.system.name | required |
| server.address | opt in |
| server.port | opt in |

While streaming RPCs may record this metric as start-of-batch
to end-of-batch, it's hard to interpret in practice.

**Streaming**: N/A.


## rpc.server.request.size

Measures the size of RPC request messages (uncompressed).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/rpc/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | By |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Removed, no replacement at this time.

Constructors:

- `create_rpc_server_request_size`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the operation failed. |
| rpc.method | Conditionally required: if available. |
| rpc.status_code | Conditionally required: if available. |
| rpc.system.name | required |
| server.address | opt in |
| server.port | opt in |

**Streaming**: Recorded per message in a streaming batch


## rpc.server.requests_per_rpc

Measures the number of messages received per RPC.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/rpc/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | {count} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Removed, no replacement at this time.

Constructors:

- `create_rpc_server_requestsPerRpc`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the operation failed. |
| rpc.method | Conditionally required: if available. |
| rpc.status_code | Conditionally required: if available. |
| rpc.system.name | required |
| server.address | opt in |
| server.port | opt in |

Should be 1 for all non-streaming RPCs.

**Streaming** : This metric is required for server and client streaming RPCs


## rpc.server.response.size

Measures the size of RPC response messages (uncompressed).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/rpc/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | By |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Removed, no replacement at this time.

Constructors:

- `create_rpc_server_response_size`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the operation failed. |
| rpc.method | Conditionally required: if available. |
| rpc.status_code | Conditionally required: if available. |
| rpc.system.name | required |
| server.address | opt in |
| server.port | opt in |

**Streaming**: Recorded per response in a streaming batch


## rpc.server.responses_per_rpc

Measures the number of messages sent per RPC.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/rpc/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | {count} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Removed, no replacement at this time.

Constructors:

- `create_rpc_server_responsesPerRpc`

| Attribute | Requirement |
| --- | --- |
| error.type | Conditionally required: If and only if the operation failed. |
| rpc.method | Conditionally required: if available. |
| rpc.status_code | Conditionally required: if available. |
| rpc.system.name | required |
| server.address | opt in |
| server.port | opt in |

Should be 1 for all non-streaming RPCs.

**Streaming**: This metric is required for server and client streaming RPCs


## signalr.server.active_connections

Number of connections that are currently active on the server.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/signalr/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | stable |


Constructors:

- `create_signalr_server_activeConnections_int64`
- `create_observable_signalr_server_activeConnections_int64`

| Attribute | Requirement |
| --- | --- |
| signalr.connection.status | recommended |
| signalr.transport | recommended |

Meter name: `Microsoft.AspNetCore.Http.Connections`; Added in: ASP.NET Core 8.0


## signalr.server.connection.duration

The duration of connections on the server.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/signalr/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | stable |


Constructors:

- `create_signalr_server_connection_duration`

| Attribute | Requirement |
| --- | --- |
| signalr.connection.status | recommended |
| signalr.transport | recommended |

Meter name: `Microsoft.AspNetCore.Http.Connections`; Added in: ASP.NET Core 8.0


## system.cpu.frequency

Operating frequency of the logical CPU in Hertz.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | Hz |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_cpu_frequency_int64`
- `create_observable_system_cpu_frequency_int64`

| Attribute | Requirement |
| --- | --- |
| cpu.logical_number | recommended |


## system.cpu.logical.count

Reports the number of logical (virtual) processor cores created by the operating system to manage multitasking.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_cpu_logical_count_int64`
- `create_observable_system_cpu_logical_count_int64`


Calculated by multiplying the number of sockets by the number of cores per socket, and then by the number of threads per core

## system.cpu.physical.count

Reports the number of actual physical processor cores on the hardware.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {cpu} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_cpu_physical_count_int64`
- `create_observable_system_cpu_physical_count_int64`


Calculated by multiplying the number of sockets by the number of cores per socket

## system.cpu.time

Seconds each logical CPU spent on each mode.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_system_cpu_time_double`
- `create_observable_system_cpu_time_double`

| Attribute | Requirement |
| --- | --- |
| cpu.logical_number | opt in |
| cpu.mode | recommended |


## system.cpu.utilization

For each logical CPU, the utilization is calculated as the change in cumulative CPU time (cpu.time) over a measurement interval, divided by the elapsed time.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_system_cpu_utilization_double`
- `create_observable_system_cpu_utilization_double`

| Attribute | Requirement |
| --- | --- |
| cpu.logical_number | opt in |
| cpu.mode | recommended |


## system.disk.io

Disk bytes transferred.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_disk_io_int64`
- `create_observable_system_disk_io_int64`

| Attribute | Requirement |
| --- | --- |
| disk.io.direction | recommended |
| system.device.name | recommended |


## system.disk.io_time

Time disk spent activated.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_system_disk_ioTime_double`
- `create_observable_system_disk_ioTime_double`

| Attribute | Requirement |
| --- | --- |
| system.device.name | recommended |

The real elapsed time ("wall clock") used in the I/O path (time from operations running in parallel are not counted). Measured as:

- Linux: Field 13 from [procfs-diskstats](https://www.kernel.org/doc/Documentation/ABI/testing/procfs-diskstats)
- Windows: The complement of
  ["Disk\% Idle Time"](https://learn.microsoft.com/archive/blogs/askcore/windows-performance-monitor-disk-counters-explained#windows-performance-monitor-disk-counters-explained)
  performance counter: `uptime * (100 - "Disk\% Idle Time") / 100`


## system.disk.limit

The total storage capacity of the disk.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_disk_limit_int64`
- `create_observable_system_disk_limit_int64`

| Attribute | Requirement |
| --- | --- |
| system.device.name | recommended |


## system.disk.merged

The number of disk reads/writes merged into single physical disk access operations.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {operation} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_disk_merged_int64`
- `create_observable_system_disk_merged_int64`

| Attribute | Requirement |
| --- | --- |
| disk.io.direction | recommended |
| system.device.name | recommended |


## system.disk.operation_time

Sum of the time each operation took to complete.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_system_disk_operationTime_double`
- `create_observable_system_disk_operationTime_double`

| Attribute | Requirement |
| --- | --- |
| disk.io.direction | recommended |
| system.device.name | recommended |

Because it is the sum of time each request took, parallel-issued requests each contribute to make the count grow. Measured as:

- Linux: Fields 7 & 11 from [procfs-diskstats](https://www.kernel.org/doc/Documentation/ABI/testing/procfs-diskstats)
- Windows: "Avg. Disk sec/Read" perf counter multiplied by "Disk Reads/sec" perf counter (similar for Writes)


## system.disk.operations

Disk operations count.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {operation} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_disk_operations_int64`
- `create_observable_system_disk_operations_int64`

| Attribute | Requirement |
| --- | --- |
| disk.io.direction | recommended |
| system.device.name | recommended |


## system.filesystem.limit

The total storage capacity of the filesystem.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_filesystem_limit_int64`
- `create_observable_system_filesystem_limit_int64`

| Attribute | Requirement |
| --- | --- |
| system.device.name | recommended |
| system.filesystem.mode | recommended |
| system.filesystem.mountpoint | recommended |
| system.filesystem.type | recommended |


## system.filesystem.lock.count

Filesystem lock counts.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {lock} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_filesystem_lock_count_int64`
- `create_observable_system_filesystem_lock_count_int64`

| Attribute | Requirement |
| --- | --- |
| file.lock.mechanism | recommended |
| file.lock.mode | recommended |
| file.lock.type | recommended |
| system.device.name | recommended |


## system.filesystem.usage

Reports a filesystem's space usage across different states.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_filesystem_usage_int64`
- `create_observable_system_filesystem_usage_int64`

| Attribute | Requirement |
| --- | --- |
| system.device.name | recommended |
| system.filesystem.mode | recommended |
| system.filesystem.mountpoint | recommended |
| system.filesystem.state | recommended |
| system.filesystem.type | recommended |

The sum of all `system.filesystem.usage` values over the different `system.filesystem.state` attributes
SHOULD equal the total storage capacity of the filesystem, that is `system.filesystem.limit`.


## system.filesystem.utilization

Fraction of filesystem bytes used.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_system_filesystem_utilization_double`
- `create_observable_system_filesystem_utilization_double`

| Attribute | Requirement |
| --- | --- |
| system.device.name | recommended |
| system.filesystem.mode | recommended |
| system.filesystem.mountpoint | recommended |
| system.filesystem.state | recommended |
| system.filesystem.type | recommended |


## system.linux.memory.available

The number of packets transferred.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {packet} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `system.memory.linux.available`.
Replacement: system.memory.linux.available.

Constructors:

- `create_system_linux_memory_available_int64`
- `create_observable_system_linux_memory_available_int64`



## system.linux.memory.slab.usage

The number of packets transferred.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {packet} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `system.memory.linux.slab.usage`.
Replacement: system.memory.linux.slab.usage.

Constructors:

- `create_system_linux_memory_slab_usage_int64`
- `create_observable_system_linux_memory_slab_usage_int64`

| Attribute | Requirement |
| --- | --- |
| linux.memory.slab.state | recommended |


## system.memory.limit

Total virtual memory available in the system.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_memory_limit_int64`
- `create_observable_system_memory_limit_int64`



## system.memory.linux.available

An estimate of how much memory is available for starting new applications, without causing swapping.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_memory_linux_available_int64`
- `create_observable_system_memory_linux_available_int64`


This is equivalent to the `system.memory.usage` metric with `state=available`.
Linux starting from 3.14 exports "available" memory. It takes "free" memory as a baseline, and then factors in kernel-specific values.
This is supposed to be more accurate than just "free" memory.
For reference, see the calculations [here](https://superuser.com/a/980821).
See also `MemAvailable` in [/proc/meminfo](https://man7.org/linux/man-pages/man5/proc.5.html).


## system.memory.linux.hugepages.limit

Total number of hugepages available.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {page} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_memory_linux_hugepages_limit_int64`
- `create_observable_system_memory_linux_hugepages_limit_int64`



## system.memory.linux.hugepages.page_size

System hugepage size in bytes.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_memory_linux_hugepages_pageSize_int64`
- `create_observable_system_memory_linux_hugepages_pageSize_int64`



## system.memory.linux.hugepages.reserved

Number of reserved hugepages.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {page} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_memory_linux_hugepages_reserved_int64`
- `create_observable_system_memory_linux_hugepages_reserved_int64`


Hugepages for which a commitment to allocate has been made, but no allocation has yet been made.
This is reported as a separate metric rather than a `usage` state because reserved pages are already counted in `free` pages.
They represent a subset of free pages that cannot be used for non-reserved allocations.


## system.memory.linux.hugepages.surplus

Number of surplus hugepages.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {page} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_memory_linux_hugepages_surplus_int64`
- `create_observable_system_memory_linux_hugepages_surplus_int64`


Overcommitted hugepages beyond the persistent pool.
This is reported as a separate metric rather than a `usage` state because surplus pages can be in either `used` or `free` state.
Including them in `usage` would break the convention that `usage` states sum to the `limit`.


## system.memory.linux.hugepages.usage

Number of hugepages in use by state.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {page} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_memory_linux_hugepages_usage_int64`
- `create_observable_system_memory_linux_hugepages_usage_int64`

| Attribute | Requirement |
| --- | --- |
| system.memory.linux.hugepages.state | recommended |


## system.memory.linux.hugepages.utilization

Percentage of hugepages in use by state.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_system_memory_linux_hugepages_utilization_double`
- `create_observable_system_memory_linux_hugepages_utilization_double`

| Attribute | Requirement |
| --- | --- |
| system.memory.linux.hugepages.state | recommended |


## system.memory.linux.shared

Shared memory used (mostly by tmpfs).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_memory_linux_shared_int64`
- `create_observable_system_memory_linux_shared_int64`


Equivalent of `shared` from [`free` command](https://man7.org/linux/man-pages/man1/free.1.html) or
`Shmem` from [`/proc/meminfo`](https://man7.org/linux/man-pages/man5/proc.5.html)"


## system.memory.linux.slab.usage

Reports the memory used by the Linux kernel for managing caches of frequently used objects.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_memory_linux_slab_usage_int64`
- `create_observable_system_memory_linux_slab_usage_int64`

| Attribute | Requirement |
| --- | --- |
| system.memory.linux.slab.state | recommended |

The sum over the `reclaimable` and `unreclaimable` state values in `memory.linux.slab.usage` SHOULD be equal to the total slab memory available on the system.
Note that the total slab memory is not constant and may vary over time.
See also the [Slab allocator](https://blogs.oracle.com/linux/post/understanding-linux-kernel-memory-statistics) and `Slab` in [/proc/meminfo](https://man7.org/linux/man-pages/man5/proc.5.html).


## system.memory.shared

Deprecated, use `system.memory.linux.shared` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `system.memory.linux.shared`.
Replacement: system.memory.linux.shared.

Constructors:

- `create_system_memory_shared_int64`
- `create_observable_system_memory_shared_int64`



## system.memory.usage

Reports memory by state.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_memory_usage_int64`
- `create_observable_system_memory_usage_int64`

| Attribute | Requirement |
| --- | --- |
| system.memory.state | recommended |

The sum of the `used` and `available` state values SHOULD be equal to `system.memory.limit`.


## system.memory.utilization

Fraction of memory bytes by state.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_system_memory_utilization_double`
- `create_observable_system_memory_utilization_double`

| Attribute | Requirement |
| --- | --- |
| system.memory.state | recommended |

The sum of the `used` and `available` state values SHOULD be equal to 1.


## system.network.connection.count

The number of connections.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_network_connection_count_int64`
- `create_observable_system_network_connection_count_int64`

| Attribute | Requirement |
| --- | --- |
| network.connection.state | recommended |
| network.interface.name | recommended |
| network.transport | recommended |


## system.network.connections

Deprecated, use `system.network.connection.count` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {connection} |
| Numeric annotation | unspecified |
| Stability | development |

**Deprecated:** Replaced by `system.network.connection.count`.
Replacement: system.network.connection.count.

Constructors:

- `create_system_network_connections_int64`
- `create_observable_system_network_connections_int64`
- `create_system_network_connections_double`
- `create_observable_system_network_connections_double`

| Attribute | Requirement |
| --- | --- |
| network.connection.state | recommended |
| network.interface.name | recommended |
| network.transport | recommended |


## system.network.dropped

Count of packets that are dropped or discarded even though there was no error.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {packet} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `system.network.packet.dropped`.
Replacement: system.network.packet.dropped.

Constructors:

- `create_system_network_dropped_int64`
- `create_observable_system_network_dropped_int64`

| Attribute | Requirement |
| --- | --- |
| network.interface.name | recommended |
| network.io.direction | recommended |

Measured as:

- Linux: the `drop` column in `/proc/dev/net` ([source](https://web.archive.org/web/20180321091318/http://www.onlamp.com/pub/a/linux/2000/11/16/LinuxAdmin.html))
- Windows: [`InDiscards`/`OutDiscards`](https://docs.microsoft.com/windows/win32/api/netioapi/ns-netioapi-mib_if_row2)
  from [`GetIfEntry2`](https://docs.microsoft.com/windows/win32/api/netioapi/nf-netioapi-getifentry2)


## system.network.errors

Count of network errors detected.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {error} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_network_errors_int64`
- `create_observable_system_network_errors_int64`

| Attribute | Requirement |
| --- | --- |
| network.interface.name | recommended |
| network.io.direction | recommended |

Measured as:

- Linux: the `errs` column in `/proc/net/dev` ([source](https://web.archive.org/web/20180321091318/http://www.onlamp.com/pub/a/linux/2000/11/16/LinuxAdmin.html)).
- Windows: [`InErrors`/`OutErrors`](https://docs.microsoft.com/windows/win32/api/netioapi/ns-netioapi-mib_if_row2)
  from [`GetIfEntry2`](https://docs.microsoft.com/windows/win32/api/netioapi/nf-netioapi-getifentry2).


## system.network.io

The number of bytes transmitted and received.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_network_io_int64`
- `create_observable_system_network_io_int64`

| Attribute | Requirement |
| --- | --- |
| network.interface.name | recommended |
| network.io.direction | recommended |


## system.network.packet.count

The number of packets transferred.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {packet} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_network_packet_count_int64`
- `create_observable_system_network_packet_count_int64`

| Attribute | Requirement |
| --- | --- |
| network.io.direction | recommended |
| system.device.name | recommended |


## system.network.packet.dropped

Count of packets that are dropped or discarded even though there was no error.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {packet} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_network_packet_dropped_int64`
- `create_observable_system_network_packet_dropped_int64`

| Attribute | Requirement |
| --- | --- |
| network.interface.name | recommended |
| network.io.direction | recommended |

Measured as:

- Linux: the `drop` column in `/proc/net/dev` ([source](https://web.archive.org/web/20180321091318/http://www.onlamp.com/pub/a/linux/2000/11/16/LinuxAdmin.html))
- Windows: [`InDiscards`/`OutDiscards`](https://docs.microsoft.com/windows/win32/api/netioapi/ns-netioapi-mib_if_row2)
  from [`GetIfEntry2`](https://docs.microsoft.com/windows/win32/api/netioapi/nf-netioapi-getifentry2)


## system.network.packets

The number of packets transferred.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {packet} |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `system.network.packet.count`.
Replacement: system.network.packet.count.

Constructors:

- `create_system_network_packets_int64`
- `create_observable_system_network_packets_int64`

| Attribute | Requirement |
| --- | --- |
| network.io.direction | recommended |
| system.device | recommended |


## system.paging.faults

The number of page faults.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {fault} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_paging_faults_int64`
- `create_observable_system_paging_faults_int64`

| Attribute | Requirement |
| --- | --- |
| system.paging.fault.type | recommended |


## system.paging.operations

The number of paging operations.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {operation} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_paging_operations_int64`
- `create_observable_system_paging_operations_int64`

| Attribute | Requirement |
| --- | --- |
| system.paging.direction | recommended |
| system.paging.fault.type | recommended |


## system.paging.usage

UNIX swap or windows pagefile usage.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_paging_usage_int64`
- `create_observable_system_paging_usage_int64`

| Attribute | Requirement |
| --- | --- |
| system.device.name | recommended |
| system.paging.state | recommended |


## system.paging.utilization

Swap (UNIX) or pagefile (windows) utilization.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | 1 |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_system_paging_utilization_double`
- `create_observable_system_paging_utilization_double`

| Attribute | Requirement |
| --- | --- |
| system.device.name | recommended |
| system.paging.state | recommended |


## system.process.count

Total number of processes in each state.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {process} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_process_count_int64`
- `create_observable_system_process_count_int64`

| Attribute | Requirement |
| --- | --- |
| process.state | recommended |


## system.process.created

Total number of processes created over uptime of the host.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | counter |
| Unit | {process} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_process_created_int64`
- `create_observable_system_process_created_int64`



## system.process.limit

The maximum number of concurrent processes/tasks allowed by the operating system.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {thread} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_system_process_limit_int64`
- `create_observable_system_process_limit_int64`


On Linux, this corresponds to `/proc/sys/kernel/pid_max` or `/proc/sys/kernel/threads-max`.
A per-user process limit may also be retrieved via `getrlimit(RLIMIT_NPROC)`.
On BSD-like systems, this corresponds to `sysctl kern.maxproc`. This metric is unsupported on Windows systems.


## system.uptime

The time the system has been running.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/system/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_system_uptime_double`
- `create_observable_system_uptime_double`


Instrumentations SHOULD use a gauge with type `double` and measure uptime in seconds as a floating point number with the highest precision available.
The actual accuracy would depend on the instrumentation and operating system.


## v8js.gc.duration

Garbage collection duration.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/v8js/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | histogram |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_v8js_gc_duration`

| Attribute | Requirement |
| --- | --- |
| v8js.gc.type | required |

The values can be retrieved from [`perf_hooks.PerformanceObserver(...).observe({ entryTypes: ['gc'] })`](https://nodejs.org/api/perf_hooks.html#performanceobserverobserveoptions)


## v8js.heap.space.available_size

Deprecated, use `v8js.memory.heap.space.available_size` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/v8js/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `v8js.memory.heap.space.available_size`.
Replacement: v8js.memory.heap.space.available_size.

Constructors:

- `create_v8js_heap_space_availableSize_int64`
- `create_observable_v8js_heap_space_availableSize_int64`

| Attribute | Requirement |
| --- | --- |
| v8js.heap.space.name | required |


## v8js.heap.space.physical_size

Deprecated, use `v8js.memory.heap.space.physical_size` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/v8js/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `v8js.memory.heap.space.physical_size`.
Replacement: v8js.memory.heap.space.physical_size.

Constructors:

- `create_v8js_heap_space_physicalSize_int64`
- `create_observable_v8js_heap_space_physicalSize_int64`

| Attribute | Requirement |
| --- | --- |
| v8js.heap.space.name | required |


## v8js.memory.heap.limit

Deprecated, use `v8js.memory.heap.space.size` instead.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/v8js/deprecated/metrics-deprecated.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |

**Deprecated:** Replaced by `v8js.memory.heap.space.size`.
Replacement: v8js.memory.heap.space.size.

Constructors:

- `create_v8js_memory_heap_limit_int64`
- `create_observable_v8js_memory_heap_limit_int64`



## v8js.memory.heap.space.available_size

Heap space available size.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/v8js/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_v8js_memory_heap_space_availableSize_int64`
- `create_observable_v8js_memory_heap_space_availableSize_int64`

| Attribute | Requirement |
| --- | --- |
| v8js.heap.space.name | required |

Value can be retrieved from value `space_available_size` of [`v8.getHeapSpaceStatistics()`](https://nodejs.org/api/v8.html#v8getheapspacestatistics)


## v8js.memory.heap.space.physical_size

Committed size of a heap space.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/v8js/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_v8js_memory_heap_space_physicalSize_int64`
- `create_observable_v8js_memory_heap_space_physicalSize_int64`

| Attribute | Requirement |
| --- | --- |
| v8js.heap.space.name | required |

Value can be retrieved from value `physical_space_size` of [`v8.getHeapSpaceStatistics()`](https://nodejs.org/api/v8.html#v8getheapspacestatistics)


## v8js.memory.heap.space.size

Total heap memory size pre-allocated for a heap space.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/v8js/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_v8js_memory_heap_space_size_int64`
- `create_observable_v8js_memory_heap_space_size_int64`

| Attribute | Requirement |
| --- | --- |
| v8js.heap.space.name | required |

The value can be retrieved from value `space_size` of [`v8.getHeapSpaceStatistics()`](https://nodejs.org/api/v8.html#v8getheapspacestatistics)


## v8js.memory.heap.used

Heap Memory size allocated.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/v8js/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | By |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_v8js_memory_heap_used_int64`
- `create_observable_v8js_memory_heap_used_int64`

| Attribute | Requirement |
| --- | --- |
| v8js.heap.space.name | required |

The value can be retrieved from value `space_used_size` of [`v8.getHeapSpaceStatistics()`](https://nodejs.org/api/v8.html#v8getheapspacestatistics)


## v8js.resource.active

Gauge of the active resources that are currently keeping the event loop alive.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/v8js/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | {resource} |
| Numeric annotation | int |
| Stability | development |


Constructors:

- `create_v8js_resource_active_int64`
- `create_observable_v8js_resource_active_int64`

| Attribute | Requirement |
| --- | --- |
| v8js.resource.type | required |

The values can be retrieved from [`process.getActiveResourcesInfo()`](https://nodejs.org/api/process.html#processgetactiveresourcesinfo)


## vcs.change.count

The number of changes (pull requests/merge requests/changelists) in a repository, categorized by their state (e.g. open or merged).

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/vcs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {change} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_vcs_change_count_int64`
- `create_observable_vcs_change_count_int64`

| Attribute | Requirement |
| --- | --- |
| vcs.change.state | required |
| vcs.owner.name | recommended |
| vcs.provider.name | opt in |
| vcs.repository.name | recommended |
| vcs.repository.url.full | required |


## vcs.change.duration

The time duration a change (pull request/merge request/changelist) has been in a given state.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/vcs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | release candidate |


Constructors:

- `create_vcs_change_duration_double`
- `create_observable_vcs_change_duration_double`

| Attribute | Requirement |
| --- | --- |
| vcs.change.state | required |
| vcs.owner.name | recommended |
| vcs.provider.name | opt in |
| vcs.ref.head.name | required |
| vcs.repository.name | recommended |
| vcs.repository.url.full | required |


## vcs.change.time_to_approval

The amount of time since its creation it took a change (pull request/merge request/changelist) to get the first approval.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/vcs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_vcs_change_timeToApproval_double`
- `create_observable_vcs_change_timeToApproval_double`

| Attribute | Requirement |
| --- | --- |
| vcs.owner.name | recommended |
| vcs.provider.name | opt in |
| vcs.ref.base.name | recommended |
| vcs.ref.base.revision | opt in |
| vcs.ref.head.name | required |
| vcs.ref.head.revision | opt in |
| vcs.repository.name | recommended |
| vcs.repository.url.full | required |


## vcs.change.time_to_merge

The amount of time since its creation it took a change (pull request/merge request/changelist) to get merged into the target(base) ref.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/vcs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | development |


Constructors:

- `create_vcs_change_timeToMerge_double`
- `create_observable_vcs_change_timeToMerge_double`

| Attribute | Requirement |
| --- | --- |
| vcs.owner.name | recommended |
| vcs.provider.name | opt in |
| vcs.ref.base.name | recommended |
| vcs.ref.base.revision | opt in |
| vcs.ref.head.name | required |
| vcs.ref.head.revision | opt in |
| vcs.repository.name | recommended |
| vcs.repository.url.full | required |


## vcs.contributor.count

The number of unique contributors to a repository.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/vcs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | {contributor} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_vcs_contributor_count_int64`
- `create_observable_vcs_contributor_count_int64`

| Attribute | Requirement |
| --- | --- |
| vcs.owner.name | recommended |
| vcs.provider.name | opt in |
| vcs.repository.name | recommended |
| vcs.repository.url.full | required |


## vcs.ref.count

The number of refs of type branch or tag in a repository.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/vcs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {ref} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_vcs_ref_count_int64`
- `create_observable_vcs_ref_count_int64`

| Attribute | Requirement |
| --- | --- |
| vcs.owner.name | recommended |
| vcs.provider.name | opt in |
| vcs.ref.type | required |
| vcs.repository.name | recommended |
| vcs.repository.url.full | required |


## vcs.ref.lines_delta

The number of lines added/removed in a ref (branch) relative to the ref from the `vcs.ref.base.name` attribute.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/vcs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | {line} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_vcs_ref_linesDelta_int64`
- `create_observable_vcs_ref_linesDelta_int64`

| Attribute | Requirement |
| --- | --- |
| vcs.change.id | Conditionally required: if a change is associated with the ref. |
| vcs.line_change.type | required |
| vcs.owner.name | recommended |
| vcs.provider.name | opt in |
| vcs.ref.base.name | required |
| vcs.ref.base.type | required |
| vcs.ref.head.name | required |
| vcs.ref.head.type | required |
| vcs.repository.name | recommended |
| vcs.repository.url.full | required |

This metric should be reported for each `vcs.line_change.type` value. For example if a ref added 3 lines and removed 2 lines,
instrumentation SHOULD report two measurements: 3 and 2 (both positive numbers).
If number of lines added/removed should be calculated from the start of time, then `vcs.ref.base.name` SHOULD be set to an empty string.


## vcs.ref.revisions_delta

The number of revisions (commits) a ref (branch) is ahead/behind the branch from the `vcs.ref.base.name` attribute.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/vcs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | {revision} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_vcs_ref_revisionsDelta_int64`
- `create_observable_vcs_ref_revisionsDelta_int64`

| Attribute | Requirement |
| --- | --- |
| vcs.change.id | Conditionally required: if a change is associated with the ref. |
| vcs.owner.name | recommended |
| vcs.provider.name | opt in |
| vcs.ref.base.name | required |
| vcs.ref.base.type | required |
| vcs.ref.head.name | required |
| vcs.ref.head.type | required |
| vcs.repository.name | recommended |
| vcs.repository.url.full | required |
| vcs.revision_delta.direction | required |

This metric should be reported for each `vcs.revision_delta.direction` value. For example if branch `a` is 3 commits behind and 2 commits ahead of `trunk`,
instrumentation SHOULD report two measurements: 3 and 2 (both positive numbers) and `vcs.ref.base.name` is set to `trunk`.


## vcs.ref.time

Time a ref (branch) created from the default branch (trunk) has existed. The `ref.type` attribute will always be `branch`.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/vcs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | gauge |
| Unit | s |
| Numeric annotation | double |
| Stability | release candidate |


Constructors:

- `create_vcs_ref_time_double`
- `create_observable_vcs_ref_time_double`

| Attribute | Requirement |
| --- | --- |
| vcs.owner.name | recommended |
| vcs.provider.name | opt in |
| vcs.ref.head.name | required |
| vcs.ref.head.type | required |
| vcs.repository.name | recommended |
| vcs.repository.url.full | required |


## vcs.repository.count

The number of repositories in an organization.

[Registry definition](https://github.com/open-telemetry/semantic-conventions/blob/v1.45.0/model/vcs/metrics.yaml)

| Property | Value |
| --- | --- |
| Instrument | updowncounter |
| Unit | {repository} |
| Numeric annotation | int |
| Stability | release candidate |


Constructors:

- `create_vcs_repository_count_int64`
- `create_observable_vcs_repository_count_int64`

| Attribute | Requirement |
| --- | --- |
| vcs.owner.name | recommended |
| vcs.provider.name | opt in |
