# @summary Configure SELinux so that StackStorm services run properly
#
# @example Basic Usage
#  include st2::dependency::selinux
#
class st2::dependency::selinux inherits st2::params {
  # note: the selinux module downcases the mode in the fact
  if ( ($facts['os']['family'] == 'RedHat') and ($facts['os']['selinux']['current_mode'] == 'enforcing')) {
    if (Numeric($facts['os']['release']['major']) >= 8) { # package was renamed in el8
      if !defined(Package['policycoreutils-python-utils']) {
        package { 'policycoreutils-python-utils':
          ensure => present,
        }
      }
    }
    else {
      if !defined(Package['policycoreutils-python']) {
        package { 'policycoreutils-python':
          ensure => present,
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
