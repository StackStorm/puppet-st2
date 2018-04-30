# == Class: st2::params
#
#  Main parameters to manage the st2 module
#
# === Parameters
#  [*packs_group_name*] - The name of the group created to hold the st2 admin user
#
# === Variables
#  [*conf_dir*] - The local directory where st2 config is stored
#  [*subsystems*] - Different executable subsystems within StackStorm
#  [*component_map*] - Hash table of mappings of Subsystems -> Components
#  [*st2_server_packages*] - A list of all upstream server packages to grab from upstream package server
#  [*st2_client_packages*] - A list of all upstream client packages to grab from upstream package server
#  [*debian_dependencies*] - Any dependencies needed to successfully run st2 server on the Debian OS Family
#  [*debian_client_dependencies*] - Any dependencies needed to successfully run st2 client on the Debian OS Family
#  [*debian_mongodb_dependencies*] - MongoDB Dependencies (if installed via this module)
#  [*redhat_dependencies*] - Any dependencies needed to successfully run st2 server on the RedHat OS Family
#  [*redhat_client_dependencies*] - Any dependencies needed to successfully run st2 client on the RedHat OS Family
#
# === Examples
#
#  include st2::params
#
#  class { 'st2::params':
#
#  }
#

class st2::params(
  $packs_group_name = 'st2packs',
  $hostname         = '127.0.0.1',
  ## StackStorm default credentials (change these!)
  $admin_username   = 'st2admin',
  $admin_password   = 'Ch@ngeMe',
) {
  $subsystems = [
    'actionrunner', 'api', 'sensorcontainer',
    'rulesengine', 'garbagecollector', 'resultstracker', 'notifier',
    'auth',
  ]

  $component_map = {
    actionrunner        => 'st2actions',
    api                 => 'st2api',
    auth                => 'st2auth',
    notifier            => 'st2actions',
    resultstracker      => 'st2actions',
    rulesengine         => 'st2reactor',
    sensorcontainer     => 'st2reactor',
    garbagecollector    => 'st2reactor',
    web                 => 'st2common',

    st2actionrunner     => 'st2actions',
    st2api              => 'st2api',
    st2auth             => 'st2auth',
    st2notifier         => 'st2actions',
    st2resultstracker   => 'st2actions',
    st2rulesengine      => 'st2reactor',
    st2sensorcontainer  => 'st2reactor',
    st2garbagecollector => 'st2reactor',
    st2web              => 'st2common',
  }

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

  ## nginx default config
  $nginx_default_conf = $::osfamily ? {
    'Debian' => '/etc/nginx/conf.d/default.conf',
    'RedHat' => $::operatingsystemmajrelease ? {
      '6'     => '/etc/nginx/conf.d/default.conf',
      default => '/etc/nginx/nginx.conf',
    }
  }
  ## nginx conf.d directory in /etc
  $nginx_conf_d = $::osfamily ? {
    'Debian' => '/etc/nginx/conf.d',
    'RedHat' => '/etc/nginx/conf.d',
  }
  # nginx config for StackStorm (installed with the st2 packages)
  $nginx_st2_conf = '/usr/share/doc/st2/conf/nginx/st2.conf'

  # syslog

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
  $rabbitmq_port = 25672
  $rabbitmq_protocol = 'tcp'
  $rabbitmq_selinux_type = 'amqp_port_t'

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
  $chatops_adapter_conf = {}
}
