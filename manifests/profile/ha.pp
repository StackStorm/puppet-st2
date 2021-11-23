# @summary Profile to install, configure and manage all server components for st2
#
# @example Basic usage
#  include st2::profile::ha
#
class st2::profile::ha (
) inherits st2 {

  contain st2::config::common

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
