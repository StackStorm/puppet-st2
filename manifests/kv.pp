# == Define: st2::kv
#
#  Sets a value to the StackStorm Key/Value Store
#
# === Parameters
#  [*key*]   - Key to set
#  [*value*] - Value of key
#
# === Examples
#
#  st2::kv { 'install_uuid':
#    value => $_uuid,
#  }
#
#
define st2::kv (
  $value,
  $ensure = present,
  $key    = $name,
) {
  include ::st2

  exec { "set-st2-key-${key}":
    command   => "st2 key set ${key} ${value}",
    unless    => "st2 key get ${key} | grep ${key}",
    path      => '/usr/sbin:/usr/bin:/sbin:/bin',
    tries     => '5',
    try_sleep => '10',
  }

  Service<| tag == 'st2::service' |> -> Exec["set-st2-key-${key}"]
  Exec<| tag == 'st2::reload' |> ~> Exec["set-st2-key-${key}"]
}
