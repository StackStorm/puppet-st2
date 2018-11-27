# Class that manages the st2scheduler service
class st2::scheduler (
  $sleep_interval = $::st2::scheduler_sleep_interval,
  $gc_interval    = $::st2::scheduler_gc_interval,
  $pool_size      = $::st2::scheduler_pool_size,
) inherits st2 {

  # st2scheduler was introduced in 3.0.0
  if ($::st2::version == 'latest' or
      $::st2::version == 'present' or
      $::st2::version == 'installed' or
      versioncmp($::st2::version, '3.0.0') >= 0) {

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
