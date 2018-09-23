#!/bin/bash
set -e
set -o xtrace

export CHECK="${CHECK:-syntax lint metadata_lint check:symlinks check:git_ignore check:dot_underscore check:test_file rubocop parallel_spec}"

bundle install --without system_tests
bundle exec rake $CHECK
