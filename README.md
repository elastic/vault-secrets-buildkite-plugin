# Vault Secrets Buildkite Plugin

A buildkite plugin to map Vault secrets to Step environments variables

## Usage

Add the following to your `pipeline.yml`:

```yml
steps:
  - command: '<your-command>'
    plugins:
      - elastic/vault-secrets#v0.0.1:
          path: 'secret/ci/elastic-<repo-name>/<secret-name>'
          field: '<secret-field-name>'
          env_var: '<environment-variable-mapping-secret>'
```
