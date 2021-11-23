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
class st2::config::coordination (
  $conf_file              = $st2::conf_file,
  $redis_hostname         = $st2::redis_hostname,
  $redis_port             = $st2::redis_port,
  $redis_password         = $st2::redis_password,
) inherits st2 {

  ## Coordination Settings (Redis)
  $_redis_url  = "redis://:${redis_password}@${redis_hostname}:${redis_port}/"
  ini_setting { 'coordination_url':
    path    => $conf_file,
    section => 'coordination',
    setting => 'url',
    value   => $_redis_url,
    tag     => 'st2::config',
  }
}
