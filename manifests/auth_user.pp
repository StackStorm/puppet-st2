# Definition: st2::auth_user
#
#  Creates and manages StackStorm application users (standalone auth only)
#
# Usage
#
#  st2::auth_user { 'st2admin':
#    password => 'neato!',
#  }
#
# TODO
#   Allow this method to be used for other types of auth
#
define st2::auth_user(
  $ensure   = present,
  $password = undef,
) {
  include ::st2::auth::standalone
  $_htpasswd_file = $::st2::auth::standalone::htpasswd_file

  httpauth { $name:
    ensure    => $ensure,
    password  => $password,
    mechanism => 'basic',
    file      => $_htpasswd_file,
    notify    => File[$_htpasswd_file],
    require   => Package['st2'],
    before    => Service['st2auth'],
  }

}
