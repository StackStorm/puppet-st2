# Class: st2::auth::standalone
#
#  Auth class to configure and setup Standalone Authentication
#
# Parameters:
#
# [*debug*] - Enable Debug (default: false)
# [*ssl*] - Enable SSL (default: false)
# [*ssl_cert*] - Path to SSL Certificate file
# [*ssl_key*] - Path to SSL Key file
# [*test_user*] - Flag to enable the test user (default: true)
# [*logging_file*] - Path to logging configuration file
# [*htpasswd_file*] - Path to htpasswd file
#
# Usage:
#
#  include ::st2::auth::standalone
#
#  class { 'st2::auth::standalone':
#    ssl      => true,
#    ssl_cert => '/etc/ssl/cert.crt',
#    ssl_key  => '/etc/ssl/cert.key',
#  }
class st2::auth::standalone(
  $debug         = false,
  $ssl           = false,
  $ssl_cert      = undef,
  $ssl_key       = undef,
  $test_user     = true,
  $logging_file  = '/etc/st2api/logging.conf',
  $htpasswd_file = '/etc/st2/htpasswd',
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
  $_auth_users = hiera_hash('st2::auth_users', {})
  $_cli_username = $::st2::cli_username
  $_cli_password = $::st2::cli_password

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
    value   => 'flat_file',
  }
  ini_setting { 'auth_backend_kwargs':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'backend_kwargs',
    value   => "{\"file_path\": \"${htpasswd_file}\"}",
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

  # System Users
  $_testuser_ensure = $test_user ? {
    true    => present,
    default => absent,
  }
  st2::auth_user { 'testu':
    ensure    => $_testuser_ensure,
    password => 'testp',
  }
  st2::auth_user { $_cli_username:
    password => $_cli_password,
  }

  if $test_user {
    notify { $::st2::notices::auth_test_user_enabled: }
  }

  # Automatically generate users from Hiera
  create_resources('st2::auth_user', $_auth_users)

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
