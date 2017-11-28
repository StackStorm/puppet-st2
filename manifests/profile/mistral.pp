# == Class: st2::profile::mistral
#
# This class installs OpenStack Mistral, a workflow engine that integrates with
# StackStorm. Has the option to manage a companion MySQL Server
#
# === Parameters
#  [*git_branch*]          - Tagged branch of Mistral to download/install
#  [*db_password*]         - Mistral user password in PostgreSQL
#  [*db_server*]           - Server hosting Mistral DB
#  [*db_database*]         - Database storing Mistral Data
#  [*db_max_pool_size*]    - Max DB Pool size for Mistral Connections
#  [*db_max_overflow*]     - Max DB overload for Mistral Connections
#  [*db_pool_recycle*]     - DB Pool recycle time
#  [*api_url*]             - URI of Mistral backend (e.x.: 127.0.0.1)
#  [*api_port*]            - Port of Mistral backend. Default: 8989
#  [*manage_service*]      - Manage the Mistral service. Default: true
#  [*api_service*]         - Run API in a separte service via gunicorn. Default: true
#  [*disable_executor*]    - Disables the executor subsystem. Default: false
#  [*disable_engine*]      - Disables the engine subsystem. Default: false
#
# === Examples
#
#  include st2::profile::mistral
#
#  class { '::st2::profile::mistral':
#    manage_postgresql   => true,
#    db_mistral_password => 'mistralpassword',
#  }
#
class st2::profile::mistral(
  $version     = $st2::version,
  $db_server   = '127.0.0.1',
  $db_name     = 'mistral',
  $db_username = 'mistral',
  $db_password = $st2::db_password,
) inherits st2 {
  include ::st2::params

  ### Mistral Variables ###
  $mistral_root = '/opt/stackstorm/mistral'
  $mistral_config = '/etc/mistral/mistral.conf'

  $_db_password = $db_password ? {
    undef   => $st2::cli_password,
    default => $db_password,
  }
  ### End Mistral Variables ###

  ### Mistral Packages ###
  if ($::osfamily == 'RedHat') and ($::operatingsystemmajrelease == '6') {
    package {'st2python':
      ensure => 'installed',
      before => Package[$st2::params::st2_mistral_packages],
    }
  }

  package { $st2::params::st2_mistral_packages:
    ensure => $version,
    tag    => ['st2::packages', 'st2::mistral::packages'],
  }
  ### End Mistral Packages ###

  ### Mistral Config ###
  ini_setting { 'database_connection':
    ensure  => present,
    path    => $mistral_config,
    section => 'database',
    setting => 'connection',
    value   => "postgresql://${db_username}:${_db_password}@${db_server}/${db_name}",
  }

  # TODO add extra config params
  # https://forge.puppet.com/puppetlabs/inifile
  # create_ini_settings()
  ### End Mistral Config ###

  ### Setup Mistral Database ###
  postgresql::server::role { $db_username:
    password_hash => postgresql_password($db_username, $_db_password),
    createdb      => true,
    before        => Postgresql::Server::Database[$db_name],
  }

  postgresql::server::database { $db_name:
    owner => $db_username,
  }

  if str2bool($::mistral_bootstrapped) != true {
    exec { 'setup mistral database':
      command     => "mistral-db-manage --config-file ${mistral_config} upgrade head",
      refreshonly => true,
      path        => ["${mistral_root}/bin"],
      require     => [Postgresql::Server::Role[$db_username],
                      Ini_Setting['database_connection']],
      subscribe   => Postgresql::Server::Database[$db_name],
      before      => File['/etc/facter/facts.d/mistral_bootstrapped.txt'],
      notify      => [Exec['populate mistral database'],
                      Service['mistral']],
    }

    exec { 'populate mistral database':
      command     => "mistral-db-manage --config-file ${mistral_config} populate",
      refreshonly => true,
      path        => ["${mistral_root}/bin"],
      subscribe   => Exec['setup mistral database'],
      before      => File['/etc/facter/facts.d/mistral_bootstrapped.txt'],
      notify      => Service['mistral'],
    }
  }
  ### End Mistral Database ###

  # Once everything is done, let the system know so we can avoid some future processing
  file { '/etc/facter/facts.d/mistral_bootstrapped.txt':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => 'mistral_bootstrapped=true',
  }

  ### Setup Mistral Service ###
  # this is a "meta-service" for mistral-server and mistral-api
  service { 'mistral':
    ensure => running,
    enable => true,
  }
  ### End Mistral Service ###


  ### Setup Dependencies ###

  # Setup refresh events on config change for mistral
  Ini_setting<| tag == 'mistral' |> ~> Service['mistral']

  # Setup dependencies between actions in this profile
  Package<| tag == 'st2::mistral::packages' |>
  -> Ini_setting <| tag == 'mistral' |>
  -> Postgresql::Server::Database[$db_name]
  -> File['/etc/facter/facts.d/mistral_bootstrapped.txt']
  -> Service['mistral']

  ### End Dependencies ###
}
