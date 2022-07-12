# @summary Manages the <code>st2api</code> service.
#
# Normally this class is instantiated by +st2::profile::fullinstall+.
# OR by +st2::profile::ha::web+
# However, advanced users can instantiate this class directly to configure
# and manage just the <code>st2api</code> service on a single node.
# Parameters for this class mirror the parameters in the st2 config.
#
# @see https://github.com/StackStorm/st2/blob/master/conf/st2.conf.sample#L337-L343
#
# @example Basic usage
#   include st2::component::api
#
# @example Customizing parameters
#   class { 'st2::component::api':
#     st2api_listen_ip   => '127.0.0.1',
#     st2api_listen_port => '9201',
#   }
#
# @param partition_provider
#   partition_provider for distribution strategy of sensors.
#   @see https://docs.stackstorm.com/reference/sensor_partitioning.html 
# @param conf_file
#   Path to  st2 conf file
# @param api_services
#   List of services for API
# @param st2api_listen_ip
#   IP to bind API server
# @param st2api_listen_port
#   Port to bind API server
#
class st2::component::api (
  $conf_file                = $st2::conf_file,
  $api_services = $st2::params::api_services,
  $st2api_listen_ip       = '0.0.0.0',
  $st2api_listen_port     = '9101',
) inherits st2 {

  $_logger_config = $st2::syslog ? {
      true    => 'syslog',
      default => 'logging',
  }

  ## API Settings
  ini_setting { 'api_listen_ip':
    ensure  => present,
    path    => $conf_file,
    section => 'api',
    setting => 'host',
    value   => $st2api_listen_ip,
    tag     => 'st2::config',
  }
  ini_setting { 'api_listen_port':
    ensure  => present,
    path    => $conf_file,
    section => 'api',
    setting => 'port',
    value   => $st2api_listen_port,
    tag     => 'st2::config',
  }
  ini_setting { 'api_allow_origin':
    ensure  => 'present',
    path    => $conf_file,
    section => 'api',
    setting => 'allow_origin',
    value   => '*',
    tag     => 'st2::config',
  }
  ini_setting { 'api_logging':
    ensure  => present,
    path    => $conf_file,
    section => 'api',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.api.gunicorn.conf",
    tag     => 'st2::config',
  }

  ########################################
  ## Services
  service { $api_services:
    ensure => 'running',
    enable => true,
    tag    => 'st2::service',
  }
}
