# == Class: st2::profile::client
#
#  Profile to install all client libraries for st2
#
# === Parameters
#
#  [*version*]              - Version of StackStorm to install
#  [*base_url*]             - CLI config - Base URL lives
#  [*api_version*]          - CLI config - API Version
#  [*debug*]                - CLI config - Enable/Disable Debug
#  [*cache_token*]          - CLI config - True to cache auth token until it expires
#  [*silence_ssl_warnings*] - CLI Config - True to silence any SSL related warnings emitted by the client.
#  [*username*]             - CLI config - Auth Username
#  [*password*]             - CLI config - Auth Password
#  [*api_url*]              - CLI config - API URL
#  [*auth_url*]             - CLI config - Auth URL
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
  $auth                 = $::st2::auth,
  $version              = $::st2::version,
  $autoupdate           = $::st2::autoupdate,
  $revision             = $::st2::revision,
  $api_url              = $::st2::cli_api_url,
  $auth_url             = $::st2::cli_auth_url,
  $base_url             = $::st2::cli_base_url,
  $username             = $::st2::cli_username,
  $password             = $::st2::cli_password,
  $api_version          = $::st2::cli_api_version,
  $cacert               = $::st2::cli_cacert,
  $debug                = $::st2::cli_debug,
  $cache_token          = $::st2::cli_cache_token,
  $silence_ssl_warnings = $::st2::cli_silence_ssl_warnings,
  $global_env           = $::st2::global_env,
) inherits ::st2 {
  $_version = $autoupdate ? {
    true    => st2_latest_stable(),
    default => $version,
  }
  $_revision = $autoupdate ? {
    true    => undef,
    default => $revision,
  }
  $_bootstrapped = $::st2client_bootstrapped ? {
    undef   => false,
    default => true,
  }
  $_git_tag = $_version ? {
    /dev/   => 'master',
    default => "v${_version}",
  }

  include '::st2::notices'
  include '::st2::params'

  $_client_packages = $st2::params::st2_client_packages
  $_client_dependencies = $st2::params::debian_client_dependencies

  st2::dependencies::install { $_client_dependencies: }

  st2::package::install { $_client_packages:
    version  => $_version,
    revision => $_revision,
  }

  ### This should be a versioned download too... currently on master
  ## Only attempt to download this if the server has been appropriately bootstrapped.
  if $autoupdate or ! $_bootstrapped {
    wget::fetch { 'Download st2client requirements.txt':
      source      => "https://raw.githubusercontent.com/StackStorm/st2/${_git_tag}/st2client/requirements.txt",
      cache_dir   => '/var/cache/wget',
      destination => '/tmp/st2client-requirements.txt'
    }

    # More RedHat 6 hackery.  Need to use pip2.7.
    case $::osfamily {
      'Debian': {
        python::requirements { '/tmp/st2client-requirements.txt':
          notify => File['/etc/facter/facts.d/st2client_bootstrapped.txt'],
          require => Wget::Fetch['Download st2client requirements.txt']
        }
      }
      'RedHat': {
        if $operatingsystemmajrelease == '6' {
          exec { 'pip27_install_st2client_reqs':
            path    => '/usr/bin:/usr/sbin:/bin:/sbin',
            command => 'pip2.7 install -U -r /tmp/st2client-requirements.txt',
            notify  => File['/etc/facter/facts.d/st2client_bootstrapped.txt'],
            require => Wget::Fetch['Download st2client requirements.txt']
          }
        } else {
          python::requirements { '/tmp/st2client-requirements.txt':
            notify => File['/etc/facter/facts.d/st2client_bootstrapped.txt'],
            require => Wget::Fetch['Download st2client requirements.txt']
          }
        }
      }
    }
  }


  # Setup st2client settings for Root user by default
  st2::client::settings { 'root':
    homedir              => '/root',
    auth                 => $auth,
    api_url              => $api_url,
    auth_url             => $auth_url,
    base_url             => $base_url,
    username             => $username,
    password             => $password,
    api_version          => $api_version,
    cacert               => $cacert,
    debug                => $debug,
    cache_token          => $cache_token,
    silence_ssl_warnings => $silence_ssl_warnings,
  }

  # Once the system is properly bootstrapped, leave a breadcrumb for future runs
  file { '/etc/facter/facts.d/st2client_bootstrapped.txt':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => 'st2client_bootstrapped=true',
  }

  # Setup global environment variables:
  if $global_env {
    file { '/etc/profile.d/st2.sh':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template('st2/etc/profile.d/st2.sh.erb'),
    }
  }
}
