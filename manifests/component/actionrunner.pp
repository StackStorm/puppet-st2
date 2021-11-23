# @summary Manages the <code>st2actionrunner</code> service.
#
# Normally this class is instantiated by +st2::profile::fullinstall+.
# However, advanced users can instantiate this class directly to configure
# and manage just the <code>st2actionrunner</code> service on a single node.
# Parameters for this class mirror the parameters in the st2 config.
#
# @see https://github.com/StackStorm/st2/blob/master/conf/st2.conf.sample#L337-L343
#
# @example Basic usage
#   include st2::component::actionrunner
#
# @example Customizing parameters
#   class { 'st2::component::actionrunner':
#   }
#
# @param enabled
#   Specify to enable sensor service.
# @param partition_provider
#   partition_provider for distribution strategy of sensors.
#   @see https://docs.stackstorm.com/reference/sensor_partitioning.html 
#
class st2::component::actionrunner (
  $actionrunner_workers   = $st2::actionrunner_workers,
  $ssh_key_location       = $st2::ssh_key_location,
  $conf_file              = $st2::conf_file,
  $actionrunner_services  = $st2::params::actionrunner_services
) inherits st2 {

  $_logger_config = $st2::syslog ? {
      true    => 'syslog',
      default => 'logging',
  }

  ## SSH
  ini_setting { 'ssh_key_stanley':
    ensure  => present,
    path    => $conf_file,
    section => 'system_user',
    setting => 'ssh_key_file',
    value   => $ssh_key_location,
    tag     => 'st2::config',
  }

  ## ActionRunner settings
  ini_setting { 'actionrunner_logging':
    ensure  => present,
    path    => $conf_file,
    section => 'actionrunner',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.actionrunner.conf",
    tag     => 'st2::config',
  }

  file { $st2::params::actionrunner_global_env_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('st2/etc/sysconfig/st2actionrunner.erb'),
    tag     => 'st2::config',
  }

  ## Resultstracker Settings (Part of Action Runner)
  ini_setting { 'resultstracker_logging':
    ensure  => present,
    path    => $conf_file,
    section => 'resultstracker',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.resultstracker.conf",
    tag     => 'st2::config',
  }

  ########################################
  ## Services
  service { $actionrunner_services:
    ensure => 'running',
    enable => true,
    tag    => 'st2::service',
  }

  ########################################
  ## Datastore keys
  class { 'st2::server::datastore_keys': }
}
