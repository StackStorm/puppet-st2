# == Define: st2::pack
#
#  Installs StackStorm Packs to the system
#
# === Parameters
#  [*pack*]     - Name of the pack to install
#  [*repo_url*] - URL to install pack from (Default: github/StackStorm/st2contrib)
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
  $ensure   = present,
  $pack     = $name,
  $repo_url = undef,
  $register = undef,
  $subtree  = undef,
  $config   = undef,
) {
  include ::st2
  $_cli_username = $::st2::cli_username
  $_cli_password = $::st2::cli_password
  $_auth = $::st2::auth
  $_st2_packs_group = $::st2::params::packs_group_name

  $_repo_url = $repo_url ? {
    undef   => '',
    default => "repo_url=${repo_url}",
  }
  $_register = $register ? {
    undef   => '',
    default => "register=${register}",
  }
  $_subtree = $subtree ? {
    undef   => '',
    default => "subtree=${subtree}",
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
    'mode'    => '0775',
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
    command   => "st2 run packs.install packs=${pack} ${_repo_url} ${_register} ${_subtree}",
    creates   => "/opt/stackstorm/packs/${pack}",
    path      => '/usr/sbin:/usr/bin:/sbin:/bin',
    tries     => '5',
    try_sleep => '3',
  }

  if $config {
    validate_hash($config)
    file { "/opt/stackstorm/configs/${pack}.yaml":
      ensure  => file,
      mode    => '0755',
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
  Service<| tag == 'st2::service' |> -> Exec["install-st2-pack-${name}"]
  Exec<| tag == 'st2::reload' |> ~> Exec["install-st2-pack-${name}"]
}
