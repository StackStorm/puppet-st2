# @summary Class to configure authentication for StackStorm.
#
# StackStorn st2auth service provides a framework for authenticating with
# various sources. Plugins to this framework that provide authentication
# implementations are called 'backends'. This generic class can be used
# to configure the st2auth service and also instantiate a proper backend.
# The auth backend implementations are in the manifests/auth/ directory.
#
# @param backend
#    Determines which auth backend to configure. (default: flat_file)
#    Available backends:
#      * flat_file
#      * keystone
#      * ldap
#      * mongodb
#      * pam
# @param backend_config
#    Hash of parameters to pass to the backend class when it's instantiated.
#    This will be different for every backend.
#    Please see the corresponding backend class to determine what the config options should be.
# @param debug
#    Enable Debug (default: false)
# @param mode
#    Authentication mode, either 'standalone' or 'proxy' (default: standalone)
# @param use_ssl
#    Enable SSL (default: false)
# @param ssl_cert
#    Path to SSL Certificate file (default: '/etc/ssl/st2/st2.crt')
# @param ssl_key
#    Path to SSL Key file (default: '/etc/ssl/st2/st2.key')
#
# @example Basic usage (via st2)
#  class { 'st2':
#    auth_backend        => 'flat_file',
#    auth_backend_config => {
#      htpasswd_file => '/etc/something/htpasswd',
#    },
#  }
#
# @example Instantiate via Hiera
#  st2::auth_backend: "flat_file"
#  st2::auth_backend_config"
#    htpasswd_file: "/etc/something/htpasswd"
#
# @example Direct usage (default Flat File auth backend)
#  include st2::auth
#
# @example Direct usage to configure a specific auth backend
#  class { 'st2::auth':
#    backend  => 'mongodb',
#    backend_config => {
#      db_host => 'mongodb.stackstorm.net',
#    }
#    use_ssl  => true,
#    ssl_cert => '/etc/ssl/cert.crt',
#    ssl_key  => '/etc/ssl/cert.key',
#  }
#
class st2::auth (
  $backend        = $::st2::auth_backend,
  $backend_config = $::st2::auth_backend_config,
  $debug          = $::st2::auth_debug,
  $mode           = $::st2::auth_mode,
  $use_ssl        = $::st2::use_ssl,
  $ssl_cert       = $::st2::ssl_cert,
  $ssl_key        = $::st2::ssl_key,
) inherits st2 {

  if !defined(Class['st2::auth::common']) {
    class { 'st2::auth::common':
      debug    => $debug,
      mode     => $mode,
      use_ssl  => $use_ssl,
      ssl_cert => $ssl_cert,
      ssl_key  => $ssl_key,
    }
  }

  # instantiate a backend
  $_backend_class = $backend ? {
    'flat_file' => 'st2::auth::flat_file',
    'keystone'  => 'st2::auth::keystone',
    'ldap'      => 'st2::auth::ldap',
    'mongodb'   => 'st2::auth::mongodb',
    'pam'       => 'st2::auth::pam',
    default     => undef,
  }
  if $_backend_class == undef {
    fail("[st2::auth] Unknown backend: ${backend}")
  }
  if !defined(Class[$_backend_class]) {
    create_resources('class', {
      "${_backend_class}" => $backend_config,
    })
  }
}
