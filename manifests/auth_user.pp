# Definition: st2::auth_user
#
#  Friendly helper to manage standalone auth for StackStorm
#
# Usage
#
#  st2::auth_user { 'jfryman':
#    password => 'neato!',
#  }
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
    notify    => Service['st2auth']
  }
}
