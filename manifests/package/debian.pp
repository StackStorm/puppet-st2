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
  $_repo_base = $::st2::repo_base
  $_repo_env = $::st2::repo_env

  if !defined(Class['::apt']) {
    include ::apt
  }

  $_suite = $_version ? {
    /dev$/  => 'unstable',
    default => 'stable',
  }

  case $_repo_base {
    /dl.bintray.com/: {
      $_repo_suffix = $_repo_env ? {
        'staging' => '_staging',
        default   => undef,
      }

      $_location   = join([
        $_repo_base,
        'stackstorm',
        "${::lsbdistcodename}${_repo_suffix}",
      ], '/')
      $_release    = $_suite
      $_key        = '' # TODO: Fill out
      $_key_source = '' # TODO: Fill out
    }
    default: {
      # download.stackstorm.com
      $_location   = "${_repo_base}/deb/"
      $_release    = "${::lsbdistcodename}_${_suite}"
      $_key        = '1E26DCC8B9D4E6FCB65CC22E40A96AE06B8C7982'
      $_key_source = "${_location}/pubkey.gpg"
    }
  }

  apt::source { 'stackstorm':
    location    => $_location,
    release     => $_release,
    repos       => 'main',
    include_src => false,
    key         => $_key,
    key_source  => $_key_source,
  }
}
