# @summary Configure SELinux so that StackStorm services run properly
#
# @example Basic Usage
#  include st2::profile::selinux
#
class st2::profile::selinux inherits st2::params {
  # note: the selinux module downcases the mode in the fact
  if ($facts['os']['family'] == 'RedHat') and ($facts['selinux_current_mode'] == 'enforcing') {
    if versioncmp($facts['os']['release']['major'], '8') >= 0 {
      $policycoreutils_package = 'policycoreutils-python-utils'
    }
    else {
      $policycoreutils_package = 'policycoreutils-python'
    }

    if !defined(Package[$policycoreutils_package]) {
      package { $policycoreutils_package:
        ensure => present,
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
