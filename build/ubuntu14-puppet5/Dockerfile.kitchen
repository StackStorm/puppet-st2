# usage (from the root of the puppet-st2/ directory):
# docker build -t stackstorm/puppet-st2-ubuntu14-puppet5 -f build/ubuntu14-puppet5/Dockerfile.kitchen .

FROM stackstorm/packagingtest:trusty-upstart

# kitchen setup
RUN mkdir -p /var/run/sshd
RUN useradd -d /home/<%= @username %> -m -s /bin/bash <%= @username %>
RUN echo '<%= @username %> ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN mkdir -p /home/<%= @username %>/.ssh
RUN chown -R <%= @username %> /home/<%= @username %>/.ssh
RUN chmod 0700 /home/<%= @username %>/.ssh
RUN touch /home/<%= @username %>/.ssh/authorized_keys
RUN chown <%= @username %> /home/<%= @username %>/.ssh/authorized_keys
RUN chmod 0600 /home/<%= @username %>/.ssh/authorized_keys
RUN echo '<%= IO.read(@public_key).strip %>' >> /home/<%= @username %>/.ssh/authorized_keys

# Due to issues with running apt-get during 'docker build' on Ubuntu 14,
# we need to install Puppet once the container has started.
# Do NOT run the following install commands on Ubuntu14, instead let kitchen-puppet
# install Puppet after the container is built.

# # install puppet
# # https://puppet.com/docs/puppet/5.5/puppet_platform.html#apt-based-systems
# RUN wget https://apt.puppetlabs.com/puppet5-release-trusty.deb
# RUN sudo dpkg -i puppet5-release-trusty.deb
# RUN sudo apt-get update
# RUN sudo apt-get -y install puppet-agent
# RUN sudo apt-get clean

# # put puppet in our path
# ENV PATH="/opt/puppetlabs/bin:${PATH}"
# RUN ln -s /opt/puppetlabs/bin/facter /usr/bin/
# RUN ln -s /opt/puppetlabs/bin/hiera /usr/bin/
# RUN ln -s /opt/puppetlabs/bin/mco /usr/bin/
# RUN ln -s /opt/puppetlabs/bin/puppet /usr/bin/

# # print versions (ruby 2.4.x, puppet 5.x)
# RUN puppet --version
# RUN sudo -E puppet --version
