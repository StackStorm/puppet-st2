# @summary Manages the <code>st2notifier</code> service (Orquesta)
#
# Normally this class is instantiated by +st2::profile::fullinstall+.
# However, advanced users can instantiate this class directly to configure
# and manage just the <code>st2notifier</code> service on a single node.
# Parameters for this class mirror the parameters in the st2 config.
#
# @see https://github.com/StackStorm/st2/blob/master/conf/st2.conf.sample
#
# @example Basic usage
#   include st2::notifier
#
# @param notifier_num
#   The number of notifiers to have in an active active state
# @param notifier_services
#   Name of all the notifier services
#
class st2::notifier (
  $notifier_num      = $st2::notifier_num,
  $notifier_services = $st2::params::notifier_services,
) inherits st2 {

  $_logger_config = $::st2::syslog ? {
    true    => 'syslog',
    default => 'logging',
  }

  ########################################
  ## Config
  ini_setting { 'notifier_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'notifier',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.notifier.conf",
    tag     => 'st2::config',
  }

  st2::service { 'st2notifier':
    service_name      => 'st2notifier',
    service_num       => $notifier_num,
    existing_services => $notifier_services,
  }
}
