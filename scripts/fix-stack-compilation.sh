#!/bin/bash
set -e
export DIRENV_DISABLE=1

cd /Users/ian/Code/mercury/hs-opentelemetry

log() { echo "=== $(date +%H:%M:%S) $1 ==="; }

# Step 1: Squash metrics commits (1-6) into one
log "Step 1: Squash metrics commits"
jj edit qmmstszm
jj restore --from wxlvmmqr
jj describe -m "feat: metrics implementation (API + SDK + exporters + build scaffolding)"
jj abandon ksprmnsl kvtynxqt uovtzvlv vnyvzsym wxlvmmqr

# Step 2: Fix stack.yaml indentation (exporters/otlp had extra indent)
log "Step 2: Fix stack.yaml indentation in metrics commit"
# The restore brought in wxlvmmqr's broken YAML
python3 -c "
import re
with open('stack-ghc-9.10.yaml') as f:
    content = f.read()
# Fix: '- exporters/in-memory\n  - exporters/otlp\n  - exporters/prometheus'
# Should be: each on own line with '- ' prefix
content = content.replace('- exporters/in-memory\n  - exporters/otlp\n  - exporters/prometheus', '- exporters/in-memory\n- exporters/otlp\n- exporters/prometheus')
# Also fix just the two-indent variant
content = content.replace('- exporters/in-memory\n  - exporters/otlp', '- exporters/in-memory\n- exporters/otlp')
with open('stack-ghc-9.10.yaml', 'w') as f:
    f.write(content)
"

# Step 3: Fix build infra commit (yttnxxvt) - remove package dirs that don't exist yet
log "Step 3: Fix build infra stack.yaml"
jj edit yttnxxvt
# At this point, api-types/, propagators/jaeger/, propagators/xray/,
# instrumentation/gogol/, instrumentation/ghc-metrics/ don't have .cabal files yet.
# Remove them from stack.yaml and add them in later commits.
python3 -c "
with open('stack-ghc-9.10.yaml') as f:
    lines = f.readlines()
# Remove lines for packages that don't exist yet at this commit
remove = ['api-types', 'propagators/jaeger', 'propagators/xray',
          'instrumentation/gogol', 'instrumentation/ghc-metrics',
          'instrumentation/hedis', 'instrumentation/amazonka',
          'utils/exceptions']
filtered = []
for line in lines:
    stripped = line.strip().lstrip('- ')
    if stripped in remove:
        continue
    filtered.append(line)
with open('stack-ghc-9.10.yaml', 'w') as f:
    f.writelines(filtered)
"

# Step 4: Add stack.yaml entries in the commits that create new packages
log "Step 4: Add stack.yaml entries for new packages"

add_to_stack_yaml() {
    local entry="$1"
    local after="$2"
    python3 -c "
with open('stack-ghc-9.10.yaml') as f:
    content = f.read()
if '- $entry' not in content:
    content = content.replace('- $after\n', '- $after\n- $entry\n')
    with open('stack-ghc-9.10.yaml', 'w') as f:
        f.write(content)
"
}

# wryqylpm: extract api-types leaf package
jj edit wryqylpm
add_to_stack_yaml "api-types" "api"

# ylpnulyv: amazonka instrumentation
jj edit ylpnulyv
add_to_stack_yaml "instrumentation/amazonka" "instrumentation/yesod"

# mnvtowpr: gogol instrumentation
jj edit mnvtowpr
add_to_stack_yaml "instrumentation/gogol" "instrumentation/amazonka"

# ozoltxul: hedis instrumentation
jj edit ozoltxul
add_to_stack_yaml "instrumentation/hedis" "instrumentation/gogol"

# vptkvwky: Jaeger propagator
jj edit vptkvwky
add_to_stack_yaml "propagators/jaeger" "propagators/datadog"

# nkpstlwt: X-Ray propagator
jj edit nkpstlwt
add_to_stack_yaml "propagators/xray" "propagators/jaeger"

# lmoqttut: heroku resource detector (goes in sdk, not separate stack.yaml entry)
# Actually check if it needs a stack.yaml entry

# Step 5: At vzpvuqzw (API 0.4 bump), widen all downstream version constraints
# AND bump thread-utils-context
log "Step 5: Widen version constraints at API 0.4 bump"
jj edit vzpvuqzw

# Bump thread-utils-context in stack.yaml
python3 -c "
with open('stack-ghc-9.10.yaml') as f:
    content = f.read()
content = content.replace('thread-utils-context-0.3.0.4', 'thread-utils-context-0.4.1.0')
with open('stack-ghc-9.10.yaml', 'w') as f:
    f.write(content)
"

# Widen version constraints in all package.yaml and .cabal files
# Change: hs-opentelemetry-api >=0.3 && <0.4 -> >=0.3 && <0.5
# Change: hs-opentelemetry-api ==0.3.* -> >=0.3 && <0.5
# Change: hs-opentelemetry-api ^>=0.3 -> >=0.3 && <0.5
find . -name '*.cabal' -o -name 'package.yaml' | while read f; do
    python3 -c "
import re, sys
with open('$f') as fh:
    content = fh.read()
orig = content
# Widen various constraint patterns for hs-opentelemetry-api
content = re.sub(r'hs-opentelemetry-api\s*>=\s*0\.3\s*&&\s*<\s*0\.4', 'hs-opentelemetry-api >=0.3 && <0.5', content)
content = re.sub(r'hs-opentelemetry-api\s*==\s*0\.3\.\*', 'hs-opentelemetry-api >=0.3 && <0.5', content)
content = re.sub(r'hs-opentelemetry-api\s*\^>=\s*0\.3', 'hs-opentelemetry-api >=0.3 && <0.5', content)
# Also handle otlp constraint if needed
content = re.sub(r'hs-opentelemetry-otlp\s*>=\s*0\.1\s*&&\s*<\s*0\.2', 'hs-opentelemetry-otlp >=0.1 && <0.3', content)
# Also widen thread-utils-context in api cabal
content = re.sub(r'thread-utils-context\s*==\s*0\.3\.\*', 'thread-utils-context >=0.3 && <0.5', content)
if content != orig:
    with open('$f', 'w') as fh:
        fh.write(content)
    print(f'Updated: $f', file=sys.stderr)
" 2>&1
done

# Step 6: Fix the ghc-metrics stack.yaml entry - it should be added in the
# commit that creates the ghc-metrics package, not in yttnxxvt
log "Step 6: Add ghc-metrics and utils/exceptions at the right commits"
# The zzkytoqt commit should have ghc-metrics
jj edit zzkytoqt
add_to_stack_yaml "instrumentation/ghc-metrics" "instrumentation/gogol"

# The qktylyps commit should have utils/exceptions
jj edit qktylyps
add_to_stack_yaml "utils/exceptions" "instrumentation/yesod"

# Step 7: Fix StorageV2 import in tlmlxntn
log "Step 7: Fix StorageV2 import"
jj edit tlmlxntn
python3 -c "
with open('api/src/OpenTelemetry/Context/ThreadLocal.hs') as f:
    content = f.read()
content = content.replace('import Control.Concurrent.Thread.StorageV2', 'import Control.Concurrent.Thread.Storage')
with open('api/src/OpenTelemetry/Context/ThreadLocal.hs', 'w') as f:
    f.write(content)
"

# Step 8: Return to top
log "Step 8: Return to top"
jj edit yvswokyu

log "All fixes applied!"
