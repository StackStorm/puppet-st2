define st2::dependencies::install(
  $package = $name,
) {
  if !defined(Package[$package]) {
    package { $package:
      ensure => present,
    }
  }
}
