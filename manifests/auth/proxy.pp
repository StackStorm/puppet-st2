# Class: st2::auth::proxy
#
#  Auth class to configure and setup proxy authentication
#
# Parameters:
#
# [*debug*] - Enable Debug (default: false)
# [*logging_file*] - Path to logging configuration file
#
# Usage:
#
#  include ::st2::auth::proxy
#
class st2::auth::proxy (
  $debug         = false,
  $logging_file  = '/etc/st2api/logging.conf',
) {
  $_debug = $debug ? {
    true    => 'True',
    default => 'False',
  }
  $_api_url = $::st2::api_url

  ini_setting { 'auth_mode':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'mode',
    value   => 'proxy',
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
}
