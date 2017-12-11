# usage (from the root of the puppet-st2/ directory):
# docker build -t stackstorm/puppet-st2-ubuntu16 -f build/ubuntu16/Dockerfile .

FROM stackstorm/packagingtest:xenial-systemd

# install ruby and dependencies for gem install
RUN sudo apt-get -y update
RUN sudo apt-get -y install ruby ruby-dev
RUN gem install bundler

# install puppet
RUN sudo apt-get -y install puppet

# print versions (ruby 2.3.1, puppet 3.8.5)
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
ENV BUNDLE_GEMFILE=$APP_HOME/build/ubuntu16/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle
RUN cat $BUNDLE_GEMFILE
RUN bundle install
RUN cat $BUNDLE_GEMFILE.lock
