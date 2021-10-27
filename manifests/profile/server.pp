# @summary Profile to install, configure and manage all server components for st2
#
# @param version
#    Version of StackStorm to install
# @param conf_dir
#    The directory where st2 configs are stored
# @param conf_file
#    The path where st2 config is stored
# @param auth
#    Toggle Auth
# @param actionrunner_workers
#    Set the number of actionrunner processes to start
# @param st2api_listen_ip
#    Listen IP for st2api process
# @param st2api_listen_port
#    Listen port for st2api process
# @param st2auth_listen_ip
#    Listen IP for st2auth process
# @param st2auth_listen_port
#    Listen port for st2auth process
# @param syslog
#    Routes all log messages to syslog
# @param syslog_host
#    Syslog host.
# @param syslog_protocol
#    Syslog protocol.
# @param syslog_port
#    Syslog port.
# @param syslog_facility
#    Syslog facility.
# @param ssh_key_location
#    Location on filesystem of Admin SSH key for remote runner
# @param db_username
#    Username to connect to MongoDB with (default: 'stackstorm')
# @param db_password
#    Password for 'stackstorm' user in MongDB.
# @param index_url
#    Url to the StackStorm Exchange index file. (default undef)
#
# @example Basic usage
#  include st2::profile::server
#
class st2::profile::server (
  $version                = $st2::version,
  $conf_dir               = $st2::conf_dir,
  $conf_file              = $st2::conf_file,
  $auth                   = $st2::auth,
  $actionrunner_workers   = $st2::actionrunner_workers,
  $syslog                 = $st2::syslog,
  $syslog_host            = $st2::syslog_host,
  $syslog_port            = $st2::syslog_port,
  $syslog_facility        = $st2::syslog_facility,
  $syslog_protocol        = $st2::syslog_protocol,
  $st2api_listen_ip       = '0.0.0.0',
  $st2api_listen_port     = '9101',
  $st2auth_listen_ip      = '0.0.0.0',
  $st2auth_listen_port    = '9100',
  $ssh_key_location       = $st2::ssh_key_location,
  $ng_init                = $st2::ng_init,
  $db_username            = $st2::db_username,
  $db_password            = $st2::db_password,
  $rabbitmq_username      = $st2::rabbitmq_username,
  $rabbitmq_password      = $st2::rabbitmq_password,
  $rabbitmq_hostname      = $st2::rabbitmq_hostname,
  $rabbitmq_port          = $st2::rabbitmq_port,
  $rabbitmq_vhost         = $st2::rabbitmq_vhost,
  $redis_hostname         = $st2::redis_hostname,
  $redis_port             = $st2::redis_port,
  $redis_password         = $st2::redis_password,
  $index_url              = $st2::index_url,
  $packs_group            = $st2::packs_group_name,
) inherits st2 {
  include st2::notices
  include st2::params

  $_enable_auth = $auth ? {
    true    => 'True',
    default => 'False',
  }
  $_logger_config = $syslog ? {
    true    => 'syslog',
    default => 'logging',
  }

  ########################################
  ## Packages
  package { $st2::params::st2_server_packages:
    ensure => $version,
    tag    => ['st2::packages', 'st2::server::packages'],
  }

  ensure_resource('file', '/opt/stackstorm', {
    'ensure' => 'directory',
    'owner'  => 'root',
    'group'  => 'root',
    'mode'   => '0755',
    'tag'    => 'st2::server',
  })

  ensure_resource('group', $packs_group, {
    'ensure' => present,
  })

  ensure_resource('file', '/opt/stackstorm/configs', {
    'ensure'  => 'directory',
    'owner'   => 'st2',
    'group'   => 'root',
    'mode'    => '0755',
    'tag'     => 'st2::server',
  })

  ensure_resource('file', '/opt/stackstorm/packs', {
    'ensure'  => 'directory',
    'owner'   => 'root',
    'group'   => $packs_group,
    'mode'    => '0775',
    'tag'     => 'st2::server',
  })

  ensure_resource('file', '/opt/stackstorm/virtualenvs', {
    'ensure'  => 'directory',
    'owner'   => 'root',
    'group'   => $packs_group,
    'mode'    => '0755',
    'tag'     => 'st2::server',
  })

  recursive_file_permissions { '/opt/stackstorm/packs':
    owner => 'root',
    group => $packs_group,
    tag   => 'st2::server',
  }

  recursive_file_permissions { '/opt/stackstorm/virtualenvs':
    owner => 'root',
    group => $packs_group,
    tag   => 'st2::server',
  }

  ########################################
  ## Config
  file { $conf_dir:
    ensure => directory,
  }

  ## SSH
  ini_setting { 'ssh_key_stanley':
    ensure  => present,
    path    => $conf_file,
    section => 'system_user',
    setting => 'ssh_key_file',
    value   => $ssh_key_location,
    tag     => 'st2::config',
  }

  ## ActionRunner settings
  ini_setting { 'actionrunner_logging':
    ensure  => present,
    path    => $conf_file,
    section => 'actionrunner',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.actionrunner.conf",
    tag     => 'st2::config',
  }

  file { $st2::params::actionrunner_global_env_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('st2/etc/sysconfig/st2actionrunner.erb'),
    tag     => 'st2::config',
  }

  ## API Settings
  ini_setting { 'api_listen_ip':
    ensure  => present,
    path    => $conf_file,
    section => 'api',
    setting => 'host',
    value   => $st2api_listen_ip,
    tag     => 'st2::config',
  }
  ini_setting { 'api_listen_port':
    ensure  => present,
    path    => $conf_file,
    section => 'api',
    setting => 'port',
    value   => $st2api_listen_port,
    tag     => 'st2::config',
  }
  ini_setting { 'api_allow_origin':
    ensure  => 'present',
    path    => $conf_file,
    section => 'api',
    setting => 'allow_origin',
    value   => '*',
    tag     => 'st2::config',
  }
  ini_setting { 'api_logging':
    ensure  => present,
    path    => $conf_file,
    section => 'api',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.api.gunicorn.conf",
    tag     => 'st2::config',
  }

  ## Authentication Settings
  ini_setting { 'auth':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'enable',
    value   => $_enable_auth,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_listen_port':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'port',
    value   => $st2auth_listen_port,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_listen_ip':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'host',
    value   => $st2auth_listen_ip,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_logging':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.auth.gunicorn.conf",
    tag     => 'st2::config',
  }

  ## Database settings (MongoDB)
  ini_setting { 'database_username':
    ensure  => present,
    path    => $conf_file,
    section => 'database',
    setting => 'username',
    value   => $db_username,
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

  ## Messaging Settings (RabbitMQ)

  # URL encode the RabbitMQ password, in case it contains special characters that
  # can mess up the URL in the config.
  $_rabbitmq_pass = st2::urlencode($rabbitmq_password)
  ini_setting { 'messaging_url':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'messaging',
    setting => 'url',
    value   => "amqp://${rabbitmq_username}:${_rabbitmq_pass}@${rabbitmq_hostname}:${rabbitmq_port}/${rabbitmq_vhost}",
    tag     => 'st2::config',
  }

  ## Coordination Settings (Redis)

  $_redis_url  = "redis://:${redis_password}@${redis_hostname}:${redis_port}/"
  ini_setting { 'coordination_url':
    path    => '/etc/st2/st2.conf',
    section => 'coordination',
    setting => 'url',
    value   => $_redis_url,
    tag     => 'st2::config',
  }

  ## Resultstracker Settings
  ini_setting { 'resultstracker_logging':
    ensure  => present,
    path    => $conf_file,
    section => 'resultstracker',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.resultstracker.conf",
    tag     => 'st2::config',
  }

  ## Garbage collector Settings
  ini_setting { 'garbagecollector_logging':
    ensure  => present,
    path    => $conf_file,
    section => 'garbagecollector',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.garbagecollector.conf",
    tag     => 'st2::config',
  }

  ## Sensor container Settings
  ini_setting { 'sensorcontainer_logging':
    ensure  => present,
    path    => $conf_file,
    section => 'sensorcontainer',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.sensorcontainer.conf",
    tag     => 'st2::config',
  }

  ## Stream Settings
  ini_setting { 'stream_logging':
    ensure  => present,
    path    => $conf_file,
    section => 'stream',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.stream.gunicorn.conf",
    tag     => 'st2::config',
  }

  ## Syslog Settings
  ini_setting { 'syslog_host':
    ensure  => present,
    path    => $conf_file,
    section => 'syslog',
    setting => 'host',
    value   => $syslog_host,
    tag     => 'st2::config',
  }
  ini_setting { 'syslog_protocol':
    ensure  => present,
    path    => $conf_file,
    section => 'syslog',
    setting => 'protocol',
    value   => $syslog_protocol,
    tag     => 'st2::config',
  }
  ini_setting { 'syslog_port':
    ensure  => present,
    path    => $conf_file,
    section => 'syslog',
    setting => 'port',
    value   => $syslog_port,
    tag     => 'st2::config',
  }
  ini_setting { 'syslog_facility':
    ensure  => present,
    path    => $conf_file,
    section => 'syslog',
    setting => 'facility',
    value   => $syslog_facility,
    tag     => 'st2::config',
  }

  ## Exchange config
  if $index_url {
    ini_setting { 'exchange_index_url':
      ensure  => present,
      path    => $conf_file,
      section => 'content',
      setting => 'index_url',
      value   => $index_url,
      tag     => 'st2::config',
    }
  }

  ########################################
  ## Services
  service { $st2::params::st2_services:
    ensure => 'running',
    enable => true,
    tag    => 'st2::service',
  }

  contain st2::notifier
  contain st2::rulesengine
  contain st2::scheduler
  contain st2::timersengine
  contain st2::workflowengine

  ########################################
  ## st2 user (stanley)
  class { 'st2::stanley': }

  ########################################
  ## Datastore keys
  class { 'st2::server::datastore_keys': }

  ########################################
  ## Dependencies
  Package<| tag == 'st2::server::packages' |>
  -> Ini_setting<| tag == 'st2::config' |>
  ~> Service<| tag == 'st2::service' |>

  Package<| tag == 'st2::server::packages' |>
  -> Class['st2::server::datastore_keys']
  -> Service<| tag == 'st2::service' |>

  Package<| tag == 'st2::server::packages' |>
  -> Class['st2::stanley']
  -> Service<| tag == 'st2::service' |>

  Package<| tag == 'st2::server::packages' |>
  -> File<| tag == 'st2::server' |>
  -> Service<| tag == 'st2::service' |>

  Service<| tag == 'st2::service' |>
  ~> Exec<| tag == 'st2::reload' |>

  St2_pack<||>
  ~> Recursive_file_permissions<| tag == 'st2::server' |>
}
