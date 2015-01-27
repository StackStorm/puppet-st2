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
  $config   = undef,
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
    command => "st2 run packs.install packs=${pack} ${_repo_url}",
    creates => "/opt/stackstorm/packs/${pack}",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    require => Exec['start st2'],
    notify  => Exec['restart-st2'],
  }

  ensure_resource('exec', 'restart-st2', {
    'command'     => 'st2ctl restart',
    'path'        => '/usr/sbin:/usr/bin:/sbin:/bin',
    'refreshonly' => true,
  })

  if $config {
    validate_hash($config)
    file { "/opt/stackstorm/packs/${pack}/config.yaml":
      ensure  => file,
      mode    => '0440',
      content => template('st2/config.yaml.erb'),
      require => Exec["install-st2-pack-${pack}"],
      notify  => Exec["restart-st2"],
    }
  }
}
