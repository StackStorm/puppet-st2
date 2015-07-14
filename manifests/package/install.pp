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
  $version     = undef,
  $revision    = undef,
) {

  case $::osfamily {
    'Debian': {
      include ::st2::package::debian

      $_type = 'debs'

      if $revision {
        $_revision = $revision
      } else {
        $_revision = st2_current_revision($version, $_type)
      }

      # Temporary Hack while fixing build pipeline
      if $name =~ /client/ {
        $_version = "${version}.${_revision}-1"
      } else {
        $_version = "${version}-${_revision}"
      }
      Class["apt::update"] -> Package<| title == $name |>
    }
    'RedHat': {
      include ::st2::package::redhat

      $_type = 'rpms'

      if $revision {
        $_revision = $revision
      } else {
        $_revision = st2_current_revision($version, $_type)
      }

      $_version = "${version}-${_revision}"
    }
    default: { fail("Class[st2::package]: $st2::notice::unsupported_os") }
  }

  package { $name:
    ensure => $_version,
  }
}
