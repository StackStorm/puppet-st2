# @summary Messaging (RabbitMQ) configuration for st2
#
# @note This class doesn't need to be invoked directly, instead it's included 
# by other installation profiles to setup the configuration properly
#
# @param conf_file
#   The path where st2 config is stored
# @param rabbitmq_username
#   Username for the RabbitMQ connection
# @param rabbitmq_password
#   Password for the RabbitMQ connection
# @param rabbitmq_hostname
#   Hostname for the RabbitMQ connection
# @param rabbitmq_port
#   Port for the RabbitMQ connection
# @param rabbitmq_vhost
#  Vhost for the RabbitMQ connection
#
class st2::config::messaging (
  $conf_file              = $st2::conf_file,
  $rabbitmq_username      = $st2::rabbitmq_username,
  $rabbitmq_password      = $st2::rabbitmq_password,
  $rabbitmq_hostname      = $st2::rabbitmq_hostname,
  $rabbitmq_port          = $st2::rabbitmq_port,
  $rabbitmq_vhost         = $st2::rabbitmq_vhost,
) inherits st2 {

  ## Messaging Settings (RabbitMQ)

  # URL encode the RabbitMQ password, in case it contains special characters that
  # can mess up the URL in the config.
  $_rabbitmq_pass = st2::urlencode($rabbitmq_password)
  ini_setting { 'messaging_url':
    ensure  => present,
    path    => $conf_file,
    section => 'messaging',
    setting => 'url',
    value   => "amqp://${rabbitmq_username}:${_rabbitmq_pass}@${rabbitmq_hostname}:${rabbitmq_port}/${rabbitmq_vhost}",
    tag     => 'st2::config',
  }
}
