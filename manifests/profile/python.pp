# @summary StackStorm compatable installation of Python and dependencies.
#
# @example Basic Usage
#  include st2::profile::python
#
# @example Install python3
#  class { 'st2':
#    python_version => '3.6',
#  }
#  include st2::profile::python
#
class st2::profile::python (
  String  $version            = $st2::python_version,
  Boolean $enable_unsafe_repo = $st2::python_enable_unsafe_repo,
) inherits st2 {
  notice("Python version: ${version}")
  if !defined(Class['python']) {
    # if we're installing a custom version of Python on Ubuntu, then install the deadsnakes PPA
    # but only if the user explicitly specified st2::python_enable_unsafe_repo: true
    if $version != 'system' and $facts['os']['family'] == 'Debian' and $enable_unsafe_repo {
      # enable the PPA
      apt::ppa { 'ppa:deadsnakes/ppa':
        before => Class['python'],
      }
    }

    # intall python and python-devel / python-dev
    class { 'python':
      version                   => $version,
      dev                       => present,
      manage_pip_package        => false,
      manage_virtualenv_package => false,
    }
  }
}
