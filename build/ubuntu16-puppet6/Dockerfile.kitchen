# usage (from the root of the puppet-st2/ directory):
# docker build -t stackstorm/puppet-st2-ubuntu16-puppet6 -f build/ubuntu16-puppet6/Dockerfile.kitchen .

FROM stackstorm/packagingtest:xenial-systemd

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

# update OS
RUN sudo apt-get -y update

# install puppet
# https://puppet.com/docs/puppet/6.0/puppet_platform.html
RUN wget https://apt.puppetlabs.com/puppet6-release-xenial.deb
RUN sudo dpkg -i puppet6-release-xenial.deb
RUN sudo apt-get -y update
RUN sudo apt-get -y install puppet-agent

# put puppet in our path
ENV PATH="/opt/puppetlabs/bin:${PATH}"
RUN ln -s /opt/puppetlabs/bin/facter /usr/bin/
RUN ln -s /opt/puppetlabs/bin/hiera /usr/bin/
RUN ln -s /opt/puppetlabs/bin/mco /usr/bin/
RUN ln -s /opt/puppetlabs/bin/puppet /usr/bin/

# print versions (ruby 2.5.x, puppet 6.x)
RUN puppet --version
RUN sudo -E puppet --version
