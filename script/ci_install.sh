#!/usr/bin/env bash

ln -s $GEMFILE_LOCK Gemfile.lock
bundle install --without rake
gem install puppet_forge:2.2.6 r10k
r10k puppetfile install -v --moduledir=/tmp/modules --puppetfile=./Puppetfile
