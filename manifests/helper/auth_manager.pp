# Definition: st2::helper::auth_manager
#
#  This defined type is used to configure various kinds of auth plugins for st2
#
define st2::helper::auth_manager (
  $auth_mode = $st2::params::auth_mode,
  $auth_backend = $st2::params::auth_backend
  $debug = False,
  $test_user = True
) {
  $_debug = $debug ? {
    true    => 'True',
    default => 'False',
  }
  $_api_url = $::st2::api_url
  $_st2_conf_file = $::st2::conf_file
  $_st2_api_logging_file  = $::st2::api_logging_file
  $_use_ssl = $::st2::use_ssl
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
  }
  ini_setting { 'auth_api_url':
    ensure  => present,
    path    => "${_st2_conf_file}",
    section => 'auth',
    setting => 'api_url',
    value   => $_api_url,
  }
  ini_setting { 'auth_mode':
    ensure  => present,
    path    => "${_st2_conf_file}",
    section => 'auth',
    setting => 'mode',
    value   => $auth_mode,
  }

  if $auth_mode == 'standalone' {
    ini_setting { 'auth_backend':
      ensure  => present,
      path    => "${_st2_conf_file}",
      section => 'auth',
      setting => 'backend',
      value   => "${auth_backend}",
    }
    ini_setting { 'auth_logging_file':
      ensure  => present,
      path    => "${_st2_conf_file}",
      section => 'auth',
      setting => 'logging',
      value   => "${_st2_api_logging_file}",
    }
    ini_setting { 'auth_ssl':
      ensure  => present,
      path    => "${_st2_conf_file}",
      section => 'auth',
      setting => 'use_ssl',
      value   => "${_use_ssl}",
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
      }
      ini_setting { 'auth_ssl_key':
        ensure  => present,
        path    => "${_st2_conf_file}",
        section => 'auth',
        setting => 'key',
        value   => "${_ssl_key}",
      }
    }

    # Backend specific ini setttings

    $_auth_backend_kwargs = ''

    case $auth_backend {
      'proxy': {
        file { '/tmp/auth_backend_proxy':
          ensure => 'file',
          owner  => 'root',
          group  => 'root',
          mode   => '0644'
        }
      }
      'pam': {
        file { '/tmp/auth_backend_pam':
          ensure => 'file',
          owner  => 'root',
          group  => 'root',
          mode   => '0644'
        }
      }
      'mongodb': {
        file { '/tmp/auth_backend_mongodb':
          ensure => 'file',
          owner  => 'root',
          group  => 'root',
          mode   => '0644'
        }
        $_db_host = $::st2::db_host
        $_db_port = $::st2::db_port
        $_db_name = $::st2::db_name
        $_auth_backend_kwargs = "{\"db_host\": \"${_db_host}\", \"db_port\": \"${_db_port}\", \"db_name\": \"${_db_name}\"}"
      }
    }

    ini_setting { 'auth_backend_kwargs':
      ensure  => present,
      path    => "${_st2_conf_file}",
      section => 'auth',
      setting => 'backend_kwargs',
      value   => "${_auth_backend_kwargs}",
    }
  } else {
      notify{ 'auth mode is not standalone': }
  }
}
