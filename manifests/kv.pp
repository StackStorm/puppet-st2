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
define st2::kv {
  $ensure   = present,
  $key      = $name,
  $value,
) {
  include ::st2
  $_ng_init = $::st2::ng_init

  exec { "set-st2-key-${key}":
    command     => "st2 key set ${key} ${value}",
    unless      => "st2 key get ${key}",
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    tries       => '5',
    try_sleep   => '10',
  }

  if $_ng_init {
    Service<| tag == 'st2::profile::service' |> -> Exec["set-st2-key-${key}"]
  } else {
    Exec['start st2'] -> Exec["set-st2-key-${key}"]
  }
}
