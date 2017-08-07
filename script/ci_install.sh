#!/usr/bin/env bash

ln -s $GEMFILE_LOCK Gemfile.lock
bundle install --without rake
