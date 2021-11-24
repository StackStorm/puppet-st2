# Test for installing standalone StackStorm using Python 3.6
$st2_python_version = $facts['os']['family'] ? {
  'RedHat' => '3.6',
  'Debian' => 'python3.6',
}
class { 'st2':
  python_version            => $st2_python_version,
}
include st2::profile::ha::sensor
include st2::profile::ha::web
include st2::profile::ha::core
include st2::profile::ha::solo
include st2::profile::ha::runner
########################################
## st2 user (stanley)
class { 'st2::stanley': }
