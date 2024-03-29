# Test for installing standalone StackStorm using Python 3.8
$st2_python_version = $facts['os']['family'] ? {
  'RedHat' => '3.8',
  'Debian' => 'python3.8',
  'Rocky' => 'python38',
  default => '3.8',
}
class { 'st2':
  python_version            => $st2_python_version,
}
include st2::profile::fullinstall
