# Class that manages the st2timersengine service
class st2::timersengine (
  $enabled  = $::st2::timersengine_enabled,
  $timezone = $::st2::timersengine_timezone,
) inherits st2 {

  # st2timersengine was introduced in 2.9.0
  if ($::st2::version == 'latest' or
      $::st2::version == 'present' or
      $::st2::version == 'installed' or
      versioncmp($::st2::version, '2.9.0') >= 0) {

    $_logger_config = $::st2::syslog ? {
      true    => 'syslog',
      default => 'logging',
    }
    $_enable_timersengine = $enabled ? {
      true    => 'True',
      default => 'False',
    }

    ########################################
    ## Config
    ini_setting { 'timersengine_logging':
      ensure  => present,
      path    => '/etc/st2/st2.conf',
      section => 'timersengine',
      setting => 'logging',
      value   => "/etc/st2/${_logger_config}.timersengine.conf",
      tag     => 'st2::config',
    }

    ini_setting { 'timersengine_enabled':
      ensure  => present,
      path    => '/etc/st2/st2.conf',
      section => 'timersengine',
      setting => 'enabled',
      value   => $_enable_timersengine,
      tag     => 'st2::config',
    }

    ini_setting { 'timersengine_local_timezone':
      ensure  => present,
      path    => '/etc/st2/st2.conf',
      section => 'timersengine',
      setting => 'local_timezone',
      value   => $::st2::timersengine_timezone,
      tag     => 'st2::config',
    }

    ########################################
    ## Services
    service { $::st2::params::timersengine_services:
      ensure => 'running',
      enable => true,
      tag    => 'st2::service',
    }
  }
}
