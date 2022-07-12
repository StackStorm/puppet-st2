# @summary Profile to install, configure and manage sensorcontainer for st2
#
# @example Basic usage
#  include st2::profile::ha::sensor
#
class st2::profile::ha::sensor (
) inherits st2::profile::ha {
  contain st2::component::sensorcontainer
}
