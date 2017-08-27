#!/usr/bin/env bash

facter && \
  bundle exec rake validate && \
  bundle exec rake lint && \
  bundle exec rake spec SPEC_OPTS='--format documentation' && \
  if [ -z ${DISTRO} ]; then echo "Not running kitchenci because DISTRO not set"; else kitchen test ${DISTRO}; fi
