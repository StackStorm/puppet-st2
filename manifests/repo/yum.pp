# Yum repo for StackStorm
class st2::repo::yum {
  if $st2::repo::ensure == 'present' {
    yumrepo { "StackStorm_${st2::repo::repository}":
      baseurl       => $st2::repo::baseurl,
      enabled       => '1',
      gpgcheck      => '0',
      repo_gpgcheck => '1',
      gpgkey        => $st2::repo::gpgkey,
    }

    Yumrepo["StackStorm_${st2::repo::repository}"]
    -> Package<| tag == 'st2::server::packages' |>
  }
  else {
    yumrepo { "StackStorm_${st2::repo::repository}":
      ensure => absent,
    }
  }
}
