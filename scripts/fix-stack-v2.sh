#!/bin/bash
set -e
export DIRENV_DISABLE=1
cd /Users/ian/Code/mercury/hs-opentelemetry

log() { echo "=== $(date +%H:%M:%S) $1 ==="; }

replace_in_file() {
    local file="$1" old="$2" new="$3"
    python3 -c "
import sys
with open('$file') as f: c = f.read()
c2 = c.replace('$old', '$new')
if c2 == c: print('WARNING: no change in $file', file=sys.stderr)
with open('$file', 'w') as f: f.write(c2)
"
}

log "Step 1: Bump thread-utils-context at qmmstszm"
jj edit qmmstszm
replace_in_file stack-ghc-9.10.yaml "thread-utils-context-0.3.0.4" "thread-utils-context-0.4.1.0"
replace_in_file api/hs-opentelemetry-api.cabal "thread-utils-context ==0.3.*" "thread-utils-context >=0.3 && <0.5"

log "Step 2: Squash yttnxxvt through lmoqttut"
jj edit yttnxxvt
jj restore --from lmoqttut
jj describe -m "build: stack files, new packages (api-types, propagators, instrumentation), and GHC version matrix"

log "Step 2b: Abandon empty intermediates"
jj abandon wryqylpm nmnuqnsy ylpnulyv mnvtowpr ozoltxul vptkvwky nkpstlwt lmoqttut

log "Step 3: Squash vzpvuqzw through yvswokyu"
jj edit vzpvuqzw
jj restore --from yvswokyu
jj describe -m "feat: API 0.4, SDK updates, exporter/propagator/instrumentation improvements, docs, and build"

log "Step 3b: Abandon empty intermediates"
jj abandon pmlomoqr kulnkpxx ovopzupr skyutoln vyznmpom oquxvmst ttkuqpqs txykxxqo qslkywpo muzumtuw snxmxutv ltytxwsx wvqoxkkv txwyqzns vwkowrqr ryoyxuxq qktylyps qpqkkonr wrutyppl zzkytoqt oxlrkuup lnwlrpos rqnuxyko tlmlxntn yvswokyu

log "Step 4: Fix StorageV2 import"
replace_in_file api/src/OpenTelemetry/Context/ThreadLocal.hs "import Control.Concurrent.Thread.StorageV2" "import Control.Concurrent.Thread.Storage"

log "Step 5: Check final stack"
jj log -r 'ancestors(@, 30) & ~ancestors(trunk())' --no-graph -T 'change_id.shortest(8) ++ " " ++ description.first_line() ++ "\n"' 2>/dev/null

log "Done!"
