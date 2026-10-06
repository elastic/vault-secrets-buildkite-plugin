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

  run bash -c 'source hooks/environment; printenv TEST_MESSAGE_SECRET'

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

  run bash -c 'source hooks/environment; printenv EXAMPLE_SERVICE_SECRET'

  unstub grep
  unstub sort
  assert_success
  assert_output '{"message":"hello-from-vault"}'
}

@test "fails after exhausting Vault retries" {
  export BUILDKITE_PLUGIN_VAULT_SECRETS_FIELD=message

  stub vault \
    "kv get -field=message secret/ci/example/service : printf x >> \"$BATS_TEST_TMPDIR/vault-attempts\"; exit 1" \
    "kv get -field=message secret/ci/example/service : printf x >> \"$BATS_TEST_TMPDIR/vault-attempts\"; exit 1" \
    "kv get -field=message secret/ci/example/service : printf x >> \"$BATS_TEST_TMPDIR/vault-attempts\"; exit 1"
  stub buildkite-agent \
    "--version : echo 3.66.0" \
    "redactor add : true"
  stub sleep \
    "5 : printf x >> \"$BATS_TEST_TMPDIR/sleep-attempts\"" \
    "5 : printf x >> \"$BATS_TEST_TMPDIR/sleep-attempts\"" \
    "5 : printf x >> \"$BATS_TEST_TMPDIR/sleep-attempts\""

  run bash -c 'source hooks/environment'

  assert_failure
  assert_output --partial "Command failed after 3 retries."
  assert_equal "$(cat "$BATS_TEST_TMPDIR/vault-attempts")" "xxx"
  assert_equal "$(cat "$BATS_TEST_TMPDIR/sleep-attempts")" "xxx"
}
