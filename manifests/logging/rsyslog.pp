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
# Parameters
#
#  This class contains no parameters
#
# Usage
#
#  include ::st2::logging::rsyslog
class st2::logging::rsyslog {
  file { '/etc/rsyslog.d/10-st2.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
    source => 'puppet:///modules/st2/etc/rsyslog.d/10-st2.conf',
  }
}
