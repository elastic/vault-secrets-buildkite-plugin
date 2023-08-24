#!/bin/bash

EXPECTED_MESSAGE="Hello from Vault"

if [ -z "$TEST_MESSAGE_SECRET" ]; then
  echo "[ERROR] MESSAGE variable is empty or not defined."
  exit 1
fi

if [ "$TEST_MESSAGE_SECRET" == "$EXPECTED_MESSAGE" ]; then
  echo "Message is correct: $TEST_MESSAGE_SECRET"
  exit 0
else
  echo "[ERROR] Expected: $EXPECTED_MESSAGE - Got: $TEST_MESSAGE_SECRET"
  exit 1
fi
