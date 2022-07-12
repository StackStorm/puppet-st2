# @summary Manages the <code>st2auth</code> service.
#
# Normally this class is instantiated by +st2::profile::fullinstall+.
# OR by +st2::profile::ha::web+
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
#     st2auth_listen_ip   => '127.0.0.1',
#     st2auth_listen_port => '9200',
#   }
#
# @param conf_file
#   Path to  st2 conf file
# @param auth
#   Enable or disable auth (default: true)
# @param st2auth_listen_ip
#   IP to bind Auth server
# @param st2auth_listen_port
#   Port to bind Auth server
# @param auth_services
#   List of services for Auth
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
