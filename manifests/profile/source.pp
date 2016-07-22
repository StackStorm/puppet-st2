# == Class: st2::profile::source
#
#  Profile to install all requirements to run st2
#
# === Parameters
#  [*branch*] - Branch of st2 to bootstrap against
#
# === Variables
#
# [*_repo_root*] - Root directory where source code is download/setup
#
# === Examples
#  include st2::profile::source
#
class st2::profile::source(
  $branch = 'master',
) {
  include ::st2::profile::python

  ensure_packages('git')

  $_repo_root = '/opt/stackstorm/src'

  file { '/opt/stackstorm':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  vcsrepo { $_repo_root:
    ensure   => present,
    source   => 'https://github.com/StackStorm/st2.git',
    revision => $branch,
    provider => 'git',
    require  => [File['/opt/stackstorm'], Package['git']],
  }

  file { '/etc/st2':
    ensure => directory,
  }
  file { '/etc/st2/st2.conf':
    ensure  => file,
    source  => "${_repo_root}/conf/st2.prod.conf",
    replace => false,
    require => Vcsrepo[$_repo_root],
  }

  python::virtualenv { $_repo_root:
    ensure     => present,
    version    => 'system',
    systempkgs => false,
    venv_dir   => "${_repo_root}/virtualenv",
    cwd        => $_repo_root,
    require    => Vcsrepo[$_repo_root],
    notify     => [
      Exec['python_requirementsst2server'],
      Exec['python_requirementsst2client'],
    ],
  }
  python::requirements { 'st2server':
    requirements => "${_repo_root}/requirements.txt",
    virtualenv   => "${_repo_root}/virtualenv",
    require      => [
      Python::Virtualenv[$_repo_root],
      Vcsrepo[$_repo_root],
    ],
  }
  python::requirements { 'st2client':
    requirements => "${_repo_root}/st2client/requirements.txt",
    virtualenv   => "${_repo_root}/virtualenv",
    require      => [
      Python::Virtualenv[$_repo_root],
      Vcsrepo[$_repo_root],
    ],
  }
}
