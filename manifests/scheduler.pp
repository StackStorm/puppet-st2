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
#   include ::st2::scheduler
#
# @example Customizing parameters
#   class { '::st2::scheduler':
#     sleep_interval => 60,
#     gc_interval    => 120,
#   }
#
# @param sleep_interval
#   How long (in seconds) to sleep between each action scheduler main loop run interval.
# @param gc_interval
#   How often (in seconds) to look for zombie execution requests before rescheduling the
# @param pool_size
#   The size of the pool used by the scheduler for scheduling executions.
#
class st2::scheduler (
  $sleep_interval = $::st2::scheduler_sleep_interval,
  $gc_interval    = $::st2::scheduler_gc_interval,
  $pool_size      = $::st2::scheduler_pool_size,
) inherits st2 {

  # st2scheduler was introduced in 2.10.0
  if ($::st2::version == 'latest' or
      $::st2::version == 'present' or
      $::st2::version == 'installed' or
      versioncmp($::st2::version, '2.10.0') >= 0) {

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

    ########################################
    ## Services
    service { $::st2::params::scheduler_services:
      ensure => 'running',
      enable => true,
      tag    => 'st2::service',
    }
  }
}