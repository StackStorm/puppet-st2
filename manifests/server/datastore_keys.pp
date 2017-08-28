# == Class: st2::server::generate_crypto
#
#  Generates symmetric
#
# === Parameters
#  [*robots_group_name*] - The name of the group created to hold the st2 admin user
#  [*robots_group_id*] - The GID of the group created to hold the st2 admin user.
#
# === Variables
#
#
# === Examples
#
#  class { 'st2::server::datastore_keys':
#
#  }
#
class st2::server::datastore_keys(
  $keys_dir = $::st2::datastore_keys_dir,
  $key_path = $::st2::datastore_key_path,
) {
  ## Directory
  file { $keys_dir:
    ensure  => directory,
    owner   => 'st2',
    group   => 'st2',
    mode    => '0600',
    require => Package['st2'],
  }

  ## Generate
  exec { "generate datastore key ${key_path}":
    command => "st2-generate-symmetric-crypto-key --key-path ${key_path}",
    creates => $key_path,
    path    => ['/opt/stackstorm/st2/bin'],
    notify  => Service['st2api'],
  }

  ## Permissions
  file { $key_path:
    ensure  => file,
    owner   => 'st2',
    group   => 'st2',
    mode    => '0600',
    require => Package['st2'],
  }

  ## Config
  ini_setting { 'keyvalue_encryption_key_path':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'keyvalue',
    setting => 'encryption_key_path',
    value   => $key_path,
    tag     => 'st2::config',
  }

  Package['st2']
  -> File[$keys_dir]
  -> Exec["generate datastore key ${key_path}"]
  -> File[$key_path]
}
