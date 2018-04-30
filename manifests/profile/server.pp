# == Class: st2::profile::server
#
#  Profile to install all server components for st2
#
# === Parameters
#
#  [*version*]                - Version of StackStorm to install
#  [*auth*]                   - Toggle Auth
#  [*workers*]                - Set the number of actionrunner processes to
#                               start
#  [*st2api_listen_ip*]       - Listen IP for st2api process
#  [*st2api_listen_port*]     - Listen port for st2api process
#  [*st2auth_listen_ip*]      - Listen IP for st2auth process
#  [*st2auth_listen_port*]    - Listen port for st2auth process
#  [*syslog*]                 - Routes all log messages to syslog
#  [*syslog_host*]            - Syslog host.
#  [*syslog_protocol*]        - Syslog protocol.
#  [*syslog_port*]            - Syslog port.
#  [*syslog_facility*]        - Syslog facility.
#  [*ssh_key_location*]       - Location on filesystem of Admin SSH key for remote runner
#  [*db_username*]            - Username to connect to MongoDB with (default: 'stackstorm')
#  [*db_password*]            - Password for 'stackstorm' user in MongDB.
#  [*index_url*]              - Url to the StackStorm Exchange index file. (default undef)
#
# === Variables
#
#  [*_server_packages*] - Local scoped variable to store st2 server packages.
#                         Sources from st2::params
#  [*_conf_dir*]        - Local scoped variable config directory for st2.
#                         Sources from st2::params
#
# === Examples
#
#  include st2::profile::client
#

