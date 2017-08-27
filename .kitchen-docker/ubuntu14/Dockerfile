FROM stackstorm/packagingtest:trusty-upstart

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

RUN wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
RUN sudo dpkg -i puppetlabs-release-trusty.deb
RUN sudo apt-get -y update
RUN sudo apt-get -y install puppet=3.8.7-1puppetlabs1
