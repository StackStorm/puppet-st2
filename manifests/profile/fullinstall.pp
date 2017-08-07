# == Class: st2::profile::fullinstall
#
# This class performs a default install of StackStorm on a single node
# including all st2 components and full installs of all components.
#
#  * RabbitMQ
#  * Python
#  * MongoDB
#  * NodeJS
#  * Mistral+PostgreSQL
#
# === Examples
#
#  include st2::profile::fullinstall
#
class st2::profile::fullinstall inherits st2 {

  anchor { 'st2::begin': }
  -> anchor { 'st2::bootstrap': }
  -> anchor { 'st2::pre_reqs': }
  -> anchor { 'st2::main': }
  -> anchor { 'st2::end': }

  Anchor['st2::begin']
  -> Anchor['st2::bootstrap']
  -> class { '::st2::profile::facter': }
  -> class { '::st2::profile::repos': }
  -> class { '::st2::profile::selinux': }
  -> Anchor['st2::pre_reqs']
  -> class { '::st2::profile::nodejs': }
  -> class { '::st2::profile::postgresql': }
  -> class { '::st2::profile::rabbitmq': }
  -> class { '::st2::profile::mongodb': }
  -> Anchor['st2::main']
  -> class { '::st2::profile::mistral': }
  -> class { '::st2::profile::client': }
  -> class { '::st2::profile::server': }
  -> class { '::st2::profile::web': }
  -> Anchor['st2::end']

  # default pack
  if !defined(St2::Pack['st2']) {
    st2::pack {'st2': }
  }

  include ::st2::auth::standalone
  include ::st2::packs
  include ::st2::kvs
}
