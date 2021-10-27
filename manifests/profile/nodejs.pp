# @summary st2 compatable installation of NodeJS and dependencies for use with StackStorm.
#
# This class is needed for StackStorm ChatOps +st2::profile::chatops::.
# Normally this class is instantiated by +st2::profile::fullinstall+.
# However, advanced users can instantiate this class directly to configure
# and manage just the <code>NodeJS</code> installation on a single node.
#
# @example Basic Usage
#  include st2::profile::nodejs
#
# @example Custom Parameters
#  class { 'st2::profile::nodejs':
#  }
#
# @param manage_repo
#   Set this to false when you have your own repositories for NodeJS.
# @param version
#   Version of NodeJS to install. If not provided it will be auto-calcuated based on $st2::version
#
class st2::profile::nodejs(
  $manage_repo = $st2::nodejs_manage_repo,
  $version     = $st2::nodejs_version,
) inherits st2 {

  $use_rhel7_builtin = false

  # if the StackStorm version is >= 3.5.0 then use NodeJS 14.x
  # if the StackStorm version is >= 2.10.0 then use NodeJS 10.x
  # if the StackStorm version is 2.10.0 < and >= 2.4.0 then use NodeJS 6.x
  # else use NodeJS 4.x
  if st2::version_ge('3.5.0') {
    $nodejs_version_default = '14.x'
  }
  elsif st2::version_ge('2.10.0') {
    $nodejs_version_default = '10.x'
  }
  elsif st2::version_ge('2.4.0') {
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
  if ($facts['os']['family'] == 'RedHat' and
      versioncmp($facts['os']['release']['major'], '7') >= 0) {
    if $use_rhel7_builtin {
      class { 'nodejs':
        manage_package_repo => false,
        npm_package_ensure  => 'present',
      }
    }
    else {
      class { 'nodejs':
        repo_url_suffix     => $nodejs_version,
        manage_package_repo => $manage_repo,
      }
      # When upgrading from NodeJS 6 installed with EPEL to NodeJS 10+
      # from the NodeSource repo, we need to remove the npm package.
      # npm is now installed with the nodejs package.
      # To do this we need to tell the rpm provider "force" uninstall
      # because the npm package from EPEL has dependencies on the nodejs
      # and st2chatops package.
      # This allows us go upgrade RHEL7 clients from NodeJS 6 -> 10
      Package<| title == $::nodejs::npm_package_name |> {
        uninstall_options => ['--nodeps'],
        provider          => 'rpm',
      }
    }
  }
  else {
    # install nodejs from nodesource repo
    class { 'nodejs':
      repo_url_suffix     => $nodejs_version,
      manage_package_repo => $manage_repo,
    }
  }
}
