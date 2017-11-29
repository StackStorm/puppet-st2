#!/bin/sh
docker rm -f stackstorm-puppet-st2-$DISTRO &> /dev/null
docker images -q stackstorm/puppet-st2-$DISTRO | xargs --no-run-if-empty docker image rm
