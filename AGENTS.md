# AGENTS.md

Guidance for AI agents (and humans skimming for the same context) working in
this repository.

## What this plugin does

A Buildkite plugin, implemented as a single Bash hook
(`hooks/environment`), that fetches a secret from Vault and exposes it to a
pipeline step as an environment variable. Configuration is declared in
`plugin.yml`; usage is documented in `README.md`.

## Org-wide blast radius — read this before changing behavior

This is not a self-contained utility used only by this repo's own tests.
Per Elastic's internal "Buildkite Guidelines"
(`codex.elastic.dev/r/observability-robots/teams/ci/buildkite/buildkite-guidelines`),
`elastic/vault-secrets` is the **org-recommended pattern** for accessing Vault
secrets from any Buildkite pipeline, explicitly preferred over reading Vault
CI secrets directly in scripts or pre-command hooks. Any pipeline across
Elastic that has adopted this recommendation depends on this plugin's current
behavior.

Concretely, this means changes to any of the following are **not
repo-local** — they can silently affect every consuming pipeline, not just
the 10 test cases under `.buildkite/scripts/`:

- The environment-variable naming scheme (see `generate_variable_name` below).
- Redaction behavior (whether/when a secret is registered with the Buildkite
  redactor).
- Retry behavior (attempt count, backoff).

Treat edits to `hooks/environment` as a change with an audience beyond this
repository, and validate against the existing `.buildkite/scripts/test-*.sh`
scripts (which exercise the plugin end-to-end against a real Vault path in
CI) before assuming a change is safe.

## Configuration (`plugin.yml`)

Properties, all under the `elastic/vault-secrets` plugin key:

| Property | Type | Required | Notes |
|---|---|---|---|
| `path` | string | yes | Vault KV path, e.g. `secret/ci/elastic-<repo-name>/<secret-name>`. |
| `field` | string | no | A specific field within the secret. If omitted, the entire secret is fetched as JSON. |
| `env_var` | string | no | Explicit environment variable name to assign the secret to. If omitted, a name is generated (see below). |
| `path_depth` | string | no | Number of trailing path components used when generating the variable name (see below). Defaults to `2`. |

`additionalProperties: false` — no other keys are accepted.

## Variable-naming scheme (`generate_variable_name` in `hooks/environment`)

When `env_var` is not set, the environment variable name is derived from
`path`, `field`, and `path_depth`:

1. Take the last `path_depth` slash-separated components of `path` (default
   `2`), via `rev | cut -d"/" -f 1-"$depth" | rev`.
2. Replace remaining `/` characters with `_`.
3. If `field` is set, append `_<field>` (as given — case is not altered at
   this step).
4. Uppercase the whole string, and replace `.` and `-` with `_`.
5. Append the literal suffix `_SECRET`.

Result shape: `<UPPERCASE_PATH>[_<FIELD>]_SECRET`.

The `_SECRET` suffix is required, not cosmetic: Buildkite auto-redacts
environment variables whose names end in `_SECRET` (or match its other
redacted-name patterns) — see the [redacted environment variables
docs](https://buildkite.com/docs/pipelines/managing-log-output#redacted-environment-variables).
If you ever add a code path that supplies a custom `env_var`, that
responsibility shifts to the pipeline author — the plugin does not enforce
the `_SECRET` suffix on explicit `env_var` values.

`path_depth` truncation examples (`rev | cut -d"/" -f 1-N | rev`):
- `path: secret/ci/elastic-foo/bar`, `path_depth: 2` (default) →
  last 2 components `elastic-foo/bar` → `ELASTIC_FOO_BAR_SECRET`.
- Same path, `path_depth: 1` → last 1 component `bar` → `BAR_SECRET`.
- Same path, `path_depth: 3` → last 3 components `ci/elastic-foo/bar` →
  `CI_ELASTIC_FOO_BAR_SECRET`.

## Runtime dependencies

`hooks/environment` shells out to:

- `vault` — unconditional (fetches the secret).
- `buildkite-agent` — unconditional (version check for redaction, and
  optionally `buildkite-agent redactor add`).
- `jq` — conditional: only invoked when `field` is **not** set (the whole
  secret is fetched as JSON via `vault kv get -format=json ... | jq -c
  .data`). When `field` **is** set, `jq` is not required.

All three are checked with `check_command` at the point of use and the hook
exits non-zero with a clear message if a required binary is missing.

## Retry behavior

The Vault fetch (`vault kv get ...`) is wrapped in `retry()`, which retries
up to `MAX_RETRIES=3` attempts total, with a 5-second sleep between failed
attempts. After the final failed attempt it prints `Command failed after 3
retries.` to stderr and exits non-zero. There is no configurable override for
retry count in `plugin.yml` today.

## Secret handling and redaction

- Before the secret value is read into a shell variable, the hook disables
  command tracing (`set +x`) so the value cannot leak into Buildkite's build
  log via `xtrace` output.
- `buildkite-agent redactor add` is used to register the fetched secret with
  Buildkite's log redactor — but **only conditionally**. The gate is a
  version check (`check_buildkite_agent_version_for_redaction`): redaction
  registration requires `buildkite-agent` **>= 3.66.0** (the version in which
  the [agent redactor](https://buildkite.com/docs/agent/v3/cli-redactor) was
  introduced). If the running agent is older, the hook logs a warning to
  stderr and skips redactor registration — it does not fail the build.
- Separately from the redactor, the generated variable name convention
  (`_SECRET` suffix) also triggers Buildkite's own name-based log redaction,
  independent of the agent's redactor feature. Both mechanisms are in play;
  neither alone is guaranteed on every agent version, which is why the
  `_SECRET` suffix matters even when redactor registration is skipped.
- The plugin never persists the secret to disk; it only ever lives in an
  exported shell environment variable for the duration of the step.

## Local dev / test loop

There is currently no single documented command (no Makefile) that
reproduces the CI test/lint loop locally. The real, CI-verified test
coverage lives at `.buildkite/scripts/test-*.sh` (10 scripts, each asserting
a plugin-populated environment variable against an expected value) and is
run in CI as the "Unit tests" step group in `.buildkite/pipeline.yml`,
invoking the plugin against a real Vault path
(`secret/ci/elastic-vault-secrets-buildkite-plugin/test`). Lint/format
checks run via `.pre-commit-config.yaml` (`shellcheck`, `shfmt`, YAML/JSON
schema checks), invoked in CI through
`.buildkite/scripts/pre-commit.sh`.

Note: an open PR (#40) previously attempted to wire local dev tooling
(Makefile + docker-compose) but stalled on mocking Bash builtins for BATS
testing; see that PR and any linked follow-up issue for current status
before assuming a `make test` entry point exists.
