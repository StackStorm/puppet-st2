# == Class: st2::profile::python
#
# st2 compatable installation of Python and dependencies for use with
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
#  include st2::profile::python
#
class st2::profile::python {
  if $::osfamily == "RedHat" {
    package {'python27':
      ensure => 'latest'
    }
    package {'python27-virtualenv':
      ensure => 'latest'
    }
    package {'python27-devel':
      ensure => 'latest'
    }
  } else {
    if !defined(Class['::python']) {
      class { '::python':
        version    => 'system',
        pip        => true,
        dev        => true,
        virtualenv => true,
      }
    }
  }


}
