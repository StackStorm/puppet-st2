#!/bin/sh
set -e
set -o xtrace

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

docker build -t stackstorm/puppet-st2-$TEST_NAME -f build/$TEST_NAME/Dockerfile .
docker run -dit --name stackstorm-puppet-st2-$TEST_NAME stackstorm/puppet-st2-$TEST_NAME
docker exec stackstorm-puppet-st2-$TEST_NAME bash -l -c "bundle exec rake validate"
docker exec stackstorm-puppet-st2-$TEST_NAME bash -l -c "bundle exec rake lint"
docker exec stackstorm-puppet-st2-$TEST_NAME bash -l -c "bundle exec rake spec SPEC_OPTS='--format documentation'"

export BUNDLE_GEMFILE=build/kitchen/Gemfile
# don't put gems locally because then the copy of files into the docker image
# takes forever
#bundle config --local path ./vendor/cache
bundle install
bundle exec kitchen test --debug $TEST_NAME
