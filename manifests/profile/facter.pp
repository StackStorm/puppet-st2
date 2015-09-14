# == Class: st2::profile::facter
#
# setup custom fact locations
#
# === Parameters
#
#  This module contains no parameters
#
# === Variables
#
#  This module contains no variables
#
# === Examples
#
#  include st2::profile::facter
#
class st2::profile::facter {
  # The hackery is strong.  Not sure where else to hack this in.
  if $::osfamily == "RedHat" {
    file{'/etc/facter':
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0444'
    }

    file{'/etc/facter/facts.d':
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      require => File['/etc/facter']
    }
  }
}