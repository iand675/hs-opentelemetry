# Semantic conventions

This package provides typed attribute keys from OpenTelemetry Semantic Conventions
[1.45.0](https://github.com/open-telemetry/semantic-conventions/tree/v1.45.0),
pinned by the `model` submodule at `fb30ca17193b551473b1f43c315482918ab6987c`.
The library includes stable, release candidate, and development definitions;
availability of a key does not mean an instrumentation emits it.

## Regeneration

Install [Weaver 0.28.0](https://github.com/open-telemetry/weaver/releases/tag/v0.28.0)
and initialize the model submodule, then run from this directory:

```sh
git submodule update --init model
make
```

`WEAVER=/path/to/weaver make` selects a specific executable. Weaver resolves both
upstream schema formats, references and inheritance; the Haskell renderer consumes
its normalized model. Generated intermediates in `.generated/` are not committed.
To check reproducibility, remove `.generated/`, regenerate, and compare the generated
Haskell file with the committed version.

The 1.45 update retains all 904 previously exported attribute keys, with their
existing types and wire names. Renamed attributes have separate new keys; using an
old Haskell name continues to emit its old attribute name. RPC status codes are now
available as `rpc_statusCode`; the new RPC header and trailer templates take string
arrays. Those templates are release candidate, while the status key is stable.

No instrumentation behavior changes merely by upgrading this package. In
particular, new HTTP body-content keys are opt-in definitions, not automatic body
capture. Deprecated GenAI, end-user and z/OS definitions remain available; their
successor [GenAI](https://github.com/open-telemetry/semantic-conventions-genai),
[client-side](https://github.com/open-telemetry/semantic-conventions-client-side)
and [mainframe](https://github.com/open-telemetry/semantic-conventions-mainframe)
registries are maintained separately upstream and are not bundled here.
