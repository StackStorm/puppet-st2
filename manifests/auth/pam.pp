# @summary Auth class to configure and setup PAM authentication.
#
# @note This backend will NOT allow you to auth with PAM for the 'root' user.
#       You will need to auth a non-root user on the Linux host.
#
# @todo Need to configure st2auth service to run as root
#
# @param conf_file
#   The path where st2 config is stored
#
# @example Instantiate via st2
#  class { 'st2':
#    backend => 'pam',
#  }
#
# @example Instantiate via Hiera
#  st2::auth_backend: "pam"
#  st2::auth_backend_config: {}
#
class st2::auth::pam(
  $conf_file = $::st2::conf_file,
) inherits st2 {
  include st2::auth::common

  # config
  ini_setting { 'auth_backend':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'backend',
    value   => 'pam',
    tag     => 'st2::config',
  }
  ini_setting { 'auth_backend_kwargs':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'backend_kwargs',
    value   => '',
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
