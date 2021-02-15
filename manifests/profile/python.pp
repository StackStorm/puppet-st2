# @summary StackStorm compatable installation of Python and dependencies.
#
# @example Basic Usage
#  include st2::profile::python
#
# @example Instally python3
#  class { 'st2':
#    python_version => '3',
#  }
#  include st2::profile::python
#
class st2::profile::python (
  $version = $st2::python_version,
) inherits st2 {
  notice("Python version: ${version}")
  if !defined(Class['python']) {
    # if we're installing a custom version of Python on Ubuntu, then install the deadsnakes PPA
    if $version != 'system' and $facts['os']['family'] == 'Debian'{
      apt::ppa { 'ppa:deadsnakes/ppa':
        before => Class['python'],
      }
    }

    # intall python, pip, virtualenv
    class { 'python':
      version    => $version,
      pip        => present,
      dev        => present,
      virtualenv => present,
    }
  }
}
