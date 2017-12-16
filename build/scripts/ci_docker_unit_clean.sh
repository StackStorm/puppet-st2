#!/bin/sh
set -o xtrace

docker rm -f stackstorm-puppet-st2-$TEST_NAME &> /dev/null
docker images -q stackstorm/puppet-st2-$TEST_NAME | xargs --no-run-if-empty docker image rm
