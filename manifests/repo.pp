# manages the StackStorm repo
class st2::repo (
  Variant[Enum['present', 'absent'], Boolean] $ensure = 'present',
  Enum['stable', 'unstable'] $repository              = 'stable',
) {
  case $facts['os']['family'] {
    'RedHat', 'Linux': {
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
        'stable'   => '3CE01873543A4CCE',
        'unstable' => '1CDF3CE710B2CCF3',
        default    => '3CE01873543A4CCE', # stable
      }
      $key_source = "https://packagecloud.io/StackStorm/${repository}/gpgkey"

      contain st2::repo::apt
    }

    default: {
      fail("Unsupported managed repository for osfamily: ${facts['os']['family']}, operatingsystem: ${facts['os']['name']}")
    }
  }
}
