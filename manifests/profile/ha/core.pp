# @summary Profile to install, configure and manage all server components for st2
#
# @example Basic usage
#  include st2::profile::server
#
class st2::profile::ha::core (
) inherits st2 {

  class { 'st2::config::common': }
  -> class { 'st2::config::db': }
  -> class { 'st2::config::messaging': }
  -> class { 'st2::config::coordination': }

  contain st2::component::notifier
  contain st2::component::rulesengine
  contain st2::component::scheduler
  contain st2::component::workflowengine

  ########################################
  ## Dependencies
  Package<| tag == 'st2::server::packages' |>
  -> Ini_setting<| tag == 'st2::config' |>
  ~> Service<| tag == 'st2::service' |>

  Package<| tag == 'st2::server::packages' |>
  -> File<| tag == 'st2::server' |>
  -> Service<| tag == 'st2::service' |>

  Service<| tag == 'st2::service' |>
  ~> Exec<| tag == 'st2::reload' |>
}
