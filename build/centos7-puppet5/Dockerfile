# usage (from the root of the puppet-st2/ directory):
# docker build -t stackstorm/puppet-st2-puppet5 -f build/puppet5/Dockerfile .

FROM stackstorm/packagingtest:centos7-systemd

# install ruby and dependencies for gem install
RUN yum -y install gcc gcc-c++ make which openssl
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.4.4"
RUN /bin/bash -l -c "rvm use 2.4.4 --default"
RUN /bin/bash -l -c "gem install bundler --no-rdoc --no-ri"

# install puppet
RUN yum -y install https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm
RUN yum -y install puppet-agent
ENV PATH="/opt/puppetlabs/bin:${PATH}"

# print versions (ruby 2.4.x, puppet 5.x)
RUN /bin/bash -l -c "ruby --version"
RUN /bin/bash -l -c "gem --version"
RUN /bin/bash -l -c "bundle --version"
RUN puppet --version

# create our working directory with the code from our repo in it
ENV APP_HOME /puppet_st2
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY . $APP_HOME

# use bundler to install our gems
ENV PUPPET_GEM_VERSION "~> 5.0"
ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle
RUN /bin/bash -l -c "bundle -v"
RUN /bin/bash -l -c "rm -f ${APP_HOME}/Gemfile.lock"
RUN /bin/bash -l -c "gem update --system"
RUN /bin/bash -l -c "gem --version"
RUN /bin/bash -l -c "bundle -v"
RUN cat $BUNDLE_GEMFILE
RUN /bin/bash -l -c "bundle install --without system_tests"
RUN cat $BUNDLE_GEMFILE.lock
