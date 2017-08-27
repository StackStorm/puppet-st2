#!/usr/bin/env bash

facter && \
  bundle exec rake validate && \
  bundle exec rake lint && \
  bundle exec rake spec SPEC_OPTS='--format documentation' && \
  if [[ -n $DISTRO ]]; then \
    kitchen test ${DISTRO}; \
  else \
    echo "Not running kitchenci because DISTRO not set"; \
  fi; \
