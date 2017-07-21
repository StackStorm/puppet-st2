# == Class st2::profile::nginx
#
# st2 compatable installation of nginx and dependencies for use with
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
#  include st2::profile::nginx
#
class st2::profile::nginx inherits st2 {

  package { 'nginx':
    ensure => 'installed'
  }

  service { 'nginx':
    ensure => 'running',
    enable => true,
  }
}
