# == Class: st2::kvs
#
#  Automatically loads Key/Value pairs for StackStorm DB from Hiera
#
#  See st2::kv
#
# === Parameters
#
#  This class takes no parameters
#
# === Examples
#
#  include st2::kvs
#
class st2::kvs {
  $_kvs = hiera_hash('st2::kvs', {})
  create_resources('st2::kv', $_kvs)
}
