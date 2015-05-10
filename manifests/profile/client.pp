# == Class: st2::profile::client
#
#  Profile to install all client libraries for st2
#
# === Parameters
#
#  [*version*] - Version of StackStorm to install
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

  $_auth = $::st2::auth
  $_api_url = $::st2::api_url
  $_auth_url = $::st2::auth_url
  $_cli_username = $::st2::cli_username
  $_cli_password = $::st2::cli_password

  st2::dependencies::install { $_client_dependencies: }

  st2::package::install { $_client_packages:
    version  => $version,
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

  file { '/root/.st2':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  if $_api_url {
    ini_setting { 'api_url':
      ensure  => 'present',
      path    => '/root/.st2/config',
      section => 'api',
      setting => 'url',
      value   => "${_api_url}/v1,
    }
  }

  if $_auth_url {
    ini_setting { 'auth_url':
      ensure  => 'present',
      path    => '/root/.st2/config',
      section => 'auth',
      setting => 'url',
      value   => $_auth_url,
    }
  }

  if $auth {
    ini_setting { 'credentials_username':
      ensure  => 'present',
      path    => '/root/.st2/config',
      section => 'credentials',
      setting => 'username',
      value   => $_cli_username,
    }
    ini_setting { 'credentials_password':
      ensure  => 'present',
      path    => '/root/.st2/config',
      section => 'credentials',
      setting => 'password',
      value   => $_cli_password,
    }
  }

  File['/root/.st2'] -> Ini_setting <| tag == 'st2::profile::client' |>
}
