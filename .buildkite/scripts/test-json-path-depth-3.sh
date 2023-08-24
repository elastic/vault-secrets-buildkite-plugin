#!/bin/bash

EXPECTED_MESSAGE='"message": "Hello from Vault"'

if [ -z "$CI_ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_SECRET" ]; then
  echo "[ERROR] CI_ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_SECRET variable is empty or not defined."
  exit 1
fi

is_expected_message=$(echo "$CI_ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_SECRET" | grep -c "$EXPECTED_MESSAGE")

if [ "$is_expected_message" -eq 1 ]; then
  echo "CI_ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_SECRET is correct: $CI_ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_SECRET"
  exit 0
else
  echo "[ERROR] Expected: $EXPECTED_MESSAGE - Got: $CI_ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_SECRET"
  exit 1
fi
