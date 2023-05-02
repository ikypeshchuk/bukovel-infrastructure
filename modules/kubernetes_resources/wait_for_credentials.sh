#!/bin/bash
set -e

KUBECONFIG_FILE="$1"
TIMEOUT_SECONDS="$2"

SECONDS_PASSED=0

while [ ! -f "${KUBECONFIG_FILE}" ]; do
  sleep 10
  SECONDS_PASSED=$((SECONDS_PASSED+10))
  if [ "${SECONDS_PASSED}" -ge "${TIMEOUT_SECONDS}" ]; then
    echo "Kubernetes credentials file not found after waiting for ${TIMEOUT_SECONDS} seconds"
    exit 1
  fi
done
