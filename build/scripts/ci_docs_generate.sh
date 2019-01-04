#!/bin/bash
set -e
set -o xtrace

bundle install --without system_tests
# generate the docs, pass `--fail-on-warning` to YARD so that it errors out if there are warnings
bundle exec rake strings:generate[,,,,,,"--fail-on-warning"]
