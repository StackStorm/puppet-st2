# Definition: systemd
#
#  Lets create some Systemd scripts
#
define st2::helper::systemd (
  $st2_process  = undef,
  $process_type = 'single'
  ) {

  if $process_type == 'multi' {
    $extra_char = "${process_type}@"
  } else {
    $extra_Char = ''
  }

  file{"/etc/systemd/system/${st2_process}${extra_char}.service":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template("st2/etc/systemd/system/st2service_${process_type}.service.erb"),
  }

  if $process_type == 'single' {
    exec{"sysctl enable ${st2_process}":
      path    => '/bin:/usr/bin:/usr/local/bin',
      command => "systemctl --no-reload enable ${st2_process}",
      require => File["/etc/systemd/system/${st2_process}${extra_char}.service"],
      notify  => Service["${st2_process}"],
    }
  }
}
