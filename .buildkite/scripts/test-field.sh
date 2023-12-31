#!/bin/bash

EXPECTED_MESSAGE="Hello from Vault"

if [ -z "$ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_MESSAGE_SECRET" ]; then
  echo "[ERROR] ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_MESSAGE_SECRET variable is empty or not defined."
  exit 1
fi

if [ "$ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_MESSAGE_SECRET" == "$EXPECTED_MESSAGE" ]; then
  echo "ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_MESSAGE_SECRET is correct: $ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_MESSAGE_SECRET"
  exit 0
else
  echo "[ERROR] Expected: $EXPECTED_MESSAGE - Got: $ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_MESSAGE_SECRET"
  exit 1
fi
