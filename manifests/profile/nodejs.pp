# == Class st2::profile::nodejs
#
# st2 compatable installation of NodeJS and dependencies for use with
# StackStorm
#
# === Parameters
#
#  [*version*]     - Version of NodeJS to install. If not provided it
#                    will be auto-calcuated based on $version
#                    (default: $::st2::nodejs_version)
#  [*manage_repo*] - Set this to false when you have your own repositories
#                    for NodeJS (default: $::st2::nodejs_manage_repo)
#
# === Variables
#
#  This module contains no variables
#
# === Examples
#
#  include st2::profile::nodejs
#
class st2::profile::nodejs(
  $manage_repo = $::st2::nodejs_manage_repo,
  $version     = $::st2::nodejs_version,
) inherits st2 {

  # if the StackStorm version is 'latest' or >= 3.0.0 then use NodeJS 10.x
  # if the StackStorm version is 3.0.0 < and >= 2.4.0 then use NodeJS 6.x
  # else use NodeJS 4.x
  if ($::st2::version == 'latest' or
      $::st2::version == 'present' or
      $::st2::version == 'installed' or
      versioncmp($::st2::version, '3.0.0') >= 0) {
    $nodejs_version_default = '10.x'
  }
  elsif versioncmp($::st2::version, '2.4.0') >= 0 {
    $nodejs_version_default = '6.x'
    $use_rhel7_builtin = true
  }
  else {
    $nodejs_version_default = '4.x'
    $use_rhel7_builtin = true
  }

  # if user specified a version of NodeJS they want to use, then use that
  # otherwise use the default version based off the StackStorm version
  $nodejs_version = $version ? {
    undef   => $nodejs_version_default,
    default => $version,
  }

  # Red Hat 7.x + already have NodeJS 6.x installed
  # trying to install from nodesource repos fails, so just use the builtin
  if ($use_rhel7_builtin and
      $::osfamily == 'RedHat' and
      versioncmp($::operatingsystemmajrelease, '7') >= 0) {
    class { '::nodejs':
      manage_package_repo => false,
      npm_package_ensure  => 'present',
    }
  }
  else {
    # else install nodejs from nodesource repo
    class { '::nodejs':
      repo_url_suffix     => $nodejs_version,
      manage_package_repo => $manage_repo,
    }
  }
}
