#!/bin/bash

printf "BUILDKITE_REDACTED_VARS: %s\n\n" "$BUILDKITE_REDACTED_VARS"

VAR_SECRET="hello, VAR"
printf "VAR_SECRET: %s\n\n" "$VAR_SECRET"

VAR_1_SECRET="hello, VAR_1"
printf "VAR_1_SECRET: %s\n\n" "$VAR_1_SECRET"

VAR_2_SECRET="hello,
VAR_2"
printf "VAR_2_SECRET: %s\n\n" "$VAR_2_SECRET"
