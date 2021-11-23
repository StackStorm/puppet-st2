# @summary Common configuration for st2
#
# @note This class doesn't need to be invoked directly, instead it's included 
# by other installation profiles to setup the configuration properly
#
# @param version
#    Version of the st2 package to install
#
# @example Basic Usage
#   class { 'st2':
#     chatops_hubot_name => '"@RosieRobot"',
#   }
#
class st2::config::db (
  $conf_file              = $st2::conf_file,
  $db_host                = $st2::db_host,
  $db_port                = $st2::db_port,
  $db_name                = $st2::db_name,
  $db_username            = $st2::db_username,
  $db_password            = $st2::db_password,
) inherits st2 {

  ## Database settings (MongoDB)
  ini_setting { 'database_host':
    ensure  => present,
    path    => $conf_file,
    section => 'database',
    setting => 'host',
    value   => $db_host,
    tag     => 'st2::config',
  }
  ini_setting { 'database_port':
    ensure  => present,
    path    => $conf_file,
    section => 'database',
    setting => 'port',
    value   => $db_port,
    tag     => 'st2::config',
  }
  ini_setting { 'database_username':
    ensure  => present,
    path    => $conf_file,
    section => 'database',
    setting => 'username',
    value   => $db_username,
    tag     => 'st2::config',
  }
  ini_setting { 'database_name':
    ensure  => present,
    path    => $conf_file,
    section => 'database',
    setting => 'db_name',
    value   => $db_name,
    tag     => 'st2::config',
  }
  ini_setting { 'database_password':
    ensure  => present,
    path    => $conf_file,
    section => 'database',
    setting => 'password',
    value   => $db_password,
    tag     => 'st2::config',
  }
}
