# @summary Generates a configuration file for the st2 CLI (st2client)
#
# @param name
#    OS-level username. Used to determine where the config file will be placed.
# @param user
#    See name
# @param homedir
#    Path to home directory of the user.
# @param auth
#    Is auth enabled or not.
# @param api_url
#    URL of the StackStorm API service
# @param auth_url
#    URL of the StackStorm Auth service
# @param base_url
#    Base URL for other StackStorm services
# @param username
#    Username for auth on the CLI
# @param password
#    Password for auth on the CLI
# @param disable_credentials
#    Prevents credentials (username, password) from being written to the config file
# @param api_version
#    Version of the StackStorm API
# @param cacert
#    Path to the SSL CA certficate for the StackStorm services
# @param debug
#    Enable debug mode
# @param cache_token
#    Enable cacheing authentication tokens until they expire
# @param silence_ssl_warnings
#    Enable silencing SSL warnings for self-signed certs
#
# @example Basic usage
#   st2::client::settings { 'john':
#     username => 'st2_john',
#     password => 'xyz123',
#   }
#
define st2::client::settings(
  $user                 = $name,
  $homedir              = "/home/${name}",
  $auth                 = $st2::auth,
  $api_url              = $st2::cli_api_url,
  $auth_url             = $st2::cli_auth_url,
  $base_url             = $st2::cli_base_url,
  $username             = $st2::cli_username,
  $password             = $st2::cli_password,
  $disable_credentials  = false,
  $api_version          = $st2::cli_api_version,
  $cacert               = $st2::cli_cacert,
  $debug                = $st2::cli_debug,
  $cache_token          = $st2::cli_cache_token,
  $silence_ssl_warnings = $st2::cli_silence_ssl_warnings,
) {
  Ini_setting {
    ensure  => present,
    path    => "${homedir}/.st2/config",
    require => File["${homedir}/.st2"],
  }

  file { "${homedir}/.st2":
    ensure => directory,
    owner  => $user,
    mode   => '0700',
  }

  ini_setting { "${user}-st2_cli_api_url":
    section => 'api',
    setting => 'url',
    value   => $api_url,
  }
  ini_setting { "${user}-st2_cli_general_base_url":
    section => 'general',
    setting => 'base_url',
    value   => $base_url,
  }
  ini_setting { "${user}-st2_cli_general_api_version":
    section => 'general',
    setting => 'api_version',
    value   => $api_version,
  }
  ini_setting { "${user}-st2_cli_general_cacert":
    section => 'general',
    setting => 'cacert',
    value   => $cacert,
  }

  $_cli_debug = $debug ? {
    true    => 'True',
    default => 'False',
  }
  ini_setting { "${user}-st2_cli_cli_debug":
    section => 'cli',
    setting => 'debug',
    value   => $_cli_debug,
  }
  $_cache_token = $cache_token ? {
    true    => 'True',
    default => 'False',
  }
  ini_setting { "${user}-st2_cli_cache_token":
    section => 'cli',
    setting => 'cache_token',
    value   => $_cache_token,
  }
  $_silence_ssl_warnings = $silence_ssl_warnings ? {
    true    => 'True',
    default => 'False',
  }
  ini_setting { "${user}-st2_general_silence_ssl_warnings":
    section => 'general',
    setting => 'silence_ssl_warnings',
    value   => $_silence_ssl_warnings,
  }
  if $auth {
    if ! $disable_credentials {
      ini_setting { "${user}-st2_cli_credentials_username":
        section => 'credentials',
        setting => 'username',
        value   => $username,
      }
      ini_setting { "${user}-st2_cli_credentials_password":
        section => 'credentials',
        setting => 'password',
        value   => $password,
      }
    }
    ini_setting { "${user}-st2_cli_auth_url":
      section => 'auth',
      setting => 'url',
      value   => $auth_url,
    }
  }
}
