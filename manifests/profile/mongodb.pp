# == Class st2::profile::mongodb
#
# st2 compatable installation of MongoDB and dependencies for use with
# StackStorm
#
# === Parameters
#
#  [*db_name*]     - Name of db to connect to
#  [*db_username*] - Username to connect to db with
#  [*db_password*] - Password for 'admin' and 'stackstorm' users in MongDB.
#                    If 'undef' then use $cli_password
#  [*db_port*]     - Port for db server for st2 to talk to
#  [*db_bind_ips*] - Array of bind IP addresses for MongoDB to listen on
#  [*version*]     - Version of MongoDB to install. If not provided it will be
#                    auto-calcuated based on $st2::version
#  [*manage_repo*] - Set this to false when you have your own repositories for mongodb
#  [*auth*]        - Boolean determining of auth should be enabled for
#                    MongoDB. Note: On new versions of Puppet (4.0+)
#                    you'll need to disable this setting.
#                    (default: $st2::mongodb_auth)
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
  $db_name     = $::st2::db_name,
  $db_username = $::st2::db_username,
  $db_password = $::st2::db_password,
  $db_port     = $::st2::db_port,
  $db_bind_ips = $::st2::db_bind_ips,
  $version     = $::st2::mongodb_version,
  $manage_repo = $::st2::mongodb_manage_repo,
  $auth        = $::st2::mongodb_auth,
) inherits st2 {

  # if the StackStorm version is 'latest' or >= 2.4.0 then use MongoDB 3.4
  # else use MongoDB 3.2
  if ($::st2::version == 'latest' or
      $::st2::version == 'present' or
      $::st2::version == 'installed' or
      versioncmp($::st2::version, '2.4.0') >= 0 {
    $_mongodb_version_default = '3.4'
  }
  else {
    $_mongodb_version_default = '3.2'
  }

  # if user specified a version of MongoDB they want to use, then use that
  # otherwise use the default version of mongo based off the StackStorm version
  $_mongodb_version = $version ? {
    undef   => $_mongodb_version_default,
    default => $version,
  }

  if !defined(Class['::mongodb::server']) {

    class { '::mongodb::globals':
      manage_package      => true,
      manage_package_repo => $manage_repo,
      version             => $_mongodb_version,
      bind_ip             => $db_bind_ips,
      manage_pidfile      => false, # mongo will not start if this is true
    }

    class { '::mongodb::client': }

    if $auth == true {
      class { '::mongodb::server':
        port           => $db_port,
        auth           => true,
        create_admin   => true,
        store_creds    => true,
        admin_username => $::st2::params::mongodb_admin_username,
        admin_password => $db_password,
      }
    }
    else {
      class { '::mongodb::server':
        port => $db_port,
      }
    }

    Class['mongodb::globals']
    -> Class['mongodb::client']
    -> Class['mongodb::server']

    case $::osfamily {
      'RedHat': {
        Package <| tag == 'mongodb' |> {
          ensure => 'present'
        }
      }
      'Debian': {
        #############
        # MongoDB module doens't ensure that the apt source is added prior to
        # the packages.
        # It also fails to ensure that apt-get update is run before trying
        # to install the packages.
        Apt::Source['mongodb'] -> Package<|tag == 'mongodb'|>
        Class['Apt::Update'] -> Package<|tag == 'mongodb'|>

        #############
        # MongoDB module doesn't pass the proper install options when using the
        # MongoDB repo on Ubuntu (Debian)
        Package <| tag == 'mongodb' |> {
          ensure          => 'present',
          install_options => ['--allow-unauthenticated'],
        }

        #############
        # Debian's mongodb doesn't create PID file properly, so we need to
        # create it and set proper permissions
        file { '/var/run/mongod.pid':
          ensure => file,
          owner  => 'mongodb',
          group  => 'mongodb',
          mode   => '0644',
          tag    => 'st2::mongodb::debian',
        }

        File <| title == '/var/lib/mongodb' |> {
          recurse => true,
          tag     => 'st2::mongodb::debian',
        }
        Package<| tag == 'mongodb' |>
        -> File<| tag == 'st2::mongodb::debian' |>
        -> Service['mongodb']
      }
      default: {
      }
    }

    # configure st2 database
    mongodb::db { $db_name:
      user     => $db_username,
      password => $db_password,
      roles    => $::st2::params::mongodb_st2_roles,
      require  => Class['::mongodb::server'],
    }
  }

}
