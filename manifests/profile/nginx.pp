# == Class st2::profile::nginx
#
# st2 compatible installation of nginx and dependencies for use with
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
#  include st2::profile::nginx
#
class st2::profile::nginx inherits st2 {
  class { '::nginx':
    manage_repo => true,
    confd_purge => false,
  }
}
