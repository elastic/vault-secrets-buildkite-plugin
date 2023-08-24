#!/bin/bash

EXPECTED_MESSAGE='"message": "Hello from Vault"'

if [ -z "$MESSAGE" ]; then
  echo "[ERROR] MESSAGE variable is empty or not defined."
  exit 1
fi

is_expected_message=$(echo "$MESSAGE" | grep -c "$EXPECTED_MESSAGE")

if [ "$is_expected_message" -eq 1 ]; then
  echo "Message is correct: $MESSAGE"
  exit 0
else
  echo "[ERROR] Expected: $EXPECTED_MESSAGE - Got: $MESSAGE"
  exit 1
fi
