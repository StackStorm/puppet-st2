# == Define: st2::user
#
#  Creates an admin user for use with st2
#
# === Parameters
#  [*client*]            - Allow incoming connections from the defined user (default: true)
#  [*server*]            - Server where connection requests originate (usually st2 server) (default: false)
#  [*create_sudo_entry*] - Manage the sudoers entry (default: false)
#  [*ssh_public_key*]    - SSH Public Key without leading key-type and end email
#  [*ssh_key_type*]      - Type of SSH Key (ssh-dsa/ssh-rsa)
#  [*ssh_private_key*]   - Private key
#
# === Variables
#  [*_robots_group_name*] - Local variable to grab the global robot group name
#
# === Examples
#
#  st2::user { 'stanley':
#    ssh_key_type => 'ssh-rsa',
#    ssh_public_key => 'AAAAAWESOMEKEY==',
#    ssh_private_key => '----- BEGIN RSA PRIVATE KEY -----\nDEADBEEF\n----- END RSA PRIVATE KEY -----',
#  }
#
define st2::user(
  $client            = true,
  $server            = false,
  $create_sudo_entry = false,
  $ssh_key_type      = undef,
  $ssh_public_key    = undef,
  $ssh_private_key   = undef,
  $groups            = undef,
) {
  include ::st2::params

  $_robots_group_name = $st2::params::robots_group_name
  $_packs_group_name = $st2::params::packs_group_name

  ensure_resource('group', $_robots_group_name, {
    'ensure' => present,
  })

  ensure_resource('group', $_packs_group_name, {
    'ensure' => present,
  })

  if $create_sudo_entry {
    ensure_resource('sudo::conf', $_robots_group_name, {
      'priority' => '10',
      'content'  => "%${_robots_group_name} ALL=(ALL) NOPASSWD: SETENV: ALL",
    })
  }

  ensure_resource('user', $name, {
    'ensure'     => present,
    'shell'      => '/bin/bash',
    'gid'        => 'st2robots',
    'groups'     => $groups,
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
