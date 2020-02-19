#!/bin/bash
set -e
set -o xtrace

TEST_NAME=docker_centos7
PUPPET_COLLECTION=puppet6
bundle exec rake "litmus:provision_list[$TEST_NAME]"
# provisioner: docker
# bundle exec bolt command run 'yum -y install wget' --inventoryfile inventory.yaml --targets='localhost*'

# provisioner: docker_exp
bundle exec bolt command run 'yum -y install wget' --inventoryfile inventory.yaml --targets='docker_nodes'
bundle exec rake "litmus:install_agent[$PUPPET_COLLECTION]"
bundle exec rake "litmus:install_module"
bundle exec rake "litmus:acceptance:parallel"
