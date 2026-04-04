# Changelog

## 0.1.0.0

* Initial release
* `TracedRedis` monad with `RedisCtx` instance for automatic command compatibility
* `traced` combinator for per-command span creation
* `tracedRunRedis` for exception-safe top-level tracing
* Follows OTel database client semantic conventions for Redis
