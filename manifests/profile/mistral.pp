# == Class: st2::profile::mistral
#
# This class installs OpenStack Mistral, a workflow engine that integrates with
# StackStorm. Has the option to manage a companion MySQL Server
#
# === Parameters
#  [*manage_mysql*]            - Flag used to have MySQL installed/managed via this profile (Default: false)
#  [*git_branch*]              - Tagged branch of Mistral to download/install
#  [*db_root_password*]        - Root MySQL Password
#  [*db_mistral_password*]     - Mistral user MySQL Password
#  [*db_server*]               - Server hosting Mistral DB
#  [*db_database*]             - Database storing Mistral Data
#  [*db_max_pool_size*]        - Max DB Pool size for Mistral Connections
#  [*db_max_overflow*]         - Max DB overload for Mistral Connections
#  [*db_pool_recycle*]         - DB Pool recycle time
#  [*uwsgi*]                   - Flag to setup uWSGI (default: false)
#  [*uwsgi_listen_ip*]         - Listen address for uWSGI (default: *)
#  [*uwsgi_listen_port*]       - Listen port for uWSGI (default: 8989)
#  [*uwsgi_processes*]         - spawn the specified number of workers/processes (default: 25)
#  [*uwsgi_listen_queue_size*] - set the socket listen queue size (default: 128)
#
# === Examples
#
#  include st2::profile::mistral
#
#  class { '::st2::profile::mistral':
#    manage_mysql        => true,
#    db_root_password    => 'datsupersecretpassword',
#    db_mistral_password => 'mistralpassword',
#  }
#
class st2::profile::mistral(
  $manage_mysql            = false,
  $git_branch              = $::st2::mistral_git_branch,
  $db_root_password        = 'StackStorm',
  $db_mistral_password     = 'StackStorm',
  $db_server               = 'localhost',
  $db_database             = 'mistral',
  $db_max_pool_size        = '100',
  $db_max_overflow         = '400',
  $db_pool_recycle         = '3600',
  $uwsgi                   = false,
  $uwsgi_listen_ip         = undef,
  $uwsgi_listen_port       = '8989',
  $uwsgi_processes         = '25',
  $uwsgi_listen_queue_size = '128',
  $manage_init             = true,
) inherits st2 {
  include '::st2::dependencies'

  $_system_python = $::st2::params::system_python

  # This needs a bit more modeling... need to understand
  # what current mistral code ships with st2 - jdf

  ### Dependencies ###
  if !defined(Class['::mysql::bindings']) {
    class { '::mysql::bindings':
      client_dev => true,
      daemon_dev => true,
    }
  }

  ### Mistral Downloads ###
  if !defined(File['/opt/openstack']) {
    file { '/opt/openstack':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  file { [ '/etc/mistral', '/etc/mistral/actions']:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  vcsrepo { '/opt/openstack/mistral':
    ensure   => present,
    source   => 'https://github.com/StackStorm/mistral.git',
    revision => $git_branch,
    provider => 'git',
    require  => File['/opt/openstack'],
    before   => [
      Exec['setup mistral'],
      Exec['setup st2mistral plugin'],
    ],
  }

  vcsrepo { '/etc/mistral/actions/st2mistral':
    ensure   => present,
    source   => 'https://github.com/StackStorm/st2mistral.git',
    revision => $git_branch,
    provider => 'git',
    require  => File['/etc/mistral/actions'],
    before   => [
      Exec['setup mistral'],
      Exec['setup st2mistral plugin'],
    ],
  }
  ### END Mistral Downloads ###

  ### Bootstrap Python ###
  ::python::virtualenv { '/opt/openstack/mistral':
    ensure       => present,
    systempkgs   => false,
    venv_dir     => '/opt/openstack/mistral/.venv',
    cwd          => '/opt/openstack/mistral',
    require      => Vcsrepo['/opt/openstack/mistral'],
    path         => [
      '/usr/local/bin',
      '/usr/local/sbin',
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin',
    ],
    notify       => [
      Exec['setup mistral', 'setup st2mistral plugin'],
      Exec['python_requirementsmistral'],
    ],
    before       => File['/etc/mistral/database_setup.lock'],
  }

  # Not using virtualenv requirements attribute because oslo
  # has bad wheel, and fails
  ::python::requirements { 'mistral':
    requirements => '/opt/openstack/mistral/requirements.txt',
    virtualenv   => '/opt/openstack/mistral/.venv',
  }

  ::python::pip { 'mysql-python':
    ensure     => present,
    virtualenv => '/opt/openstack/mistral/.venv',
    require    => Vcsrepo['/opt/openstack/mistral'],
    before     => [
      Exec['setup mistral'],
      Exec['setup st2mistral plugin'],
      Exec['setup mistral database'],
    ],
  }

  ::python::pip { 'python-mistralclient':
    ensure     => present,
    virtualenv => $_system_python,
    url        => "git+https://github.com/StackStorm/python-mistralclient.git@${git_branch}",
    before     => [
      Exec['setup mistral'],
      Exec['setup st2mistral plugin'],
      Exec['setup mistral database'],
    ],
  }
  ### END Bootstrap Python ###

  ### Bootstrap Mistral ###
  exec { 'setup mistral':
    command     => 'python setup.py develop',
    cwd         => '/opt/openstack/mistral',
    path        => [
      '/opt/openstack/mistral/.venv/bin',
      '/usr/local/bin',
      '/usr/local/sbin',
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin',
    ],
    refreshonly => true,
  }

  exec { 'setup st2mistral plugin':
    command     => 'python setup.py develop',
    cwd         => '/etc/mistral/actions/st2mistral',
    path        => [
      '/opt/openstack/mistral/.venv/bin',
      '/usr/local/bin',
      '/usr/local/sbin',
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin',
    ],
    refreshonly => true,
  }
  ### END Bootstrap Mistral ###


  ### Mistral Config Modeling ###
  ini_setting { 'connection config':
    ensure  => present,
    path    => '/etc/mistral/mistral.conf',
    section => 'database',
    setting => 'connection',
    value   => "mysql://mistral:${db_mistral_password}@${db_server}/${db_database}",
  }
  ini_setting { 'connection pool config':
    ensure  => present,
    path    => '/etc/mistral/mistral.conf',
    section => 'database',
    setting => 'max_pool_size',
    value   => $db_max_pool_size,
  }
  ini_setting { 'connection overflow config':
    ensure  => present,
    path    => '/etc/mistral/mistral.conf',
    section => 'database',
    setting => 'max_overflow',
    value   => $db_max_overflow,
  }
  ini_setting { 'db pool recycle config':
    ensure  => present,
    path    => '/etc/mistral/mistral.conf',
    section => 'database',
    setting => 'pool_recycle',
    value   => $db_pool_recycle,
  }

  ini_setting { 'pecan settings':
    ensure  => present,
    path    => '/etc/mistral/mistral.conf',
    section => 'pecan',
    setting => 'auth_enable',
    value   => 'false',
  }

  ### RabbitMQ Settings ###
  ini_setting { 'mistral_rabbit_host':
    ensure  => present,
    path    => '/etc/mistral/mistral.conf',
    section => 'DEFAULT',
    setting => 'rabbit_host',
    value   => $::st2::rabbit_host,
  }

  ini_setting { 'mistral_rabbit_port':
    ensure  => present,
    path    => '/etc/mistral/mistral.conf',
    section => 'DEFAULT',
    setting => 'rabbit_port',
    value   => $::st2::rabbit_port,
  }

  ini_setting { 'mistral_rabbit_userid':
    ensure  => present,
    path    => '/etc/mistral/mistral.conf',
    section => 'DEFAULT',
    setting => 'rabbit_userid',
    value   => $::st2::rabbit_user,
  }

  ini_setting { 'mistral_rabbit_password':
    ensure  => present,
    path    => '/etc/mistral/mistral.conf',
    section => 'DEFAULT',
    setting => 'rabbit_password',
    value   => $::st2::rabbit_pass,
  }

  File<| tag == 'mistral' |> -> Ini_setting <| tag == 'mistral' |> -> Exec['setup mistral database']
  ### End Mistral Config Modeling ###

  ### Setup Mistral Database ###
  if $manage_mysql {
    class { '::mysql::server':
      root_password => $db_root_password,
    }
  }

  ::mysql::db { 'mistral':
    user     => 'mistral',
    password => $db_mistral_password,
    before   => Exec['setup mistral database'],
  }

  file { '/etc/mistral/database_setup.lock':
    ensure  => file,
    content => 'This file is the lock file that prevents Puppet from attempting to setup the database again. Delete this file if it needs to be re-run',
    notify  => Exec['setup mistral database'],
  }

  exec { 'setup mistral database':
    command     => 'python ./tools/sync_db.py --config-file /etc/mistral/mistral.conf',
    refreshonly => true,
    cwd         => '/opt/openstack/mistral',
    path        => [
      '/opt/openstack/mistral/.venv/bin',
      '/usr/local/bin',
      '/usr/local/sbin',
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin',
    ],
    require     => [
      Vcsrepo['/opt/openstack/mistral'],
    ],
  }

  ### Mistral Init Scripts ###
  if $manage_init {
    $_upstart_init_script = $uwsgi ? {
      true    => 'puppet:///modules/st2/etc/init/mistral.uwsgi.conf',
      default => 'puppet:///modules/st2/etc/init/mistral.conf',
    }
    $_systemd_init_script = $uwsgi ? {
      true    => 'puppet:///modules/st2/etc/systemd/system/mistral.uwsgi.service',
      default => 'puppet:///modules/st2/etc/systemd/system/mistral.service',
    }

    case $::osfamily {
      'Debian': {
        # A bit sloppy, but this only covers Ubuntu right now. Fix this
        file { '/etc/init/mistral.conf':
          ensure => file,
          owner  => 'root',
          group  => 'root',
          mode   => '0444',
          source => $_upstart_init_script,
        }
      }
      'RedHat': {
        file { '/etc/systemd/system/mistral.service':
          ensure => file,
          owner  => 'root',
          group  => 'root',
          mode   => '0444',
          source => $_systemd_init_script,
        }
      }
      default: {
        fail('[st2::profile::mistral] Unsupported Operatingsystem')
      }
    }
  }
  ### END Mistral Init Scripts ###

  ### START uWSGI Specific Items ###
  if $uwsgi {
    $_sock_user = $::osfamily ? {
      'Debian' => 'www-data',
      'RedHat' => 'nginx',
    }
    $_socket = '/var/run/mistral_api.sock'
    $_wsgi_file = '/opt/openstack/mistral/mistral/api/wsgi.py'

    # WSGI file exists in 0.9 branch, so this is only temporary.
    # JDF - 20150424
    if $::st2::mistral_git_branch =~ /0.8/ {
      file { $_wsgi_file:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///modules/st2/mistral/wsgi.py',
        require => Vcsrepo['/opt/openstack/mistral'],
      }
    }

    ### Mistral API Settings
    ini_setting { 'mistral_api_host':
      ensure  => present,
      path    => '/etc/mistral/mistral.conf',
      section => 'api',
      setting => 'host',
      value   => $::st2::mistral_api_url,
    }

    ini_setting { 'mistral_api_port':
      ensure  => present,
      path    => '/etc/mistral/mistral.conf',
      section => 'api',
      setting => 'port',
      value   => $::st2::mistral_api_port,
    }

    file { $_socket:
      ensure => present,
      owner  => $_sock_user,
      group  => $_sock_user,
    }

    # Install a process supervisor. Using supervisord to assert
    # a consistent management experience across systems, regardless
    # if they are init.d, upstart, or systemd
    include ::supervisord
    ::python::pip { 'uwsgi':
      ensure     => present,
      virtualenv => $_system_python,
    }

    ::supervisord::program { 'mistral-uwsgi':
      command  => "uwsgi -s ${_socket} --wsgi-file ${_wsgi_file} --chown-socket ${_sock_user}:${_sock_user} -H /opt/openstack/mistral/.venv/ -p ${uwsgi_processes} -l ${uwsgi_listen_queue_size}",
      priority => '100',
    }

    # Proxy all requests from nginx to uwsgi
    include ::nginx
    ::nginx::resource::upstream { 'mistral-uwsgi':
      ensure  => present,
      members => [ "unix://${_socket}" ],
    }

    ::nginx::resource::vhost { 'mistral':
      ensure               => present,
      listen_ip            => $uwsgi_listen_ip,
      listen_port          => $uwsgi_listen_port,
      use_default_location => false,
      vhost_cfg_prepend    => {
        'charset' => 'utf-8',
      },
    }

    ::nginx::resource::location { 'mistral-uwsgi':
      vhost               => 'mistral',
      location            => '/',
      location_custom_cfg => {
        'uwsgi_pass'  => 'mistral-uwsgi',
        'uwsgi_param' => [
          'UWSGI_PYHOME    /opt/openstack/mistral/.venv',
          'QUERY_STRING    $query_string',
          'REQUEST_METHOD  $request_method',
          'CONTENT_TYPE    $content_type',
          'CONTENT_LENGTH  $content_length',
          'REQUEST_URI     $request_uri',
          'PATH_INFO       $document_uri',
          'DOCUMENT_ROOT   $document_root',
          'SERVER_PROTOCOL $server_protocol',
          'REMOTE_ADDR     $remote_addr',
          'REMOTE_PORT     $remote_port',
          'SERVER_PORT     $server_port',
          'SERVER_NAME     $server_name',
        ],
      },
    }
  }
}
