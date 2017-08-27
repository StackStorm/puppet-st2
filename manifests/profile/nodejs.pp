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
  if $::osfamily == 'RedHat' {
    # Red Hat 7.x + already have NodeJS 6.x+ installed
    # trying to install from nodesource repos fails, so just use the builtin
    if $::operatingsystemmajrelease >= '7' {
      class { '::nodejs':
        manage_package_repo => false,
        npm_package_ensure  => 'present',
        require             => Class['::epel'],
      }
    }
    # Red Hat 6.x requires us to use an OLD version of puppet/nodejs (1.3.0)
    # In this old repo they hard-code some verifications about which versions
    # are allowed to be installed (at the time the module was released).
    # This has changed and NodeJS 4.x is supported and can be installed on
    # RHEL 6.x. To fake this out we need to hard code the "repo_class"
    # to the same thing they use internally but without the leading "::"
    # to avoid their verification checks (ugh...).
    else {
      class { '::nodejs':
        repo_url_suffix => '4.x',
        repo_class      => 'nodejs::repo::nodesource',
      }
    }
  }
  else {
    # else install nodejs 4.x from nodesource repo
    class { '::nodejs':
      repo_url_suffix => '4.x',
    }
  }
}
