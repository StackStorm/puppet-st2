# @summary Profile to install, configure and manage all NON HA server components for st2
#
# @example Basic usage
#  include st2::profile::ha::solo
#
class st2::profile::ha::solo (
) inherits st2::profile::ha {
  contain st2::component::timersengine
  contain st2::component::garbagecollector
}
