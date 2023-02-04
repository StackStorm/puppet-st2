# @summary StackStorm compatable installation of MongoDB and dependencies.
#
# @param metrics_include
#    Should metrics be enabled
# @param metric_driver
#    The driver to use for the metrics. Default='statsd'
# @param metric_host
#    The host to pull metrics from. Default='127.0.0.1'
# @param metric_port
#    The port for the metrics. Default='8125'
#
# @example Basic Usage
#   include st2::profile::metrics
#
# @example Customize (done via st2)
#   class { 'st2':
#     metrics_include => true,
#     metric_driver   => 'statsd',
#     metric_host     => '127.0.0.1',
#     metric_port     => '8125',
#   }
#   include st2::profile::metrics
#
class st2::profile::metrics (
  $metrics_include = $st2::metrics_include,
  $metric_driver   = $st2::metric_driver,
  $metric_host     = $st2::metric_host,
  $metric_port     = $st2::metric_port,
) inherits st2 {
  if $metrics_include {
    ini_setting { 'metrics_driver':
      path    => '/etc/st2/st2.conf',
      section => 'metrics',
      setting => 'driver',
      value   => $metric_driver,
      tag     => 'st2::config',
    }

    ini_setting { 'metrics_host':
      path    => '/etc/st2/st2.conf',
      section => 'metrics',
      setting => 'host',
      value   => $metric_host,
      tag     => 'st2::config',
    }

    ini_setting { 'metrics_port':
      path    => '/etc/st2/st2.conf',
      section => 'metrics',
      setting => 'port',
      value   => $metric_port,
      tag     => 'st2::config',
    }
  }
}
