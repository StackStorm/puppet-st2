# Definition: st2::auth_user
#
#  Creates and manages StackStorm application users (flat_file auth only)
#
# Usage
#
#  st2::auth_user { 'st2admin':
#    password => 'neato!',
#  }
#
define st2::auth_user(
  $ensure   = present,
  $password = undef,
) {
  include ::st2::auth::flat_file
  $_htpasswd_file = $::st2::auth::flat_file::htpasswd_file

  httpauth { $name:
    ensure    => $ensure,
    password  => $password,
    mechanism => 'basic',
    file      => $_htpasswd_file,
    notify    => File[$_htpasswd_file],
  }

  ########################################
  ## Dependencies
  Package<| tag == 'st2::server::packages' |>
  -> Httpauth[$name]
  -> Service<| tag == 'st2::service' |>
}
