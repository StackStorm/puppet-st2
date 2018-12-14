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
class st2::profile::repos(
  $repository   = $::st2::repository,
  $package_type = $::st2::params::package_type,
) inherits st2 {
  require ::packagecloud

  if $::osfamily == 'RedHat' {
    require ::epel
  }
  $_packagecloud_repo = "StackStorm/${repository}"
  packagecloud::repo { $_packagecloud_repo:
    type => $package_type,
  }

  # On ubuntu 14, the packagecloud repo addition corrupts the apt-cache...
  # this cleans it out and refreshes it
  if ($::osfamily == 'Debian' and
      versioncmp($::operatingsystemmajrelease, '14.04') == 0) {
    exec { 'Refresh apt-cache after packagecloud':
      command     =>  'rm -rf /var/lib/apt/lists/*; apt-get update',
      path        => ['/usr/bin/', '/bin/'],
      refreshonly => true,
      subscribe   => Packagecloud::Repo[$_packagecloud_repo],
    }
  }
}
