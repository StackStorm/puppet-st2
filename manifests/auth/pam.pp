# Class: st2::auth::pam
#
#  Auth class to configure and setup PAM authentication
#
# Parameters:
#
#  None
#
# Usage:
#
#  # Instantiate via ::st2
#  class { '::st2':
#    backend => 'pam',
#  }
#
#  # Instantiate via Hiera
#  st2::auth_backend: "pam"
#  st2::auth_backend_config: {}
#
class st2::auth::pam() {
  include ::st2::auth::common

  # config
  ini_setting { 'auth_backend':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'backend',
    value   => 'pam',
    tag     => 'st2::config',
  }

  # install package dependency
  $_dep_pkgs = $::osfamily ? {
    'Debian' => 'libpam0g',
    'RedHat' => 'pam-devel',
    default  => undef,
  }
  ensure_packages($_dep_pkgs,
                  {
                    'ensure' => 'present',
                    'tag'    => 'st2::auth::ldap',
                  })

  # install the backend package
  python::pip { 'st2-auth-backend-pam':
    ensure     => present,
    pkgname    => 'st2-auth-backend-pam',
    url        => 'git+https://github.com/StackStorm/st2-auth-backend-pam.git@master#egg=st2_auth_backend_pam',
    owner      => 'root',
    virtualenv => '/opt/stackstorm/st2',
    timeout    => 1800,
  }

  # dependencies
  Package<| tag == 'st2::server::packages' |>
  -> Package[$_dep_pkgs]
  -> Python::Pip['st2-auth-backend-pam']
  ~> Service['st2auth']
}
