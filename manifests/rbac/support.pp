class st2::rbac::support {
  $_rbac_dir = '/opt/stackstorm/rbac'

  file { $_rbac_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    require => Class['::st2::profile::server'],
  }

  file { "${_rbac_dir}/assignments":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Class['::st2::profile::server'],
  }

  file { "${_rbac_dir}/roles":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Class['::st2::profile::server'],
  }

  exec { 'reload st2 rbac definitions':
    command         => 'st2-apply-rbac-definitions',
    refreshonly     => 'true',
    path            => '/usr/sbin:/usr/bin:/sbin:/bin',
  }
}
