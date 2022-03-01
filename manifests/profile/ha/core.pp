# @summary Profile to install, configure and manage all core components for st2
#
# @example Basic usage
#  include st2::profile::ha::core
#
class st2::profile::ha::core (
) inherits st2::profile::ha {
  contain st2::component::notifier
  contain st2::component::rulesengine
  contain st2::component::scheduler
  contain st2::component::workflowengine
}
