# @summary Profile to install, configure and manage all client libraries for st2
#
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
# @example Basic Usage
#  include st2::profile::client
#
class st2::profile::client (
  $auth                 = $st2::auth,
  $api_url              = $st2::cli_api_url,
  $auth_url             = $st2::cli_auth_url,
  $stream_url           = $st2::cli_stream_url,
  $base_url             = $st2::cli_base_url,
  $username             = $st2::cli_username,
  $password             = $st2::cli_password,
  $api_version          = $st2::cli_api_version,
  $cacert               = $st2::cli_cacert,
  $debug                = $st2::cli_debug,
  $cache_token          = $st2::cli_cache_token,
  $silence_ssl_warnings = $st2::cli_silence_ssl_warnings,
) inherits st2 {

  # Setup st2client settings for Root user by default
  st2::client::settings { 'root':
    homedir              => '/root',
    auth                 => $auth,
    api_url              => $api_url,
    auth_url             => $auth_url,
    stream_url           => $stream_url,
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
