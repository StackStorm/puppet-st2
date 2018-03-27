# Class: st2::auth::mongodb
#
#  Auth class to configure and setup MongoDB Based Authentication
#
# Parameters:
#
# [*db_host*] - MongoDB Host to connect to (default: 127.0.0.1)
# [*db_port*] - MongoDB Port to connect to (default: 27017)
# [*db_name*] - MongoDB DB storing credentials (default: st2auth)
#
# Usage:
#
#  # basic usage, accepting all defaults in ::st2::auth
#  include ::st2::auth::mongodb
#
#  # advanced usage for overriding defaults in ::st2::auth
#  class { '::st2::auth':
#    backend        => 'mongodb',
#    backend_config => {
#      db_host => 'mongodb.stackstorm.net',
#      db_port => '1234',
#      db_name => 'myauthdb',
#    },
#  }
class st2::auth::mongodb (
  $db_host = $::st2::db_host,
  $db_port = $::st2::db_port,
  $db_name = 'st2auth',
) {
  include ::st2::auth

  ini_setting { 'auth_backend':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'backend',
    value   => 'mongodb',
    tag     => 'st2::config',
  }
  ini_setting { 'auth_backend_kwargs':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'backend_kwargs',
    value   => "{\"db_host\": \"${db_host}\", \"db_port\": \"${db_port}\",\
     \"db_name\": \"${db_name}\"}",
    tag     => 'st2::config',
  }

  # install the backend package
  python::pip { 'st2-auth-backend-mongodb':
    ensure     => 'latest',
    pkgname    => 'st2-auth-backend-mongodb',
    url        => 'git+https://github.com/StackStorm/st2-auth-backend-mongodb.git@master#egg=st2_auth_backend_mongodb',
    owner      => 'root',
    virtualenv => '/opt/stackstorm/st2/bin',
    timeout    => 1800,
  }

  # dependencies
  Package<| tag == 'st2::server::packages' |>
  -> Python::Pip['st2-auth-backend-ldap']
  ~> Service['st2auth']
}
