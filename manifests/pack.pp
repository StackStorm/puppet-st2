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
) {

  if $repo_url { $_repo_url = "repo_url=${repo_url}" }
  else { $_repo_url = '' }

  # To support many packs in a single action, SHA it out!
  $_sha = sha1($pack)
  file { "/opt/stackstorm/packs/.${_sha}":
    ensure  => file,
    content => "This file was installed when Puppet installed the st2 pack(s): ${pack}\nDelete it to reinstall via Puppet.",
    notify  => Exec["install-st2-pack-${pack}"],
  }

  exec { "install-st2-pack-${pack}":
    command     => "st2 action execute packs.install packs=${pack} ${_repo_url}",
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    refreshonly => true,
    notify      => Exec['restart-st2'],
  }

  ensure_resource('exec', 'restart-st2', {
    'command'     => 'st2ctl restart',
    'path'        => '/usr/sbin:/usr/bin:/sbin:/bin',
    'refreshonly' => true,
  })
}
