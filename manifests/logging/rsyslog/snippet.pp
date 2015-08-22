# Definition: st2::logging::rsyslog::snippet
#
#  Loop to create logging/auditing routes for rsyslog
#
# Description
#
#  This defined type creates a rsyslog snippet for routing
#  the regular log files and the audit files to the right place.
#
# Usage
#
#  st2::logging::rsyslog::snippet { 'st2api': }
define st2::logging::rsyslog::snippet(
  $subsystem = $name,
) {
  include ::st2::params
  $_route = $::st2::params::component_map[$subsystem]

  if ! defined(Rsyslog::Snippet[$_route]) {
   ::rsyslog::snippet { $_route:
      content => template('st2/etc/rsyslog/snippet.erb'),
    }
  }
}
