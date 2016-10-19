# Class: st2::profile::nodejs
#
#  Parts taken from:
#  https://github.com/voxpupuli/puppet-nodejs
#  Module was not used due to incompatibilities
#
class st2::profile::nodejs {
  case $::osfamily {
    'Debian': {
        ensure_packages(['ca-certificates'])
        apt::source { 'nodesource':
          key      => {
            'id'     => '9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280',
            'source' => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key',
          },
          location => 'https://deb.nodesource.com/node_4.x',
          release  => $::lsbdistcodename,
          repos    => 'main',
          require  => [
            Package['apt-transport-https'],
            Package['ca-certificates'],
          ],
        }
    }
    'RedHat': {
        if $::operatingsystemrelease =~ /^5\.(\d+)/ {
            include ::epel
            $dist_version  = '5'
            $name_string   = 'Enterprise Linux 5'
        }

        elsif $::operatingsystemrelease =~ /^6\.(\d+)/ {
            $dist_version = '6'
            $name_string  = 'Enterprise Linux 6'
        }

        elsif $::operatingsystemrelease =~ /^7\.(\d+)/ {
            $dist_version = '7'
            $name_string  = 'Enterprise Linux 7'
        }
        # nodesource repo
        $descr   = "Node.js Packages for ${name_string} - \$basearch"
        $baseurl = "https://rpm.nodesource.com/pub_4.x/el/${dist_version}/\$basearch"

        # nodesource-source repo
        $source_descr   = "Node.js for ${name_string} - \$basearch - Source"
        $source_baseurl = "https://rpm.nodesource.com/pub_4.x/el/${dist_version}/SRPMS"

        yumrepo { 'nodesource':
          descr          => $descr,
          baseurl        => $baseurl,
          enabled        => '1',
          failovermethod => 'priority',
          gpgkey         => 'file:///etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL',
          gpgcheck       => '1',
          #require        => File['/etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL'],
        }

        yumrepo { 'nodesource-source':
          descr          => $source_descr,
          baseurl        => $source_baseurl,
          enabled        => '0',
          failovermethod => 'priority',
          gpgkey         => 'file:///etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL',
          gpgcheck       => '1',
          #require        => File['/etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL'],
        }

        file { '/etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL':
          ensure => file,
          group  => '0',
          mode   => '0644',
          owner  => 'root',
          source => "puppet:///modules/${module_name}/repo/nodesource/NODESOURCE-GPG-SIGNING-KEY-EL",
        }
    }
    default: {
      notify{'Unsupported OS':}
    }
  }
}
