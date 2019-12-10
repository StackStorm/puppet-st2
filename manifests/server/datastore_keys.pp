# @summary Generates and manages crypto keys for use with the StackStorm datastore
#
# @param conf_file
#    The path where st2 config is stored
# @param keys_dir
#    The directory where the datastore keys will be stored
# @param key_path
#    Path to the key file
#
# @example Basic Usage
#   include st2::server::datastore_keys
#
# @example Custom key path
#   class { '::st2::server::datastore_keys':
#     keys_dir => '/path/to/custom/keys',
#     key_path => '/path/to/custom/keys/datastore_key.json.',
#   }
#
class st2::server::datastore_keys (
  $conf_file = $::st2::conf_file,
  $keys_dir  = $::st2::datastore_keys_dir,
  $key_path  = $::st2::datastore_key_path,
) inherits st2 {
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
    path    => $conf_file,
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
