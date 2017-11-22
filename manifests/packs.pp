# == Class: st2::packs
#
#  Install and configure st2 packages
#
#  See st2::pack and st2::pack::config for usage
#
# === Parameters
#
#  This class takes no parameters
#
# === Examples
#
#  include st2::packs
#
class st2::packs (
  $packs = $::st2::packs,
){
  create_resources('::st2::pack', $packs)
}
