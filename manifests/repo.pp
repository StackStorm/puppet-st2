# @summary Manages the installation of st2 required repos for installing the StackStorm packages.
#
# @example Basic usage
#   include st2::repo
#
# @example Installing from unstable
#   class { 'st2::repo':
#     repository => 'unstable',
#   }
#
# @param [Enum['present', 'absent']] ensure
#   The basic state the repo should be in
#
# @param [St2::Repository] repository
#   Release repository to enable
#
class st2::repo (
  Enum['present', 'absent'] $ensure = 'present',
  St2::Repository $repository = $st2::repository,
  Boolean $manage_epel_repo = true
) inherits st2 {
  case $facts['os']['family'] {
    'RedHat': {
      # RedHat distros need EPEL, $manage_epel_repo can be set to false if not needed
      if $manage_epel_repo {
        require epel
      }

      $dist_version = $facts['os']['release']['major']
      $baseurl = "https://packagecloud.io/StackStorm/${repository}/el/${dist_version}/\$basearch"
      $gpgkey = "https://packagecloud.io/StackStorm/${repository}/gpgkey"

      contain st2::repo::yum
    }

    'Debian': {
      # debian, ubuntu, etc
      $osname = downcase($facts['os']['name'])
      # trusty, xenial, bionic, etc
      $release = downcase($facts['os']['distro']['codename'])
      $location = "https://packagecloud.io/StackStorm/${repository}/${osname}"
      $repos = 'main'

      $key_id = $repository ? {
        'stable'           => '3CE01873543A4CCE',
        'staging-stable'   => '527B93CA96ADF311',
        'staging-unstable' => '9A2236A8CEC0C6A8',
        'unstable'         => '1CDF3CE710B2CCF3',
        default            => '3CE01873543A4CCE', # stable
      }
      $key_source = "https://packagecloud.io/StackStorm/${repository}/gpgkey"

      contain st2::repo::apt
    }

    default: {
      fail("Unsupported managed repository for osfamily: ${facts['os']['family']}, operatingsystem: ${facts['os']['name']}")
    }
  }
}
