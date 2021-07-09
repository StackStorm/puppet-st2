# @summary Manages the <code>st2workflowengine</code> service (Orquesta)
#
# Normally this class is instantiated by +st2::profile::fullinstall+.
# However, advanced users can instantiate this class directly to configure
# and manage just the <code>st2workflowengine</code> service on a single node.
# Parameters for this class mirror the parameters in the st2 config.
#
# @see https://github.com/StackStorm/st2/blob/master/conf/st2.conf.sample
#
# @example Basic usage
#   include st2::workflowengine
#
class st2::workflowengine (
  $workflowengine_num      = $st2::workflowengine_num,
  $workflowengine_services = $st2::params::workflowengine_services,
) inherits st2 {

  # st2workflowengine was introduced in 2.8.0
  if st2::version_ge('2.8.0') {

    $_logger_config = $::st2::syslog ? {
      true    => 'syslog',
      default => 'logging',
    }

    ########################################
    ## Config
    ini_setting { 'workflow_engine_logging':
      ensure  => present,
      path    => '/etc/st2/st2.conf',
      section => 'workflow_engine',
      setting => 'logging',
      value   => "/etc/st2/${_logger_config}.workflowengine.conf",
      tag     => 'st2::config',
    }

    if ($workflowengine_num > 1) {
      $additional_services = range("2", "$workflowengine_num").reduce([]) |$memo, $number| {
        $workflowengine_name = "st2workflowengine${number}"
        case $facts['os']['family'] {
          'RedHat': {
            $file_path = '/usr/lib/systemd/system/'
          }
          'Debian': {
            $file_path = '/lib/systemd/system/'
          }
          default: {
            fail("Unsupported managed repository for osfamily: ${facts['os']['family']}, operatingsystem: ${facts['os']['name']}")
          }
        }

        systemd::unit_file { "${workflowengine_name}.service":
          path => $file_path,
          source => "${file_path}st2workflowengine.service",
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
        }

        $memo + [$workflowengine_name]
      }

      $_workflowengine_services = $workflowengine_services + $additional_services

    } else {
      $_workflowengine_services = $workflowengine_services
    }

    ########################################
    ## Services
    service { $_workflowengine_services:
      ensure => 'running',
      enable => true,
      tag    => 'st2::service',
    }
  }
}
