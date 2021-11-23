# @summary Manages the <code>st2sensorcontainer</code> service.
#
# Normally this class is instantiated by +st2::profile::fullinstall+.
# However, advanced users can instantiate this class directly to configure
# and manage just the <code>st2sensorcontainer</code> service on a single node.
# Parameters for this class mirror the parameters in the st2 config.
#
# @see https://github.com/StackStorm/st2/blob/master/conf/st2.conf.sample#L337-L343
#
# @example Basic usage
#   include st2::component::sensorcontainer
#
# @example Customizing parameters
#   class { 'st2::component::sensorcontainer':
#     partition_provider => 'name:hash, hash_ranges:0..1024|2048..3072|2147483648..MAX',
#   }
#
# @param partition_provider
#   partition_provider for distribution strategy of sensors.
#   @see https://docs.stackstorm.com/reference/sensor_partitioning.html 
#
class st2::component::sensorcontainer (
  $partition_provider       = $st2::sensor_partition_provider,
  $conf_file                = $st2::conf_file,
  $sensorcontainer_services = $st2::params::sensorcontainer_services,
) inherits st2 {

  $_logger_config = $st2::syslog ? {
      true    => 'syslog',
      default => 'logging',
  }

  ## Sensor container Settings
  ini_setting { 'sensorcontainer_logging':
    ensure  => present,
    path    => $conf_file,
    section => 'sensorcontainer',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.sensorcontainer.conf",
    tag     => 'st2::config',
  }

  ini_setting { 'sensorcontainer_partitioning':
    ensure  => present,
    path    => $conf_file,
    section => 'sensorcontainer',
    setting => 'partition_provider',
    value   => $partition_provider,
    tag     => 'st2::config',
  }

  file { $st2::params::sensorcontainer_global_env_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('st2/etc/sysconfig/st2sensorcontainer.erb'),
    tag     => 'st2::config',
  }


  ########################################
  ## Services
  service { $sensorcontainer_services:
    ensure => 'running',
    enable => true,
    tag    => 'st2::service',
  }
}
