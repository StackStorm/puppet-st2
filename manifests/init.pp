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
#
#  Variables can be set in Hiera and take advantage of automatic data bindings:
#
#  Example:
#    st2::version: 0.6.0
#    st2::revison: 11
#
class st2(
  $version            = '0.9.0',
  $revision           = undef,
  $mistral_git_branch = 'st2-0.9.0',
  $api_url            = "http://${::fqdn}:9101",
  $auth               = true,
  $auth_url           = "http://${::fqdn}:9100",
  $auth_mode          = 'standalone',
  $cli_username       = 'puppet',
  $cli_password       = fqdn_rand_string(32),
) { }
