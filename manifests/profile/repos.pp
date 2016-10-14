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
  $package_type = $st2::params::package_type
) {
  require packagecloud

  if $::osfamily == "RedHat" {
    require epel
  }
  packagecloud::repo{"stackstorm/stable":
    type => $package_type
  }
}