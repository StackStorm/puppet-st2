# == Class st2::profile::mongodb
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
class st2::profile::mongodb (
  $version     = $::st2::mongodb_version,
  $db_port     = $::st2::db_port,
  $db_name     = $::st2::db_nane,
  $db_password = $::st2::db_password,
) inherits st2 {
  include ::st2::params

  # if user specified a version of MongoDB they want to use, then use that
  # otherwise auto-determine the version to use (as of st2 v2.3 MongoDB = 3.2)
  if $version != undef {
    $mongodb_version = $version
  }
  else {
    $mongodb_version = '3.2'
  }

  if $db_password != undef {
    $mongo_db_password = $db_password
  }
  else {
    $mongo_db_password = $::st2::cli_password
  }

  if !defined(Class['::mongodb::server']) {
    class { '::mongodb::globals':
      manage_package_repo => true,
      version             => $mongodb_version,
      bind_ip             => '127.0.0.1',
    }->
    class { '::mongodb::server':
      auth           => true,
      create_admin   => true,
      admin_username => 'admin',
      admin_password => $mongo_db_password,
    }->
    class { '::mongodb::client': }

    mongodb::db { $::st2::db_name:
      user     => 'stackstorm',
      password => $mongo_db_password,
    }
  }

}
