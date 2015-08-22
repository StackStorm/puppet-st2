# Class: st2::logging::rsyslog
#
#  Helper class to route syslog messages when using rsyslog
#
# Description
#
#  This class bootstraps a system configured with rsyslog
#  and st2::syslog enabled to route messages to all the right
#  places.
#
#  The loop structure still uses old-school defined type
#  until we can assert that all systems are using Puppet 4 or
#  future-parser.
#
# Parameters
#
#  This class contains no parameters
#
# Usage
#
#  include ::st2::logging::rsyslog
class st2::logging::rsyslog inherits st2::params {
  $_subsystems = $::st2::params::subsystems
  ::st2::logging::rsyslog::snippet { $_subsystems: }
}
