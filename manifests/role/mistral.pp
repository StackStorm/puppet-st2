class st2::role::mistral(
  $manage_mysql        = false,
  $github_branch       = "st2-${::st2::version}"
  $db_root_password    = 'StackStorm',
  $db_mistral_password = 'StackStorm',
) inherits st2 {
  include '::st2::dependencies'

  # This needs a bit more modeling... need to understand
  # what current mistral code ships with st2 - jdf

  ### Dependencies ###
  if !defined(Class['::mysql::bindings']) {
    class { '::mysql::bindings':
      client_dev => true,
      daemon_dev => true,
    }
  }

  ### Mistral Downloads ###
  if !defined(File['/opt/openstack']) {
    file { '/opt/openstack':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  file { [ '/etc/mistral', '/etc/mistral/actions']:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  vcsrepo { '/opt/openstack/mistral':
    ensure   => present,
    source   => 'https://github.com/StackStorm/mistral.git',
    revision => $github_branch,
    provider => 'git',
    require  => File['/opt/openstack'],
    before   => [
      Exec['setup mistral'],
      Exec['setup st2mistral plugin'],
    ],
  }

  vcsrepo { '/etc/mistral/actions/st2mistral':
    ensure => present,
    source => 'https://github.com/StackStorm/st2mistral.git',
    revision => $github_branch,
    provider => 'git',
    require  => File['/etc/mistral/actions'],
    before   => [
      Exec['setup mistral'],
      Exec['setup st2mistral plugin'],
    ],
  }
  ### END Mistral Downloads ###

  ### Bootstrap Python ###
  python::virtualenv { '/opt/openstack/mistral':
    ensure       => present,
    version      => 'system',
    requirements => '/opt/openstack/mistral/requirements.txt',
    systempkgs   => false,
    venv_dir     => '/opt/openstack/mistral/.venv',
    cwd          => '/opt/openstack/mistral',
    require      => Vcsrepo['/opt/openstack/mistral'],
    notify       => Exec['setup mistral', 'setup st2mistral plugin'],
  }

  python::pip { 'mysql-python':
    ensure     => present,
    virtualenv => '/opt/openstack/mistral/.venv',
    require    => Vcsrepo['/opt/openstack/mistral'],
  }

  python::pip { 'python-mistralclient':
    ensure => present,
    url    => 'git+https://github.com/stackforge/python-mistralclient.git',
  }
  ### END Bootstrap Python ###

  ### Bootstrap Mistral ###
  exec { 'setup mistral':
    command     => 'python setup.py develop',
    cwd         => '/opt/openstack/mistral',
    path        => [
      '/opt/openstack/mistral/.venv/bin',
      '/usr/local/bin',
      '/usr/local/sbin',
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin',
    ],
    refreshonly => true,
  }

  exec { 'setup st2mistral plugin':
    command     => 'python setup.py develop',
    cwd         => '/etc/mistral/actions/st2mistral',
    path        => [
      '/opt/openstack/mistral/.venv/bin',
      '/usr/local/bin',
      '/usr/local/sbin',
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin',
    ],
    refreshonly => true,
  }
  ### END Bootstrap Mistral ###


  ### Mistral Config Modeling ###
  ini_setting { 'connection config':
    ensure  => present,
    path    => '/etc/mistral/mistral.conf',
    section => 'database',
    setting => 'connection',
    value   => "mysql://mistral:${db_mistral_password}@localhost/mistral",
  }

  ini_setting { 'pecan settings':
    ensure  => present,
    path    => '/etc/mistral/mistral.conf',
    section => 'pecan',
    setting => 'auth_enable',
    value   => 'false',
  }

  File<| tag == 'mistral' |> -> Ini_setting <| tag == 'mistral' |> -> Exec['setup mistral database']
  ### End Mistral Config Modeling ###

  ### Setup Mistral Database ###
  if $manage_mysql {
    class { '::mysql::server':
      root_password => $db_root_password,
    }
  }

  mysql::db { 'mistral':
    user     => 'mistral',
    password => $db_mistral_password,
    before   => Exec['setup mistral database'],
  }

  file { '/etc/mistral/database_setup.lock':
    ensure => file,
    content => 'This file is the lock file that prevents Puppet from attempting to setup the database again. Delete this file if it needs to be re-run',
    notify  => Exec['setup mistral database'],
  }

  exec { 'setup mistral database':
    command     => 'python ./tools/sync_db.py --config-file /etc/mistral/mistral.conf',
    refreshonly => true,
    cwd         => '/opt/openstack/mistral',
    path        => [
      '/opt/openstack/mistral/.venv/bin',
      '/usr/local/bin',
      '/usr/local/sbin',
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin',
    ],
    require     => Vcsrepo['/opt/openstack/mistral'],
  }

  ### Mistral Init Scripts ###
  case $::osfamily {
    'Debian': {
      # A bit sloppy, but this only covers Ubuntu right now. Fix this
      file { '/etc/init/mistral.conf':
        ensure => file,
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
        source => 'puppet:///modules/st2/etc/init/mistral.conf',
      }
    }
    'RedHat': {
      file { '/etc/systemd/system/mistral.service':
        ensure => file,
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
        source => 'puppet:///modules/st2/etc/systemd/system/mistral.service',
      }
    }
  }
  ### END Mistral Init Scripts ###
}
