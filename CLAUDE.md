# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

The project uses both Cabal and Stack as build tools, with Nix for environment management:

### Build Commands
- `make` - Build and test everything across multiple GHC versions (9.4, 9.6, 9.8, 9.10) using both Stack and Cabal
- `make build.all` - Build everything without running tests
- `stack build --test --bench` - Build with Stack (default: GHC 9.10)
- `cabal build --enable-tests --enable-benchmarks all` - Build with Cabal
- `cabal test all` - Run all tests with Cabal

### Code Formatting
- `make format` - Format all Haskell files with fourmolu (requires fourmolu 0.13.1.0+)
- `make format.check` - Check formatting without modifying files

### Development Environment
- `nix develop` - Enter default development environment (GHC 9.10)
- `nix develop .#ghc94` - Enter specific GHC version environment (9.4, 9.6, 9.8, 9.10 available)
- `direnv allow` - Allow direnv to load `.envrc` for automatic environment setup

### Testing
- Run tests via the build commands above (`--test` flag for Stack, `cabal test` for Cabal)
- Tests are located in `test/` directories within each package

## Code Architecture

This is a multi-package Haskell project implementing OpenTelemetry for Haskell. The architecture follows the OpenTelemetry specification with clear separation between API and SDK:

### Core Package Structure
- **`api/`** - OpenTelemetry API types and interfaces (for library instrumentation)
- **`sdk/`** - OpenTelemetry SDK implementation (for applications)
- **`otlp/`** - OpenTelemetry Protocol (OTLP) implementation
- **`semantic-conventions/`** - Auto-generated semantic conventions

### Instrumentation Libraries
Located in `instrumentation/`:
- `wai/` - WAI middleware instrumentation
- `yesod/` - Yesod web framework instrumentation
- `persistent/` - Persistent database library instrumentation
- `http-client/` - HTTP client instrumentation
- `conduit/` - Conduit streaming library instrumentation

### Exporters
Located in `exporters/`:
- `otlp/` - OTLP exporter (primary export format)
- `handle/` - Handle-based exporter (e.g., stdout)
- `in-memory/` - In-memory exporter for testing

### Propagators
Located in `propagators/`:
- `w3c/` - W3C trace context and baggage propagation
- `b3/` - B3 propagation format
- `datadog/` - Datadog propagation format

### Key Concepts
- **TracerProvider**: Factory for creating Tracer instances
- **Tracer**: Creates and manages Spans
- **Span**: Represents a unit of work in a trace
- **Context**: Carries trace context and baggage across process boundaries
- **Resource**: Describes the service/process generating telemetry

### Important Implementation Notes
- The API package should be used for library instrumentation
- The SDK package should be used for application-level configuration
- Traces are the primary focus; metrics and logs are not yet fully implemented
- The project supports multiple GHC versions (9.4, 9.6, 9.8, 9.10, 9.12)

### Code Style
- Uses fourmolu for formatting
- HLint configuration in `.hlint.yaml` prohibits direct stdout/stderr usage
- Follows standard Haskell conventions with some project-specific patterns

### Development Workflow
1. Use `nix develop` to enter the development environment
2. Make changes and run `make format` before committing
3. Use `make` to build and test across all supported configurations
4. Follow the multi-package structure when adding new functionality
- shell scripts should go in the scripts/ folder
