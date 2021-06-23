# @summary StackStorm compatable installation of RabbitMQ and dependencies.
#
# @param username
#   User to create within RabbitMQ for authentication.
# @param password
#   Password of +username+ for RabbitMQ authentication.
# @param port
#   Port to bind to for the RabbitMQ server
# @param bind_ip
#   IP address to bind to for the RabbitMQ server
# @param vhost
#   RabbitMQ virtual host to create for StackStorm
#
# @example Basic Usage
#   include st2::profile::rabbitmq
#
# @example Authentication enabled (configured vi st2)
#   class { 'st2':
#     rabbitmq_username => 'rabbitst2',
#     rabbitmq_password => 'secret123',
#   }
#   include st2::profile::rabbitmq
#
class st2::profile::rabbitmq (
  $username = $st2::rabbitmq_username,
  $password = $st2::rabbitmq_password,
  $port     = $st2::rabbitmq_port,
  $bind_ip  = $st2::rabbitmq_bind_ip,
  $vhost    = $st2::rabbitmq_vhost,
) inherits st2 {

  # RHEL 8 Requires another repo in addition to epel to be installed
  if ($::osfamily == 'RedHat') and ($facts['os']['release']['major'] == '8') {
    $repos_ensure = true
  }
  else {
    $repos_ensure = false
  }

  # In new versions of the RabbitMQ module we need to explicitly turn off
  # the ranch TCP settings so that Kombu can connect via AMQP
  class { 'rabbitmq' :
    config_ranch          => false,
    repos_ensure          => $repos_ensure,
    delete_guest_user     => true,
    port                  => $port,
    environment_variables => {
      'RABBITMQ_NODE_IP_ADDRESS' => $st2::rabbitmq_bind_ip,
    },
  }
  contain 'rabbitmq'

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
    Class['epel']
    -> Class['rabbitmq']

    Yumrepo['epel']
    -> Class['rabbitmq']

    Yumrepo['epel']
    -> Package['rabbitmq-server']
  }
}
