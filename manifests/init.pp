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
#  [*repo_url*]           - The URL where the StackStorm project is hosted on GitHub
#  [*repo_env*]           - Specify the environment of package repo (production, staging)
#  [*conf_file*]          - The path where st2 config is stored
#  [*use_ssl*]            - Enable/Disable SSL for all st2 APIs
#  [*ssl_key*]            - The path to SSL key for all st2 APIs
#  [*ssl_cert*]           - The path to SSL cert for all st2 APIs
#  [*api_url*]            - URL where the StackStorm API lives (default: undef)
#  [*api_logging_file*]   - Path to st2 API logging file (default: /etc/st2api/logging.conf)
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
#  [*syslog*]             - Routes all log messages to syslog
#  [*syslog_host*]        - Syslog host. Default: localhost
#  [*syslog_protocol*]    - Syslog protocol. Default: udp
#  [*syslog_port*]        - Syslog port. Default: 514
#  [*syslog_facility*]    - Syslog facility. Default: local7
#  [*ssh_key_location*]   - Location on filesystem of Admin SSH key for remote runner
#  [*db_host*]            - Hostname to talk to st2 db
#  [*db_port*]            - Port for db server for st2 to talk to
#  [*db_name*]            - Name of db to connect to
#
#  Variables can be set in Hiera and take advantage of automatic data bindings:
#
#  Example:
#    st2::version: 0.6.0
#    st2::revison: 11
#
class st2(
  $version                  = '1.2.0',
  $revision                 = '8',
  $autoupdate               = false,
  $mistral_git_branch       = 'st2-1.2.0',
  $repo_base                = $::st2::params::repo_base,
  $repo_env                 = $::st2::params::repo_env,
  $conf_dir                 = $::st2::params::conf_dir,
  $conf_file                = "${::st2::params::conf_dir}/st2.conf",
  $use_ssl                  = false,
  $ssl_cert                 = '/etc/ssl/cert.crt',
  $ssl_key                  = '/etc/ssl/cert.key',
  $api_url                  = undef,
  $api_logging_file         = '/etc/st2api/logging.conf',
  $auth                     = true,
  $auth_url                 = undef,
  $api_logging_file         = '/etc/st2auth/logging.conf',
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
  $mistral_api_url          = undef,
  $mistral_api_port         = '8989',
  $mistral_api_service      = false,
  $syslog                   = false,
  $syslog_host              = 'localhost',
  $syslog_protocol          = 'udp',
  $syslog_port              = 514,
  $syslog_facility          = 'local7',
  $ssh_key_location         = '/home/stanley/.ssh/st2_stanley_key',
  $db_host                  = 'localhost',
  $db_port                  = '27017',
  $db_name                  = 'st2',
  $ng_init                  = true,
) inherits st2::params {}
