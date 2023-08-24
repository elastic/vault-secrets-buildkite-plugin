#!/bin/bash

EXPECTED_MESSAGE="Hello from Vault"

if [ -z "$CI_ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_MESSAGE_SECRET" ]; then
  echo "[ERROR] MESSAGE variable is empty or not defined."
  exit 1
fi

if [ "$CI_ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_MESSAGE_SECRET" == "$EXPECTED_MESSAGE" ]; then
  echo "Message is correct: $CI_ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_MESSAGE_SECRET"
  exit 0
else
  echo "[ERROR] Expected: $EXPECTED_MESSAGE - Got: $CI_ELASTIC_VAULT_SECRETS_BUILDKITE_PLUGIN_TEST_MESSAGE_SECRET"
  exit 1
fi
