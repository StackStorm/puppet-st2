# @summary Manages a StackStorm Pack
#
# @param pack
#    Name of the pack to install.
# @param repo_url
#    URL of the package to install when not installing from the exchange.
# @param config
#    Hash that will be translated into YAML in the pack's config file after installation.
#
# @example Basic Usage
#  st2::pack { 'puppet': }
#
# @example Install from a custom URL
#  st2::pack { 'custom':
#    repo_url => 'http://github.com/myorg/stackstorm-custom.git',
#  }
#
define st2::pack (
  $ensure   = present,
  $pack     = $name,
  $repo_url = undef,
  $config   = undef,
) {
  include st2
  $_cli_username = $::st2::cli_username
  $_cli_password = $::st2::cli_password
  $_st2_packs_group = $::st2::params::packs_group_name

  ensure_resource('group', $_st2_packs_group, {
    'ensure' => present,
  })

  ensure_resource('file', '/opt/stackstorm', {
    'ensure' => 'directory',
    'owner'  => 'root',
    'group'  => 'root',
    'mode'   => '0755',
  })

  ensure_resource('file', '/opt/stackstorm/packs', {
    'ensure'  => 'directory',
    'owner'   => 'root',
    'group'   => $_st2_packs_group,
    'recurse' => true,
    'tag'     => 'st2::subdirs',
  })

  ensure_resource('file', '/opt/stackstorm/configs', {
    'ensure'  => 'directory',
    'owner'   => 'st2',
    'group'   => 'root',
    'mode'    => '0755',
    'tag'     => 'st2::subdirs',
  })

  ensure_resource('file', '/opt/stackstorm/virtualenvs', {
    'ensure'  => 'directory',
    'owner'   => 'root',
    'group'   => $_st2_packs_group,
    'mode'    => '0755',
    'tag'     => 'st2::subdirs',
  })


  st2_pack { $pack:
    ensure   => $ensure,
    name     => $pack,
    user     => $_cli_username,
    password => $_cli_password,
    source   => $repo_url,
  }

  if $config {
    validate_hash($config)
    file { "/opt/stackstorm/configs/${pack}.yaml":
      ensure  => file,
      mode    => '0640',
      owner   => 'st2',
      group   => 'root',
      content => template('st2/config.yaml.erb'),
    }

    # Register package after it is downloaded and configured
    St2_pack<| name == $pack |>
    -> File["/opt/stackstorm/configs/${pack}.yaml"]
    ~> Exec<| tag == 'st2::register-configs' |>
  }

  Group[$_st2_packs_group]
  -> File['/opt/stackstorm']
  -> File<| tag == 'st2::subdirs' |>

  Service<| tag == 'st2::service' |> -> St2_pack<||>
  Exec<| tag == 'st2::reload' |> -> St2_pack<||>
}
