#!/bin/sh
set -e
set -o xtrace

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $SCRIPT_DIR
export TEST_NAME="$TEST_NAME"
echo $TEST_NAME

if [ ! -z "$UNIT_TEST" ]; then
  "$SCRIPT_DIR"/ci_docker_unit.sh
else
  "$SCRIPT_DIR"/ci_docker_integration.sh
fi
