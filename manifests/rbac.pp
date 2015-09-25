# Definition: st2::rbac
#
# This defined type creates RBAC resources for users
# This is an enterprise feature, and requires a license
# to be used.
#
define st2::rbac (
  $ensure      = 'present',
  $user        = $name,
  $description = "Created and managed by Puppet",
  $roles       = [],
) {
  $_rbac_dir = '/opt/stackstorm/rbac'
  $_enabled_state = $ensure ? {
    'present' => 'true',
    default   => 'false',
  }

  ensure_resource('file', $_rbac_dir, {
    'ensure'  => 'directory',
    'owner'   => 'root',
    'group'   => 'root',
    'mode'    => '0755',
    'require' => Class['::st2::profile::server'],
  })
  ensure_resource('file', "${_rbac_dir}/assignments", {
    'ensure'  => 'directory',
    'owner'   => 'root',
    'group'   => 'root',
    'mode'    => '0755',
    'require' => Class['::st2::profile::server'],
  })
  ensure_resource('file', "${_rbac_dir}/roles", {
    'ensure'  => 'directory',
    'owner'   => 'root',
    'group'   => 'root',
    'mode'    => '0755',
    'require' => Class['::st2::profile::server'],
  })
  ensure_resource('file', "${_rbac_dir}/assignments", {
    'ensure'  => 'directory',
    'owner'   => 'root',
    'group'   => 'root',
    'mode'    => '0755',
    'require' => Class['::st2::profile::server'],
  })
  ensure_resource('exec', 'reload st2 rbac definitions', {
    'cmd'         => 'st2-apply-rbac-definitions',
    'refreshonly' => 'true',
    'path'        => '/usr/sbin:/usr/bin:/sbin:/bin',
  })
  file { "${_rbac_dir}/assignments/${user}.yaml":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('st2/rbac/assignments/user.yaml.erb'),
    notify  => Exec['reload st2 rbac definitions'],
  }
}
