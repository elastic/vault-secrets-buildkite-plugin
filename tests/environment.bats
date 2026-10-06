#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

setup() {
  export BUILDKITE_PLUGIN_VAULT_SECRETS_PATH=secret/ci/example/service
  export BUILDKITE_PLUGIN_VAULT_SECRETS_FIELD=""
  export BUILDKITE_PLUGIN_VAULT_SECRETS_ENV_VAR=""
  export BUILDKITE_PLUGIN_VAULT_SECRETS_PATH_DEPTH=""
}

@test "exports a selected Vault field to the requested variable" {
  export BUILDKITE_PLUGIN_VAULT_SECRETS_FIELD=message
  export BUILDKITE_PLUGIN_VAULT_SECRETS_ENV_VAR=TEST_MESSAGE_SECRET

  stub vault \
    "kv get -field=message secret/ci/example/service : echo hello-from-vault"
  stub buildkite-agent \
    "--version : echo 3.66.0" \
    "redactor add : true"
  stub grep '-oP * : echo 3.66.0'
  stub sort '--version-sort : echo 3.66.0'

  run bash -c 'source hooks/environment; printf "%s" "$TEST_MESSAGE_SECRET"'

  unstub grep
  unstub sort
  assert_success
  assert_output "hello-from-vault"
}

@test "exports the full Vault secret as JSON under the generated variable name" {
  stub vault \
    "kv get -format=json secret/ci/example/service : echo '{\"data\":{\"message\":\"hello-from-vault\"}}'"
  stub buildkite-agent \
    "--version : echo 3.66.0" \
    "redactor add : true"
  stub grep '-oP * : echo 3.66.0'
  stub sort '--version-sort : echo 3.66.0'

  run bash -c 'source hooks/environment; printf "%s" "$EXAMPLE_SERVICE_SECRET"'

  unstub grep
  unstub sort
  assert_success
  assert_output '{"message":"hello-from-vault"}'
}
