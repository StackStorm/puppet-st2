# Class: st2::auth::mongodb
#
#  Auth class to configure and setup MongoDB Based Authentication
#
# Parameters:
#
# [*backend*] - Determines which auth backend to configure. (default: flat_file)
#               Available backends:
#                 - flat_file
#                 - keystone
#                 - ldap
#                 - mongodb
#                 - pam
# [*backend_config*] - Hash of parameters to pass to the backend class when
#                      it's instantiated. This will be different for every backend
#                      Please see the corresponding backend class to determine
#                      what the config options should be.
# [*debug*] - Enable Debug (default: false)
# [*mode*] - Authentication mode, either 'standalone' or 'proxy'
#            (default: standalone)
# [*use_ssl*] - Enable SSL (default: false)
# [*ssl_cert*] - Path to SSL Certificate file (default: '/etc/ssl/st2/st2.crt')
# [*ssl_key*] - Path to SSL Key file (default: '/etc/ssl/st2/st2.key')
#
# Usage:
#
#  # Basic usage if you want to use Flat File auth
#  include ::st2::auth
#
#  # Utilize the this class to configure a specific auth backend
#  class { 'st2::auth':
#    backend  => 'mongodb',
#    backend_config => {
#      db_host => 'mongodb.stackstorm.net',
#    }
#    ssl      => true,
#    ssl_cert => '/etc/ssl/cert.crt',
#    ssl_key  => '/etc/ssl/cert.key',
#  }
class st2::auth (
  $backend        = $::st2::auth_backend,
  $backend_config = $::st2::auth_backend_config,
  $debug          = $::st2::auth_debug,
  $mode           = $::st2::auth_mode,
  $use_ssl        = $::st2::use_ssl,
  $ssl_cert       = $::st2::ssl_cert,
  $ssl_key        = $::st2::ssl_key,
) {
  $_debug = $debug ? {
    true    => 'True',
    default => 'False',
  }
  $_mode = $mode ? {
    'standalone' => 'standalone',
    'proxy'      => 'proxy',
    default      => fail("[st2::auth] Unsupported mode: ${mode}")
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

  # instantiate a backend
  $_backend_class = $backend ? {
    'flat_file' => '::st2::auth::flat_file',
    'keystone'  => '::st2::auth::keystone',
    'ldap'      => '::st2::auth::ldap',
    'mongodb'   => '::st2::auth::mongodb',
    'pam'       => '::st2::auth::pam',
    default     => fail("[st2::auth] Unknown backend: ${backend}"),
  }

  ensure_resources('class', $_backend_class, $backend_config)
}
