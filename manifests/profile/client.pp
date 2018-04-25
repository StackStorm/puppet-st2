# == Class: st2::profile::client
#
#  Profile to install all client libraries for st2
#
# === Parameters
#
#  [*base_url*]             - CLI config - Base URL lives
#  [*api_version*]          - CLI config - API Version
#  [*debug*]                - CLI config - Enable/Disable Debug
#  [*cache_token*]          - CLI config - True to cache auth token until it expires
#  [*silence_ssl_warnings*] - CLI Config - True to silence any SSL related warnings emitted by the client.
#  [*username*]             - CLI config - Auth Username
#  [*password*]             - CLI config - Auth Password
#  [*api_url*]              - CLI config - API URL
#  [*auth_url*]             - CLI config - Auth URL
#
# === Examples
#
#  include st2::profile::client
#
class st2::profile::client (
  $auth                 = $::st2::auth,
  $api_url              = $::st2::cli_api_url,
  $auth_url             = $::st2::cli_auth_url,
  $base_url             = $::st2::cli_base_url,
  $username             = $::st2::cli_username,
  $password             = $::st2::cli_password,
  $api_version          = $::st2::cli_api_version,
  $cacert               = $::st2::cli_cacert,
  $debug                = $::st2::cli_debug,
  $cache_token          = $::st2::cli_cache_token,
  $silence_ssl_warnings = $::st2::cli_silence_ssl_warnings,
) inherits ::st2 {

  # Setup st2client settings for Root user by default
  st2::client::settings { 'root':
    homedir              => '/root',
    auth                 => $auth,
    api_url              => $api_url,
    auth_url             => $auth_url,
    base_url             => $base_url,
    username             => $username,
    password             => $password,
    api_version          => $api_version,
    cacert               => $cacert,
    debug                => $debug,
    cache_token          => $cache_token,
    silence_ssl_warnings => $silence_ssl_warnings,
  }

  # Setup global environment variables:
  file { '/etc/profile.d/st2.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('st2/etc/profile.d/st2.sh.erb'),
  }
}
