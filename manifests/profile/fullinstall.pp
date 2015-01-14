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
# === Parameters
#
#  [*web*] - Include `st2web` in install (requires early access, contact support@stackstorm.com for access)
#
# === Examples
#
#  include st2::profile::fullinstall
#
class st2::profile::fullinstall(
  $web = false,
) {
  class { '::st2::profile::python':
    before => Anchor['st2::pre_reqs'],
  }

  class { '::st2::profile::rabbitmq':
    before => Anchor['st2::pre_reqs'],
  }

  class { '::st2::profile::nodejs':
    before => Anchor['st2::pre_reqs'],
  }

  class { '::st2::profile::mongodb':
    before => Anchor['st2::pre_reqs'],
  }

  class { '::st2::profile::mistral':
    manage_mysql => true,
    before => Anchor['st2::pre_reqs'],
  }


  anchor { 'st2::pre_reqs': }

  Anchor['st2::pre_reqs']
  -> class { '::st2::profile::client': }
  -> class { '::st2::profile::server': }
  -> class { '::st2::stanley': }

  if $web {
    class { '::st2::profile::web':
      require => Anchor['st2::pre_reqs'],
    }
  }
}
