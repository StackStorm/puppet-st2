#!/bin/sh
set -e
set -o xtrace

export CHECK="${CHECK:-syntax lint metadata_lint check:symlinks check:git_ignore check:dot_underscore check:test_file rubocop parallel_spec}"

docker build -t stackstorm/puppet-st2-$TEST_NAME -f build/$TEST_NAME/Dockerfile .
docker run -dit --name stackstorm-puppet-st2-$TEST_NAME stackstorm/puppet-st2-$TEST_NAME
docker exec stackstorm-puppet-st2-$TEST_NAME bash -l -c "bundle exec rake $CHECK"
