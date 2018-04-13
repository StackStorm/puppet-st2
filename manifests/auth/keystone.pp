# Class: st2::auth::keystone
#
#  Auth class to configure and setup Keystone Based Authentication
#
#  For information on parameters see the backend documentation:
#   https://github.com/StackStorm/st2-auth-backend-keystone#configuration-options
#
# Parameters:
#
# [*keystone_url*]     - Keystone URL to connect to (default: '127.0.0.1')
# [*keystone_version*] - Keystone API version (default: '2')
#
# Usage:
#
#  # Instantiate via ::st2
#  class { '::st2':
#    auth_backend        => 'keystone',
#    auth_backend_config => {
#      keystone_url     => 'http://keystone.domain.tld:5000',
#      keystone_version => '3',
#    },
#  }
#
#  # Instantiate via Hiera
#  st2::auth_backend: "keystone"
#  st2::auth_backend_config:
#    keystone_url: "http://keystone.domain.tld:5000"
#    keystone_version: "3"
#
class st2::auth::keystone (
  $keystone_url     = 'http://127.0.0.1:5000',
  $keystone_version = '2',
) {
  include ::st2::auth::common

  # config
  ini_setting { 'auth_backend':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'backend',
    value   => 'keystone',
    tag     => 'st2::config',
  }
  ini_setting { 'auth_backend_kwargs':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
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
