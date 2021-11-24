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
#     chatops_api_key    => '"xxxxyyyyy123abc"',
#     chatops_adapter    => {
#       hubot-adapter => {
#         package => 'hubot-rocketchat',
#         source  => 'git+ssh://git@git.company.com:npm/hubot-rocketchat#master',
#       },
#     },
#     chatops_adapter_conf => {
#       HUBOT_ADAPTER        => 'rocketchat',
#       ROCKETCHAT_URL       => 'https://chat.company.com',
#       ROCKETCHAT_ROOM      => 'stackstorm',
#       LISTEN_ON_ALL_PUBLIC => 'true',
#       ROCKETCHAT_USER      => 'st2',
#       ROCKETCHAT_PASSWORD  => 'secret123',
#       ROCKETCHAT_AUTH      => 'password',
#       RESPOND_TO_DM        => 'true',
#     },
#   }
#
class st2::config::common (
  $version                = $st2::version,
  $conf_dir               = $st2::conf_dir,
  $conf_file              = $st2::conf_file,
  $index_url              = $st2::index_url,
  $packs_group            = $st2::packs_group_name,
  $validate_output_schema = $st2::validate_output_schema,
  $manage_nfs_dirs        = $st2::manage_nfs_dirs,
  $stanley_user           = $st2::stanley_user,
  $syslog_host            = $st2::syslog_host,
  $syslog_port            = $st2::syslog_port,
  $syslog_facility        = $st2::syslog_facility,
  $syslog_protocol        = $st2::syslog_protocol,
) inherits st2 {
  include st2::notices
  include st2::params

  $_validate_output_schema = $validate_output_schema ? {
    true    => 'True',
    default => 'False',
  }

  ########################################
  ## Packages
  package { $st2::params::st2_server_packages:
    ensure => $version,
    tag    => ['st2::packages', 'st2::server::packages'],
  }

  ## Groups
  ensure_resource('group', $packs_group, {
    'ensure' => present,
  })

  if $manage_nfs_dirs {
    ensure_resource('file', '/opt/stackstorm', {
      'ensure' => 'directory',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0755',
      'tag'    => 'st2::server',
    })

    ensure_resource('file', '/opt/stackstorm/packs', {
      'ensure'  => 'directory',
      'owner'   => 'root',
      'group'   => $packs_group,
      'mode'    => '0775',
      'tag'     => 'st2::server',
      'recurse' => true,
    })

    ensure_resource('file', '/opt/stackstorm/virtualenvs', {
      'ensure'  => 'directory',
      'owner'   => 'root',
      'group'   => $packs_group,
      'mode'    => '0755',
      'tag'     => 'st2::server',
      'recurse' => true,
    })

    ensure_resource('file', '/opt/stackstorm/configs', {
      'ensure'  => 'directory',
      'owner'   => 'st2',
      'group'   => 'root',
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
  }

  ########################################
  ## Config
  file { $conf_dir:
    ensure => directory,
  }

  ## System Settings
  ini_setting { 'validate_output_schema':
    ensure  => present,
    path    => $conf_file,
    section => 'system',
    setting => 'validate_output_schema',
    value   => $_validate_output_schema,
    tag     => 'st2::config',
  }

  ## System User Setting (Override stanley user with this setting)
  ini_setting { 'stanley_system_user':
    ensure  => present,
    path    => $conf_file,
    section => 'system_user',
    setting => 'user',
    value   => $stanley_user,
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

  ## Enable system debug
  ini_setting { 'enable_system_debug':
    ensure  => present,
    path    => $conf_file,
    section => 'system',
    setting => 'debug',
    value   => 'True',
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
}
