# @summary StackStorm compatable installation of Python and dependencies.
#
# @example Basic Usage
#  include st2::profile::python
#
class st2::profile::python {
  if !defined(Class['python']) {
    class { 'python':
      version    => 'system',
      pip        => present,
      dev        => true,
      virtualenv => present,
      provider   => 'pip',
    }
  }
}
