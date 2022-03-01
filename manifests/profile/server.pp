# @summary Profile to install, configure and manage all server components for st2
#
# @example Basic usage
#  include st2::profile::server
#
class st2::profile::server (
  $version                = $st2::version,
  $conf_dir               = $st2::conf_dir,
  $conf_file              = $st2::conf_file,
  $auth                   = $st2::auth,
  $actionrunner_workers   = $st2::actionrunner_workers,
  $syslog                 = $st2::syslog,
  $syslog_host            = $st2::syslog_host,
  $syslog_port            = $st2::syslog_port,
  $syslog_facility        = $st2::syslog_facility,
  $syslog_protocol        = $st2::syslog_protocol,
  $st2api_listen_ip       = '127.0.0.1',
  $st2api_listen_port     = '9101',
  $st2auth_listen_ip      = '127.0.0.1',
  $st2auth_listen_port    = '9100',
  $ssh_key_location       = $st2::ssh_key_location,
  $ng_init                = $st2::ng_init,
  $db_username            = $st2::db_username,
  $db_password            = $st2::db_password,
  $rabbitmq_username      = $st2::rabbitmq_username,
  $rabbitmq_password      = $st2::rabbitmq_password,
  $rabbitmq_hostname      = $st2::rabbitmq_hostname,
  $rabbitmq_port          = $st2::rabbitmq_port,
  $rabbitmq_vhost         = $st2::rabbitmq_vhost,
  $redis_hostname         = $st2::redis_hostname,
  $redis_port             = $st2::redis_port,
  $redis_password         = $st2::redis_password,
  $index_url              = $st2::index_url,
  $packs_group            = $st2::packs_group_name,
  $validate_output_schema = $st2::validate_output_schema,
) inherits st2 {

  contain st2::config::common
  contain st2::config::db
  contain st2::config::messaging
  contain st2::config::coordination
  contain st2::config::runners

  contain st2::component::actionrunner
  contain st2::component::sensorcontainer
  contain st2::component::web
  contain st2::component::api
  contain st2::component::auth
  contain st2::component::stream

  contain st2::component::notifier
  contain st2::component::rulesengine
  contain st2::component::scheduler
  contain st2::component::timersengine
  contain st2::component::workflowengine
  contain st2::component::garbagecollector

  ########################################
  ## st2 user (stanley)
  contain st2::stanley

  ########################################
  ## Dependencies
  Package<| tag == 'st2::server::packages' |>
  -> Ini_setting<| tag == 'st2::config' |>
  ~> Service<| tag == 'st2::service' |>

  Package<| tag == 'st2::server::packages' |>
  -> Class['st2::server::datastore_keys']
  -> Service<| tag == 'st2::service' |>

  Package<| tag == 'st2::server::packages' |>
  -> Class['st2::stanley']
  -> Service<| tag == 'st2::service' |>

  Package<| tag == 'st2::server::packages' |>
  -> File<| tag == 'st2::server' |>
  -> Service<| tag == 'st2::service' |>

  Service<| tag == 'st2::service' |>
  ~> Exec<| tag == 'st2::reload' |>

  St2_pack<||>
  ~> Recursive_file_permissions<| tag == 'st2::server' |>
}
