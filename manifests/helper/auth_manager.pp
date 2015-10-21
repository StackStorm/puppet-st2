# Class : st2::helper::auth_manager
#
#  This defined type is used to configure various kinds of auth plugins for st2
#
class st2::helper::auth_manager (
  $auth_mode      = $::st2::params::auth_mode,
  $auth_backend   = $::st2::params::auth_backend,
  $debug          = false,
  $syslog         = false,
  $backend_kwargs = undef,
) inherits st2::params {

  $_debug = $debug ? {
    true    => 'True',
    default => 'False',
  }
  $_api_url = $::st2::api_url
  $_st2_conf_file = $::st2::conf_file

  $_logger_config = $syslog ? {
    true    => 'syslog',
    default => 'logging',
  }
  $_st2_api_logging_file = "/etc/st2api/${_logger_config}.conf"
  $_st2_auth_logging_file = "/etc/st2auth/${_logger_config}.conf"

  # Casting here necessary for Ruby->Python boolean type.
  $_use_ssl = $::st2::use_ssl
  $_use_ssl_value = $_use_ssl ? {
    true    => 'True',
    default => 'False',
  }
  $_ssl_key = $::st2::ssl_key
  $_ssl_cert = $::st2::ssl_cert
  $_auth_users = hiera_hash('st2::auth_users', {})
  $_cli_username = $::st2::cli_username
  $_cli_password = $::st2::cli_password

  tag('st2::auth_manager')

  # Common settings for all auth backends
  ini_setting { 'auth_debug':
    ensure  => present,
    path    => "${_st2_conf_file}",
    section => 'auth',
    setting => 'debug',
    value   => $_debug,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_api_url':
    ensure  => present,
    path    => "${_st2_conf_file}",
    section => 'auth',
    setting => 'api_url',
    value   => $_api_url,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_mode':
    ensure  => present,
    path    => "${_st2_conf_file}",
    section => 'auth',
    setting => 'mode',
    value   => $auth_mode,
    tag     => 'st2::config',
  }

  if $auth_mode == 'standalone' {
    ini_setting { 'auth_backend':
      ensure  => present,
      path    => "${_st2_conf_file}",
      section => 'auth',
      setting => 'backend',
      value   => "${auth_backend}",
      tag     => 'st2::config',
    }
    ini_setting { 'auth_logging_file':
      ensure  => present,
      path    => "${_st2_conf_file}",
      section => 'auth',
      setting => 'logging',
      value   => "${_st2_auth_logging_file}",
      tag     => 'st2::config',
    }
    ini_setting { 'auth_ssl':
      ensure  => present,
      path    => "${_st2_conf_file}",
      section => 'auth',
      setting => 'use_ssl',
      value   => "${_use_ssl_value}",
      tag     => 'st2::config',
    }


# SSL Settings
    if $_use_ssl {
      if !$ssl_cert or !$ssl_key {
        fail('[st2::helper::auth_manager] Missing $ssl_cert or $ssl_key to enable SSL')
      }

      ini_setting { 'auth_ssl_cert':
        ensure  => present,
        path    => "${_st2_conf_file}",
        section => 'auth',
        setting => 'cert',
        value   => "${_ssl_cert}",
        tag     => 'st2::config',
      }
      ini_setting { 'auth_ssl_key':
        ensure  => present,
        path    => "${_st2_conf_file}",
        section => 'auth',
        setting => 'key',
        value   => "${_ssl_key}",
        tag     => 'st2::config',
      }
    }

    # Backend specific ini setttings

    case $auth_backend {
      'proxy', 'pam': {
        $_auth_backend_kwargs = undef
      }
      'mongodb': {
        $_db_host = $::st2::db_host
        $_db_port = $::st2::db_port
        $_db_name = $::st2::db_name
        $_kwargs  = {
          'db_host' => "${_db_host}",
          'db_port' => "${_db_port}",
          'db_name' => "${_db_name}",
        }

        # Use inline_template to use native JSON function
        $_auth_backend_kwargs = inline_template('<%= require "json"; @_kwargs.to_json %>')
      }
      default: {
        if $backend_kwargs {
          validate_hash($backend_kwargs)
          $_auth_backend_kwargs = inline_template('<%= require "json"; @backend_kwargs.to_json %>')
        }
      }
    }

    facter::fact { 'st2_auth_mode':
      value => $auth_mode,
    }
    facter::fact { 'st2_auth_backend':
      value => $_auth_backend,
    }

    # Only evaluate if kwargs are not undefined.
    if $_auth_backend_kwargs {
      ini_setting { 'auth_backend_kwargs':
        ensure  => present,
        path    => "${_st2_conf_file}",
        section => 'auth',
        setting => 'backend_kwargs',
        value   => "${_auth_backend_kwargs}",
        tag     => 'st2::config',
      }
    }
  } else {
    facter::fact { 'st2_auth_mode':
      value => $auth_mode,
    }
  }
}
