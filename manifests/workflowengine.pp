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
class st2::workflowengine {
  include st2

  # st2workflowengine was introduced in 2.8.0
  if st2::version_ge('2.8.0') {

    $_logger_config = $st2::syslog ? {
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

    ########################################
    ## Services
    service { $st2::params::workflowengine_services:
      ensure => 'running',
      enable => true,
      tag    => 'st2::service',
    }
  }
}
