# Definition: st2::helper::service_manager
#
#  This deined type is used to add service management scripts for the various distros
#
define st2::helper::service_manager (
  $process = $name,
) {
  $_package_map = $::st2::params::component_map
  $package = $_package_map["${process}"]
  $st2_process = "st2${process}"
  $_init_provider = $::st2::params::init_type

  case $_init_provider {
    'upstart': {
      file { "/etc/init/${process}.conf":
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
        source => "puppet:///modules/st2/etc/init/${process}.conf",
        notify => Service["${st2_process}"],
      }
    }
    'systemd': {
      if $process == 'st2actionrunner' {
        $process_type = 'multi'
        file{ "/etc/systemd/system/st2actionrunner.service":
          ensure => file,
          owner  => 'root',
          group  => 'root',
          mode   => '0444',
          source => "puppet:///modules/st2/systemd/system/st2actionrunner.service",
          notify => Exec["sysctl enable ${st2_process}
        }

        exec{"sysctl enable ${st2_process}":
          path        => '/bin:/usr/bin:/usr/local/bin',
          command     => "systemctl --no-reload enable st2actionrunner",
          refreshonly => true,
          require     => File["/etc/systemd/system/${st2_process}.service"],
          notify      => Service["${st2_process}"],
        }

        st2::helper::systemd{ "${st2_process}_multi_systemd":
          st2_process  => $process,
          process_type => $process_type
        }
      } else {
        $process_type = 'single'
        st2::helper::systemd{ "${st2_process}_systemd":
          st2_process  => $st2_process,
          process_type => $process_type
        }
      }
    }
    'sysv': {
      file { "/etc/init.d/${process}":
        ensure => file,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        source => "puppet:///modules/st2/etc/init.d/${process}.conf",
        notify => Service[$st2_process],
      }
    }
  }

  service { "${st2_process}":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    provider   => $_init_provider,
    subscribe  => [
      Package["${package}"],
      Package['st2common'],
    ],
  }
}
