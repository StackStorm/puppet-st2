#!/bin/bash
set -e
set -o xtrace

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
echo $SCRIPT_DIR

if [ ! -z "$UNIT_TEST" ]; then
  export CHECK="$CHECK"
  echo $CHECK
  "$SCRIPT_DIR"/ci_pdk_unit.sh
else
  export TEST_NAME="$TEST_NAME"
  echo $TEST_NAME
  "$SCRIPT_DIR"/ci_docker_integration.sh
fi
