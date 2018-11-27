# Class that manages the st2workflowengine service (Orquesta)
class st2::workflowengine {
  include ::st2

  # st2workflowengine was introduced in 2.8.0
  if ($::st2::version == 'latest' or
      $::st2::version == 'present' or
      $::st2::version == 'installed' or
      versioncmp($::st2::version, '2.8.0') >= 0) {

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

    ########################################
    ## Services
    service { $::st2::params::workflowengine_services:
      ensure => 'running',
      enable => true,
      tag    => 'st2::service',
    }
  }
}
