# == Class: st2::package::debion
#
#  Helper class to install APT repository
#
# === Parameters
#  [*version*] - Version of st2 package to install
#
# === Examples
#  include ::st2::package::debian
class st2::package::debian(
  $version   = $::st2::version,
  $repo_base = $::st2::repo_base,
  $repo_env  = $::st2::repo_env,
  ) {

  if !defined(Class['::apt']) {
    include ::apt
  }

  $_suite = $version ? {
    /dev$/  => 'unstable',
    default => 'stable',
  }

  case $repo_base {
    /^https:\/\/dl.bintray.com/: {
      $_repo_suffix = $repo_env ? {
        'staging' => '_staging',
        default   => undef,
      }

      $_location   = join([
        $repo_base,
        'stackstorm',
        "${::lsbdistcodename}${_repo_suffix}",
      ], '/')
      $_release    = $_suite
      $_key        = '8756C4F765C9AC3CB6B85D62379CE192D401AB61'
      $_key_source = 'https://bintray.com/user/downloadSubjectPublicKey?username=bintray'
    }
    default: {
      $_location   = 'https://downloads.stackstorm.com/deb/'
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
