# @summary Main parameters to manage the st2 module
#
# @param packs_group_name
#   The name of the group created to hold the st2 admin user
# @param hostname
#   Hostname of the StackStorm box. This is used as the default to drive a lot of
#   other parameters in the st2 class such as auth URL, MongoDB host, RabbitMQ host, etc.
# @param admin_username
#   Username of the StackStorm admin user. Best practice is to change this to a unique username.
# @param admin_password
#   Password of the StackStorm admin user. Best practice is to change this to a unique password.
#
# @example Best Practice
#   class { 'st2::params':
#     admin_username => 'myuser',
#     admin_password => 'SuperSecret!',
#   }
#   include st2::profile::fullinstall
#
class st2::params(
  $packs_group_name = 'st2packs',
  $hostname         = '127.0.0.1',
  ## StackStorm default credentials (change these!)
  $admin_username   = 'st2admin',
  $admin_password   = 'Ch@ngeMe',
) {

  # SSL settings
  $use_ssl  = false
  $ssl_dir  = '/etc/ssl/st2'
  $ssl_cert = '/etc/ssl/st2/st2.crt'
  $ssl_key  = '/etc/ssl/st2/st2.key'

  # Auth settings
  $auth_mode = standalone
  $auth_backend = flat_file
  $auth_htpasswd_file = '/etc/st2/htpasswd'
  $auth_backend_config = {
    htpasswd_file => $auth_htpasswd_file,
  }
  $auth_port = 9100

  # API settings
  $api_port = 9101

  # Non-user configurable parameters
  $repository = 'stable'
  $conf_dir = '/etc/st2'
  $datstore_keys_dir = "${conf_dir}/keys"

  $st2_server_packages = [
    'st2',
  ]
  $st2_chatops_packages = [
    'st2chatops',
  ]
  $st2_mistral_packages = [
    'st2mistral',
  ]
  $st2_web_packages = [
    'st2web',
  ]
  case $::osfamily {
    'Debian': {
      $st2_client_packages = [
        'python-st2client',
      ]
      $package_type = 'deb'
    }
    'RedHat': {
      $st2_client_packages = [
        'st2client',
      ]
      $package_type = 'rpm'
    }
    default: {
      $st2_client_packages = [
        'python-st2client',
      ]
      $package_type = 'deb'
    }
  }

  ## StackStorm core services
  $st2_services = [
    'st2actionrunner',
    'st2api',
    'st2auth',
    'st2garbagecollector',
    'st2notifier',
    'st2resultstracker',
    'st2rulesengine',
    'st2sensorcontainer',
    'st2stream',
  ]

  ## StackStorm ChatOps services
  $st2_chatops_services = [
    'st2chatops',
  ]

  ## StackStorm Workflow Engine (Orchestra)
  $workflowengine_services = [
    'st2workflowengine',
  ]

  ## StackStorm Timers Engine
  $timersengine_services = [
    'st2timersengine',
  ]
  $timersengine_enabled = true
  $timersengine_timezone = 'America/Los_Angeles'

  ## StackStorm Scheduler
  $scheduler_services = [
    'st2scheduler',
  ]
  $scheduler_sleep_interval = 0.1
  $scheduler_gc_interval = 10
  $scheduler_pool_size = 10

  ## nginx default config
  $nginx_default_conf = $::osfamily ? {
    'Debian' => '/etc/nginx/conf.d/default.conf',
    'RedHat' => '/etc/nginx/conf.d/default.conf',
  }
  ## nginx conf.d directory in /etc
  $nginx_conf_d = $::osfamily ? {
    'Debian' => '/etc/nginx/conf.d',
    'RedHat' => '/etc/nginx/conf.d',
  }
  # nginx config for StackStorm (installed with the st2 packages)
  $nginx_st2_conf = '/usr/share/doc/st2/conf/nginx/st2.conf'

  # st2web certs
  $st2web_ssl_dir = '/etc/ssl/st2'
  $st2web_ssl_cert = "${st2web_ssl_dir}/st2.crt"
  $st2web_ssl_key = "${st2web_ssl_dir}/st2.key"

  ## MongoDB Data
  $mongodb_admin_username = 'admin'

  $mongodb_port = 27017
  $mongodb_bind_ips = ['127.0.0.1']

  $mongodb_st2_db = 'st2'
  $mongodb_st2_username = 'stackstorm'
  $mongodb_st2_roles = ['readWrite']

  ## Mistral data
  $mistral_db_name = 'mistral'
  $mistral_db_username = 'mistral'
  $mistral_db_bind_ips = '127.0.0.1'

  ## RabbitMQ
  $rabbitmq_username = $admin_username
  $rabbitmq_password = $admin_password
  $rabbitmq_hostname = '127.0.0.1'
  $rabbitmq_port = 5672
  $rabbitmq_bind_ip = '127.0.0.1'
  $rabbitmq_vhost = '/'

  ## actionrunner config
  $actionrunner_workers = 10
  $actionrunner_global_env_file = $::osfamily ? {
    'Debian' => '/etc/default/st2actionrunner',
    'RedHat' => '/etc/sysconfig/st2actionrunner',
  }

  ## chatops default config
  $st2_chatops_dir  = '/opt/stackstorm/chatops'
  $st2_chatops_global_env_file = $::osfamily ? {
    'Debian' => '/etc/default/st2chatops',
    'RedHat' => '/etc/sysconfig/st2chatops',
  }

  $hubot_log_level = 'debug'
  $hubot_express_port = '8081'
  $tls_cert_reject_unauthorized = '0'
  $hubot_name = '"hubot"'
  $hubot_alias = "'!'"
  $chatops_adapter = {}
  $chatops_adapter_conf = {
    'HUBOT_ADAPTER' => 'slack',
  }
}
