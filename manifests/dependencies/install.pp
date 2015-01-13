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
