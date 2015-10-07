# Definition: st2::helper::service_manager
#
#  This deined type is used to add service management scripts for the various distros
#
define st2::helper::service_manager (
  $process = undef,
) {

  $_package_map = $::st2::params::component_map
  $st2_process = $_package_map["${process}"]
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

      st2::helper::systemd{ "${st2_process}_systemd":
        st2_process  => $st2_process,
        process_type => 'single'
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
      Package[$_package_map["${process}"],
      Package['st2common'],
    ],
  }
}