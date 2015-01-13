class st2::profile::rabbitmq {
  if !defined(Class['::rabbitmq']) {
    class { '::rabbitmq':
      package_apt_pin => '100',
    }
  }
}
