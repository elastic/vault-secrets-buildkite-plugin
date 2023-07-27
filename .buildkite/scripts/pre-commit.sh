#!/bin/bash

pre-commit run --from-ref origin/HEAD --to-ref HEAD --show-diff-on-failure
