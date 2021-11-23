# @summary Manages the <code>st2garbagecollector</code> service.
#
# Normally this class is instantiated by +st2::profile::fullinstall+.
# However, advanced users can instantiate this class directly to configure
# and manage just the <code>st2garbagecollector</code> service on a single node.
# Parameters for this class mirror the parameters in the st2 config.
#
# @see https://github.com/StackStorm/st2/blob/master/conf/st2.conf.sample#L337-L343
#
# @example Basic usage
#   include st2::component::garbagecollector
#
# @example Customizing parameters
#   class { 'st2::component::garbagecollector':
#     partition_provider => 'name:hash, hash_ranges:0..1024|2048..3072|2147483648..MAX',
#   }
#
# @param partition_provider
#   partition_provider for distribution strategy of sensors.
#   @see https://docs.stackstorm.com/reference/sensor_partitioning.html 
#
class st2::component::garbagecollector (
  $conf_file          = $st2::conf_file,
  $garbagecollector_services = $st2::params::garbagecollector_services,
) inherits st2 {

  $_logger_config = $st2::syslog ? {
      true    => 'syslog',
      default => 'logging',
  }

  ## Sensor container Settings
  ini_setting { 'garbagecollector_logging':
    ensure  => present,
    path    => $conf_file,
    section => 'garbagecollector',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.garbagecollector.conf",
    tag     => 'st2::config',
  }

  ########################################
  ## Services
  service { $garbagecollector_services:
    ensure => 'running',
    enable => true,
    tag    => 'st2::service',
  }
}
