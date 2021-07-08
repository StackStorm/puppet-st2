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
class st2::service_reload {
  case $facts['os']['family'] {
    'RedHat': {
      exec { 'Reload Daemon':
        command     => 'systemctl daemon-reload',
        path        => '/usr/bin',
        refreshonly => true,
      }
    }
    default: {
      fail("Unsupported managed repository for osfamily: ${facts['os']['family']}, operatingsystem: ${facts['os']['name']}")
    }
  }
}
