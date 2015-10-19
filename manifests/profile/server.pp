# == Class: st2::profile::server
#
#  Profile to install all server components for st2
#
# === Parameters
#
#  [*version*]                - Version of StackStorm to install
#  [*revision*]               - Revision of StackStorm to install
#  [*auth*]                   - Toggle Auth
#  [*workers*]                - Set the number of actionrunner processes to start
#  [*st2api_listen_ip*]       - Listen IP for st2api process
#  [*st2api_listen_port*]     - Listen port for st2api process
#  [*st2auth_listen_ip*]      - Listen IP for st2auth process
#  [*st2auth_listen_port*]    - Listen port for st2auth process
#  [*manage_st2api_service*]  - Toggle whether this module creates an init script for st2api.
#                               If you disable this, it is your responsibility to create a service
#                               named `st2api` for `st2ctl` to continue to work.
#  [*manage_st2auth_service*] - Toggle whether this module creates an init script for st2auth.
#                               If you disable this, it is your responsibility to create a service
#                               named `st2auth` for `st2ctl` to continue to work.
#  [*manage_st2web_service*]  - Toggle whether this module creates an init script for st2web.
#                               If you disable this, it is your responsibility to create a service
#                               named `st2web` for `st2ctl` to continue to work.
#  [*syslog*]                 - Routes all log messages to syslog
#  [*syslog_host*]            - Syslog host.
#  [*syslog_protocol*]        - Syslog protocol.
#  [*syslog_port*]            - Syslog port.
#  [*syslog_facility*]        - Syslog facility.
#  [*ssh_key_location*]       - Location on filesystem of Admin SSH key for remote runner
#
# === Variables
#
#  [*_server_packages*] - Local scoped variable to store st2 server packages.
#                         Sources from st2::params
#  [*_conf_dir*]        - Local scoped variable config directory for st2.
#                         Sources from st2::params
#  [*_python_pack*]     - Local scoped variable directory where system python lives
#
# === Examples
#
#  include st2::profile::client
#
class st2::profile::server (
  $version                = $::st2::version,
  $autoupdate             = $::st2::autoupdate,
  $revision               = $::st2::revision,
  $auth                   = $::st2::auth,
  $workers                = $::st2::workers,
  $syslog                 = $::st2::syslog,
  $syslog_host            = $::st2::syslog_host,
  $syslog_port            = $::st2::syslog_port,
  $syslog_facility        = $::st2::syslog_facitily,
  $syslog_protocol        = $::st2::syslog_protocol,
  $st2api_listen_ip       = '0.0.0.0',
  $st2api_listen_port     = '9101',
  $st2auth_listen_ip      = '0.0.0.0',
  $st2auth_listen_port    = '9100',
  $manage_st2api_service  = true,
  $manage_st2auth_service = true,
  $manage_st2web_service  = true,
  $ssh_key_location       = $::st2::ssh_key_location,
  $ng_init                = $::st2::ng_init,
) inherits st2 {
  include '::st2::notices'
  include '::st2::params'
  require '::st2::dependencies'

  $_version = $autoupdate ? {
    true    => st2_latest_stable(),
    default => $version,
  }
  $_bootstrapped = $::st2server_bootstrapped ? {
    undef   => false,
    default => true,
  }
  $_revision = $autoupdate ? {
    true    => undef,
    default => $revision,
  }
  $_git_tag = $_version ? {
    /dev/   => "master",
    default => "v${_version}",
  }

  $_server_packages = $::st2::params::st2_server_packages
  $_conf_dir = $::st2::params::conf_dir
  $_init_provider = $::st2::params::init_type

  $_python_pack = $::osfamily ? {
    'Debian' => '/usr/lib/python2.7/dist-packages',
    'RedHat' => '/usr/lib/python2.7/site-packages',
  }
  $_register_command = $_version ? {
    /^0.8/  => "${_python_pack}/st2common/bin/registercontent.py",
    default => "${_python_pack}/st2common/bin/st2-register-content",
  }
  $_enable_auth = $auth ? {
    true    => 'True',
    default => 'False',
  }
  $_logger_config = $syslog ? {
    true    => 'syslog',
    default => 'logging',
  }

  # This must remain here until upstream packages fully use
  # init scripts. Otherwise, it's Puppet-specific right now
  if $ng_init {
    file_line { 'st2 ng_init enable':
      path => '/etc/environment',
      line => 'NG_INIT=true',
    }
  }

  file { $_conf_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  ### This should be a versioned download too... currently on master
  if $autoupdate or ! $_bootstrapped {
    wget::fetch { 'Download st2server requirements.txt':
      source      => "https://raw.githubusercontent.com/StackStorm/st2/${_git_tag}/requirements.txt",
      cache_dir   => '/var/cache/wget',
      destination => '/tmp/st2server-requirements.txt'
    }
    # More RedHat 6 hackery.  Need to use pip2.7.
    case $::osfamily {
      'Debian': {
        python::requirements { '/tmp/st2server-requirements.txt':
          before  => Exec['register st2 content'],
          require => Wget::Fetch['Download st2server requirements.txt']
        }
      }
      'RedHat': {
        if $operatingsystemmajrelease == '6' {
          exec { 'pip27_install_st2server_reqs':
            path    => '/usr/bin:/usr/sbin:/bin:/sbin',
            command => 'pip2.7 install -U -r /tmp/st2server-requirements.txt',
            notify  => File['/etc/facter/facts.d/st2server_bootstrapped.txt'],
            require => Wget::Fetch['Download st2server requirements.txt']
          }
        } else {
          python::requirements { '/tmp/st2server-requirements.txt':
            before  => Exec['register st2 content'],
            require => Wget::Fetch['Download st2server requirements.txt']
          }
        }
      }
    }
  }


  st2::package::install { $_server_packages:
    version     => $_version,
    revision    => $_revision,
    notify      => Exec['register st2 content'],
  }

  exec { 'register st2 content':
    command     => "python2.7 ${_register_command} --register-all --config-file ${_conf_dir}/st2.conf",
    path        => '/usr/bin:/usr/sbin:/bin:/sbin',
    refreshonly => true,
    notify      => File['/etc/facter/facts.d/st2server_bootstrapped.txt'],
  }

  file { '/etc/facter/facts.d/st2server_bootstrapped.txt':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => 'st2server_bootstrapped=true',
  }

  ini_setting { 'ssh_key_stanley':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'system_user',
    setting => 'ssh_key_file',
    value   => $ssh_key_location,
    tag     => 'st2::config',
  }

  ## ActionRunner settings
  ini_setting { 'actionrunner_logging':
    ensure => present,
    path   => '/etc/st2/st2.conf',
    section => 'actionrunner',
    setting => 'logging',
    value   => "/etc/st2actions/${_logger_config}.conf",
    tag     => 'st2::config',
  }

  ## API Settings
  ini_setting { 'api_listen_ip':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'api',
    setting => 'host',
    value   => $st2api_listen_ip,
    tag     => 'st2::config',
  }
  ini_setting { 'api_listen_port':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'api',
    setting => 'port',
    value   => $st2api_listen_port,
    tag     => 'st2::config',
  }
  ini_setting { 'api_allow_origin':
    ensure  => 'present',
    path    => '/etc/st2/st2.conf',
    section => 'api',
    setting => 'allow_origin',
    value   => '*',
    tag     => 'st2::config',
  }
  ini_setting { 'api_logging':
    ensure => present,
    path   => '/etc/st2/st2.conf',
    section => 'api',
    setting => 'logging',
    value   => "/etc/st2api/${_logger_config}.conf",
    tag     => 'st2::config',
  }

  ## Authentication Settings
  ini_setting { 'auth':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'enable',
    value   => $_enable_auth,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_listen_port':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'port',
    value   => $st2auth_listen_port,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_listen_ip':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'host',
    value   => $st2auth_listen_ip,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_logging':
    ensure => present,
    path   => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'logging',
    value   => "/etc/st2auth/${_logger_config}.conf",
    tag     => 'st2::config',
  }

  ## Notifier Settings
  ini_setting { 'notifier_logging':
    ensure => present,
    path   => '/etc/st2/st2.conf',
    section => 'notifier',
    setting => 'logging',
    value   => "/etc/st2actions/${_logger_config}.notifier.conf",
    tag     => 'st2::config',
  }

  ## Resultstracker Settings
  ini_setting { 'resultstracker_logging':
    ensure => present,
    path   => '/etc/st2/st2.conf',
    section => 'resultstracker',
    setting => 'logging',
    value   => "/etc/st2actions/${_logger_config}.resultstracker.conf",
    tag     => 'st2::config',
  }

  ## Rules Engine Settings
  ini_setting { 'rulesengine_logging':
    ensure => present,
    path   => '/etc/st2/st2.conf',
    section => 'rulesengine',
    setting => 'logging',
    value   => "/etc/st2reactor/${_logger_config}.rulesengine.conf",
    tag     => 'st2::config',
  }

  ## Sensor container Settings
  ini_setting { 'sensorcontainer_logging':
    ensure => present,
    path   => '/etc/st2/st2.conf',
    section => 'sensorcontainer',
    setting => 'logging',
    value   => "/etc/st2reactor/${_logger_config}.sensorcontainer.conf",
    tag     => 'st2::config',
  }

  ## Syslog Settings
  ini_setting { 'syslog_host':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'syslog',
    setting => 'host',
    value   => $syslog_host,
    tag     => 'st2::config',
  }
  ini_setting { 'syslog_protocol':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'syslog',
    setting => 'protocol',
    value   => $syslog_protocol,
    tag     => 'st2::config',
  }
  ini_setting { 'syslog_port':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'syslog',
    setting => 'port',
    value   => $syslog_port,
    tag     => 'st2::config',
  }
  ini_setting { 'syslog_facility':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'syslog',
    setting => 'facility',
    value   => $syslog_facility,
    tag     => 'st2::config',
  }

  # Spin up any number of workers as needed
  $_workers = prefix(range("0", "${workers}"), "worker")

  case $_init_provider {
    'upstart': {
      ::st2::helper::actionrunner_upstart { $_workers: }

      file { '/etc/default/st2actionrunner':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        mode   => '0444'
      }

      file_line{'st2actionrunner count':
        path => '/etc/default/st2actionrunner',
        line => "WORKERS=${workers}",
        require => File['/etc/default/st2actionrunner']
      }

      # Stub init script for workers to anchor to
      file { '/etc/init/st2actionrunner.conf':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        source  => 'puppet:///modules/st2/etc/init/st2actionrunner.conf',
      }
    }
    'systemd': {
      ::st2::helper::service_manager{'st2actionrunner':
        process => 'st2actionrunner'
      }

      file { '/etc/sysconfig/st2actionrunner':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        mode   => '0444'
      }

      file_line{'st2actionrunner count':
        path => '/etc/sysconfig/st2actionrunner',
        line => "WORKERS=${workers}",
        require => File['/etc/sysconfig/st2actionrunner']
      }
    }
    'init': {
      ::st2::helper::service_manager{ 'actionrunner': }
    }
  }

  if $manage_st2web_service {
    ::st2::helper::service_manager { 'st2web': }
  }

  if $auth and $manage_st2auth_service {
    st2::helper::service_manager { 'auth': }
  }

  if $manage_st2api_service {
    st2::helper::service_manager { 'api': }
  }

  ::st2::helper::service_manager { 'resultstracker': }
  ::st2::helper::service_manager { 'sensorcontainer': }
  ::st2::helper::service_manager { 'notifier': }
  ::st2::helper::service_manager { 'rulesengine': }

  St2::Package::Install<| tag == 'st2::profile::server' |>
  -> Ini_setting<| tag == 'st2::config' |>
  ~> Service<| tag == 'st2::server' |>

  Service<| tag == 'st2::server' |> -> St2::Pack<||>
}
