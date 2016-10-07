# == Class: st2::params
#
#  Main parameters to manage the st2 module
#
# === Variables
#  [*install_st2*] - Whether to install st2 package
#  [*install_chatops*] - Whether to install chatops package
#  [*install_web*] - Whether to install web package
#  [*repo_url*] - The URL where the StackStorm project is hosted on GitHub
#  [*conf_dir*] - The local directory where st2 config is stored
#
# === Examples
#
#  include st2::params
#
#  class { 'st2::params':
#
#  }
#

class st2::params {

  $install_st2 = true
  $install_chatops = true
  $install_web = true

  # Auth settings
  $auth_mode = standalone
  $auth_backend = pam

  # Non-user configurable parameters
  $repo_url = 'https://github.com/StackStorm/st2'
  $conf_dir = '/etc/st2'

  $st2_server_packages = [
    'st2',
    'st2web',
    'st2chatops',
    'mistral'
  ]

  # OS Init Type Detection
  # This block of code is used to detect the underlying Init Daemon
  # automatically.  This code is based on
  # https://github.com/jethrocarr/puppet-initfact/blob/master/lib/facter/initsystem.rb
  # This is Puppet code because masterless puppet has issues with pluginsync,
  # so we need a way to determine what the init system.
  case $::osfamily {
    'RedHat': {
      $package_type = 'rpm'
      if $::operatingsystem == 'Amazon' {
        $init_type = $::operatingsystemmajrelease ? {
          '2014'  => 'init',
          '2015'  => 'init',
          default => 'init',
        }
      } else {
        $init_type = $::operatingsystemmajrelease ? {
          '5'     => 'init',
          '6'     => 'init',
          default => 'systemd',
        }
      }
    }
    'Debian': {
      $package_type = 'deb'
      if $::operatingsystem == 'Debian' {
        $init_type = $::operatingsystemmajrelease ? {
          '6'     => 'init',
          '7'     => 'init',
          '8'     => 'systemd',
          default => 'systemd',
        }
      } elsif $::operatingsystem == 'Ubuntu' {
        $init_type = $::operatingsystemmajrelease ? {
          '12.04' => 'upstart',
          '14.04' => 'upstart',
          '14.10' => 'upstart',
          '15.04' => 'systemd',
          default => 'systemd',
        }
      }
    }
    default: {
      $package_type = undef
      $init_type = undef
    }
  }
}
