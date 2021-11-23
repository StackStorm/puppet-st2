# @summary StackStorm compatible installation of nginx and dependencies.
#
# @param manage_repo
#    Set this to false when you have your own repository for nginx
#
# @example Basic Usage
#  include st2::dependency::nginx
#
# @example Disable managing the nginx repo so you can manage it yourself
#  class { 'st2::dependency::nginx':
#    manage_repo => false,
#  }
#
class st2::dependency::nginx (
  $manage_repo = $st2::nginx_manage_repo
) inherits st2 {
  class { 'nginx':
    manage_repo => $manage_repo,
    confd_purge => true,
  }
}
