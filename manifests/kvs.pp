# @summary Automatically loads Key/Value pairs for StackStorm DB from Hiera
#
# @see st2::kv
#
# @example Key/value pairs defined in Hiera
#   st2::kvs:
#     keyname:
#       value: 'blah'
#     mysupercoolkey:
#       value: 'xyz123'
#
class st2::kvs {
  $_kvs = hiera_hash('st2::kvs', {})
  create_resources('st2::kv', $_kvs)
}
