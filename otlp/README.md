# otlp
A package containing `.hs` files with data types generated from the Protobuf definitions (i.e.: `.proto` files) of the OpenTelemetry protocol (OTLP).

## Auto-generation Instructions
To generate `.hs` files from a new version of OTLP, you need to take the corresponding Git tag from the opentelemetry-proto repository [1], write it into the `OTLP_VERSION` file, and run the `./scripts/generate-modules.sh` script.

Auto-generated files can be found in the `src` directory.

[1] https://github.com/open-telemetry/opentelemetry-proto
