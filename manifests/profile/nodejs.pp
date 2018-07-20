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

  # if the StackStorm version is 'latest' or >= 2.4.0 then use NodeJS 6.x
  # else use MongoDB 4.x
  if ($::st2::version == 'latest' or
      $::st2::version == 'present' or
      $::st2::version == 'installed' or
      versioncmp($::st2::version, '2.4.0') >= 0) {
    $nodejs_version_default = '6.x'
  }
  else {
    $nodejs_version_default = '4.x'
  }

  # if user specified a version of NodeJS they want to use, then use that
  # otherwise use the default version based off the StackStorm version
  $nodejs_version = $version ? {
    undef   => $nodejs_version_default,
    default => $version,
  }

  if $::osfamily == 'RedHat' {
    # Red Hat 7.x + already have NodeJS 6.x+ installed
    # trying to install from nodesource repos fails, so just use the builtin
    if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
      class { '::nodejs':
        manage_package_repo => false,
        npm_package_ensure  => 'present',
        require             => Class['::epel'],
      }

      # TODO remove all of this when we remove support for Puppet 3
      # the following is required because of Puppet 3's ordering guarnatees
      Yumrepo['epel']
      -> Class['::nodejs']

      Yumrepo['epel']
      -> Package<| tag == 'nodesource_repo' |>

      File['/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7']
      -> Class['::nodejs']

      File['/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7']
      -> Package<| tag == 'nodesource_repo' |>

      Epel::Rpm_gpg_key['EPEL-7']
      -> Class['::nodejs']

      Epel::Rpm_gpg_key['EPEL-7']
      -> Package<| tag == 'nodesource_repo' |>
    }
    else {
      # Red Hat 6.x requires us to use an OLD version of puppet/nodejs (1.3.0)
      # In this old repo they hard-code some verifications about which versions
      # are allowed to be installed (at the time the module was released).
      # This has changed and NodeJS 4.x is supported and can be installed on
      # RHEL 6.x. To fake this out we need to hard code the "repo_class"
      # to the same thing they use internally but without the leading "::"
      # to avoid their verification checks (ugh...).
      class { '::nodejs':
        repo_url_suffix     => $nodejs_version,
        repo_class          => 'nodejs::repo::nodesource',
        manage_package_repo => $manage_repo,
      }
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
