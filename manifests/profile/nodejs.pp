class st2::profile::nodejs {
  class { '::nodejs':
    proxy       => false,
    manage_repo => true,
    notify      => Exec['upgrade npm'],
  }

  exec { 'upgrade npm':
    command     => 'npm install npm -g --ca=""',
    path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    refreshonly => true,
  }

  package { 'bower':
    ensure   => present,
    provider => 'npm',
    require  => Class['::nodejs'],
  }
  package { 'gulp':
    ensure   => present,
    provider => 'npm',
    require  => Class['::nodejs'],
  }

  Exec['upgrade npm'] -> Package<| provider == 'npm' |>
}
