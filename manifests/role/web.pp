class st2::role::web(
  $github_oauth_token = undef,
) {
  if !$github_oauth_token {
    fail("Class['st2::profile::web']: ${st2::notices::web_no_oauth_token}")
  }

  file { '/opt/st2web':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  vcsrepo { '/opt/st2web':
    ensure   => present,
    provider => git,
    source   => "https://${github_oauth_token}@github.com/StackStorm/st2web.git",
    notify   => [
      Exec['npm-install-st2repo'],
      Exec['bower-install-st2repo'],
    ],
  }

  exec { 'npm-install-st2repo':
    command     => 'npm install',
    cwd         => '/opt/st2web',
    path        => '/usr/bin:/usr/sbin:/bin:/sbin',
    refreshonly => true,
    require     => Class['::nodejs'],
  }

  exec { 'bower-install-st2repo':
    command     => 'bower --allow-root install',
    cwd         => '/opt/st2web',
    path        => '/usr/bin:/usr/sbin:/bin:/sbin',
    refreshonly => true,
    require     => [
      Exec['npm-install-st2repo'],
      Class['::nodejs'],
    ],
  }

  # Needs a SystemD init script too!
  file { '/etc/init/st2web.conf':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0444',
    source => 'puppet:///modules/st2/etc/init/st2web.conf',
  }

  service { 'st2web':
    ensure  => running,
    enable  => true,
    require => [
      Exec['bower-install-st2repo'],
      Class['::nodejs'],
      File['/etc/init/st2web.conf'],
    ],
  }
}
