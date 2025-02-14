#!/bin/bash

EXPECTED_MESSAGE='{"message":"Hello from Vault"}'

if [ -z "$TEST_FORMAT_SECRET" ]; then
  echo "[ERROR] TEST_FORMAT_SECRET variable is empty or not defined."
  exit 1
fi

if [ "$TEST_FORMAT_SECRET" == "$EXPECTED_MESSAGE" ]; then
  echo "TEST_FORMAT_SECRET is correct: $TEST_FORMAT_SECRET"
  exit 0
else
  echo "[ERROR] Expected: $EXPECTED_MESSAGE - Got: $TEST_FORMAT_SECRET"
  exit 1
fi
