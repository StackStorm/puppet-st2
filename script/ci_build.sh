#!/usr/bin/env bash

bundle exec rake validate && bundle exec rake lint && bundle exec rake spec SPEC_OPTS='--format documentation'
