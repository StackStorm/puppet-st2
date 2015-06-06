# == Class: st2
#
#  Base class for st2 module. Used as top-level to set parameters via Hiera
#  This class does not need to be called directly
#
# === Parameters
#
#  [*version*]            - Version of StackStorm to install
#  [*revision*]           - Revision of StackStorm to install
#  [*mistral_git_branch*] - Tagged branch of Mistral to download/install
#  [*api_url*]            - URL where the StackStorm API lives (default: undef)
#  [*auth*]               - Toggle to enable/disable auth (Default: false)
#  [*auth_url*]           - URL where the StackStorm WebUI lives (default: undef)
#  [*cli_base_url*]       - CLI config - Base URL lives
#  [*cli_api_version*]    - CLI config - API Version
#  [*cli_debug*]          - CLI config - Enable/Disable Debug
#  [*cli_cache_token*]    - CLI config - True to cache auth token until expries
#  [*cli_username*]       - CLI config - Auth Username
#  [*cli_password*]       - CLI config - Auth Password
#  [*cli_api_url*]        - CLI config - API URL
#  [*cli_auth_url*]       - CLI config - Auth URL
#
#  Variables can be set in Hiera and take advantage of automatic data bindings:
#
#  Example:
#    st2::version: 0.6.0
#    st2::revison: 11
#
class st2(
  $version            = '0.11.0',
  $revision           = undef,
  $mistral_git_branch = 'st2-0.9.0',
  $api_url            = undef,
  $auth               = true,
  $auth_url           = undef,
  $auth_mode          = 'standalone',
  $cli_base_url       = 'http://localhost',
  $cli_api_version    = 'v1',
  $cli_debug          = false,
  $cli_cache_token    = true,
  $cli_username       = 'puppet',
  $cli_password       = fqdn_rand_string(32),
  $cli_api_url        = 'http://localhost:9101',
  $cli_auth_url       = 'http://localhost:9100',
) { }
