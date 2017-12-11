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
class st2::profile::postgresql(
  $db_name     = 'mistral',
  $db_username = 'mistral',
  $db_password = $st2::db_password,
  $db_listen_addresses = '127.0.0.1',
) inherits st2 {
  if !defined(Class['postgresql::server']) {
    if ($::osfamily == 'RedHat') and ($::operatingsystemmajrelease == '6') {
      class { '::postgresql::globals':
        version             => '9.4',
        manage_package_repo => true,
      }

      # Ugly hack, but sometimes this data directory is created (empty) before
      # initdb is run, causing the postgres-server service to fail to start
      # (only on CentOS 6).
      # The same thing is present in the bootstrap-el6.sh script from
      # st2 base.
      exec { 'Move postgres data directory on first install':
        command     => '/bin/mv /var/lib/pgsql/9.4/data /var/lib/pgsql/9.4/data.bck',
        refreshonly => true,
        subscribe   => Class['::postgresql::server::install'],
        before      => Class['::postgresql::server::initdb'],
      }
    }

    class { '::postgresql::server':
      listen_addresses => $db_listen_addresses,
    }
  }
}
