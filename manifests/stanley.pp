# @summary Installs the default admin user for st2 (stanley).
#
# @note Will install auto-generate SSH keys of none are provided.
#
# @param username
#    Name of the stanley user
# @param ssh_public_key
#    SSH Public Key without leading key-type and end email
# @param ssh_key_type
#    Type of SSH Key (ssh-dsa/ssh-rsa)
# @param ssh_private_key
#    Private key
# @param client
#    Allow incoming connections from the defined user
# @param server
#    Server where connection requests originate (usually st2 server)
#
# @example Basic Usage
#  include st2::stanley
#
# @example Custom SSH keys
#  class { 'st2::stanley':
#    ssh_key_type => 'ssh-rsa',
#    ssh_public_key => 'AAAAAWESOMEKEY==',
#    ssh_private_key => '----- BEGIN RSA PRIVATE KEY -----\nDEADBEEF\n----- END RSA PRIVATE KEY -----',
#  }
#
class st2::stanley (
  $username        = 'stanley',
  $ssh_public_key  = undef,
  $ssh_key_type    = undef,
  $ssh_private_key = undef,
  $client          = true,
  $server          = true,
) {
  st2::user { $username:
    client            => $client,
    server            => $server,
    create_sudo_entry => true,
    groups            => 'st2packs',
    ssh_public_key    => $ssh_public_key,
    ssh_key_type      => $ssh_key_type,
    ssh_private_key   => $ssh_private_key,
  }
}
