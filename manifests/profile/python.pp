# @summary StackStorm compatable installation of Python and dependencies.
#
# @param [String] version
#   Version of Python to install. Default is 'system' meaning the system version
#   of Python will be used.
#   To install Python 3.6 on RHEL/CentOS 7 specify '3.6'.
#   To install Python 3.6 on Ubuntu 16.05 specify 'python3.6'.
#
# @param [Boolean] enable_unsafe_repo
#   The python3.6 package is a required dependency for the StackStorm `st2` package
#   but that is not installable from any of the default Ubuntu 16.04 repositories.
#   We recommend switching to Ubuntu 18.04 LTS (Bionic) as a base OS. Support for
#   Ubuntu 16.04 will be removed with future StackStorm versions.
#   Alternatively the Puppet will try to add python3.6 from the 3rd party 'deadsnakes' repository: https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa.
#   Only set to true, if you are aware of the support and security risks associated
#   with using unofficial 3rd party PPA repository, and you understand that StackStorm
#   does NOT provide ANY support for python3.6 packages on Ubuntu 16.04.
#   The unsafe PPA `'ppa:deadsnakes/ppa'` https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa
#   can be enabled if you specify `true` for this parameter. (default: `false`)
#
# @example Basic Usage
#  include st2::profile::python
#
# @example Install with python 3.6 (if not default on your system)
#   $st2_python_version = $facts['os']['family'] ? {
#     'RedHat' => '3.6',
#     'Debian' => 'python3.6',
#   }
#   class { 'st2':
#     python_version            => $st2_python_version,
#     python_enable_unsafe_repo => true,
#   }
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
      version            => $version,
      dev                => present,
      manage_pip_package => false,
    }
  }
}
