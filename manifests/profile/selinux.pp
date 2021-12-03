# @summary Configure SELinux so that StackStorm services run properly
#
# @example Basic Usage
#  include st2::profile::selinux
#
class st2::profile::selinux inherits st2::params {
  # note: the selinux module downcases the mode in the fact
  if ( ($facts['os']['family'] == 'RedHat') and ($facts['os']['selinux']['current_mode'] == 'enforcing')) {
    if (Numeric($facts['os']['release']['major']) >= 8) { # package was renamed in el8
      $package_policycoreutils = 'policycoreutils-python-utils'
    }
    else {
      $package_policycoreutils = 'policycoreutils-python'
    }
    if !defined(Package[$package_policycoreutils]) {
      package { $package_policycoreutils:
        ensure => present,
      }
    }
      }
    }

    # nginx doesn't so we have to enable this here
    selinux::boolean {'st2 nginx httpd_can_network_connect':
      ensure => 'on',
      name   => 'httpd_can_network_connect',
    }

    # note: rabbitmq puppet module manages its own SELinux config
  }
}
