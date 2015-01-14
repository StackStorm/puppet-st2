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
      $_type     = 'debs'
      $_provider = 'dpkg'
      if $revision {
        $_revision = $revision
      } else {
        $_revision = st2_current_revision($version, $_type)
      }
      $_suffix   = "_${version}-${_revision}_amd64.deb"
    }
    'RedHat': {
      $_type     = 'rpms'
      $_provider = 'rpm'
      if $revision {
        $_revision = $revision
      } else {
        $_revision = st2_current_revision($version, $_type)
      }
      $_suffix   = "-${version}-${_revision}.noarch.rpm"
    }
    default: { fail("Class[st2::package]: $st2::notice::unsupported_os") }
  }

  wget::fetch { "Download ${name}":
    source             => "https://ops.stackstorm.net/releases/st2/${version}/${_type}/${_revision}/${name}${_suffix}",
    cache_dir          => '/var/cache/wget',
    destination        => "/tmp/${name}${_suffix}",
    nocheckcertificate => true,
    before             => Package[$name],
  }

  package { $name:
    ensure   => present,
    source   => "/tmp/${name}${_suffix}",
    provider => $_provider,
  }
}
