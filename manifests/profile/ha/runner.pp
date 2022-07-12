# @summary Profile to install, configure and manage actionrunner for st2
#
# @example Basic usage
#  include st2::profile::ha::runner
#
class st2::profile::ha::runner (
) inherits st2::profile::ha {
  contain st2::component::actionrunner
}
