# @summary Runners (Actionrunner and SensorConainer) configuration for st2
#
# @note This class doesn't need to be invoked directly, instead it's included 
# by other installation profiles to setup the configuration properly
#
# @param actionrunner_workers
#   Number of action runners.
#
class st2::config::runners (
  $actionrunner_workers = $st2::actionrunner_workers,
) inherits st2 {
  file { $st2::params::actionrunner_global_env_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('st2/etc/sysconfig/st2actionrunner.erb'),
    tag     => 'st2::config',
  }

  file { $st2::params::sensorcontainer_global_env_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('st2/etc/sysconfig/st2sensorcontainer.erb'),
    tag     => 'st2::config',
  }
}
