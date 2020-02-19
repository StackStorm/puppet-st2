#!/bin/bash
set -e
set -o xtrace

# Tear down all targets in inventory.yml
bundle exec rake "litmus:tear_down"
