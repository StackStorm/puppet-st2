# Class: st2::auth::pam
#
#  Auth class to configure and setup Standalone PAM Authentication
#
# Parameters:
#
# [*debug*] - Enable Debug (default: false)
# [*test_user*] - Flag to enable the test user (default: true)
# [*logging_file*] - Path to logging configuration file
# [*htpasswd_file*] - Path to htpasswd file
# Usage:
#
#  include ::st2::auth::pam
#
#  class { 'st2::auth::pam':
#    debug      => true,
#    ssl_cert => '/etc/ssl/cert.crt',
#    ssl_key  => '/etc/ssl/cert.key',
#  }
class st2::auth::pam(
  $debug         = false,
  $test_user     = true,
  $logging_file  = '/etc/st2api/logging.conf'
) {
  $_debug = $debug ? {
    true    => 'True',
    default => 'False',
  }
  $_api_url = $::st2::api_url
  $_auth_users = hiera_hash('st2::auth_users', {})
  $_cli_username = $::st2::cli_username
  $_cli_password = $::st2::cli_password

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
    value   => 'pam',
  }
  ini_setting { 'auth_debug':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'debug',
    value   => $_debug,
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
}
