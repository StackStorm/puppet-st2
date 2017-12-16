#!/usr/bin/env bash

facter && \
  bundle exec rake validate && \
  bundle exec rake lint && \
  bundle exec rake spec SPEC_OPTS='--format documentation' && \
  if [[ -n $TEST_NAME ]]; then \
    kitchen test ${TEST_NAME}; \
  else \
    echo "Not running kitchenci because TEST_NAME not set"; \
  fi; \
