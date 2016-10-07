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
#                         Sources from st2::params
#
# === Examples
#
#  include st2::profile::client
#
class st2::profile::server (
  $install_chatops        = $::st2::install_chatops,
  $install_web            = $::st2::install_web,
  $install_st2            = $::st2::install_st2,
  $enterprise_token       = $::st2::enterprise_token,
) inherits st2 {
  include '::st2::notices'
  include '::st2::params'

  if $install_st2 == true {
    package{'st2':
      ensure    => 'latest',
    }
  }

  if $install_web {
    package{'st2web':
      ensure    => 'latest',
    }
  }

  if $install_chatops {
    package{'st2chatops':
      ensure    => 'latest',
    }
  }

  package{'st2mistral':
    ensure      => 'latest',
  }

  if $enterprise_token != undef {
    package{'st2enterprise':
      ensure    => 'latest',
    }

    package{'st2-auth-ldap':
      ensure    => 'latest',
    }
  }

}
