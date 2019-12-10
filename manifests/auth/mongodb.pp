# @summary Auth class to configure and setup MongoDB Based Authentication
#
# For information on parameters see the
# {backend documentation}[https://github.com/StackStorm/st2-auth-backend-mongodb#configuration-options]
#
# @param conf_file
#    The path where st2 config is stored
# @param db_host
#    Hostname for the MongoDB server (default: 127.0.0.1)
# @param db_port
#    Port for the MongoDB server (default: 27017)
# @param db_name
#    Database name in MongoDB (default: st2auth)
# @param db_auth
#    Enable authentication with MongoDB (required for MongoDB installs with auth enabled)
# @param db_username
#    Username for MongoDB login (default: st2auth)
# @param db_password
#    Password for MongoDB login (default: st2auth)
#
# @example Instantiate via st2
#  class { 'st2':
#    auth_backend        => 'mongodb',
#    auth_backend_config => {
#      db_host => 'mongodb.stackstorm.net',
#      db_port => '1234',
#      db_name => 'myauthdb',
#    },
#  }
#
# @example Instantiate via Hiera
#  st2::auth_backend: "mongodb"
#  st2::auth_backend_config:
#    db_host: "mongodb.stackstorm.net"
#    db_port: "1234"
#    db_name: "myauthdb"
#
class st2::auth::mongodb (
  $conf_file   = $::st2::conf_file,
  $db_host     = $::st2::db_host,
  $db_port     = $::st2::db_port,
  $db_name     = 'st2auth',
  $db_auth     = $::st2::mongodb_auth,
  $db_username = $::st2::db_username,
  $db_password = $::st2::db_password,
) inherits st2 {
  include st2::auth::common

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
    path    => $conf_file,
    section => 'auth',
    setting => 'backend',
    value   => 'mongodb',
    tag     => 'st2::config',
  }
  ini_setting { 'auth_backend_kwargs':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'backend_kwargs',
    value   => $_kwargs,
    tag     => 'st2::config',
  }

  # install the backend package
  python::pip { 'st2-auth-backend-mongodb':
    ensure     => present,
    pkgname    => 'st2-auth-backend-mongodb',
    url        => 'git+https://github.com/StackStorm/st2-auth-backend-mongodb.git@master#egg=st2_auth_backend_mongodb',
    owner      => 'root',
    virtualenv => '/opt/stackstorm/st2',
    timeout    => 1800,
  }

  # dependencies
  Package<| tag == 'st2::server::packages' |>
  -> Python::Pip['st2-auth-backend-mongodb']
  ~> Service['st2auth']
}
