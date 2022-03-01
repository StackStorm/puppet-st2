# @summary StackStorm compatable installation of Python and dependencies.
#
# @param [String] version
#   Version of Python to install. Default is 'system' meaning the system version
#   of Python will be used.
#   To install Python 3.6 on RHEL/CentOS 7 specify '3.6'.
#   To install Python 3.6 on Ubuntu 16.05 specify 'python3.6'.
#
# @example Basic Usage
#  include st2::dependency::python
#
# @example Install with python 3.6 (if not default on your system)
#   $st2_python_version = $facts['os']['family'] ? {
#     'RedHat' => '3.6',
#     'Debian' => 'python3.6',
#   }
#   class { 'st2':
#     python_version            => $st2_python_version,
#   }
#  include st2::dependency::python
#
class st2::dependency::python (
  String  $version            = $st2::python_version,
) inherits st2 {
  notice("Python version: ${version}")
  if !defined(Class['python']) {
    # intall python and python-devel / python-dev
    class { 'python':
      version            => $version,
      dev                => present,
      manage_pip_package => false,
    }
  }
}