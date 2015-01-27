# == Class: st2::pack::incubator
#
#  Helper function to clean up Hiera imports
#
# === Parameters
#  [*packs*] - Array of packs to install
#
# === Examples
#
#  include st2::pack::incubator
#
#  class { 'st2::pack::incubator':
#    packs => ['cicd', 'jenkins'],
#  }
#
class st2::pack::incubator(
  $packs = hiera_array('st2::pack::incubator', []),
) {
  $_packs = join($packs, ',')

  st2::pack { $_packs:
    repo_url => 'https://github.com/StackStorm/st2incubator.git',
  }
}