class st2::profile::server (
  $version                = $::st2::version,
  $auth                   = $::st2::auth,
  $workers                = $::st2::workers,
  $syslog                 = $::st2::syslog,
  $syslog_host            = $::st2::syslog_host,
  $syslog_port            = $::st2::syslog_port,
  $syslog_facility        = $::st2::syslog_facility,
  $syslog_protocol        = $::st2::syslog_protocol,
  $st2api_listen_ip       = '0.0.0.0',
  $st2api_listen_port     = '9101',
  $st2auth_listen_ip      = '0.0.0.0',
  $st2auth_listen_port    = '9100',
  $ssh_key_location       = $::st2::ssh_key_location,
  $ng_init                = $::st2::ng_init,
  $db_username            = $::st2::db_username,
  $db_password            = $::st2::db_password,
  $index_url              = $::st2::index_url,
) inherits st2 {
  include ::st2::notices
  include ::st2::params

  $_server_packages = $::st2::params::st2_server_packages
  $_conf_dir = $::st2::params::conf_dir

  $_enable_auth = $auth ? {
    true    => 'True',
    default => 'False',
  }
  $_logger_config = $syslog ? {
    true    => 'syslog',
    default => 'logging',
  }

  ########################################
  ## Packages
  if ($::osfamily == 'RedHat') and ($::operatingsystemmajrelease == '6') {
    package { 'libffi-devel':
      ensure => present,
      before => Package[$_server_packages],
    }
  }

  package { $_server_packages:
    ensure => $version,
    tag    => ['st2::packages', 'st2::server::packages'],
  }

  ensure_resource('file', '/opt/stackstorm', {
    'ensure' => 'directory',
    'owner'  => 'root',
    'group'  => 'root',
    'mode'   => '0755',
  })

  ensure_resource('file', '/var/run/st2', {
    'ensure' => 'directory',
    'owner'  => 'st2',
    'group'  => 'root',
    'mode'   => '0755',
    'tag'    => 'st2::server',
  })

  ########################################
  ## Config
  file { '/etc/st2':
    ensure => directory,
  }

  ## SSH
  ini_setting { 'ssh_key_stanley':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'system_user',
    setting => 'ssh_key_file',
    value   => $ssh_key_location,
    tag     => 'st2::config',
  }

  ## ActionRunner settings
  ini_setting { 'actionrunner_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'actionrunner',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.actionrunner.conf",
    tag     => 'st2::config',
  }

  ## API Settings
  ini_setting { 'api_listen_ip':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'api',
    setting => 'host',
    value   => $st2api_listen_ip,
    tag     => 'st2::config',
  }
  ini_setting { 'api_listen_port':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'api',
    setting => 'port',
    value   => $st2api_listen_port,
    tag     => 'st2::config',
  }
  ini_setting { 'api_allow_origin':
    ensure  => 'present',
    path    => '/etc/st2/st2.conf',
    section => 'api',
    setting => 'allow_origin',
    value   => '*',
    tag     => 'st2::config',
  }
  ini_setting { 'api_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'api',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.api.conf",
    tag     => 'st2::config',
  }

  ## Authentication Settings
  ini_setting { 'auth':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'enable',
    value   => $_enable_auth,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_listen_port':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'port',
    value   => $st2auth_listen_port,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_listen_ip':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'host',
    value   => $st2auth_listen_ip,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.auth.conf",
    tag     => 'st2::config',
  }

  ## Database settings
  ini_setting { 'database_username':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'database',
    setting => 'username',
    value   => $db_username,
    tag     => 'st2::config',
  }
  ini_setting { 'database_password':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'database',
    setting => 'password',
    value   => $db_password,
    tag     => 'st2::config',
  }

  ## Notifier Settings
  ini_setting { 'notifier_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'notifier',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.notifier.conf",
    tag     => 'st2::config',
  }

  ## Resultstracker Settings
  ini_setting { 'resultstracker_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'resultstracker',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.resultstracker.conf",
    tag     => 'st2::config',
  }

  ## Rules Engine Settings
  ini_setting { 'rulesengine_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'rulesengine',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.rulesengine.conf",
    tag     => 'st2::config',
  }

  ## Garbage collector Settings
  ini_setting { 'garbagecollector_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'garbagecollector',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.garbagecollector.conf",
    tag     => 'st2::config',
  }

  ## Sensor container Settings
  ini_setting { 'sensorcontainer_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'sensorcontainer',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.sensorcontainer.conf",
    tag     => 'st2::config',
  }

  ## Syslog Settings
  ini_setting { 'syslog_host':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'syslog',
    setting => 'host',
    value   => $syslog_host,
    tag     => 'st2::config',
  }
  ini_setting { 'syslog_protocol':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'syslog',
    setting => 'protocol',
    value   => $syslog_protocol,
    tag     => 'st2::config',
  }
  ini_setting { 'syslog_port':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'syslog',
    setting => 'port',
    value   => $syslog_port,
    tag     => 'st2::config',
  }
  ini_setting { 'syslog_facility':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'syslog',
    setting => 'facility',
    value   => $syslog_facility,
    tag     => 'st2::config',
  }

  ## Exchange config
  if $index_url {
    ini_setting { 'exchange_index_url':
      ensure  => present,
      path    => '/etc/st2/st2.conf',
      section => 'content',
      setting => 'index_url',
      value   => $index_url,
      tag     => 'st2::config',
    }
  }

  ########################################
  ## Services
  service { $::st2::params::st2_services:
    ensure   => 'running',
    enable   => true,
    loglevel => 'debug',
    tag      => 'st2::service',
  }

  ########################################
  ## st2 user (stanley)
  class { '::st2::stanley': }

  ########################################
  ## Datastore keys
  class { '::st2::server::datastore_keys': }

  ########################################
  ## Dependencies
  Package<| tag == 'st2::server::packages' |>
  -> Ini_setting<| tag == 'st2::config' |>
  ~> Service<| tag == 'st2::service' |>

  Package<| tag == 'st2::server::packages' |>
  -> Class['::st2::server::datastore_keys']
  -> Service<| tag == 'st2::service' |>

  Package<| tag == 'st2::server::packages' |>
  -> Class['::st2::stanley']
  -> Service<| tag == 'st2::service' |>

  Package<| tag == 'st2::server::packages' |>
  -> File<| tag == 'st2::server' |>
  -> Service<| tag == 'st2::service' |>

  Service<| tag == 'st2::service' |>
  ~> Exec<| tag == 'st2::reload' |>
}
