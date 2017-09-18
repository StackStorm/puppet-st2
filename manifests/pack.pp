# == Define: st2::pack
#
#  Installs StackStorm Packs to the system
#
# === Parameters
#  [*pack*]     - Name of the pack to install. This should be the name
#                 of the pack in the pack's YAML along with the directory
#                 created in /opt/stackstorm/packs/${pack}/ and name of config in
#                 /opt/stackstorm/configs/${pack}.yaml
#  [*repo_url*] - URL of the pack to install when not installing from the exchange.
#                 If undef then install the pack from the exchange
#                 (default = undef)
#  [*version*]  - Version of pack to install can be tag, commit, or branch
#  [*config*]   - Hash that will be translated into YAML in the pack's config
#                 file after installation.
#
# === Examples
#
#  st2::pack { 'puppet': }
#
#  st2::pack { ['linux', 'cicd']:
#    repo_url => 'http://github.com/StackStorm/st2incubator.git',
#  }
#
#  st2::pack { 'linux, cicd': }
#
define st2::pack (
  $pack     = $name,
  $repo_url = undef,
  $version  = 'latest',
  $config   = undef,
) {
  include ::st2
  $_cli_username = $::st2::cli_username
  $_cli_password = $::st2::cli_password
  $_auth = $::st2::auth
  $_st2_packs_group = $::st2::params::packs_group_name

  $_pack_or_url = $repo_url ? {
    undef   => $pack,
    default => $repo_url,
  }

  $_pack_version = $version ? {
    'latest' => undef,
    default  => $version,
  }

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

  exec { "install-st2-pack-${pack}":
    command   => "st2 pack install ${_pack_or_url}${_pack_version}",
    creates   => "/opt/stackstorm/packs/${pack}",
    path      => '/usr/sbin:/usr/bin:/sbin:/bin',
    tries     => '5',
    try_sleep => '3',
  }

  if $config {
    validate_hash($config)
    file { "/opt/stackstorm/configs/${pack}.yaml":
      ensure  => file,
      mode    => '0640',
      owner   => 'st2',
      group   => 'root',
      content => template('st2/config.yaml.erb'),
      require => [
        Exec["install-st2-pack-${pack}"],
        File['/opt/stackstorm/configs'],
      ],
    }

    File["/opt/stackstorm/configs/${pack}.yaml"] ~> Exec<| tag == 'st2::reload' |>
  }

  Group[$_st2_packs_group] -> File['/opt/stackstorm']
  File['/opt/stackstorm'] -> File<| tag == 'st2::subdirs' |>
  Package<| tag == 'st2::server::packages' |> -> File['/opt/stackstorm/packs']
  Service<| tag == 'st2::service' |> -> Exec["install-st2-pack-${pack}"]
  Exec<| tag == 'st2::reload' |> ~> Exec["install-st2-pack-${pack}"]
}
