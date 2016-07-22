# == Class: st2::profile::python
#
# Installation of st2 required repos
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
#  include st2::profile::repos
#
class st2::profile::repos {
  if $::osfamily == 'RedHat' {
    require epel

    if $::operatingsystemmajrelease == '6' {
      package{'ius-release':
        ensure          => 'installed',
        provider        => 'rpm',
        source          => 'https://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/ius-release-1.0-14.ius.centos6.noarch.rpm',
        install_options => '--nodeps',
        require         => Yumrepo['epel']
      }
    }
  }
}
