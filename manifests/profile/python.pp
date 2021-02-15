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
  $version = $st2::python_version,
) inherits st2 {
  notice("Python version: ${version}")
  if !defined(Class['python']) {
    # if we're installing a custom version of Python on Ubuntu, then install the deadsnakes PPA
    if $version != 'system' and $facts['os']['family'] == 'Debian'{
      $msg = "Passing in st2::python_version: ${version} automatically enables the deadsnakes PPA."
      # server-side warning
      notice($msg)
      # client-side warning
      notify { $msg: }
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
