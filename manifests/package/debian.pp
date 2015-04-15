# == Class: st2::package::debion
#
#  Helper class to install APT repository
#
# === Parameters
#  [*version*] - Version of st2 package to install
#
# === Examples
#  include ::st2::package::debian
class st2::package::debian {
  $_version = $::st2::version

  if !defined(Class['::apt']) {
    include ::apt
  }

  if $_version =~ /dev$/ {
    $_suite = "unstable"
  } else {
    $_suite = "stable"
  }

  apt::source { 'stackstorm':
    location    => 'https://downloads.stackstorm.net/deb/',
    release     => "${::lsbdistcodename}_${_suite}",
    repos       => 'main',
    include_src => false,
    key         => '6B8C7982',
    key_source  => 'https://downloads.stackstorm.net/deb/pubkey.gpg',
  }
}
