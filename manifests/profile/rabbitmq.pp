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
class st2::profile::rabbitmq (
  $username = $::st2::rabbitmq_username,
  $password = $::st2::rabbitmq_password,
  $port     = $::st2::rabbitmq_port,
  $bind_ip  = $::st2::rabbitmq_bind_ip,
  $vhost    = $::st2::rabbitmq_vhost,
) inherits st2 {

  # In new versions of the RabbitMQ module we need to explicitly turn off
  # the ranch TCP settings so that Kombu can connect via AMQP
  class { '::rabbitmq' :
    config_ranch          => false,
    delete_guest_user     => true,
    port                  => $port,
    environment_variables => {
      'RABBITMQ_NODE_IP_ADDRESS' => $::st2::rabbitmq_bind_ip,
    },
  }
  contain '::rabbitmq'

  rabbitmq_user { $username:
    admin    => true,
    password => $password,
  }

  rabbitmq_vhost { $vhost:
    ensure => present,
  }

  rabbitmq_user_permissions { "${username}@${vhost}":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
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
