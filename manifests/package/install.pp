# == Define: st2::package::install
#
#  Defined type to manage download of st2 while package repo is being built
#
# === Parameters
#  [*title*] - Name of st2 package to install
#  [*version*] - Version of st2 package to install
#  [*revision*] - Revision of st2 package to install
#
# === Examples
#  st2::package::install { 'st2api':
#    version  => '0.6.0',
#    revision => '11',
#  }
#
define st2::package::install(
  $version  = undef,
  $revision = undef,
) {
  case $::osfamily {
    'Debian': {
      include ::st2::package::debian
      $_type = 'debs'
      $_version = $version ? {
        undef   => st2_latest_stable(),
        default => $version,
      }
      $_revision = $revision ? {
        undef   => st2_latest_stable_revision($_version, $_type),
        default => $revision,
      }
      # Temporary Hack while fixing build pipeline
      if $name =~ /client/ {
        $_package_version = "${_version}.${_revision}-1"
      } else {
        $_package_version = "${_version}-${_revision}"
      }
      Class["apt::update"] -> Package<| title == $name |>
    }
    'RedHat': {
      include ::st2::package::redhat
      $_type = 'rpms'
      $_version = $version ? {
        undef   => st2_latest_stable(),
        default => $version,
      }
      $_revision = $revision ? {
        undef   => st2_latest_stable_revision($_version, $_type),
        default => $revision,
      }
      # Temporary Hack while fixing build pipeline
      if $name =~ /client/ {
        $_package_version = "${_version}.${_revision}-1"
      } else {
        $_package_version = "${_version}-${_revision}"
      }
  
      $_package_version = "${_version}-${_revision}"
    }
    default: { fail("Class[st2::package]: $st2::notice::unsupported_os") }
  }

  package { $name:
    ensure => $_package_version,
  }
}
