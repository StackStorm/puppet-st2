# == Class: st2::profile::mongodb
#
# st2 compatable installation of MongoDB and dependencies for use with
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
#  include st2::profile::mongodb
#
class st2::profile::mongodb {
  include '::st2::params'

  if !defined(Class['::mongodb::server']) {
    class { '::mongodb::server': }
  }

  $_mongodb_dependencies = $::osfamily ? {
    'Debian' => $::st2::params::debian_mongodb_dependencies,
    default  => undef,
  }

  if $_mongodb_dependencies {
    ::st2::dependencies::install { $_mongodb_dependencies: }
  }
}
