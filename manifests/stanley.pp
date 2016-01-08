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
# === Variables
#  [*default_ssh_public_key*]  - Default SSH Public Key without leading key-type and end email
#  [*default_ssh_key_type*]    - Default SSH Key (ssh-dsa/ssh-rsa)
#  [*default_ssh_private_key*] - Default Private Key
#  [*_ssh_public_key*]         - Local variable holding the real value of `ssh_public_key` (set or default)
#  [*_ssh_key_type*]           - Local variable holding the real value of `ssh_key_type` (set or default)
#  [*_ssh_private_key*]        - Local variable holding the real value of `ssh_private_key` (set or default)
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

  if !$ssh_public_key or !$ssh_private_key {
    notify { '[st2::stanley] WARNING: No private and public SSH key provided. Please refer to Class[st2] to learn more on configuring this for production use': }
  }

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
