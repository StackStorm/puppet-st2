# Class: st2::auth::common
#
#  Class that contains all of the "common" settings for auth.
#
# Parameters:
#
# [*debug*]    - Enable Debug (default: false)
# [*mode*]     - Authentication mode, either 'standalone' or 'proxy'
#                (default: standalone)
# [*use_ssl*]  - Enable SSL (default: false)
# [*ssl_cert*] - Path to SSL Certificate file (default: '/etc/ssl/st2/st2.crt')
# [*ssl_key*]  - Path to SSL Key file (default: '/etc/ssl/st2/st2.key')
#
# Usage:
#
#   Don't use directly
#
class st2::auth::common (
  $debug    = $::st2::auth_debug,
  $mode     = $::st2::auth_mode,
  $use_ssl  = $::st2::use_ssl,
  $ssl_cert = $::st2::ssl_cert,
  $ssl_key  = $::st2::ssl_key,
) inherits ::st2 {

  $_debug = $debug ? {
    true    => 'True',
    default => 'False',
  }
  $_mode = $mode ? {
    'standalone' => 'standalone',
    'proxy'      => 'proxy',
    default      => undef,
  }
  if $_mode == undef {
    fail("[st2::auth] Unsupported mode: ${mode}")
  }
  $_use_ssl = $use_ssl ? {
    true    => 'True',
    default => 'False',
  }
  $_api_url = $::st2::api_url

  ini_setting { 'auth_mode':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'mode',
    value   => $_mode,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_debug':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'debug',
    value   => $_debug,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_ssl':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'use_ssl',
    value   => $_use_ssl,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_api_url':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'api_url',
    value   => $_api_url,
    tag     => 'st2::config',
  }

  # SSL Settings
  if $use_ssl {
    if !$ssl_cert or !$ssl_key {
      fail('[st2::auth] Missing $ssl_cert or $ssl_key to enable SSL')
    }

    ini_setting { 'auth_ssl_cert':
      ensure  => present,
      path    => '/etc/st2/st2.conf',
      section => 'auth',
      setting => 'cert',
      value   => $ssl_cert,
      tag     => 'st2::config',
    }
    ini_setting { 'auth_ssl_key':
      ensure  => present,
      path    => '/etc/st2/st2.conf',
      section => 'auth',
      setting => 'key',
      value   => $ssl_key,
      tag     => 'st2::config',
    }
  }
}
