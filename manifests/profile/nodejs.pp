# == Class st2::profile::nodejs
#
# st2 compatable installation of NodeJS and dependencies for use with
# StackStorm
#
# === Parameters
#
#  This module contains no parameters
#
# === Variables
#
#  This module contains no variables
#
# === Examples
#
#  include st2::profile::nodejs
#
class st2::profile::nodejs {
  # Red Hat 7.x + already have NodeJS 6.x+ installed
  # trying to install from nodesource repos fails, so just use the builtin
  if $::osfamily == 'RedHat' and $::operatingsystemmajrelease >= '7' {
    class { '::nodejs':
      manage_package_repo => false,
      npm_package_ensure  => 'present',
    }
  }
  else {
    # else install nodejs 4.x from nodesource repo
    class { '::nodejs':
      repo_url_suffix    => '4.x',
    }
  }
}
