# usage (from the root of the puppet-st2/ directory):
# docker build -t stackstorm/puppet-st2-ubuntu14 -f build/ubuntu14/Dockerfile .

FROM stackstorm/packagingtest:trusty-upstart

# RUN mkdir -p /var/run/sshd
# RUN useradd -d /home/<%= @username %> -m -s /bin/bash <%= @username %>
# RUN echo '<%= @username %> ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# RUN mkdir -p /home/<%= @username %>/.ssh
# RUN chown -R <%= @username %> /home/<%= @username %>/.ssh
# RUN chmod 0700 /home/<%= @username %>/.ssh
# RUN touch /home/<%= @username %>/.ssh/authorized_keys
# RUN chown <%= @username %> /home/<%= @username %>/.ssh/authorized_keys
# RUN chmod 0600 /home/<%= @username %>/.ssh/authorized_keys
# RUN echo '<%= IO.read(@public_key).strip %>' >> /home/<%= @username %>/.ssh/authorized_keys

# install ruby and dependencies for gem install
RUN sudo apt-get -y update
RUN sudo apt-get -y install ruby ruby-dev
RUN gem install bundler

# install puppet
RUN wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
RUN sudo dpkg -i puppetlabs-release-trusty.deb
RUN sudo apt-get -y update
RUN sudo apt-get -y install puppet=3.8.7-1puppetlabs1

# print versions (ruby 1.9.3, puppet 3.8.7)
RUN ruby --version
RUN gem --version
RUN bundle --version
RUN puppet --version

# create our working directory with the code from our repo in it
ENV APP_HOME /puppet_st2
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY . $APP_HOME

# use bundler to install our gems
ENV BUNDLE_GEMFILE=$APP_HOME/build/ubuntu14/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle
RUN cat $BUNDLE_GEMFILE
RUN bundle install
RUN cat $BUNDLE_GEMFILE.lock

# remove the deprecated 'templatedir' option from puppet config, otherwise
# the following warning is printed every time we invoke puppet:
# Warning: Setting templatedir is deprecated. See http://links.puppetlabs.com/env-settings-deprecations
#   (at /bundle/gems/puppet-3.8.7/lib/puppet/settings.rb:1139:in `issue_deprecation_warning')
# https://tickets.puppetlabs.com/browse/PUP-2566
RUN sudo sed -i '/templatedir=/d' /etc/puppet/puppet.conf
