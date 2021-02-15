# Test for installing standalone StackStorm
class { 'st2':
  python_version => '3.6',
}
include st2::profile::fullinstall
