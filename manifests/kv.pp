# @summary Sets a value to the StackStorm Key/Value Store
#
# @param key
#    Key to set
# @param value
#    Value of key
#
# @example Basic usage
#  st2::kv { 'install_uuid':
#    value => $_uuid,
#  }
#
define st2::kv (
  $value,
  $ensure = present,
  $key    = $name,
  $apikey = $st2::cli_apikey,
) {
  include st2

  if $apikey {
    _command = "st2 key set --api-key ${apikey} ${key} ${value}"
    _unless = "st2 key get --api-key ${apikey} ${key} | grep ${key}"
  }
  else {
    _command = "st2 key set ${key} ${value}"
    _unless = "st2 key get ${key} | grep ${key}"
  }

  exec { "set-st2-key-${key}":
    command   => _command,
    unless    => _unless,
    path      => '/usr/sbin:/usr/bin:/sbin:/bin',
    tries     => '5',
    try_sleep => '10',
  }

  Service<| tag == 'st2::service' |> -> Exec["set-st2-key-${key}"]
  Exec<| tag == 'st2::reload' |> ~> Exec["set-st2-key-${key}"]
}
