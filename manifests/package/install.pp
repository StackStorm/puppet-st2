define st2::package::install(
  $version     = undef,
  $revision    = undef,
) {

  if $revision {
    $_revision = $revision
  } else {
    $_revision = st2_current_revision($version, $_type)
  }

  case $::osfamily {
    'Debian': {
      $_type     = 'debs'
      $_provider = 'dpkg'
      $_suffix   = "_${version}-${_revision}_amd64.deb"
    }
    'RedHat': {
      $_type     = 'rpm'
      $_provider = 'rpm'
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
