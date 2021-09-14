
class { 'st2':
  repository => 'unstable',
}
include st2::profile::fullinstall
