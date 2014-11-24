class st2::role::server (
  $version     = $::st2::version,
  $revision    = $::st2::revision,
) inherits st2 {
  include '::st2::notices'
  include '::st2::params'
  include '::st2::dependencies'

  $_server_packages = $::st2::params::st2_server_packages
  $_conf_dir = $::st2::params::conf_dir
  $_python_pack = $::osfamily ? {
    'Debian' => '/usr/lib/python2.7/dist-packages',
    'RedHat' => '/usr/lib/python2.7/site-packages',
  }

  file { $_conf_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  ### This should be a versioned download too... currently on master
  wget::fetch { 'Download st2server requirements.txt':
    source      => 'https://raw.githubusercontent.com/StackStorm/st2/master/requirements.txt',
    cache_dir   => '/var/cache/wget',
    destination => '/tmp/st2server-requirements.txt',
  }

  python::requirements { '/tmp/st2server-requirements.txt':
    require => Wget::Fetch['Download st2server requirements.txt'],
    before  => Exec['register st2 content'],
  }

  st2::package::install { $_server_packages:
    version     => $version,
    revision    => $revision,
    notify      => Exec['register st2 content'],
  }

  exec { 'register st2 content':
    command     => "python ${_python_pack}/st2common/bin/registercontent.py --config-file ${_conf_dir}/st2.conf",
    path        => '/usr/bin:/usr/sbin:/bin:/sbin',
    refreshonly => true,
  }

  ini_setting { 'api_allow_origin':
    ensure  => 'present',
    path    => '/etc/st2/st2.conf',
    section => 'api',
    setting => 'allow_origin',
    value   => '*',
  }

  ini_setting { 'ssh_key_stanley':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'system_user',
    setting => 'ssh_key_file',
    value   => '/home/stanley/.ssh/st2_stanley_key',
  }

  ## Needs to have real init scripts
  exec { 'start st2':
    command => 'st2ctl start',
    onlyif  => 'st2ctl status | grep "not started"',
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    require => Exec['register st2 content'],
  }

  St2::Package::Install<| tag == 'st2::role::server' |>
  -> Ini_setting<| tag == 'st2::role::server' |>
  -> Exec['start st2']
}
