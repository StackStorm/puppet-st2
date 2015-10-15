# Definition: st2::helper::actionrunner_upstart
#
#  This defined type is used to simulate a loop in
#  pre-4.0 clients, creating N instances of the
#  st2actionrunner-worker upstart script.
#
#  Usage:
#    st2::helper::actionrunner_upstart { '1': }
define st2::helper::actionrunner_upstart (
  $worker_id = $name,
) {
  file { "/etc/init/st2actionrunner-${worker_id}.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('st2/etc/init/st2actionrunner-worker.conf.erb'),
  }

  service { "st2actionrunner-${worker_id}":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    tag        => 'st2::server',
  }
}
