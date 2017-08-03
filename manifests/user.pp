# == Define: st2::user
#
#  Creates an system (OS level) user for use with st2 backend
#
# === Parameters
#  [*client*]            - Allow incoming connections from the defined user (default: true)
#  [*server*]            - Server where connection requests originate (usually st2 server) (default: false)
#  [*create_sudo_entry*] - Manage the sudoers entry (default: false)
#  [*ssh_public_key*]    - SSH Public Key without leading key-type and end email
#  [*ssh_key_type*]      - Type of SSH Key (ssh-dsa/ssh-rsa)
#  [*ssh_private_key*]   - Private key
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

  $_packs_group_name = $st2::params::packs_group_name
  $_ssh_dir = "/home/${name}/.ssh"

  ensure_resource('group', $_packs_group_name, {
    'ensure' => present,
  })

  if $create_sudo_entry {
    ensure_resource('sudo::conf', $name, {
      'priority' => '10',
      # note: passes in $name variable into template
      'content'  => template('st2/etc/sudoers.d/user.erb'),
    })
  }

  ensure_resource('user', $name, {
    'ensure'     => present,
    'shell'      => '/bin/bash',
    'gid'        => $name,
    'groups'     => $groups,
    'managehome' => true,
  })

  ### Setup SSH Keys ###
  if !defined(File["/home/${name}/.ssh"]) {
    file { "/home/${name}/.ssh":
      ensure => directory,
      owner  => $name,
      group  => $name,
      mode   => '0700',
    }
  }

  if $server {
    if !$ssh_private_key {
      $_ssh_keygen = true
      $_ssh_keygen_type = $ssh_key_type ? {
        undef => 'rsa',
        default => $ssh_key_type,
      }

      $_ssh_keygen_key_path = "${_ssh_dir}/st2_${name}_key"
      exec { "generate ssh key ${_ssh_keygen_key_path}":
        command => "ssh-keygen -f ${_ssh_keygen_key_path} -t ${_ssh_keygen_type} -P ''",
        creates => $_ssh_keygen_key_path,
        path    => ['/usr/bin', '/sbin', '/bin'],
        require => File[$_ssh_dir]
      }
    }
    else {
      $_ssh_keygen = false
      file { "/home/${name}/.ssh/st2_${name}_key":
        ensure  => file,
        owner   => $name,
        group   => 'root',
        mode    => '0600',
        content => $ssh_private_key,
      }

      file { "/home/${name}/.ssh/st2_${name}_key.pub":
        ensure  => file,
        owner   => $name,
        group   => 'root',
        mode    => '0644',
        content => $ssh_public_key,
      }
    }
  }

  if $client {
    if $_ssh_keygen {
      exec { "add st2_${name}_key to ssh authorized keys":
        command   => "cat ${_ssh_keygen_key_path}.pub >> ${_ssh_dir}/authorized_keys",
        onlyif    => "test `grep -f ${_ssh_keygen_key_path}.pub ${_ssh_dir}/authorized_keys | wc -l` == 0",
        path      => ['/usr/bin', '/bin'],
        require   => File[$_ssh_dir],
        subscribe => Exec["generate ssh key ${_ssh_keygen_key_path}"],
      }
    }
    elsif $ssh_key_type and $ssh_public_key {
      ssh_authorized_key { "st2_${name}_key":
        type    => $ssh_key_type,
        user    => $name,
        key     => $ssh_public_key,
        require => File[$_ssh_dir],
      }
    }
    else {
      notify { "St2::User[${name}]: ${st2::notices::user_missing_client_keys}": }
    }
  }
  ### END Setup SSH Keys ###
}
