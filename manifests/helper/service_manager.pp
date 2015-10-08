# Definition: st2::helper::service_manager
#
#  This deined type is used to add service management scripts for the various distros
#
define st2::helper::service_manager (
  $st2_process = undef,
) {

  $init_provider = $::st2::params::init_type

  if $osfamily == 'Debian' {

    file { "/etc/init/${st2_process}.conf":
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0444',
      source => "puppet:///modules/st2/etc/init/${st2_process}.conf",
      notify => Service["${st2_process}"],
    }
  } elsif $osfamily == 'RedHat' {
    if $operatingsystemmajrelease == '7' {
      if $st2_process == 'st2actionrunner' {
        $process_type = 'multi'
        file{"/etc/systemd/system/st2actionrunner.service":
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0444',
          source  => "puppet:///modules/st2/systemd/system/st2actionrunner.service",
        }

        exec{'sysctl enable':
          path    => '/bin:/usr/bin:/usr/local/bin',
          command => "systemctl --no-reload enable st2actionrunner",
          require => File["/etc/systemd/system/${st2_process}${type}.service"],
          notify  => Service["${st2_process}"],
        }

        st2::helper::systemd{ "${st2_process}s_systemd":
          st2_process  => $st2_process,
          process_type => $process_type
        }
      } else {
        $process_type = 'single'
        st2::helper::systemd{ "${st2_process}_systemd":
          st2_process  => $st2_process,
          process_type => $process_type
        }
      }
    } elsif $operatingsystemmajrelease == '6' {

    }
  }

  service { "${st2_process}":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    provider   => $init_provider,
    subscribe  => [
      Package[$_package_map["${process}"]],
      Package['st2common'],
    ],
  }
}
