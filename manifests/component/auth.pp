# @summary Manages the <code>st2auth</code> service.
#
# Normally this class is instantiated by +st2::profile::fullinstall+.
# However, advanced users can instantiate this class directly to configure
# and manage just the <code>st2auth</code> service on a single node.
# Parameters for this class mirror the parameters in the st2 config.
#
# @see https://github.com/StackStorm/st2/blob/master/conf/st2.conf.sample#L337-L343
#
# @example Basic usage
#   include st2::component::auth
#
# @example Customizing parameters
#   class { 'st2::component::auth':
#     partition_provider => 'name:hash, hash_ranges:0..1024|2048..3072|2147483648..MAX',
#   }
#
# @param partition_provider
#   partition_provider for distribution strategy of sensors.
#   @see https://docs.stackstorm.com/reference/sensor_partitioning.html 
#
class st2::component::auth (
  $conf_file           = $st2::conf_file,
  $auth                = $st2::auth,
  $st2auth_listen_ip   = '0.0.0.0',
  $st2auth_listen_port = '9100',
  $auth_services       = $st2::params::auth_services,
) inherits st2 {

  $_enable_auth = $auth ? {
    true    => 'True',
    default => 'False',
  }

  $_logger_config = $st2::syslog ? {
      true    => 'syslog',
      default => 'logging',
  }

  ## Authentication Settings
  ini_setting { 'auth':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'enable',
    value   => $_enable_auth,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_listen_port':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'port',
    value   => $st2auth_listen_port,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_listen_ip':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'host',
    value   => $st2auth_listen_ip,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_logging':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.auth.gunicorn.conf",
    tag     => 'st2::config',
  }

  ########################################
  ## Services
  service { $auth_services:
    ensure => 'running',
    enable => true,
    tag    => 'st2::service',
  }
}
