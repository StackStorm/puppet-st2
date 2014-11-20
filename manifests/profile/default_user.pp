class st2::profile::default_user {
  st2::user { 'stanley':
    client            => false,
    server            => true,
    create_sudo_entry => true,
    generate_keypair  => true,
  }
}
