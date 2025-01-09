# HTTP server example

This example uses:

- hs-opentelemetry-api
- hs-opentelemetry-sdk
- hs-opentelemetry-propagator-datadog
- hs-opentelemetry-propagator-w3c
- hs-opentelemetry-instrumentation-wai
- hs-opentelemetry-instrumentation-http-client

## Run

You must start servers with Docker:

```
$ make server.run
```

and run this example in another shell:

```
$ make app.run
```

You can access following end points.

- http://localhost:16686/
  - Jaeger UI
- http://localhost:7777/
  - this example app

When you want to use a Datadog propagator, give a `datadog` argument (a default propagator is W3C):

```
$ make app.run HTTP_SERVER_OPTS=datadog
```
