# == Class: st2::dependencies
#
# Private class used to install any and all system dependencies
# prior to installation
#
# Please do not call directly
#
# === Parameters
#
# This class takes no parameters
#
# === Variables
#
# This class takes no variables
#
class st2::dependencies {
  include '::st2::params'

  $_dependencies = $::osfamily ? {
    'Debian' => $::st2::params::debian_dependencies,
    'RedHat' => $::st2::params::redhat_dependencies,
    default  => undef,
  }

  st2::dependencies::install { $_dependencies: }
}
