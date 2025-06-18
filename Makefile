.PHONY: all lint pre-commit shellcheck clean

all: lint pre-commit shellcheck

lint:
	-docker compose run lint

pre-commit:
	-.buildkite/scripts/pre-commit.sh

shellcheck:
	-docker compose run shellcheck

clean:
	-docker compose \
		rm --force --stop
