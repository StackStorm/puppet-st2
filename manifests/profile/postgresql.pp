# == Class: st2::profile::postgresql
#
# st2 compatable installation of PostgreSQL and dependencies for use with
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
#  include st2::profile::postgresql
#
class st2::profile::postgresql {
  if !defined(Class['::postgresql::server']) {
    class { '::postgresql::server': }
  }
}
