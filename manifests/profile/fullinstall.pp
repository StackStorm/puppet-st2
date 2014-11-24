class st2::profile::fullinstall(
  $web = false,
) {
  class { '::st2::profile::python': }
  -> class { '::st2::profile::rabbitmq': }
  -> class { '::st2::profile::nodejs': }
  -> class { '::st2::profile::mongodb': }
  -> class { '::st2::stanley': }
  -> class { '::st2::role::mistral':
    manage_mysql => true,
  }
  -> class { '::st2::role::client': }
  -> class { '::st2::role::server': }

  if $web {
    class { '::st2::role::web': }
  }
}
