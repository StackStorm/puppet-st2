# Class: st2::auth::flat_file
#
#  Auth class to configure and setup Flat File (htpasswd) Authentication
#
# Parameters:
#
# [*htpasswd_file*] - Path to htpasswd file (default: /etc/st2/htpasswd)
#
# Usage:
#
#  # Instantiate via ::st2
#  class { '::st2':
#    auth_backend        => 'flat_file',
#    auth_backend_config => {
#      htpasswd_file => '/etc/something/htpasswd',
#    },
#  }
#
#  # Instantiate via Hiera
#  st2::auth_backend: "flat_file"
#  st2::auth_backend_config"
#    htpasswd_file: "/etc/something/htpasswd"
#
class st2::auth::flat_file(
  $htpasswd_file = $::st2::params::auth_htpasswd_file,
) inherits ::st2 {
  include ::st2::auth::common

  $_auth_users   = hiera_hash('st2::auth_users', {})
  $_cli_username = $::st2::cli_username
  $_cli_password = $::st2::cli_password

  file { $htpasswd_file:
    ensure => file,
    owner  => 'st2',
    group  => 'st2',
    mode   => '0600',
  }

  ini_setting { 'auth_backend':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'backend',
    value   => 'flat_file',
    tag     => 'st2::config',
  }
  ini_setting { 'auth_backend_kwargs':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'backend_kwargs',
    value   => "{\"file_path\": \"${htpasswd_file}\"}",
    tag     => 'st2::config',
  }

  # System Users
  st2::auth_user { $_cli_username:
    password => $_cli_password,
  }

  # Automatically generate users from Hiera
  create_resources('st2::auth_user', $_auth_users)

  ##############
  # Dependencies
  File[$htpasswd_file]
  -> Service<| title == 'st2auth' |>
}
