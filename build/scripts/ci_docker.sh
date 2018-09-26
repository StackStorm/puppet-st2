#!/bin/bash
set -e
set -o xtrace

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

export TEST_NAME="$TEST_NAME"
echo $TEST_NAME

if [ ! -z "$UNIT_TEST" ]; then
  export CHECK="$CHECK"
  echo $CHECK
  export PUPPET_GEM_VERSION="$PUPPET_GEM_VERSION"
  echo $PUPPET_GEM_VERSION
  "$SCRIPT_DIR"/ci_docker_unit.sh
else
  "$SCRIPT_DIR"/ci_docker_integration.sh
fi
