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
  require ::rabbitmq

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
