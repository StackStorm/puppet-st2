# @summary Creates an system (OS level) user for use with StackStorm
#
# @param client
#    Allow incoming connections from the defined user
# @param server
#    Server where connection requests originate (usually st2 server)
# @param create_sudo_entry
#    Manage the sudoers entry (default: false)
# @param ssh_public_key
#    SSH Public Key without leading key-type and end email.
# @param ssh_key_type
#    Type of SSH Key (ssh-dsa/ssh-rsa)
# @param ssh_private_key
#    SSH Private key. If not specified, then one will be generated.
# @param groups
#    List of groups (OS level) that this user should be a member of
# @param ssh_dir
#    Directory where SSH keys will be stored
#
# @example Custom SSH keys
#  st2::user { 'stanley':
#    ssh_key_type => 'ssh-rsa',
#    ssh_public_key => 'AAAAAWESOMEKEY==',
#    ssh_private_key => '----- BEGIN RSA PRIVATE KEY -----\nDEADBEEF\n----- END RSA PRIVATE KEY -----',
#  }
#
define st2::process(
  $process_name,
  $process_num,
  $process_services,
) {
  if ($process_num > 1) {
    $additional_services = range('2', $process_num).reduce([]) |$memo, $number| {
      $new_process_name = "${process_name}${number}"
      case $facts['os']['family'] {
        'RedHat': {
          $file_path = '/usr/lib/systemd/system/'
        }
        'Debian': {
          $file_path = '/lib/systemd/system/'
        }
        default: {
          fail("Unsupported managed repository for osfamily: ${facts['os']['family']}, operatingsystem: ${facts['os']['name']}")
        }
      }

      systemd::unit_file { "${new_process_name}.service":
        path   => $file_path,
        source => "${file_path}${process_name}.service",
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
      }

      $memo + [$new_process_name]
    }

    $_process_services = $process_services + $additional_services

  } else {
    $_process_services = $process_services
  }

  ########################################
  ## Services
  service { $_process_services:
    ensure => 'running',
    enable => true,
    tag    => 'st2::service',
  }
}
