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
  if !defined(Class['::rabbitmq']) {
    class { '::rabbitmq':
      package_apt_pin => '100',
    }
  }

  if $::osfamily == "RedHat" {
    include erlang
    case $::operatingsystemmajrelease {
      '7': {
        yumrepo { 'erlang-solutions':
          ensure   => present,
          baseurl  => "http://packages.erlang-solutions.com/rpm/centos/\$releasever/\$basearch",
          descr    => 'Centos $releasever - $basearch - Erlang Solutions',
          enabled  => 1,
          gpgcheck => 0,
        }
        Yumrepo['erlang-solutions']
          -> Class['::erlang']
          -> Class['::rabbitmq']
      }
      '6': {
        Class['erlang'] -> Class['::rabbitmq']
      }
    }
  }
}
