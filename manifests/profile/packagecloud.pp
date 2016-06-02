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

    if $st2::enterprise_token != undef {
    	packagecloud::repo{'stackstorm/enterprise':
            type         => "$package_type",
            master_token => $st2::enterprise_token
        }
    }
}
