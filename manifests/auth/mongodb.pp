# Class: st2::auth::mongodb
#
#  Auth class to configure and setup MongoDB Based Authentication
#
#  For information on parameters see the backend documentation:
#   https://github.com/StackStorm/st2-auth-backend-mongodb#configuration-options
#
# Parameters:
#
# [*db_host*]     - Hostname for the MongoDB server (default: 127.0.0.1)
# [*db_port*]     - Port for the MongoDB server (default: 27017)
# [*db_name*]     - Database name in MongoDB (default: st2auth)
# [*db_username*] - Username for MongoDB login (default: st2auth)
# [*db_password*] - MongoDB DB storing credentials (default: st2auth)
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
  $db_auth = $::st2::mongodb_auth,
  $db_username = $::st2::db_username,
  $db_password = $::st2::db_password,
) inherits ::st2 {
  include ::st2::auth::common

  if $db_auth {
    $_kwargs = "{\"db_host\": \"${db_host}\", \"db_port\": \"${db_port}\",\
      \"db_name\": \"${db_name}\", \"db_username\": \"${db_username}\", \
      \"db_password\": \"${db_password}\"}"
  }
  else {
    $_kwargs = "{\"db_host\": \"${db_host}\", \"db_port\": \"${db_port}\",\
      \"db_name\": \"${db_name}\"}"
  }

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
    value   => $_kwargs,
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
