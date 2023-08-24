#!/bin/bash

EXPECTED_MESSAGE="Hello from Vault"

echo "BUILDKITE_REDACTED_VARS: $BUILDKITE_REDACTED_VARS"

if [ -z "$MESSAGE" ]; then
  echo "[ERROR] MESSAGE variable is empty or not defined."
  exit 1
fi

if [ "$MESSAGE" == "$EXPECTED_MESSAGE" ]; then
  echo "Message is correct: $MESSAGE"
  exit 0
else
  echo "[ERROR] Expected: $EXPECTED_MESSAGE - Got: $MESSAGE"
  exit 1
fi
