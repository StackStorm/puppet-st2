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
# note: This path is relative to the Gemfile setup above
#       We meed to place the bundler cache outside of this directory root.
#       Kitchen-puppet copies this whole directory tree into the
#       cotainer. If bundler installed gems into this directory tree
#       then it would consuime several 100 MBs of space.
#       Due to `inspec` testing, we need to use the `ssh` transport
#       and doing so slows down file copy.
#       So, large directory, plus slow copy means very slow testing.
#       Instead we simply can place the bundler cache outside of this
#       directory tree and avoid the slow copy propblems.
#bundle config --local path vendor/cache  # don't use local path anymore
bundle config --local path /tmp/puppet-st2/build/kitchen/vendor/cache
bundle install
bundle exec kitchen test --debug $TEST_NAME
