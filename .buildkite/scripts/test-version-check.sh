#!/bin/bash
set -eo pipefail

# shellcheck source=hooks/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../hooks/lib.sh"

PASS=0
FAIL=0

run_case() {
  local description="$1"
  local mock_output="$2"
  local mock_exit="$3"
  local expect_result="$4"  # "pass" or "fail"
  local expect_reason="$5"  # optional substring expected in stdout on failure

  buildkite-agent() { echo "$mock_output"; return "$mock_exit"; }
  export -f buildkite-agent

  local reason actual
  if reason=$(check_buildkite_agent_version_for_redaction); then
    actual="pass"
  else
    actual="fail"
  fi

  local ok=true
  [[ "$actual" != "$expect_result" ]] && ok=false
  [[ -n "$expect_reason" && "$reason" != *"$expect_reason"* ]] && ok=false

  if $ok; then
    echo "  OK  $description"
    PASS=$((PASS + 1))
  else
    echo "FAIL  $description"
    [[ "$actual" != "$expect_result" ]] && echo "      expected $expect_result, got $actual"
    [[ -n "$expect_reason" ]] && echo "      expected reason to contain: $expect_reason"
    [[ -n "$reason" ]]        && echo "      actual reason: $reason"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== check_buildkite_agent_version_for_redaction ==="

# Version comparison
run_case "exact minimum"        "buildkite-agent version 3.66.0, build 1" 0 pass
run_case "patch above minimum"  "buildkite-agent version 3.66.1, build 1" 0 pass
run_case "minor above minimum"  "buildkite-agent version 3.67.0, build 1" 0 pass
run_case "major above minimum"  "buildkite-agent version 4.0.0, build 1"  0 pass
run_case "patch below minimum"  "buildkite-agent version 3.65.9, build 1" 0 fail "requires buildkite-agent"
run_case "minor below minimum"  "buildkite-agent version 3.65.0, build 1" 0 fail "requires buildkite-agent"
run_case "major below minimum"  "buildkite-agent version 2.99.99, build 1" 0 fail "requires buildkite-agent"

# Numeric (not lexicographic) comparison
run_case "minor > 9"            "buildkite-agent version 3.100.0, build 1" 0 pass
run_case "patch > 9"            "buildkite-agent version 3.66.10, build 1" 0 pass

# Error cases
run_case "command exits non-zero" "some error"                              1 fail "failed to run"
run_case "no version in output"   "buildkite-agent dev build"               0 fail "could not parse version"
run_case "empty output"           ""                                         0 fail "could not parse version"

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
[[ "$FAIL" -eq 0 ]]
