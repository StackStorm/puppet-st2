# Test for installing standalone StackStorm using Python 3.6
$python_version = $facts['os']['family'] ? {
  'RedHat' => '3.6',
  'Debian' => 'python3.6',
}
class { 'st2':
  python_version => $python_version,
}
include st2::profile::fullinstall
