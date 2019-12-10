# @summary Helper class to route syslog messages when using rsyslog
#
# This class bootstraps a system configured with rsyslog
# and st2::syslog enabled to route messages to all the right
# places.
#
# @example Basic usage
#  include st2::logging::rsyslog
class st2::logging::rsyslog {
  file { '/etc/rsyslog.d/10-st2.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
    source => 'puppet:///modules/st2/etc/rsyslog.d/10-st2.conf',
  }
}
