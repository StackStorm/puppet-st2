# @summary Manages the <code>st2stream</code> service.
#
# Normally this class is instantiated by +st2::profile::fullinstall+.
# OR by +st2::profile::ha::web+
# However, advanced users can instantiate this class directly to configure
# and manage just the <code>st2stream</code> service on a single node.
# Parameters for this class mirror the parameters in the st2 config.
#
# @see https://github.com/StackStorm/st2/blob/master/conf/st2.conf.sample#L337-L343
#
# @example Basic usage
#   include st2::component::stream
#
# @param conf_file
#   Path to  st2 conf file
# @param stream_services
#   List of services for stream
#
class st2::component::stream (
  $conf_file                = $st2::conf_file,
  $stream_services = $st2::params::stream_services,
) inherits st2 {

  $_logger_config = $st2::syslog ? {
      true    => 'syslog',
      default => 'logging',
  }

  ## Stream Settings
  ini_setting { 'stream_logging':
    ensure  => present,
    path    => $conf_file,
    section => 'stream',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.stream.gunicorn.conf",
    tag     => 'st2::config',
  }

  ########################################
  ## Services
  service { $stream_services:
    ensure => 'running',
    enable => true,
    tag    => 'st2::service',
  }
}
