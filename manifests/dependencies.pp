class st2::dependencies {
  include '::st2::params'

  $_dependencies = $::osfamily ? {
    'Debian' => $::st2::params::debian_dependencies,
    'RedHat' => $::st2::params::redhat_dependencies,
    default  => undef,
  }

  st2::dependencies::install { $_dependencies: }
}
