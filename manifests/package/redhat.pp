# == Class: st2::package::redhat
#
#  Helper class to install RPM repository
#
# === Parameters
#  [*version*] - Version of st2 package to install
#
# === Examples
#  include ::st2::package::redhat
class st2::package::redhat (
  $version = $::st2::version,
) inherits st2 {
  $_os = downcase($::operatingsystem)
  $_osver = $::operatingsystemrelease

  if $version =~ /dev$/ {
    $_suite = "unstable"
  } else {
    $_suite = "stable"
  }

  yumrepo { 'stackstorm':
    ensure   => present,
    baseurl  => "https://downloads.stackstorm.net/rpm/${_os}/${_osver}/${_suite}",
    descr    => 'StackStorm RPM Repository',
    enabled  => 1,
    gpgcheck => 0,
  }
}
