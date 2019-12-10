# @summary Base class for st2 module. Used as top-level to set parameters via Hiera, this class does not need to be called directly.
#
# @param version
#   Version of StackStorm package to install (default = 'present')
#   See the package 'ensure' property:
#   https://puppet.com/docs/puppet/5.5/types/package.html#package-attribute-ensure
# @param repository
#   Release repository to enable. 'stable', 'unstable'
#   (default = 'stable')
# @param conf_dir
#   The directory where st2 configs are stored
# @param conf_file
#   The path where st2 config is stored
# @param use_ssl
#   Enable/Disable SSL for all st2 APIs
# @param ssl_dir
#   Directory where st2web will look for its SSL info.
#   (default: /etc/ssl/st2)
# @param ssl_cert
#   Path to the file where the StackStorm SSL cert will
#   be generated. (default: /etc/ssl/st2/st2.crt)
# @param ssl_key
#   Path to the file where the StackStorm SSL key will
#   be generated. (default: /etc/ssl/st2/st2.key)
# @param auth
#   Toggle to enable/disable auth (Default: true)
# @param auth_api_url
#   URL where StackStorm auth service will communicate
#   with the StackStorm API service
# @param auth_debug
#   Toggle to enable/disable auth debugging (Default: false)
# @param auth_mode
#   Auth mode, either 'standalone' or 'backend (default: 'standalone')
# @param auth_backend
#   Determines which auth backend to configure. (default: flat_file)
#   Available backends:
#   - flat_file
#   - keystone
#   - ldap
#   - mongodb
#   - pam
# @param auth_backend_config
#   Hash of parameters to pass to the auth backend
#   class when it's instantiated. This will be different
#   for every backend. Please see the corresponding
#   backend class to determine what the config options
#   should be.
# @param cli_base_url
#   CLI config - Base URL lives
# @param cli_api_version
#   CLI config - API Version
# @param cli_debug
#   CLI config - Enable/Disable Debug
# @param cli_cache_token
#   CLI config - True to cache auth token until expries
# @param cli_username
#   CLI config - Auth Username
# @param cli_password
#   CLI config - Auth Password
# @param cli_api_url
#   CLI config - API URL
# @param cli_auth_url
#   CLI config - Auth URL
# @param actionrunner_workers
#   Set the number of actionrunner processes to start
# @param packs
#   Hash of st2 packages to be installed
# @param index_url
#   Url to the StackStorm Exchange index file. (default undef)
# @param mistral_db_host
#   Hostname/IP of the Mistral Postgres database
# @param mistral_db_name
#   Database name of the Mistral Postgres database
# @param mistral_db_username
#   Username for authentication to the Mistral Postgres database
# @param mistral_db_password
#   Password for authentication to the Mistral Postgres database
# @param mistral_db_bind_ips
#   String of IPs (csv) that the Mistral Postgres database
#   will accept connections on (default: 127.0.0.1)
# @param syslog
#   Routes all log messages to syslog
# @param syslog_host
#   Syslog host. Default: localhost
# @param syslog_protocol
#   Syslog protocol. Default: udp
# @param syslog_port
#   Syslog port. Default: 514
# @param syslog_facility
#   Syslog facility. Default: local7
# @param ssh_key_location
#   Location on filesystem of Admin SSH key for remote runner
# @param db_host
#   Hostname to talk to st2 db
# @param db_port
#   Port for db server for st2 to talk to
# @param db_bind_ips
#   Array of bind IP addresses for MongoDB to listen on
# @param db_name
#   Name of db to connect to (default: 'st2')
# @param db_username
#   Username to connect to db with (default: 'stackstorm')
# @param db_password
#   Password for 'admin' and 'stackstorm' users in MongDB.
#   If 'undef' then use $cli_password
# @param mongodb_version
#   Version of MongoDB to install. If not provided it
#   will be auto-calcuated based on $version
#   (default: undef)
# @param mongodb_manage_repo
#   Set this to false when you have your own repositories
#   for MongoDB (default: true)
# @param mongodb_auth
#   Boolean determining if auth should be enabled for
#   MongoDB. Note: On new versions of Puppet (4.0+)
#   you'll need to disable this setting.
#   (default: true)
# @param nginx_manage_repo
#   Set this to false when you have your own repositories for nginx
#   (default: true)
# @param timersengine_enabled
#   Set to true if the st2timersengine service should be enabled
#   on this node (default: true)
# @param timersengine_timezone
#   The local timezone for this node. (default: 'America/Los_Angeles')
# @param scheduler_sleep_interval
#   How long (in seconds) to sleep between each action
#   scheduler main loop run interval. (default = 0.1)
# @param scheduler_gc_interval
#   How often (in seconds) to look for zombie execution requests
#   before rescheduling them. (default = 10)
# @param scheduler_pool_size
#   The size of the pool used by the scheduler for scheduling
#   executions. (default = 10)
# @param chatops_adapter
#   Adapter package(s) to be installed with npm. List of hashes.
# @param chatops_adapter_conf
#   Configuration parameters for Hubot adapter (hash)
# @param chatops_hubot_log_level
#   Logging level for hubot (string)
# @param chatops_hubot_express_port
#   Port that hubot operates on (integer or string)
# @param chatops_tls_cert_reject_unauthorized
#   Should hubot validate SSL certs
#   Set to 1 when using self signed certs
# @param chatops_hubot_name
#   Name of the bot in chat. Should be
#   properly quoted if it has special characters,
#   example: '"MyBot!"'
# @param chatops_hubot_alias
#   Character to trigger the bot at the
#   beginning of a message. Must be properly
#   quoted of it's a special character,
#   example: "'!'"
# @param chatops_api_key
#   API key generated by `st2 apikey create`
#   that hubot will use to post data back
#   to StackStorm.
#   (default: undef)
# @param chatops_st2_hostname
#   Hostname of the StackStorm instance
#   that chatops will connect to for
#   API and Auth. If unspecified it will
#   use the default in /opt/stackstorm/chatops/st2chatops.env
#   (default: undef)
# @param chatops_api_url
#   ChatOps config - API URL
# @param chatops_auth_url
#   ChatOps config - Auth URL
# @param chatops_web_url
#   Public URL of StackStorm instance.
#   used by chatops to offer links to
#   execution details in a chat.
#   If unspecified it will use the
#   default in /opt/stackstorm/chatops/st2chatops.env
#   (default: undef)
# @param nodejs_version
#   Version of NodeJS to install. If not provided it
#   will be auto-calcuated based on $version
#   (default: undef)
# @param nodejs_manage_repo
#   Set this to false when you have your own repositories
#   for NodeJS (default: true)
#
#
# @example Basic Usage
#   include st2
#
# @example Variables can be set in Hiera and take advantage of automatic data bindings:
#   st2::version: 2.10.1
#
# @example Customizing parameters
#   # best practice is to change default username/password
#   class { '::st2::params':
#     admin_username => 'st2admin',
#     admin_password => 'SuperSecret!',
#   }
#
#   class { '::st2':
#     version => '2.10.1',
#   }
#
# @example Different passwords for each database (MongoDB, RabbitMQ, Postgres)
#   class { '::st2':
#     # StackStorm user
#     cli_username        => 'st2admin',
#     cli_password        => 'SuperSecret!',
#     # MongoDB user for StackStorm
#     db_username         => 'admin',
#     db_password         => 'KLKfp9#!2',
#     # RabbitMQ user for StackStorm
#     rabbitmq_username   => 'st2',
#     rabbitmq_password   => '@!fsdf0#45',
#     # Postrgres user for Mistral
#     mistral_db_username => 'stackstorm',
#     mistral_db_password => 'FSDfcds#45w',
#   }
#
class st2(
  $version                  = 'present',
  $repository               = $::st2::params::repository,
  $conf_dir                 = $::st2::params::conf_dir,
  $conf_file                = "${::st2::params::conf_dir}/st2.conf",
  $use_ssl                  = $::st2::params::use_ssl,
  $ssl_dir                  = $::st2::params::ssl_dir,
  $ssl_cert                 = $::st2::params::ssl_cert,
  $ssl_key                  = $::st2::params::ssl_key,
  $auth                     = true,
  $auth_api_url             = "http://${::st2::params::hostname}:${::st2::params::api_port}",
  $auth_debug               = false,
  $auth_mode                = $::st2::params::auth_mode,
  $auth_backend             = $::st2::params::auth_backend,
  $auth_backend_config      = $::st2::params::auth_backend_config,
  $cli_base_url             = "http://${::st2::params::hostname}",
  $cli_api_version          = 'v1',
  $cli_debug                = false,
  $cli_cache_token          = true,
  $cli_silence_ssl_warnings = false,
  $cli_username             = $::st2::params::admin_username,
  $cli_password             = $::st2::params::admin_password,
  $cli_api_url              = "http://${::st2::params::hostname}:${::st2::params::api_port}",
  $cli_auth_url             = "http://${::st2::params::hostname}:${::st2::params::auth_port}",
  $actionrunner_workers     = $::st2::params::actionrunner_workers,
  $packs                    = {},
  $index_url                = undef,
  $mistral_db_host          = $::st2::params::hostname,
  $mistral_db_name          = $::st2::params::mistral_db_name,
  $mistral_db_username      = $::st2::params::mistral_db_username,
  $mistral_db_password      = $::st2::params::admin_password,
  $mistral_db_bind_ips      = $::st2::params::mistral_db_bind_ips,
  $syslog                   = false,
  $syslog_host              = 'localhost',
  $syslog_protocol          = 'udp',
  $syslog_port              = 514,
  $syslog_facility          = 'local7',
  $ssh_key_location         = '/home/stanley/.ssh/st2_stanley_key',
  $db_host                  = $::st2::params::hostname,
  $db_port                  = $::st2::params::mongodb_port,
  $db_bind_ips              = $::st2::params::mongodb_bind_ips,
  $db_name                  = $::st2::params::mongodb_st2_db,
  $db_username              = $::st2::params::mongodb_st2_username,
  $db_password              = $::st2::params::admin_password,
  $mongodb_version          = undef,
  $mongodb_manage_repo      = true,
  $mongodb_auth             = true,
  $ng_init                  = true,
  $datastore_keys_dir       = $::st2::params::datstore_keys_dir,
  $datastore_key_path       = "${::st2::params::datstore_keys_dir}/datastore_key.json",
  $nginx_manage_repo        = true,
  $rabbitmq_username        = $::st2::params::rabbitmq_username,
  $rabbitmq_password        = $::st2::params::rabbitmq_password,
  $rabbitmq_hostname        = $::st2::params::rabbitmq_hostname,
  $rabbitmq_port            = $::st2::params::rabbitmq_port,
  $rabbitmq_bind_ip         = $::st2::params::rabbitmq_bind_ip,
  $rabbitmq_vhost           = $::st2::params::rabbitmq_vhost,
  $timersengine_enabled     = $::st2::params::timersengine_enabled,
  $timersengine_timezone    = $::st2::params::timersengine_timezone,
  $scheduler_sleep_interval = $::st2::params::scheduler_sleep_interval,
  $scheduler_gc_interval    = $::st2::params::scheduler_gc_interval,
  $scheduler_pool_size      = $::st2::params::scheduler_pool_size,
  $chatops_adapter          = $::st2::params::chatops_adapter,
  $chatops_adapter_conf     = $::st2::params::chatops_adapter_conf,
  $chatops_hubot_log_level              = $::st2::params::hubot_log_level,
  $chatops_hubot_express_port           = $::st2::params::hubot_express_port,
  $chatops_tls_cert_reject_unauthorized = $::st2::params::tls_cert_reject_unauthorized,
  $chatops_hubot_name                   = $::st2::params::hubot_name,
  $chatops_hubot_alias                  = $::st2::params::hubot_alias,
  $chatops_api_key                      = undef,
  $chatops_st2_hostname                 = $::st2::params::hostname,
  $chatops_api_url                      = "https://${::st2::params::hostname}/api",
  $chatops_auth_url                     = "https://${::st2::params::hostname}/auth",
  $chatops_web_url                      = undef,
  $nodejs_version           = undef,
  $nodejs_manage_repo       = true,
) inherits st2::params {

  ########################################
  ## Control commands
  exec {'/usr/bin/st2ctl reload --register-all':
    tag         => 'st2::reload',
    refreshonly => true,
  }

  exec {'/usr/bin/st2ctl reload --register-configs':
    tag         => 'st2::register-configs',
    refreshonly => true,
  }
}
