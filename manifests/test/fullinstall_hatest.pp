# Test for installing standalone StackStorm using Python 3.6
$st2_python_version = $facts['os']['family'] ? {
  'RedHat' => '3.6',
  'Debian' => 'python3.6',
}
class { 'st2':
  python_version => $st2_python_version,
  cli_silence_ssl_warnings => true, # needed for clean pack install in tests
}

class { 'st2::dependency::facter': }
-> class { 'st2::repo': }
-> class { 'st2::dependency::selinux': }
-> class { 'st2::dependency::redis': }
-> class { 'st2::dependency::python': }
-> class { 'st2::dependency::nodejs': }
-> class { 'st2::dependency::rabbitmq': }
-> class { 'st2::dependency::mongodb': }
-> class { 'st2::profile::client': }
-> class { 'st2::component::chatops': }

include st2::profile::ha::sensor
include st2::profile::ha::web
include st2::profile::ha::core
include st2::profile::ha::solo
include st2::profile::ha::runner

########################################
## st2 user (stanley)

class { 'st2::stanley': }

include st2::auth
include st2::packs
include st2::kvs

# If user has not defined a pack "st2", install it from the Exchange.
if ! defined(St2::Pack['st2']) {
  ensure_resource('st2::pack', 'st2', {'ensure' => 'present'})
}
