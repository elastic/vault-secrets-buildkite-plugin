#!/bin/bash

echo "BUILDKITE_REDACTED_VARS: $BUILDKITE_REDACTED_VARS"

EXPECTED_MESSAGE='"message": "Hello from Vault"'

if [ -z "$TEST_SECRET" ]; then
  echo "[ERROR] MESSAGE variable is empty or not defined."
  exit 1
fi

is_expected_message=$(echo "$TEST_SECRET" | grep -c "$EXPECTED_MESSAGE")

if [ "$is_expected_message" -eq 1 ]; then
  echo "Message is correct: $TEST_SECRET"
  exit 0
else
  echo "[ERROR] Expected: $EXPECTED_MESSAGE - Got: $TEST_SECRET"
  exit 1
fi
