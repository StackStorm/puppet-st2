# @summary Manages the <code>st2timersengine</code> service.
#
# Normally this class is instantiated by +st2::profile::fullinstall+.
# OR by +st2::profile::ha::solo+
# However, advanced users can instantiate this class directly to configure
# and manage just the <code>st2timersengine</code> service on a single node.
# Parameters for this class mirror the parameters in the st2 config.
#
# @see https://github.com/StackStorm/st2/blob/master/conf/st2.conf.sample#L337-L343
#
# @example Basic usage
#   include st2::component::timersengine
#
# @example Customizing parameters
#   class { 'st2::component::timersengine':
#     enabled  => true,
#     timezone => 'America/Los_Angeles',
#   }
#
# @param enabled
#   Specify to enable timer service.
# @param timezone
#   Timezone pertaining to the location where st2 is run.
#
class st2::component::timersengine (
  $enabled  = $st2::timersengine_enabled,
  $timezone = $st2::timersengine_timezone,
) inherits st2 {

  # st2timersengine was introduced in 2.9.0
  if st2::version_ge('2.9.0') {

    $_logger_config = $st2::syslog ? {
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
      value   => $st2::timersengine_timezone,
      tag     => 'st2::config',
    }

    ########################################
    ## Services
    service { $st2::params::timersengine_services:
      ensure => 'running',
      enable => true,
      tag    => 'st2::service',
    }
  }
}
