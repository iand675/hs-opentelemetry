#!/bin/bash
set -o pipefail

export DIRENV_LOG_FORMAT=

results_file="/tmp/otel-build-results.txt"
original_commit=$(jj log -r '@' --no-graph -T 'change_id.shortest(8)' 2>/dev/null)

commits=$(jj log -r '@ | (::@- & ~::trunk())' --no-graph -T 'change_id.shortest(8) ++ "\n"' 2>/dev/null | tac)

> "$results_file"
echo "Stack verification started at $(date)" | tee -a "$results_file"
echo "---" >> "$results_file"

count=0
total=$(echo "$commits" | wc -l | tr -d ' ')
pass=0
fail=0
failed_commits=""

for commit in $commits; do
    count=$((count + 1))
    desc=$(jj log -r "$commit" --no-graph -T 'description.first_line()' 2>/dev/null)
    echo "=== [$count/$total] $commit: $desc ===" | tee -a "$results_file"

    jj edit "$commit" 2>/dev/null

    start_time=$(date +%s)
    build_output=$(stack test -j4 --no-run-tests 2>&1)
    build_exit=$?
    end_time=$(date +%s)
    elapsed=$(( end_time - start_time ))

    if [ $build_exit -eq 0 ]; then
        echo "  PASS (${elapsed}s)" | tee -a "$results_file"
        pass=$((pass + 1))
    else
        echo "  FAIL (${elapsed}s)" | tee -a "$results_file"
        echo "$build_output" | tail -40 >> "$results_file"
        echo "---" >> "$results_file"
        fail=$((fail + 1))
        failed_commits="$failed_commits $commit"
    fi
done

jj edit "$original_commit" 2>/dev/null

echo "" | tee -a "$results_file"
echo "=== SUMMARY ===" | tee -a "$results_file"
echo "Total: $total, Pass: $pass, Fail: $fail" | tee -a "$results_file"
if [ -n "$failed_commits" ]; then
    echo "Failed:$failed_commits" | tee -a "$results_file"
fi
echo "Completed at $(date)" | tee -a "$results_file"
