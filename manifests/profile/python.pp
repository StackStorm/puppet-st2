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
    class { 'python':
      version    => $version,
      pip        => present,
      dev        => present,
      virtualenv => present,
    }
  }
}
