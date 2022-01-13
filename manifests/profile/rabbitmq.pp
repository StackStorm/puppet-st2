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
  $username   = $st2::rabbitmq_username,
  $password   = $st2::rabbitmq_password,
  $port       = $st2::rabbitmq_port,
  $bind_ip    = $st2::rabbitmq_bind_ip,
  $vhost      = $st2::rabbitmq_vhost,
  $erlang_url = $st2::erlang_url,
  $erlang_key = $st2::erlang_key
) inherits st2 {

  # RHEL 8 Requires another repo in addition to epel to be installed
  if ($facts['os']['family'] == 'RedHat') and ($facts['os']['release']['major'] == '8') {
    $repos_ensure = true

    # This is required because when using the latest version of rabbitmq because the latest version in EPEL
    # for Erlang is 22.0.7 which is not compatible: https://www.rabbitmq.com/which-erlang.html
    yumrepo { 'erlang':
      ensure   => present,
      name     => 'rabbitmq_erlang',
      baseurl  => $erlang_url,
      gpgkey   => $erlang_key,
      enabled  => 1,
      gpgcheck => 1,
      before   => Class['rabbitmq::repo::rhel'],
    }
  }
  elsif ($facts['os']['family'] == 'Debian') {
    $repos_ensure = true
    # debian, ubuntu, etc
    $osname = downcase($facts['os']['name'])
    # trusty, xenial, bionic, etc
    $release = downcase($facts['os']['distro']['codename'])
    $repos = 'main'

    $location_erlang = "https://packagecloud.io/rabbitmq/rabbitmq-erlang/${osname}"
    $location_rabbitmq = "https://packagecloud.io/rabbitmq/rabbitmq-server/${osname}"

    $erlang_packages = [
      'erlang-base',
      'erlang-asn1',
      'erlang-crypto',
      'erlang-eldap',
      'erlang-ftp',
      'erlang-inets',
      'erlang-mnesia',
      'erlang-os-mon',
      'erlang-parsetools',
      'erlang-public-key',
      'erlang-runtime-tools',
      'erlang-snmp',
      'erlang-ssl',
      'erlang-syntax-tools',
      'erlang-tftp',
      'erlang-tools',
      'erlang-xmerl',
    ]

    $erlang_key_id = '0xf77f1eda57ebb1cc'
    $erlang_key_source = 'https://keyserver.ubuntu.com'

    $rabbit_key_id = '8C695B0219AFDEB04A058ED8F4E789204D206F89'
    $rabbit_key_source = 'https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey'

    $team_key_id = '0A9AF2115F4687BD29803A206B73A36E6026DFCA'
    $team_key_source = 'hkps://keys.openpgp.org'

    apt::key { 'rabbitmq-team':
      id     => $team_key_id
      server => 'https://keys.openpgp.org'
    }

    apt::source { 'erlang':
      location => $location_erlang,
      release  => $release,
      repos    => $repos,
      key      => {
        'id'     => $erlang_key_id,
        'source' => $erlang_key_source,
    },

    apt::source { 'rabbitmq':
      location => $location_rabbitmq,
      release  => $release,
      repos    => $repos,
      key      => {
        'id'     => $rabbit_key_id,
        'source' => $rabbit_key_source,
      },
    }

    package { $erlang_packages:
      ensure => 'present',
      tag    => ['st2::packages', 'st2::rabbitmq::packages'],
    }
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
    manage_python         => false,
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
  if $facts['os']['family'] == 'RedHat' {
    Class['epel']
    -> Class['rabbitmq']

    Yumrepo['epel']
    -> Class['rabbitmq']

    Yumrepo['epel']
    -> Package['rabbitmq-server']
  }
  # Debian/Ubuntu needs erlang before rabbitmq
  elsif $facts['os']['family'] == 'Debian' {
    Package<| tag == 'st2::rabbitmq::packages' |>
    -> Class['rabbitmq']
  }
}
