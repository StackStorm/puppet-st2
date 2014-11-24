define st2::user(
  $client            = true,
  $server            = false,
  $create_sudo_entry = false,
  $ssh_key_type      = undef,
  $ssh_public_key    = undef,
  $ssh_private_key   = undef,
  $uid               = '800',
) {
  include ::st2::params

  $_robots_group_name = $st2::params::robots_group_name
  $_robots_group_gid  = $st2::params::robots_group_gid

  ensure_resource('group', $_robots_group_name, {
    'ensure' => present,
    'gid'    => $_robots_group_gid,
  })

  if $create_sudo_entry {
    ensure_resource('sudo::conf', $_robots_group_name, {
      'priority' => '10',
      'content'  => "%${_robots_group_name} ALL=(ALL) NOPASSWD: ALL",
    })
  }

  ensure_resource('user', $name, {
    'ensure'     => present,
    'shell'      => '/bin/bash',
    'uid'        => $uid,
    'gid'        => 'st2robots',
    'managehome' => true,
  })

  ### Setup SSH Keys ###
  if !defined(File["/home/${name}/.ssh"]) {
    file { "/home/${name}/.ssh":
      ensure => directory,
      owner  => $name,
      group  => $_robots_group_name,
      mode   => '0750',
    }
  }

  if $client {
    if !$ssh_key_type or !$ssh_public_key {
      fail("St2::User[${name}]: ${st2::notices::user_missing_client_keys}")
    }
    ssh_authorized_key { "st2_${name}_key":
      type    => $ssh_key_type,
      user    => $name,
      key     => $ssh_public_key,
      require => File["/home/${name}/.ssh"],
    }
  }
  if $server {
    if !$ssh_private_key {
      fail("St2::User[${name}]:: ${st2::notices::user_missing_private_key}")
    }
    file { "/home/${name}/.ssh/st2_${name}_key":
      ensure  => file,
      owner   => $name,
      group   => 'root',
      mode    => '0400',
      content => $ssh_private_key,
    }
  }
  ### END Setup SSH Keys ###
}
