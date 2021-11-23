# @summary This class performs a full default install of StackStorm and all its components on a single node.
#
# Components:
#  * RabbitMQ
#  * Python
#  * MongoDB
#  * NodeJS
#  * nginx
#  * redis
#
# @example Basic Usage
#   include st2::profile::fullinstall
#
# @example Customizing parameters
#   # Customizations are done via the main st2 class
#   class { 'st2':
#     # ... assign custom parameters
#   }
#
#   include st2::profile::fullinstall
#
class st2::profile::fullinstall inherits st2 {

  Anchor['st2::begin']
  -> Anchor['st2::bootstrap']
  -> class { 'st2::dependency::facter': }
  -> class { 'st2::repo': }
  -> class { 'st2::dependency::selinux': }
  -> Anchor['st2::pre_reqs']
  -> class { 'st2::dependency::redis': }
  -> class { 'st2::dependency::python': }
  -> class { 'st2::dependency::nodejs': }
  -> class { 'st2::dependency::rabbitmq': }
  -> class { 'st2::dependency::mongodb': }
  -> Anchor['st2::main']
  -> class { 'st2::profile::client': }
  -> class { 'st2::profile::server': }
  -> class { 'st2::profile::chatops': }
  -> Anchor['st2::end']

  include st2::auth
  include st2::packs
  include st2::kvs

  # If user has not defined a pack "st2", install it from the Exchange.
  if ! defined(St2::Pack['st2']) {
    ensure_resource('st2::pack', 'st2', {'ensure' => 'present'})
  }
}
