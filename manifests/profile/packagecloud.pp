# == Class: st2::profile::packagecloud
#
# This class adds packagecloud repos
#
# === Examples
#
#  include st2::profile::packagecloud
#
class st2::profile::packagecloud {

    $package_type = $::st2::package_type
    packagecloud::repo{'stackstorm/stable':
        type    => "$package_type"
    }
}
