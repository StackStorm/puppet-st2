# == Class: st2::params
#
#  Main parameters to manage the st2 module
#
# === Parameters
#  [*robots_group_name*] - The name of the group created to hold the st2 admin user
#  [*robots_group_id*] - The GID of the group created to hold the st2 admin user.
#
# === Variables
#  [*repo_url*] - The URL where the StackStorm project is hosted on GitHub
#  [*conf_dir*] - The local directory where st2 config is stored
#  [*subsystems*] - Different executable subsystems within StackStorm
#  [*component_map*] - Hash table of mappings of Subsystems -> Components
#  [*st2_server_packages*] - A list of all upstream server packages to grab from upstream package server
#  [*st2_client_packages*] - A list of all upstream client packages to grab from upstream package server
#  [*debian_dependencies*] - Any dependencies needed to successfully run st2 server on the Debian OS Family
#  [*debian_client_dependencies*] - Any dependencies needed to successfully run st2 client on the Debian OS Family
#  [*debian_mongodb_dependencies*] - MongoDB Dependencies (if installed via this module)
#  [*redhat_dependencies*] - Any dependencies needed to successfully run st2 server on the RedHat OS Family
#  [*redhat_client_dependencies*] - Any dependencies needed to successfully run st2 client on the RedHat OS Family
#
# === Examples
#
#  include st2::params
#
#  class { 'st2::params':
#
#  }
#

class st2::params(
  $robots_group_name = 'st2robots',
  $robots_group_gid  = 800,
) {
  $subsystems = [
    'actionrunner', 'api', 'sensorcontainer',
    'rulesengine', 'resultstracker', 'notifier',
    'auth'
  ]

  $component_map = {
    actionrunner       => 'st2actions',
    api                => 'st2api',
    auth               => 'st2auth',
    notifier           => 'st2actions',
    resultstracker     => 'st2actions',
    rulesengine        => 'st2reactor',
    sensorcontainer    => 'st2reactor
    st2actionrunner    => 'st2actions',
    st2api             => 'st2api',
    st2auth            => 'st2auth',
    st2notifier        => 'st2actions',
    st2resultstracker  => 'st2actions',
    st2rulesengine     => 'st2reactor',
    st2sensorcontainer => 'st2reactor',
  }
  $subsystem_map = {
    actionrunner       => 'st2actionrunner',
    api                => 'st2api',
    auth               => 'st2auth',
    notifier           => 'st2notifier',
    resultstracker     => 'st2resultstracker',
    rulesengine        => 'st2rulesengine',
    sensorcontainer    => 'st2sensorcontainer',
    st2actionrunner    => 'st2actionrunner',
    st2api             => 'st2api',
    st2auth            => 'st2auth',
    st2notifier        => 'st2notifier',
    st2resultstracker  => 'st2resultstracker',
    st2rulesengine     => 'st2rulesengine',
    st2sensorcontainer => 'st2sensorcontainer',
  }

  # Non-user configurable parameters
  $repo_url = 'https://github.com/StackStorm/st2'
  $conf_dir = '/etc/st2'

  $st2_server_packages = [
    'st2common',
    'st2reactor',
    'st2actions',
    'st2api',
    'st2auth',
    'st2debug',
  ]
  case $::osfamily {
    'Debian': {
      $st2_client_packages = [
        'python-st2client',
      ]
    }
    'RedHat': {
      $st2_client_packages = [
        'st2client',
      ]
    }
    default: {
      $st2_client_packages = [
        'python-st2client',
      ]
    }
  }

  ### Debian Specific Information ###
  $debian_dependencies = [
    'make',
    'realpath',
    'gcc',
    'python-yaml',
    'libssl-dev',
    'libyaml-dev',
    'libffi-dev',
    'libxml2-dev',
    'libxslt1-dev',
    'python-tox',
  ]
  $debian_client_dependencies = [
    'python-prettytable',
    'python-jsonpath-rw',
    'python-dateutil',
  ]
  $debian_mongodb_dependencies = [
    'mongodb-dev',
  ]
  ### END Debian Specific Information ###

  ### RedHat Specific Information ###
  $redhat_dependencies = [
    'gcc-c++',
    'openssl-devel',
    'libyaml-devel',
    'libffi-devel',
    'libxml2-devel',
    'libxslt-devel',
  ]
  $redhat_client_dependencies = [
    'python-prettytable',
  ]
  ### END RedHat Specific Information ###

  # OS Init Type Detection
  # This block of code is used to detect the underlying Init Daemon
  # automatically.  This code is based on
  # https://github.com/jethrocarr/puppet-initfact/blob/master/lib/facter/initsystem.rb
  # This is Puppet code because masterless puppet has issues with pluginsync,
  # so we need a way to determine what the init system.
  case $::osfamily {
    'RedHat': {
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
      $init_type = undef
    }
  }
}
