# == Define: st2::dependencies::install
#
#  Defined type for Package resource to simulate a loop in lieu of future-parser
#
# === Parameters
#
#  [*package*] - Name of the package to install
#  [*version*] - Version of package to install
#  [*provider*] - Provider to use while installing the package
#
# === Examples
#
#  st2::dependencies::install { ['st2api', 'st2core']:
#    ensure => present,
#  }
#
define st2::dependencies::install(
  $package  = $name,
  $version  = present,
  $provider = undef,
) {
  if !defined(Package[$package]) {
    package { $package:
      ensure   => $version,
      provider => $provider,
    }
  }
}
