# == Class: st2::profile::client
#
#  Profile to install all client libraries for st2
#
# === Parameters
#
#  [*version*] - Version of StackStorm to install
#  [*revision*] - Revision of StackStorm to install
#
# === Variables
#
#  [*_client_packages*] - Local scoped variable to store all st2 client packages. Default: $::st2::version
#  [*_client_dependencies*] - Local scoped variable to store any client dependencies Default: $::st2::revision
#
# === Examples
#
#  include st2::profile::client
#
class st2::profile::client (
  $version  = $::st2::version,
  $revision = $::st2::revision,
) inherits ::st2 {

  include '::st2::notices'
  include '::st2::params'

  $_client_packages = $st2::params::st2_client_packages
  $_client_dependencies = $st2::params::debian_client_dependencies

  st2::dependencies::install { $_client_dependencies: }

  st2::package::install { $_client_packages:
    version     => $version,
    revision    => $revision,
  }

  ### This should be a versioned download too... currently on master
  wget::fetch { 'Download st2client requirements.txt':
    source      => 'https://raw.githubusercontent.com/StackStorm/st2/master/st2client/requirements.txt',
    cache_dir   => '/var/cache/wget',
    destination => '/tmp/st2client-requirements.txt',
  }

  python::requirements { '/tmp/st2client-requirements.txt':
    require => Wget::Fetch['Download st2client requirements.txt'],
  }
}
