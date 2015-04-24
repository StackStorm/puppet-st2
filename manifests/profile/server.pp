# == Class: st2::profile::server
#
#  Profile to install all server components for st2
#
# === Parameters
#
#  [*version*] - Version of StackStorm to install
#  [*revision*] - Revision of StackStorm to install
#
# === Variables
#
#  [*_server_packages*] - Local scoped variable to store st2 server packages.
#                         Sources from st2::params
#  [*_conf_dir*]        - Local scoped variable config directory for st2.
#                         Sources from st2::params
#  [*_python_pack*]     - Local scoped variable directory where system python lives
#
# === Examples
#
#  include st2::profile::client
#
class st2::profile::server (
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
  $_register_command = $version ? {
    /^0.8/  => "${_python_pack}/st2common/bin/registercontent.py",
    default => "${_python_pack}/st2common/bin/st2-register-content",
  }
  $_enable_auth = $::st2::auth ? {
    true    => 'True',
    default => 'False',
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
    command     => "python ${_register_command} --register-all --config-file ${_conf_dir}/st2.conf",
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

  ini_setting { 'auth':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'enable',
    value   => $_enable_auth,
  }

  ## Needs to have real init scripts
  exec { 'start st2':
    command => 'st2ctl start',
    unless  => 'ps ax | grep -v grep | grep actionrunner',
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    require => Exec['register st2 content'],
  }

  St2::Package::Install<| tag == 'st2::profile::server' |>
  -> Ini_setting<| tag == 'st2::profile::server' |>
  -> Exec['start st2']

  Exec['start st2'] -> St2::Pack<||>
}
