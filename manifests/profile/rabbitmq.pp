# == Class: st2::profile::rabbitmq
#
# st2 compatable installation of RabbitMQ and dependencies for use with
# StackStorm
#
# === Parameters
#
#  This module contains no parameters
#
# === Variables
#
#  This module contains no variables
#
# === Examples
#
#  include st2::profile::rabbitmq
#
class st2::profile::rabbitmq {

  if versioncmp($::puppetversion, '4') >= 0 {
    # In new versions of the RabbitMQ module we need to explicitly turn off
    # the ranch TCP settings so that Kombu can connect via AMQP
    class { '::rabbitmq' :
      config_ranch          => false,
      environment_variables => {
        'RABBITMQ_NODE_IP_ADDRESS' => '127.0.0.1',
      },
    }
  }
  else {
    class { '::rabbitmq':
      environment_variables => {
        'RABBITMQ_NODE_IP_ADDRESS' => '127.0.0.1',
      },
    }
  }

  # RHEL needs EPEL installed prior to rabbitmq
  if $::osfamily == 'RedHat' {
    Class['::epel']
    -> Class['::rabbitmq']

    Yumrepo['epel']
    -> Class['::rabbitmq']

    Yumrepo['epel']
    -> Package['rabbitmq-server']
  }
}
