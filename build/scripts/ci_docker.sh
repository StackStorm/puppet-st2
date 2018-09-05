#!/bin/bash
set -e
set -o xtrace

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
echo "SCRIPT_DIR = $SCRIPT_DIR"

export TEST_NAME="$TEST_NAME"
echo "TEST_DIR = $TEST_NAME"

if [ ! -z "$UNIT_TEST" ]; then
  export CHECK="$CHECK"
  echo "CHECK = $CHECK"
  "$SCRIPT_DIR"/ci_docker_unit.sh
else
  "$SCRIPT_DIR"/ci_docker_integration.sh
fi
