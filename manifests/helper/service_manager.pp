# Definition: st2::helper::service_manager
#
#  This deined type is used to add service management scripts for the various distros
#
define st2::helper::service_manager (
  $process = undef,
) {
  $_package_map = $::st2::params::component_map
  $package = $_package_map["${process}"]
  $st2_process = "st2${process}"
  $init_provider = $::st2::params::init_type

  if $osfamily == 'Debian' {

    file { "/etc/init/${process}.conf":
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0444',
      source => "puppet:///modules/st2/etc/init/${st2_process}.conf",
      notify => Service["${st2_process}"],
    }
  } elsif $osfamily == 'RedHat' {
    if $operatingsystemmajrelease == '7' {
      if $process == 'st2actionrunner' {
        $process_type = 'multi'
        file{"/etc/systemd/system/st2actionrunner.service":
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0444',
          source  => "puppet:///modules/st2/systemd/system/st2actionrunner.service",
        }

        exec{"sysctl enable ${st2_process}":
          path    => '/bin:/usr/bin:/usr/local/bin',
          command => "systemctl --no-reload enable st2actionrunner",
          require => File["/etc/systemd/system/${st2_process}.service"],
          notify  => Service["${st2_process}"],
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
      Package["${package}"],
      Package['st2common'],
    ],
  }
}
