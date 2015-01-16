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
#    repo_url => 'http://github.com/StackStorm/st2incubator',
#  }
#
define st2::pack (
  $ensure   = present,
  $pack     = $name,
  $repo_url = undef,
) {

  if $repo_url { $_repo_url = "repo_url=${repo_url}" }
  else { $_repo_url = '' }

  exec { "install-st2-pack-${pack}":
    command => "st2 action execute packs.install packs=${pack} ${_repo_url}",
    creates => "/opt/stackstorm/packs/${pack}",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    notify  => Exec['restart-st2'],
  }

  ensure_resource('exec', 'restart-st2', {
    'command'     => 'st2ctl restart',
    'path'        => '/usr/sbin:/usr/bin:/sbin:/bin',
    'refreshonly' => true,
  })
}
