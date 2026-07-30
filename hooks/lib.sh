#!/bin/bash

# In `buildkite-agent` 3.66.0
# (https://github.com/buildkite/agent/releases/tag/v3.66.0) the ability to
# redact secrets (https://buildkite.com/docs/agent/v3/cli-redactor) was added.
# However, because we may not always run that version of `buildkite-agent`, we
# should conditionally enable it
check_buildkite_agent_version_for_redaction() {
  local version_output
  if ! version_output="$(buildkite-agent --version 2>&1)"; then
    echo "failed to run 'buildkite-agent --version': ${version_output}"
    return 1
  fi
  local version
  version="$(echo "$version_output" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  if [[ -z "$version" ]]; then
    echo "could not parse version from 'buildkite-agent --version' output: ${version_output}"
    return 1
  fi
  local min_version="3.66.0"
  if [[ "$(printf '%s\n%s\n' "$min_version" "$version" | sort -t. -k1,1n -k2,2n -k3,3n | head -n1)" = "$min_version" ]]; then
    return 0
  else
    echo "requires buildkite-agent >= $min_version (got $version)"
    return 1
  fi
}
