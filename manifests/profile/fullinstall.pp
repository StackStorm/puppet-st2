class st2::profile::fullinstall {
  class { '::st2::profile::python': }
  -> class { '::st2::profile::rabbitmq': }
  -> class { '::st2::profile::mongodb': }
  -> class { '::st2::profile::default_user': }
  -> class { '::st2::role::mistral': }
  -> class { '::st2::role::client': }
  -> class { '::st2::role::server': }
}
