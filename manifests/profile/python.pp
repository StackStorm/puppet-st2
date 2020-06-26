# @summary StackStorm compatable installation of Python and dependencies.
#
# @example Basic Usage
#  include st2::profile::python
#
class st2::profile::python {
  if ($facts['os']['family'] == 'RedHat') and ($facts['os']['release']['major'] == '6') {
    package {'python27':
      ensure => present,
    }
    package {'python27-virtualenv':
      ensure => present,
    }
    package {'python27-devel':
      ensure => present,
    }
    exec {'install_pip27':
      path    => '/usr/bin:/usr/sbin:/bin:/sbin',
      command => 'easy_install-2.7 pip',
      require => Package['python27'],
    }
  } else {
    if !defined(Class['python']) {
      class { 'python':
        version    => 'system',
        pip        => present,
        dev        => true,
        virtualenv => present,
        provider   => 'pip',
      }
    }
  }
}
