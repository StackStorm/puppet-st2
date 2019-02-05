# @summary Creates an system (OS level) user for use with StackStorm
#
# @param client
#    Allow incoming connections from the defined user
# @param server
#    Server where connection requests originate (usually st2 server)
# @param create_sudo_entry
#    Manage the sudoers entry (default: false)
# @param ssh_public_key
#    SSH Public Key without leading key-type and end email.
# @param ssh_key_type
#    Type of SSH Key (ssh-dsa/ssh-rsa)
# @param ssh_private_key
#    SSH Private key. If not specified, then one will be generated.
# @param groups
#    List of groups (OS level) that this user should be a member of
# @param ssh_dir
#    Directory where SSH keys will be stored
#
# @example Custom SSH keys
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
  $ssh_dir           = "/home/${name}/.ssh",
) {
  include ::st2::params

  $_packs_group_name = $st2::params::packs_group_name

  if $create_sudo_entry {
    if !defined(Class['::sudo']) and !defined(Class['sudo']) {
      class { '::sudo':
        # do not purge files in /etc/sudoers.d/*
        purge               => false,
        # the 'enable' option (for some reason) purges all /etc/sudoers.d/* files
        enable              => false,
        # do not replace /etc/sudoers file
        config_file_replace => false,
      }
    }

    ensure_resource('sudo::conf', $name, {
      'priority' => '10',
      # note: passes in $name variable into template
      'content'  => template('st2/etc/sudoers.d/user.erb'),
    })
  }

  ensure_resource('group', $_packs_group_name, {
    'ensure' => present,
  })

  ensure_resource('group', $name, {
    'ensure' => present,
  })

  ensure_resource('user', $name, {
    'ensure'     => present,
    'shell'      => '/bin/bash',
    'gid'        => $name,
    'groups'     => $groups,
    'managehome' => true,
  })

  ### Setup SSH Keys ###
  ensure_resource('file', $ssh_dir, {
    'ensure' => directory,
    'owner'  => $name,
    'group'  => $name,
    'mode'   => '0700',
  })

  if $server {
    if !$ssh_private_key {
      $_ssh_keygen = true
      $_ssh_keygen_type = $ssh_key_type ? {
        undef => 'rsa',
        default => $ssh_key_type,
      }

      $_ssh_keygen_key_path = "${ssh_dir}/st2_${name}_key"
      exec { "generate ssh key ${_ssh_keygen_key_path}":
        command => "ssh-keygen -f ${_ssh_keygen_key_path} -t ${_ssh_keygen_type} -P ''",
        creates => $_ssh_keygen_key_path,
        path    => ['/usr/bin', '/sbin', '/bin'],
        require => File[$ssh_dir],
        before  => [File["${ssh_dir}/st2_${name}_key"],
                    File["${ssh_dir}/st2_${name}_key.pub"]],
      }

      # define these files so proper owner and permissions are set
      file { "${ssh_dir}/st2_${name}_key":
        ensure => file,
        owner  => $name,
        group  => $name,
        mode   => '0600',
      }

      file { "${ssh_dir}/st2_${name}_key.pub":
        ensure => file,
        owner  => $name,
        group  => $name,
        mode   => '0644',
      }
    }
    else {
      $_ssh_keygen = false
      file { "${ssh_dir}/st2_${name}_key":
        ensure  => file,
        owner   => $name,
        group   => $name,
        mode    => '0600',
        content => $ssh_private_key,
      }

      file { "${ssh_dir}/st2_${name}_key.pub":
        ensure  => file,
        owner   => $name,
        group   => $name,
        mode    => '0644',
        content => "${ssh_key_type} ${ssh_public_key}",
      }
    }
  }

  if $client {
    if $_ssh_keygen {
      # set proper owner + permissions on authorized keys
      ensure_resource('file', "${ssh_dir}/authorized_keys", {
        'ensure' => file,
        'owner'  => $name,
        'group'  => $name,
        'mode'   => '0600'
      })

      # add this user's key to authorized_keys
      exec { "add st2_${name}_key to ssh authorized keys":
        command   => "cat ${_ssh_keygen_key_path}.pub >> ${ssh_dir}/authorized_keys",
        onlyif    => "test `grep -f ${_ssh_keygen_key_path}.pub ${ssh_dir}/authorized_keys | wc -l` == 0",
        path      => ['/usr/bin', '/bin'],
        require   => File["${ssh_dir}/authorized_keys"],
        subscribe => Exec["generate ssh key ${_ssh_keygen_key_path}"],
      }
    }
    elsif $ssh_key_type and $ssh_public_key {
      ssh_authorized_key { "st2_${name}_key":
        type    => $ssh_key_type,
        user    => $name,
        key     => $ssh_public_key,
        require => File[$ssh_dir],
      }
    }
    else {
      notify { "St2::User[${name}]: ${st2::notices::user_missing_client_keys}": }
    }
  }
  ### END Setup SSH Keys ###
}
