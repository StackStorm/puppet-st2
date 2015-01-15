# == Class: st2::profile::nodejs
#
# st2 compatable installation of NodeJS and dependencies for use with
# StackStorm
#
# === Parameters
#
#  This module contains no parameters
#
# === Variables
#
#  This module contains no variables
#
# === Examples
#
#  include st2::profile::nodejs
#
class st2::profile::nodejs {
  class { '::nodejs':
    proxy       => false,
    manage_repo => true,
    notify      => Exec['upgrade npm'],
  }

  package { 'bower':
    ensure   => present,
    provider => 'npm',
    require  => Class['::nodejs'],
  }
  package { 'gulp':
    ensure   => present,
    provider => 'npm',
    require  => Class['::nodejs'],
  }
}
