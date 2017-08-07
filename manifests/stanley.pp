# == Class: st2::stanley
#
#  Installs the default admin user for st2 (stanley). Will install
#  insecure keys by default to allow testing, but also allows override of
#  values.
#
# === Parameters
#  [*ssh_public_key*]  - SSH Public Key without leading key-type and end email
#  [*ssh_key_type*]    - Type of SSH Key (ssh-dsa/ssh-rsa)
#  [*ssh_private_key*] - Private key
#  [*client*]          - Allow incoming connections from the defined user (default: true)
#  [*server*]          - Server where connection requests originate (usually st2 server) (default: false)
#
# === Examples
#
#  include ::st2::stanley
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
