# @summary Auth class to configure and setup Flat File (htpasswd) Authentication
#
# @param cli_username
#   CLI config - Auth Username
# @param cli_password
#   CLI config - Auth Password
# @param conf_file
#   The path where st2 config is stored
# @param htpasswd_file
#   Path to htpasswd file (default: /etc/st2/htpasswd)
#
# @example Instantiate via st2
#  class { '::st2':
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
class st2::auth::flat_file(
  $cli_username  = $::st2::cli_username,
  $cli_password  = $::st2::cli_password,
  $conf_file     = $::st2::conf_file,
  $htpasswd_file = $::st2::params::auth_htpasswd_file,
) inherits st2 {
  include st2::auth::common

  $_auth_users = hiera_hash('st2::auth_users', {})

  file { $htpasswd_file:
    ensure => file,
    owner  => 'st2',
    group  => 'st2',
    mode   => '0600',
  }

  ini_setting { 'auth_backend':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'backend',
    value   => 'flat_file',
    tag     => 'st2::config',
  }
  ini_setting { 'auth_backend_kwargs':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'backend_kwargs',
    value   => "{\"file_path\": \"${htpasswd_file}\"}",
    tag     => 'st2::config',
  }

  # System Users
  st2::auth_user { $cli_username:
    password => $cli_password,
  }

  # Automatically generate users from Hiera
  create_resources('st2::auth_user', $_auth_users)

  ##############
  # Dependencies
  File[$htpasswd_file]
  -> Service<| tag == 'st2::service' |>
}
