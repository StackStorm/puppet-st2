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
    class { 'postgresql::server':
      listen_addresses => $db_listen_addresses,
    }

    postgresql::server::role { $db_username:
      password_hash => postgresql_password($db_username, $db_password),
      createdb      => true,
      before        => Postgresql::Server::Database[$db_name],
    }

    postgresql::server::database { $db_name:
      owner => $db_username,
    }
  }
}
