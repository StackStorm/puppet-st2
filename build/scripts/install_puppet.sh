#!/bin/sh

# install puppet
curl -sSL https://raw.githubusercontent.com/nmaludy/puppet-install-shell/master/install_puppet_6_agent.sh | sudo bash -s

# install librarian-puppet
sudo /opt/puppetlabs/puppet/bin/gem install librarian-puppet

# Install git
sudo yum -y install git

# Install puppet module dependencies
sudo -i bash -c "pushd /vagrant/build/centos7-puppet6 && /opt/puppetlabs/puppet/bin/librarian-puppet install --verbose --path=/etc/puppetlabs/code/modules"

# Create symlink for the st2/ puppet module in the Pupept code directory.
# This allows us to make changes locally, outside of the VM then automatically available
# within the VM so you can run `puppet agent -t` and it will just work!
#
# FYI the local puppet-st2/ directory is automatically mounted as /vagrant
#     inside the vagrant VM when it comes up, that's why we're linking /vagrant as st2/
sudo ln -s /vagrant /etc/puppetlabs/code/modules/st2
