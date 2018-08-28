#!/bin/sh
set -e
set -o xtrace

docker build -t stackstorm/puppet-st2-$TEST_NAME -f build/$TEST_NAME/Dockerfile .
docker run -dit --name stackstorm-puppet-st2-$TEST_NAME stackstorm/puppet-st2-$TEST_NAME
docker exec stackstorm-puppet-st2-$TEST_NAME bash -l -c "bundle exec rake validate"
docker exec stackstorm-puppet-st2-$TEST_NAME bash -l -c "bundle exec rake lint"
docker exec stackstorm-puppet-st2-$TEST_NAME bash -l -c "bundle exec rake spec SPEC_OPTS='--format documentation'"
