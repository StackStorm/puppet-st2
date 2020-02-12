#!/bin/bash
set -e
set -o xtrace

TEST_NAME=docker_centos7
PUPPET_COLLECTION=puppet5
bundle exec rake "litmus:provision_list[$TEST_NAME]"
bundle exec bolt command run 'yum -y install wget' --inventoryfile inventory.yaml --targets='localhost*'
bundle exec rake "litmus:install_agent[$PUPPET_COLLECTION]"
bundle exec rake "litmus:install_module"
bundle exec rake "litmus:acceptance:parallel"
