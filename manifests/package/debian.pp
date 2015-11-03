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
    location    => "${::st2::repo_base}/deb/",
    release     => "${::lsbdistcodename}_${_suite}",
    repos       => 'main',
    include_src => false,
    key         => '1E26DCC8B9D4E6FCB65CC22E40A96AE06B8C7982',
    key_source  => "${::st2::repo_base}/deb/pubkey.gpg",
  }
}
