# Apt repo for StackStorm
class st2::repo::apt {
  if $st2::repo::ensure == 'present' or $st2::repo::ensure == true {
    apt::source { "StackStorm_${st2::repo::repository}":
      location => $st2::repo::location,
      release  => $st2::repo::release,
      repos    => $st2::repo::repos,
      key      => {
        'id'     => $st2::repo::key_id,
        'source' => $st2::repo::key_server,
      },
    }

    Apt::Source["StackStorm_${st2::repo::repository}"]
    -> Package<| tag == 'st2::server::packages' |>
  }
  else {
    apt::source { "StackStorm_${st2::repo::repository}":
      ensure => absent,
    }
  }
}
