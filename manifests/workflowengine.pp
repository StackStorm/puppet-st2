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
# @param workflowengine_num
#   The number of workflowengines to have in an active active state
# @param workflowengine_services
#   Name of all the workflowengine services.
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

    st2::service { 'st2workflowengine':
      service_name      => 'st2workflowengine',
      service_num       => $workflowengine_num,
      existing_services => $workflowengine_services,
    }
  }
}
