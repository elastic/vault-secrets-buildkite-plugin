#!/bin/bash

EXPECTED_MESSAGE='"message": "Hello from Vault"'

if [ -z "$ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_SECRET" ]; then
  echo "[ERROR] ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_SECRET variable is empty or not defined."
  exit 1
fi

is_expected_message=$(echo "$ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_SECRET" | grep -c "$EXPECTED_MESSAGE")

if [ "$is_expected_message" -eq 1 ]; then
  echo "ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_SECRET is correct: $ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_SECRET"
  exit 0
else
  echo "[ERROR] Expected: $EXPECTED_MESSAGE - Got: $ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_SECRET"
  exit 1
fi
