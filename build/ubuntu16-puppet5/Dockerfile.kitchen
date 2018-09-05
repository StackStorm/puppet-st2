# usage (from the root of the puppet-st2/ directory):
# docker build -t stackstorm/puppet-st2-ubuntu16-puppet5 -f build/ubuntu16-puppet5/Dockerfile.kitchen .

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
# https://puppet.com/docs/puppet/5.5/puppet_platform.html#apt-based-systems
RUN wget https://apt.puppetlabs.com/puppet5-release-xenial.deb
RUN sudo dpkg -i puppet5-release-xenial.deb
RUN sudo apt-get -y update
RUN sudo apt-get -y install puppet-agent

# put puppet in our path
ENV PATH="/opt/puppetlabs/bin:${PATH}"
RUN ln -s /opt/puppetlabs/bin/facter /usr/bin/
RUN ln -s /opt/puppetlabs/bin/hiera /usr/bin/
RUN ln -s /opt/puppetlabs/bin/mco /usr/bin/
RUN ln -s /opt/puppetlabs/bin/puppet /usr/bin/

# print versions (ruby 2.4.x, puppet 5.x)
RUN puppet --version
RUN sudo -E puppet --version
