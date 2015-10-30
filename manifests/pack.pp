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

  ensure_resource('file', '/opt/stackstorm/packs', {
    'ensure'  => 'directory',
    'owner'   => 'root',
    'group'   => $_st2_packs_group,
    'mode'    => '2775',
    'recurse' => true,
  })

  exec { "install-st2-pack-${pack}":
    command   => "st2 run packs.install packs=${pack} ${_repo_url} ${_register} ${_subtree}",
    creates   => "/opt/stackstorm/packs/${pack}",
    path      => '/usr/sbin:/usr/bin:/sbin:/bin',
    tries     => '5',
    try_sleep => '3',
  }

  Package<| tag == 'st2::package::install' |> -> File['/opt/stackstorm/packs']
  Service<| tag == 'st2::profile::service' |> -> Exec["install-st2-pack-${name}"]

  if $config {
    validate_hash($config)
    file { "/opt/stackstorm/packs/${pack}/config.yaml":
      ensure  => file,
      mode    => '0440',
      content => template('st2/config.yaml.erb'),
      require => [
        Exec["install-st2-pack-${pack}"],
        File['/opt/stackstorm/packs'],
      ],
    }
  }
}
