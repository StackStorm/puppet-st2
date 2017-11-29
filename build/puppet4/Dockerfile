# usage (from the root of the puppet-st2/ directory):
# docker build -t stackstorm/puppet-st2-puppet4 -f build/puppet4/Dockerfile .

FROM stackstorm/packagingtest:centos7-systemd

# RUN mkdir -p /var/run/sshd
# RUN useradd -d /home/<%= @username %> -m -s /bin/bash <%= @username %>
# RUN echo <%= "#{@username}:#{@password}" %> | chpasswd
# RUN echo '<%= @username %> ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# RUN mkdir -p /home/<%= @username %>/.ssh
# RUN chown -R <%= @username %> /home/<%= @username %>/.ssh
# RUN chmod 0700 /home/<%= @username %>/.ssh
# RUN touch /home/<%= @username %>/.ssh/authorized_keys
# RUN chown <%= @username %> /home/<%= @username %>/.ssh/authorized_keys
# RUN chmod 0600 /home/<%= @username %>/.ssh/authorized_keys
# RUN echo '<%= IO.read(@public_key).strip %>' >> /home/<%= @username %>/.ssh/authorized_keys

# install ruby and dependencies for gem install
RUN yum -y install gcc gcc-c++ make ruby ruby-devel rubygems
RUN gem install bundler

# install puppet
RUN yum -y install https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
RUN yum -y install puppet
ENV PATH="/opt/puppetlabs/bin:${PATH}"

# print versions (ruby 2.0.0, puppet 3.8.7)
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
ENV BUNDLE_GEMFILE=$APP_HOME/build/puppet4/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle
RUN cat $BUNDLE_GEMFILE
RUN bundle install
RUN cat $BUNDLE_GEMFILE.lock
