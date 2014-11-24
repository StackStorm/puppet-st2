class st2::profile::nodejs {
  class { '::nodejs':
    proxy       => false,
    manage_repo => true,
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
}
