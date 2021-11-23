# @summary Profile to install, configure and manage all server components for st2
#
# @example Basic usage
#  include st2::profile::server
#
class st2::profile::server (
) inherits st2 {

  class { 'st2::config::common': }

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
  class { 'st2::stanley': }

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
