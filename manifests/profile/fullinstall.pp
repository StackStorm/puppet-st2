# == Class: st2::profile::fullinstall
#
# This class performs a default install of StackStorm on a single node
# including all st2 components and full installs of all components.
#
#  * RabbitMQ
#  * Python
#  * MongoDB
#  * NodeJS
#  * Mistral/MySQL
#
# === Examples
#
#  include st2::profile::fullinstall
#
class st2::profile::fullinstall inherits st2 {
  class { '::st2::profile::facter':
    before => Anchor['st2::bootstrap']
  }

  class { '::st2::profile::rabbitmq':
    before => Anchor['st2::pre_reqs'],
  }

  class { '::st2::profile::mongodb':
    before => Anchor['st2::pre_reqs'],
  }

  class { '::st2::profile::packagecloud':
    before => Anchor['st2::pre_reqs'],
  }

  anchor { 'st2::bootstrap': }
  anchor { 'st2::pre_reqs': }

  Anchor['st2::bootstrap']
    -> Class['::st2::profile::packagecloud']
    -> Class['::st2::profile::rabbitmq']
    -> Class['::st2::profile::mongodb']

  Anchor['st2::pre_reqs']
    -> class { '::st2::profile::server': }

  include ::st2::packs
  include ::st2::kvs

}
