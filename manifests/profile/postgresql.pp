# @summary st2 compatable installation of PostgreSQL and dependencies for use with StackStorm and Mistral.
#
# @example Basic usage
#   include ::st2::profile::postgresql
#
# @example Customizing parameters
#   class { '::st2::profile::postgresql':
#     db_bind_ips => '0.0.0.0',
#   }
#
# @param db_bind_ips
#   String of IPs (csv) that the Postgres database will accept connections on.
#
class st2::profile::postgresql(
  $bind_ips = $::st2::mistral_db_bind_ips,
) inherits st2 {
  if !defined(Class['::postgresql::server']) {
    if ($::osfamily == 'RedHat') and ($::operatingsystemmajrelease == '6') {
      class { '::postgresql::globals':
        version             => '9.4',
        manage_package_repo => true,
      }
    }

    class { '::postgresql::server':
      listen_addresses => $bind_ips,
    }
  }
}
