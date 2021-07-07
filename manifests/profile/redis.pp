# @summary StackStorm compatable installation of Redis.
#
# @param [String] String
#   Bind IP of the Redis server. Default is 127.0.0.1
#
# @example Basic Usage
#  include st2::profile::redis
#
# @example Install with redis
#   class { '::redis':
#      bind => '127.0.0.1',
#    }
#
class st2::profile::redis (
  String  $bind_ip = $st2::redis_bind_ip,
) inherits st2 {

  class { 'redis':
      bind => $bind_ip,
  }

  contain redis
}
