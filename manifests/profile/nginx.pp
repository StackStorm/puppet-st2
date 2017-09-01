# == Class st2::profile::nginx
#
# st2 compatible installation of nginx and dependencies for use with
# StackStorm
#
# === Parameters
#
#  [*manage_repo*] - Set this to false when you have your own repository for nginx
#
# === Variables
#
#  This module contains no variables
#
# === Examples
#
#  include st2::profile::nginx
#
class st2::profile::nginx (
  $manage_repo = $::st2::nginx_manage_repo
) inherits st2 {
  class { '::nginx':
    manage_repo => $manage_repo,
    confd_purge => false,
  }
}
