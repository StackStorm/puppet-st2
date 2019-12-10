# @summary Install and configure st2 packages in bulk and via Hiera.
#
# @see st2::pack and st2::pack::config for usage
#
# @example Basic Usage
#  class { '::st2::packs':
#    packs => {
#      puppet => {},
#      influxdb => {
#        config => {
#          server => 'influxdb.domain.tld',
#      },
#    },
#  }
#
# @example Created via Hiera
#  st2::packs:
#    puppet: {}
#    influxdb:
#      config:
#        server => 'influxdb.domain.tld'
#
class st2::packs (
  $packs = $::st2::packs,
) inherits st2 {
  create_resources('::st2::pack', $packs)
}
