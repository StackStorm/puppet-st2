# @summary Manages the <code>st2rulesengine</code> service (Orquesta)
#
# Normally this class is instantiated by +st2::profile::fullinstall+.
# However, advanced users can instantiate this class directly to configure
# and manage just the <code>st2rulesengine</code> service on a single node.
# Parameters for this class mirror the parameters in the st2 config.
#
# @see https://github.com/StackStorm/st2/blob/master/conf/st2.conf.sample
#
# @example Basic usage
#   include st2::rulesengine
#
class st2::rulesengine (
  $rulesengine_num      = $st2::rulesengine_num,
  $rulesengine_services = $st2::params::rulesengine_services,
) inherits st2 {

  $_logger_config = $::st2::syslog ? {
    true    => 'syslog',
    default => 'logging',
  }

  ########################################
  ## Config
  ini_setting { 'rulesengine_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'rulesengine',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.rulesengine.conf",
    tag     => 'st2::config',
  }

  if ($rulesengine_num > 1) {
    $additional_services = range("2", "$rulesengine_num").reduce([]) |$memo, $number| {
      $rulesengine_name = "st2rulesengine${number}"

      case $facts['os']['family'] {
        'RedHat': {
          $file_path = '/usr/lib/systemd/system/'
          file { "${file_path}${rulesengine_name}.service":
            ensure => present,
            source => "${file_path}st2rulesengine.service",
            owner  => 'root',
            group  => 'root',
            mode   => '0644',
            # notify => Exec['Reload Daemon'],
            notify => Class['st2::service_reload'],
          }
        }
        default: {
          fail("Unsupported managed repository for osfamily: ${facts['os']['family']}, operatingsystem: ${facts['os']['name']}")
        }
      }

      $memo + [$rulesengine_name]
    }

    $_rulesengine_services = $rulesengine_services + $additional_services

    # case $facts['os']['family'] {
    #   'RedHat': {
    #     exec { 'Reload Daemon':
    #       command => 'systemctl daemon-reload',
    #       path    => '/usr/bin',
    #       refreshonly => true,
    #     }
    #   }
    #   default: {
    #     fail("Unsupported managed repository for osfamily: ${facts['os']['family']}, operatingsystem: ${facts['os']['name']}")
    #   }
    # }

  } else {
    $_rulesengine_services = $rulesengine_services
  }

  ########################################
  ## Services
  service { $_rulesengine_services:
    ensure => 'running',
    enable => true,
    tag    => 'st2::service',
  }
}
