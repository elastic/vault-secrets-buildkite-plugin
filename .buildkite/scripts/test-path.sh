#!/bin/bash

EXPECTED_MESSAGE='{"message":"Hello from Vault"}'

if [ -z "$TEST_ELASTIC_CO_SECRET" ]; then
  echo "[ERROR] TEST_ELASTIC_CO_SECRET variable is empty or not defined."
  exit 1
fi

if [ "$TEST_ELASTIC_CO_SECRET" == "$EXPECTED_MESSAGE" ]; then
  echo "TEST_ELASTIC_CO_SECRET is correct: $TEST_ELASTIC_CO_SECRET"
  exit 0
else
  echo "[ERROR] Expected: $EXPECTED_MESSAGE - Got: $TEST_ELASTIC_CO_SECRET"
  exit 1
fi
