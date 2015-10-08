# Definition: st2::helper::service_manager
#
#  This deined type is used to add service management scripts for the various distros
#
define st2::helper::service_manager (
  $process = $name,
) {

  $_init_provider = $::st2::params::init_type

  case $_init_provider {
    'upstart': {
      file { "/etc/init/${process}.conf":
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
        source => "puppet:///modules/st2/etc/init/${process}.conf",
        notify => Service["${process}"],
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
        }

        exec{ "sysctl enable ${process}":
          path    => '/bin:/usr/bin:/usr/local/bin',
          command => "systemctl --no-reload enable st2actionrunner",
          require => File["/etc/systemd/system/${process}${type}.service"],
          notify  => Service["${process}"],
        }

        st2::helper::systemd { "${process}_multi_systemd":
          st2_process  => $process,
          process_type => $process_type
        }
      } else {
        $process_type = 'single'
        st2::helper::systemd { "${process}_systemd":
          st2_process  => $process,
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
      }
    }
  }

  service { "${process}":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    provider   => $_init_provider,
    subscribe  => [
      Package["${process}"],
      Package['st2common'],
    ],
  }
}
