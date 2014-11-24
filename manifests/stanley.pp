class st2::stanley (
  $ssh_public_key  = undef,
  $ssh_key_type    = undef,
  $ssh_private_key = undef,
) {
  st2::user { 'stanley':
    client            => true,
    server            => true,
    create_sudo_entry => true,
    ssh_public_key    => $ssh_public_key,
    ssh_key_type      => $ssh_key_type,
    ssh_private_key   => $ssh_private_key,
  }
}
