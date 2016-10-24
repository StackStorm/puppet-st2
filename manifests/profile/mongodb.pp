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
    if $::osfamily == "RedHat" {
      class {'::mongodb::globals':
          manage_package_repo => true,}->
      class {'::mongodb::server': }->
      class {'::mongodb::client': }

    }else{
      class { '::mongodb::server': }
    }
  }

}
