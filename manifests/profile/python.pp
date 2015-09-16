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
  if ($::osfamily == "RedHat") and ($operatingsystemmajrelease == '6') {
    package {'python27':
      ensure => 'latest'
    }
    package {'python27-virtualenv':
      ensure => 'latest'
    }
    package {'python27-devel':
      ensure => 'latest'
    }
    exec {'install_pip27':
      path        => '/usr/bin:/usr/sbin:/bin:/sbin',
      command     => 'easy_install-2.7 pip',
      require     => Package['python27']
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
