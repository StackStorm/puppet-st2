#!/bin/sh

docker build -t stackstorm/puppet-st2-$DISTRO -f $BUILD_PATH/Dockerfile .
docker run -dit --name stackstorm-puppet-st2-$DISTRO stackstorm/puppet-st2-$DISTRO
docker exec stackstorm-puppet-st2-$DISTRO bash -c "bundle exec rake validate"
docker exec stackstorm-puppet-st2-$DISTRO bash -c "bundle exec rake lint"
docker exec stackstorm-puppet-st2-$DISTRO bash -c "bundle exec rake spec SPEC_OPTS='--format documentation'"
