define st2::user(
  $client              = true,
  $server              = false,
  $create_sudo_entry   = false,
  $generate_keypair    = false,
  $ssh_key_type        = undef,
  $ssh_public_key      = undef,
  $ssh_ssh_private_key = undef,
  $uid                 = '800',
) {
  include ::st2::params

  $_robot_group_name = $st2::params::robot_group_name
  $_robot_group_gid  = $st2::params::robot_group_gid

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
      fail("St2::User[${name}]: Unable to create user ${name} to be used by StackStorm for remote access. Please supply both a \$ssh_key_type and \$ssh_public_key for this resource.")
    }
    ssh_authorized_keys { "st2_${name}_key":
      type => $ssh_key_type,
      user => $name,
      key  => $ssh_public_key,
    }
  }
  if $server {
    if $generate_keypair {
      exec { "Generate keypair for st2robot: ${name}":
        command => "ssh-keygen -f /home/${name}/.ssh/st2_${name}_key -P ''",
        creates => "/home/${name}/.ssh/st2_${name}_key",
      }
    } else {
      file { "/home/${name}/.ssh/st2_${name}_key":
        ensure  => file,
        owner   => $name,
        group   => 'root',
        mode    => '0400',
        content => $ssh_private_key,
      }
    }
  }
  ### END Setup SSH Keys ###
}
