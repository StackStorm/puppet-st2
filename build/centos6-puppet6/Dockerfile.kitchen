# usage (from the root of the puppet-st2/ directory):
# docker build -t stackstorm/puppet-st2-centos6 -f build/centos6-puppet6/Dockerfile.kitchen .

FROM stackstorm/packagingtest:centos6-sshd

RUN mkdir -p /var/run/sshd
RUN useradd -d /home/<%= @username %> -m -s /bin/bash <%= @username %>
RUN echo <%= "#{@username}:#{@password}" %> | chpasswd
RUN echo '<%= @username %> ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN mkdir -p /home/<%= @username %>/.ssh
RUN chown -R <%= @username %> /home/<%= @username %>/.ssh
RUN chmod 0700 /home/<%= @username %>/.ssh
RUN touch /home/<%= @username %>/.ssh/authorized_keys
RUN chown <%= @username %> /home/<%= @username %>/.ssh/authorized_keys
RUN chmod 0600 /home/<%= @username %>/.ssh/authorized_keys
RUN echo '<%= IO.read(@public_key).strip %>' >> /home/<%= @username %>/.ssh/authorized_keys

# upgrade the image, otherwise installing st2 package hangs
RUN yum -y upgrade

# install doc files (/usr/share/docs) when installing yum packages
# otherwise /usr/share/docs/st2/conf/nginx/st2.conf won't be present
# https://github.com/docker-library/docs/tree/master/centos#package-documentation
RUN sed -i '/nodocs/d' /etc/yum.conf

# install puppet
RUN yum -y install https://yum.puppet.com/puppet6/puppet6-release-el-6.noarch.rpm
RUN yum -y install puppet-agent
ENV PATH="/opt/puppetlabs/bin:${PATH}"
RUN ln -s /opt/puppetlabs/bin/facter /usr/bin/
RUN ln -s /opt/puppetlabs/bin/hiera /usr/bin/
RUN ln -s /opt/puppetlabs/bin/mco /usr/bin/
RUN ln -s /opt/puppetlabs/bin/puppet /usr/bin/

# print versions (ruby 2.5.x, puppet 6.x)
RUN puppet --version
RUN sudo -E puppet --version
