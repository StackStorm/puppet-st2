# == Class: st2::packs
#
#  Automatically loads packs and their configs from Hiera
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
class st2::packs {
  $_packs = hiera_hash('st2::packs', {})
  create_resources('st2::pack', $_packs)
}
