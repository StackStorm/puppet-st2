# @summary Profile to install, configure and manage all server components for st2
#
# @example Basic usage
#  include st2::profile::ha::web
#
class st2::profile::ha::web (
) inherits st2::profile::ha {
  contain st2::component::web
  contain st2::component::api
  contain st2::component::auth
  contain st2::component::stream
}
