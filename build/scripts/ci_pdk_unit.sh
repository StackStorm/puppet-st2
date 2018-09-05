#!/bin/bash
set -e
set -o xtrace

bundle exec rake $CHECK
