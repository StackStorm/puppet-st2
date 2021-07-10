# @summary Manages the <code>st2scheduler</code> service.
#
# Normally this class is instantiated by <code>st2::profile::fullinstall</code>.
# However, advanced users can instantiate this class directly to configure
# and manage just the <code>st2scheduler</code> service on a single node.
# Parameters for this class mirror the parameters in the st2 config.
#
# @see https://github.com/StackStorm/st2/blob/master/conf/st2.conf.sample#L251-L259
#
# @example Basic usage
#   include st2::scheduler
#
# @example Customizing parameters
#   class { 'st2::scheduler':
#     sleep_interval => 60,
#     gc_interval    => 120,
#   }
#
# @param sleep_interval
#   How long (in seconds) to sleep between each action scheduler main loop run interval.
# @param gc_interval
#   How often (in seconds) to look for zombie execution requests before rescheduling them.
# @param pool_size
#   The size of the pool used by the scheduler for scheduling executions.
# @param scheduler_num
#   The number of schedulers to have in an active active state
# @param scheduler_services
#   Name of all the scheduler services.
#
class st2::scheduler (
  $sleep_interval     = $::st2::scheduler_sleep_interval,
  $gc_interval        = $::st2::scheduler_gc_interval,
  $pool_size          = $::st2::scheduler_pool_size,
  $scheduler_num      = $st2::scheduler_num,
  $scheduler_services = $st2::params::scheduler_services
) inherits st2 {

  # st2scheduler was introduced in 2.10.0
  if st2::version_ge('2.10.0') {

    $_logger_config = $::st2::syslog ? {
      true    => 'syslog',
      default => 'logging',
    }

    ########################################
    ## Config
    ini_setting { 'scheduler_logging':
      ensure  => present,
      path    => '/etc/st2/st2.conf',
      section => 'scheduler',
      setting => 'logging',
      value   => "/etc/st2/${_logger_config}.scheduler.conf",
      tag     => 'st2::config',
    }

    if ($scheduler_num > 1) {
      $additional_services = range("2", "${scheduler_num}").reduce([]) |$memo, $number| {
        $schedule_name = "st2scheduler${number}"
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

        systemd::unit_file { "${schedule_name}.service":
          path   => $file_path,
          source => "${file_path}st2scheduler.service",
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
        }

        $memo + [$schedule_name]
      }

      $_scheduler_services = $scheduler_services + $additional_services

    } else {
      $_scheduler_services = $scheduler_services
    }

    ########################################
    ## Services
    service { $_scheduler_services:
      ensure => 'running',
      enable => true,
      tag    => 'st2::service',
    }
  }
}
