# usage (from the root of the puppet-st2/ directory):
# docker build -t stackstorm/puppet-st2-centos7 -f build/centos7/Dockerfile .

FROM stackstorm/packagingtest:centos7-systemd

# install ruby and dependencies for gem install
RUN yum -y install gcc gcc-c++ make ruby ruby-devel rubygems
RUN gem install bundler

# install puppet
RUN yum -y install https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
RUN yum -y install puppet

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
ENV BUNDLE_GEMFILE=$APP_HOME/build/centos7/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle
RUN cat $BUNDLE_GEMFILE
RUN bundle install
RUN cat $BUNDLE_GEMFILE.lock
