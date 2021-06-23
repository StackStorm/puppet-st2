# @summary Auth class to configure and setup Keystone Based Authentication
#
# For information on parameters see the
# {backend documentation}[https://github.com/StackStorm/st2-auth-backend-keystone#configuration-options]
#
# @param conf_file
#    The path where st2 config is stored
# @param keystone_url
#    Keystone URL to connect to (default: '127.0.0.1')
# @param keystone_version
#    Keystone API version (default: '2')
#
# @example Instantiate via st2
#  class { 'st2':
#    auth_backend        => 'keystone',
#    auth_backend_config => {
#      keystone_url     => 'http://keystone.domain.tld:5000',
#      keystone_version => '3',
#    },
#  }
#
# @example Instantiate via Hiera
#  st2::auth_backend: "keystone"
#  st2::auth_backend_config:
#    keystone_url: "http://keystone.domain.tld:5000"
#    keystone_version: "3"
#
class st2::auth::keystone (
  $conf_file        = $st2::conf_file,
  $keystone_url     = 'http://127.0.0.1:5000',
  $keystone_version = '2',
) inherits st2 {
  include st2::auth::common

  # config
  ini_setting { 'auth_backend':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'backend',
    value   => 'keystone',
    tag     => 'st2::config',
  }
  ini_setting { 'auth_backend_kwargs':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'backend_kwargs',
    value   => "{\"keystone_url\": \"${keystone_url}\", \
      \"keystone_version\": \"${keystone_version}\"}",
    tag     => 'st2::config',
  }

  # install the backend package
  python::pip { 'st2-auth-backend-keystone':
    ensure     => present,
    pkgname    => 'st2-auth-backend-keystone',
    url        => 'git+https://github.com/StackStorm/st2-auth-backend-keystone.git@master#egg=st2_auth_backend_keystone',
    owner      => 'root',
    virtualenv => '/opt/stackstorm/st2',
    timeout    => 1800,
  }

  ##############
  # Dependencies
  Package<| tag == 'st2::server::packages' |>
  -> Python::Pip['st2-auth-backend-keystone']
  ~> Service['st2auth']
}
