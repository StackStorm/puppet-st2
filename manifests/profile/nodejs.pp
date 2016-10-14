class st2::profile::nodejs {
  case $::osfamily {
    'Debian': {
        ensure_packages(['ca-certificates'])
	    apt::source { 'nodesource':
	      include  => {
	        'src' => $enable_src,
	      },
	      key      => {
	        'id'     => '9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280',
	        'source' => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key',
	      },
	      location => "https://deb.nodesource.com/node_4.x",
	      pin      => $pin,
	      release  => $::lsbdistcodename,
	      repos    => 'main',
	      require  => [
	        Package['apt-transport-https'],
	        Package['ca-certificates'],
	      ],
	    }
    }
    'RedHat': {
      notify{'Unsupported OS: RedHat':}
    }
    default: {
      notify{'Unsupported OS':}
    }
  }
}