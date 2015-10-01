# == Class: st2
#
#  Base class for st2 module. Used as top-level to set parameters via Hiera
#  This class does not need to be called directly
#
# === Parameters
#
#  [*version*]            - Version of StackStorm to install
#  [*revision*]           - Revision of StackStorm to install
#  [*autoupdate*]         - Automatically update to latest stable. (default: false)
#  [*mistral_git_branch*] - Tagged branch of Mistral to download/install
#  [*api_url*]            - URL where the StackStorm API lives (default: undef)
#  [*auth*]               - Toggle to enable/disable auth (Default: false)
#  [*auth_url*]           - URL where the StackStorm WebUI lives (default: undef)
#  [*flow_url*]           - URL Path where StackStorm Flow lives (default: undef)
#  [*cli_base_url*]       - CLI config - Base URL lives
#  [*cli_api_version*]    - CLI config - API Version
#  [*cli_debug*]          - CLI config - Enable/Disable Debug
#  [*cli_cache_token*]    - CLI config - True to cache auth token until expries
#  [*cli_username*]       - CLI config - Auth Username
#  [*cli_password*]       - CLI config - Auth Password
#  [*cli_api_url*]        - CLI config - API URL
#  [*cli_auth_url*]       - CLI config - Auth URL
#  [*global_env*]         - Globally set the environment variables for ST2 API/Auth
#                           Overwritten by local config or CLI arguments.
#  [*workers*]            - Set the number of actionrunner processes to start
#  [*ng_init*]            - [Experimental] Init scripts for services. Upstart ONLY
#  [*syslog*]             - Routes all log messages to syslog
#  [*syslog_host*]        - Syslog host. Default: localhost
#  [*syslog_protocol*]    - Syslog protocol. Default: udp
#  [*syslog_port*]        - Syslog port. Default: 514
#  [*syslog_facility*]    - Syslog facility. Default: local7
#  [*ssh_key_location*]   - Location on filesystem of Admin SSH key for remote runner
#
#  Variables can be set in Hiera and take advantage of automatic data bindings:
#
#  Example:
#    st2::version: 0.6.0
#    st2::revison: 11
#
class st2(
  $version            = '0.13.2',
  $revision           = '5',
  $autoupdate         = false,
  $mistral_git_branch = 'st2-0.13.1',
  $api_url                  = undef,
  $auth                     = true,
  $auth_url                 = undef,
  $auth_mode                = 'standalone',
  $flow_url                 = undef,
  $cli_base_url             = 'http://localhost',
  $cli_api_version          = 'v1',
  $cli_debug                = false,
  $cli_cache_token          = true,
  $cli_silence_ssl_warnings = false,
  $cli_username             = 'puppet',
  $cli_password             = fqdn_rand_string(32),
  $cli_api_url              = 'http://localhost:9101',
  $cli_auth_url             = 'http://localhost:9100',
  $global_env               = false,
  $workers                  = 8,
  $ng_init                  = false,
  $mistral_api_url          = undef,
  $mistral_api_port         = '8989',
  $syslog                   = false,
  $syslog_host              = 'localhost',
  $syslog_protocol          = 'udp',
  $syslog_port              = 514,
  $syslog_facility          = 'local7',
  $ssh_key_location         = '/home/stanley/.ssh/st2_stanley_key',
) {}
