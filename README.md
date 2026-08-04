# Vault Secrets Buildkite Plugin

[![Build status](https://badge.buildkite.com/d5246cdaa0cb57cb86f0de499111ee4b4a00ef78941af6ba84.svg)](https://buildkite.com/elastic/vault-secrets-buildkite-plugin)

A simple buildkite plugin to map a Vault secret to a Step environment variable

## Requirements

`vault` and `buildkite-agent` are expected to be installed on your Buildkite
worker. `jq` is also required, but only when the `field` property (see
below) is not set.

## Usage

Add the following to your `pipeline.yml`:

```yml
steps:
  - command: "<your-command>"
    plugins:
      - elastic/vault-secrets#v0.1.0:
          path: "secret/ci/elastic-<repo-name>/<secret-name>"
          field: "<secret-field-name>" # OPTIONAL
          env_var: "<environment-variable-mapping-secret>" # OPTIONAL
          path_depth: "2" # OPTIONAL
```

- `field` specifies the exact Vault secret field to retrieve.
  When `field` isn't defined, the entire secret is retrieved in json format
- `env_var` specifies the name of the environment variable that will contain the secret.
  When `env_var` is not specified, the name of the environment variable will be generated
  using this scheme: `<UPPERCASE_SECRET_NAME>[_<UPPERCASE_FIELD_NAME>]_SECRET`. Note
  that if you do specify an `env_var`, you should use one of the patterns that will
  ensure Buildkite will redact the secret, see [the docs][0] for details.
- `path_depth` specifies the number of elements of the path to use in the variable name when
  `env_var` isn't defined. When not defined the default value is `2`

Please refer to the test pipeline and scripts in ths `.buildkite` directory as examples.

[0]: https://buildkite.com/docs/pipelines/managing-log-output#redacted-environment-variables

## Testing

To test changes on a branch before merging, reference the plugin directly by branch name or commit SHA instead of a version tag (e.g. `elastic/vault-secrets#your-branch-name`). Buildkite fetches the plugin from GitHub at the specified ref, so the branch does not need to be merged first.

For testing in Flavortown, you should ensure:
1. That the pipeline has `gobld-pipelines` set as the team for testing
2. The secret you are attempting to fetch is available in `ci-dev`

> NOTE: You can use a known existing secret or you can copy over another secret ([civet can help with this](https://github.com/elastic/civet#copy-secrets-replaces-vault-cp-and-works-across-vaults)), but just make sure you remove it from `ci-dev` after testing.

## Releases

Releases follow the standard GitHub Releases flow:

1. Merge your changes to `main`
2. Navigate to the [Releases page](https://github.com/elastic/vault-secrets-buildkite-plugin/releases) and draft a new release
3. Create a new tag following semantic versioning (e.g. `v0.2.0`)
4. Generate or write release notes describing the changes
5. Publish the release

Once published, the new tag can be referenced in pipelines (e.g. `elastic/vault-secrets#v0.2.0`).
