# @summary Manages the <code>st2rulesengine</code> service (Orquesta)
#
# Normally this class is instantiated by +st2::profile::fullinstall+.
# OR by +st2::profile::ha::core+
# However, advanced users can instantiate this class directly to configure
# and manage just the <code>st2rulesengine</code> service on a single node.
# Parameters for this class mirror the parameters in the st2 config.
#
# @see https://github.com/StackStorm/st2/blob/master/conf/st2.conf.sample
#
# @example Basic usage
#   include st2::component::rulesengine
#
# @param rulesengine_num
#   The number of rulesengines to have in an active active state
# @param rulesengine_services
#   Name of all the rulesengine services
#
class st2::component::rulesengine (
  $rulesengine_num      = $st2::rulesengine_num,
  $rulesengine_services = $st2::params::rulesengine_services,
) inherits st2 {

  $_logger_config = $st2::syslog ? {
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

  st2::service { 'st2rulesengine':
    service_name      => 'st2rulesengine',
    service_num       => $rulesengine_num,
    existing_services => $rulesengine_services,
  }
}
