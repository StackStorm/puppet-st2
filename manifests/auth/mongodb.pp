# Class: st2::auth::mongodb
#
#  Auth class to configure and setup MongoDB Based Authentication
#
# Parameters:
#
# [*debug*] - Enable Debug (default: false)
# [*db_host*] - MongoDB Host to connect to (default: 127.0.0.1)
# [*db_port*] - MongoDB Port to connect to (default: 27017)
# [*db_name*] - MongoDB DB storing credentials (default: st2auth)
# [*ssl*] - Enable SSL (default: false)
# [*ssl_cert*] - Path to SSL Certificate file
# [*ssl_key*] - Path to SSL Key file
# [*logging_file*] - Path to logging configuration file
#
# Usage:
#
#  include ::st2::auth::mongodb
#
#  class { 'st2::auth::mongodb':
#    db_host  => 'mongodb.stackstorm.net',
#    ssl      => true,
#    ssl_cert => '/etc/ssl/cert.crt',
#    ssl_key  => '/etc/ssl/cert.key',
#  }
class st2::auth::mongodb (
  $debug         = false,
  $db_host       = '127.0.0.1',
  $db_port       = '27017',
  $db_name       = 'st2auth',
  $ssl           = false,
  $ssl_cert      = undef,
  $ssl_key       = undef,
  $logging_file  = '/etc/st2api/logging.conf',
) {
  $_debug = $debug ? {
    true    => 'True',
    default => 'False',
  }
  $_ssl = $ssl ? {
    true    => 'True',
    default => 'False',
  }
  $_api_url = $::st2::api_url

  # Defaults for st2config to ensure service refresh propagates
  # anytime these values are changed. See profile/server.pp
  # for more info
  Ini_setting {
    tag => 'st2::config',
  }

  ini_setting { 'auth_mode':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'mode',
    value   => 'standalone',
  }
  ini_setting { 'auth_backend':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'backend',
    value   => 'mongodb',
  }
  ini_setting { 'auth_backend_kwargs':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'backend_kwargs',
    value   => "{\"db_host\": \"${db_host}\", \"db_port\": \"${db_port}\", \"db_name\": \"${db_name}\"}",
  }
  ini_setting { 'auth_debug':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'debug',
    value   => $_debug,
  }
  ini_setting { 'auth_ssl':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'use_ssl',
    value   => $_ssl,
  }
  ini_setting { 'auth_api_url':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'api_url',
    value   => $_api_url,
  }
  ini_setting { 'auth_logging_file':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'logging',
    value   => $logging_file,
  }

  # SSL Settings
  if $ssl {
    if !$ssl_cert or !$ssl_key {
      fail('[st2::auth::standalone] Missing $ssl_cert or $ssl_key to enable SSL')
    }

    ini_setting { 'auth_ssl_cert':
      ensure  => present,
      path    => '/etc/st2/st2.conf',
      section => 'auth',
      setting => 'cert',
      value   => $ssl_cert,
    }
    ini_setting { 'auth_ssl_key':
      ensure  => present,
      path    => '/etc/st2/st2.conf',
      section => 'auth',
      setting => 'key',
      value   => $ssl_key,
    }
  }
}
