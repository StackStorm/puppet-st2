# @summary st2 compatable installation of PostgreSQL and dependencies for use with StackStorm and Mistral.
#
# @param bind_ips
#   String of IPs (csv) that the Postgres database will accept connections on.
# @param manage
#   If this module should manage the postgres install and service
#   (default: true if Ubuntu <= 16.04 or CentOS <= 7, false otherwise)
#
# @example Basic usage
#   include st2::profile::postgresql
#
# @example Customizing parameters
#   class { 'st2::profile::postgresql':
#     db_bind_ips => '0.0.0.0',
#   }
#
class st2::profile::postgresql(
  $bind_ips = $::st2::mistral_db_bind_ips,
  $manage   = $::st2::mistral_manage,
) inherits st2 {
  if $manage and !defined(Class['postgresql::server']) {
    if ($::osfamily == 'RedHat') and ($::operatingsystemmajrelease == '6') {
      class { 'postgresql::globals':
        version             => '9.4',
        manage_package_repo => true,
      }
    }

    class { 'postgresql::server':
      listen_addresses => $bind_ips,
    }
  }
}
