define st2::pack::config (
  $pack   = $name,
  $config = undef,
) {
  if $config {
    validate_hash($config)
    $_config = to_yaml($config)
  } else {
    $_hiera_lookup = hiera("st2::pack::${pack}", {})
    validate_hash($_hiera_lookup)
    $_config = to_yaml($_hiera_lookup)
  }

  file { "/opt/stackstorm/packs/${pack}/config.yaml":
    ensure  => file,
    mode    => 0440,
    content => $_config,
  }

  Exec<| tag == 'st2::pack' |> -> File["/opt/stackstorm/packs/${pack}/config.yaml"]
}
