# Definition: st2::helper::service_manager
#
#  This defined type is used to add service management scripts for the various distros
#
define st2::helper::service_manager (
  $process = $name,
) {
  include ::st2::params

  $_package_map = $::st2::params::component_map
  $_package     = $_package_map[$process]
  $_init_type   = $::st2::params::init_type
  $_subsystem   = $::st2::params::subsystem_map[$process]
  $_python_pack = $::st2::params::python_pack

  tag('st2::service_manager')

  case $_init_type {
    'upstart': {
      $_init_file   = "/etc/init/${_subsystem}.conf"
      $_init_mode   = '0644'
      $_init_source = "puppet:///modules/st2/etc/init/${_subsystem}.conf"
    }
    'systemd': {
      $init_file = undef

      $process_type = $_subsystem ? {
        'st2web'          => 'complex',
        'st2actionrunner' => 'multi',
        default           => 'single'
      }

      unless $process_type == 'single' {
        # If Actionrunner, we need two init scripts. First is the
        # anchor init script, which calls out actionrunner
        # The WebUI is served via python SimpleHTTP and has a custom
        # unit file.
        case $_subsystem {
          'st2web': {
            file{ "/etc/systemd/system/${_subsystem}.service":
              ensure => file,
              owner  => 'root',
              group  => 'root',
              mode   => '0444',
              source => "puppet:///modules/st2/systemd/system/${_subsystem}.service",
            }
          }
          'st2actionrunner': {
            $runners_script = "${_python_pack}/st2actions/bin/runners.sh"
            file{ "/etc/systemd/system/${_subsystem}.service":
              ensure  => file,
              owner   => 'root',
              group   => 'root',
              mode    => '0444',
              content => template("st2/etc/systemd/system/${_subsystem}.service.erb"),
            }
          }
          default: {
              crit('Invalid subsystem provided, only st2web and st2actionrunner are valid options')
          }
        }

        exec{ "sysctl enable ${_subsystem}":
          path    => '/bin:/usr/bin:/usr/local/bin',
          command => "systemctl --no-reload enable ${_subsystem}",
          require => File["/etc/systemd/system/${_subsystem}.service"],
          notify  => Service[$_subsystem],
        }
      }

      unless $process_type == 'complex' {
        # Declare the Subsystem for SystemD.
        st2::helper::systemd{ $_subsystem:
          st2_process  => $_subsystem,
          process_type => $process_type,
        }
      }
    }
    'init': {
      $_init_file   = "/etc/init.d/${_subsystem}"
      $_init_mode   = '0755'
      $_init_source = "puppet:///modules/st2/etc/init.d/${_subsystem}"
    }
    default: {
      fail("[st2::helper::service_manager] Unable to setup init script for init system ${_init_type}. Not supported")
    }
  }

  if $_init_file {
    file { $_init_file:
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => $_init_mode,
      source => $_init_source,
      notify => Service[$_subsystem],
    }
  }

  service { $_subsystem:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    provider   => $_init_type,
    tag        => 'st2::server',
  }

  Package[$_package] ~> Service[$_subsystem]
  File<| tag == 'st2::service_manager' |> ~> Service[$_subsystem]
}
