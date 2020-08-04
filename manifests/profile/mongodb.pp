# @summary StackStorm compatable installation of MongoDB and dependencies.
#
# @param db_name
#    Name of the StackStorm database
# @param db_username
#    Username to connect to db with
# @param db_password
#    Password for 'admin' and 'stackstorm' users in MongDB. If 'undef' then use $cli_password
# @param db_port
#    Port for db server for st2 to talk to
# @param db_bind_ips
#    Array of bind IP addresses for MongoDB to listen on
# @param version
#    Version of MongoDB to install. If not provided it will be auto-calcuated based on $st2::version.
# @param manage_repo
#    Set this to +false+ when you have your own repositories for mongodb
# @param auth
#    Boolean determining if auth should be enabled for MongoDB.
#
# @example Basic Usage
#   include st2::profile::mongodb
#
# @example Customize (done via st2)
#   class { 'st2':
#     db_name     => 'stackstormdb',
#     db_username => 'abc',
#     db_password => 'xyz123',
#     db_port     => 12345,
#   }
#   include st2::profile::mongodb
#
class st2::profile::mongodb (
  $db_name     = $st2::db_name,
  $db_username = $st2::db_username,
  $db_password = $st2::db_password,
  $db_port     = $st2::db_port,
  $db_bind_ips = $st2::db_bind_ips,
  $version     = $st2::mongodb_version,
  $manage_repo = $st2::mongodb_manage_repo,
  $auth        = $st2::mongodb_auth,
) inherits st2 {
  # if the StackStorm version is > 3.3.0 then MongoDB 4.0
  # if the StackStorm version is > 2.4.0 then MongoDB 3.4
  # else use MongoDB 3.2
  if st2::version_ge('3.3.0') {
    $_mongodb_version_default = '4.0'
  }
  elsif st2::version_ge('2.4.0') {
    $_mongodb_version_default = '3.4'
  }
  else {
    $_mongodb_version_default = '3.2'
  }

  # if user specified a version of MongoDB they want to use, then use that
  # otherwise use the default version of mongo based off the StackStorm version
  $_mongodb_version = $version ? {
    undef   => $_mongodb_version_default,
    default => $version,
  }

  if !defined(Class['mongodb::server']) {
    class { 'mongodb::globals':
      manage_package      => true,
      manage_package_repo => $manage_repo,
      version             => $_mongodb_version,
      bind_ip             => $db_bind_ips,
      manage_pidfile      => false, # mongo will not start if this is true
    }

    class { 'mongodb::client': }

    if $auth == true {
      class { 'mongodb::server':
        port           => $db_port,
        auth           => true,
        create_admin   => true,
        store_creds    => true,
        admin_username => $::st2::params::mongodb_admin_username,
        admin_password => $db_password,
      }

      # In puppet-mongodb module, latest versions used with Puppet >= 4, the
      # auth parameter is broken and doesn't work properly on the first run.
      # https://github.com/voxpupuli/puppet-mongodb/issues/437
      #
      # The problem is because Puppet enables auth before setting the password
      # on the admin database.
      #
      # The code below fixes this by first disabling auth, then creates the
      # database, the re-enables auth.
      #
      # To prevent this from running every time we've create a puppet fact
      # called $::mongodb_auth_init that is set when
      if !$facts['mongodb_auth_init'] {
        # unfortinately there is no way to synchronously force a service restart
        # in Puppet, so we have to revert to exec... sorry
        include mongodb::params
        $_mongodb_stop_cmd = "systemctl stop ${::mongodb::params::service_name}"
        $_mongodb_start_cmd = "systemctl start ${::mongodb::params::service_name}"
        $_mongodb_restart_cmd = "systemctl restart ${::mongodb::params::service_name}"
        $_mongodb_exec_path = ['/usr/sbin', '/usr/bin', '/sbin', '/bin']

        # stop mongodb; disable auth
        exec { 'mongodb - stop service':
          command => $_mongodb_stop_cmd,
          unless  => 'grep "^security.authorization: disabled" /etc/mongod.conf',
          path    => $_mongodb_exec_path,
        }
        exec { 'mongodb - disable auth':
          command     => 'sed -i \'s/security.authorization: enabled/security.authorization: disabled/g\' /etc/mongod.conf',
          refreshonly => true,
          path        => $_mongodb_exec_path,
        }
        facter::fact { 'mongodb_auth_init':
          value => bool2str(true),
        }

        # start mongodb with auth disabled
        exec { 'mongodb - start service':
          command     => $_mongodb_start_cmd,
          refreshonly => true,
          path        => $_mongodb_exec_path,
        }

        # create mongodb admin database with auth disabled

        # enable auth
        exec { 'mongodb - enable auth':
          command => 'sed -i \'s/security.authorization: disabled/security.authorization: enabled/g\' /etc/mongod.conf',
          unless  => 'grep "^security.authorization: enabled" /etc/mongod.conf',
          path    => $_mongodb_exec_path,
        }
        exec { 'mongodb - restart service':
          command     => $_mongodb_restart_cmd,
          refreshonly => true,
          path        => $_mongodb_exec_path,
        }

        # wait for MongoDB restart by trying to establish a connection
        if $db_bind_ips[0] == '0.0.0.0' {
          $_mongodb_bind_ip = '127.0.0.1'
        } else {
          $_mongodb_bind_ip = $db_bind_ips[0]
        }
        mongodb_conn_validator { 'mongodb - wait for restart':
          server  => $_mongodb_bind_ip,
          port    => $db_port,
          timeout => '240',
        }


        # ensure MongoDB config is present and service is running
        Class['mongodb::server::config']
        -> Class['mongodb::server::service']
        # stop mongodb; disable auth
        -> Exec['mongodb - stop service']
        ~> Exec['mongodb - disable auth']
        ~> Facter::Fact['mongodb_auth_init']
        # start mongodb with auth disabled
        ~> Exec['mongodb - start service']
        # create mongodb admin database with auth disabled
        -> Mongodb::Db['admin']
        # enable auth
        ~> Exec['mongodb - enable auth']
        ~> Exec['mongodb - restart service']
        # wait for MongoDB restart
        ~> Mongodb_conn_validator['mongodb - wait for restart']
        # create other databases
        -> Mongodb::Db <| title != 'admin' |>
      }
    }
    else {
      class { 'mongodb::server':
        port => $db_port,
      }
    }

    # setup proper ordering
    Class['mongodb::globals']
    -> Class['mongodb::client']
    -> Class['mongodb::server']

    # Handle more special cases of things that didn't work properly...
    case $facts['os']['family'] {
      'RedHat': {
        Package <| tag == 'mongodb' |> {
          ensure => 'present'
        }
      }
      'Debian': {
        #############
        # MongoDB module doens't ensure that the apt source is added prior to
        # the packages.
        # It also fails to ensure that apt-get update is run before trying
        # to install the packages.
        Apt::Source['mongodb'] -> Package<|tag == 'mongodb'|>
        Class['Apt::Update'] -> Package<|tag == 'mongodb'|>

        #############
        # MongoDB module doesn't pass the proper install options when using the
        # MongoDB repo on Ubuntu (Debian)
        Package <| tag == 'mongodb' |> {
          ensure          => 'present',
          install_options => ['--allow-unauthenticated'],
        }

        #############
        # Debian's mongodb doesn't create PID file properly, so we need to
        # create it and set proper permissions
        file { '/var/run/mongod.pid':
          ensure => file,
          owner  => 'mongodb',
          group  => 'mongodb',
          mode   => '0644',
          tag    => 'st2::mongodb::debian',
        }

        File <| title == '/var/lib/mongodb' |> {
          recurse => true,
          tag     => 'st2::mongodb::debian',
        }
        Package<| tag == 'mongodb' |>
        -> File<| tag == 'st2::mongodb::debian' |>
        -> Service['mongodb']
      }
      default: {
      }
    }

    # configure st2 database
    mongodb::db { $db_name:
      user     => $db_username,
      password => $db_password,
      roles    => $st2::params::mongodb_st2_roles,
      require  => Class['mongodb::server'],
    }
  }

}
