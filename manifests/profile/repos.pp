# @summary Manages the installation of st2 required repos for installing the StackStorm packages.
#
# @example Basic usage
#   include st2::profile::repos
#
# @example Installing from unstable
#   class { 'st2::profile::repos':
#     repository => 'unstable',
#   }
#
# @param repository
#   Release repository to enable. Options: 'stable', 'unstable'.
# @param package_type
#   Type of package management system used for repo. Options: 'rpm', 'deb'
#
class st2::profile::repos(
  $repository   = $::st2::repository,
  $package_type = $::st2::params::package_type,
) inherits st2 {
  require packagecloud

  if $::osfamily == 'RedHat' {
    require epel
  }
  $_packagecloud_repo = "StackStorm/${repository}"
  packagecloud::repo { $_packagecloud_repo:
    type => $package_type,
  }

  # On ubuntu 14, the packagecloud repo addition corrupts the apt-cache...
  # this cleans it out and refreshes it
  if ($::osfamily == 'Debian' and
      versioncmp($::operatingsystemmajrelease, '14.04') == 0) {
    exec { 'Refresh apt-cache after packagecloud':
      command     =>  'rm -rf /var/lib/apt/lists/*; apt-get update',
      path        => ['/usr/bin/', '/bin/'],
      refreshonly => true,
      subscribe   => Packagecloud::Repo[$_packagecloud_repo],
    }
  }
}
