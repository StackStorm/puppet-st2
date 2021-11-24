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
