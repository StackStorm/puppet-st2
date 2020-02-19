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
#
class st2::profile::repos(
  Enum['stable', 'unstable'] $repository = $st2::repository,
) inherits st2 {
  if $::osfamily == 'RedHat' {
    require epel
  }

  # defines the StackStorm repo (Yum and Apt are handled here)
  class { 'st2::repo':
    repository => $repository,
  }
  contain st2::repo
}
