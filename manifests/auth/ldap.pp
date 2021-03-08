# @summary Auth class to configure and setup LDAP Based Authentication
#
# For information on parameters see the
# {backend documentation}[https://docs.stackstorm.com/authentication.html#ldap]
#
# @param conf_file
#    The path where st2 config is stored
# @param host
#    URI of the LDAP server.
#    Format: <code><protocol>://<hostname>[:port]</code> (protocol: ldap or ldaps)
# @param use_tls
#    Boolean parameter to set if tls is required.
#    Should be set to false using ldaps in the uri. (default: false)
# @param use_ssl
#    Boolean parameter to set if ssl is required.
#    Should be set to true using ldaps in the uri. (default: false)
# @param port
#    Integer port to be used for LDAP connection
#    Should be set to false using ldaps in the uri. (default: 389)
# @param bind_dn
#    DN user to bind to LDAP. If an empty string, an anonymous bind is performed.
#    To use the user supplied username in the bind_dn, use the <code>{username}</code> placeholder
#    in string.
# @param bind_pw
#    DN password. Use the <code>{password}</code> placeholder in the string to use the user supplied password.
# @param base_dn
#    Base DN to search for all users/groups entries.
# @param group_dns
#    DN of groups user must be member of to be granted access
# @param chase_referrals
#    Boolean parameter to set whether to chase referrals. (default: true)
# @param scope
#    Search scope (base, onelevel, or subtree) (default: subtree)
# @param id_attr
#    Field name of the user ID attribute (default: uid)
# @param account_pattern
#    LDAP subtree pattern to match user. The user’s username is escaped and interpolated into this string
# @param group_pattern
#    LDAP subtree pattern for user groups. Both user_dn and username are escaped and then interpolated into this string
#
# @example Instantiate via st2 (Active Directory)
#  class { 'st2':
#    auth_backend        => 'ldap',
#    auth_backend_config => {
#      host            => 'ldap.domain.tld',
#      bind_dn         => 'cn=ldap_stackstorm,ou=service accounts,dc=domain,dc=tld',
#      base_dn         => 'dc=domain,dc=tld',
#      scope           => 'subtree',
#      id_attr         => 'username',
#      bind_pw         => 'some_password',
#      group_dns       => ['"cn=stackstorm_users,ou=groups,dc=domain,dc=tld"'],
#      account_pattern => 'userPrincipalName={username}',
#    },
#  }
#
# @example Instantiate via Hiera (Active Directory)
#  st2::auth_backend: "ldap"
#  st2::auth_backend_config:
#    host: "ldaps.domain.tld"
#    use_tls: false
#    use_ssl: true
#    port: 636
#    bind_dn: 'cn=ldap_stackstorm,ou=service accounts,dc=domain,dc=tld'
#    bind_pw: 'some_password'
#    chase_referrals: false
#    base_dn: 'dc=domain,dc=tld'
#    group_dns:
#      - '"cn=stackstorm_users,ou=groups,dc=domain,dc=tld"'
#    scope: "subtree"
#    id_attr: "username"
#    account_pattern: "userPrincipalName={username}"
#
class st2::auth::ldap (
  $conf_file       = $::st2::conf_file,
  $host            = '',
  $use_tls         = false,
  $use_ssl         = false,
  $port            = 389,
  $bind_dn         = '',
  $bind_pw         = '',
  $base_dn         = '',
  $group_dns       = undef,
  $chase_referrals = true,
  $scope           = 'subtree',
  $id_attr         = 'uid',
  $account_pattern = undef,
  $group_pattern   = undef,
) inherits st2 {
  include st2::auth::common

  $_use_tls = bool2str($use_tls)
  $_use_ssl = bool2str($use_ssl)
  $_chase_refs = bool2str($chase_referrals)
  if $account_pattern != undef and $group_pattern != undef {
    $_kwargs = "{\"host\": \"${host     }\", \"use_tls\": ${_use_tls}, \
      \"bind_dn\": \"${bind_dn}\", \"bind_password\": \"${bind_pw}\", \
      \"chase_referrals\": ${_chase_refs}, \"base_ou\": \"${base_dn}\", \
      \"group_dns\": ${group_dns}, \"use_ssl\": ${_use_ssl}, \"port\": ${port}, \
      \"scope\": \"${scope}\", \"id_attr\": \"${id_attr}\", \
      \"account_pattern\": \"${account_pattern}\", \"group_pattern\": \"${group_pattern}\"}"
  }
  elsif $account_pattern != undef {
    $_kwargs = "{\"host\": \"${host     }\", \"use_tls\": ${_use_tls}, \
      \"bind_dn\": \"${bind_dn}\", \"bind_password\": \"${bind_pw}\", \
      \"chase_referrals\": ${_chase_refs}, \"base_ou\": \"${base_dn}\", \
      \"group_dns\": ${group_dns}, \"use_ssl\": ${_use_ssl}, \"port\": ${port}, \
      \"scope\": \"${scope}\", \"id_attr\": \"${id_attr}\", \
      \"account_pattern\": \"${account_pattern}\"}"
  }
  elsif $group_pattern != undef {
    $_kwargs = "{\"host\": \"${host     }\", \"use_tls\": ${_use_tls}, \
      \"bind_dn\": \"${bind_dn}\", \"bind_password\": \"${bind_pw}\", \
      \"chase_referrals\": ${_chase_refs}, \"base_ou\": \"${base_dn}\", \
      \"group_dns\": ${group_dns}, \"use_ssl\": ${_use_ssl}, \"port\": ${port}, \
      \"scope\": \"${scope}\", \"id_attr\": \"${id_attr}\", \
      \"group_pattern\": \"${group_pattern}\"}"
  }
  else {
    $_kwargs = "{\"host\": \"${host     }\", \"use_tls\": ${_use_tls}, \
      \"bind_dn\": \"${bind_dn}\", \"bind_password\": \"${bind_pw}\", \
      \"chase_referrals\": ${_chase_refs}, \"base_ou\": \"${base_dn}\", \
      \"group_dns\": ${group_dns}, \"use_ssl\": ${_use_ssl}, \"port\": ${port}, \
      \"scope\": \"${scope}\", \"id_attr\": \"${id_attr}\"}"
  }

  # config
  ini_setting { 'auth_backend':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'backend',
    value   => 'ldap',
    tag     => 'st2::config',
  }
  ini_setting { 'auth_backend_kwargs':
    ensure  => present,
    path    => $conf_file,
    section => 'auth',
    setting => 'backend_kwargs',
    value   => $_kwargs,
    tag     => 'st2::config',
  }

  # install package dependency
  $_dep_pkgs = $::osfamily ? {
    'Debian' => ['gcc', 'libldap2-dev'],
    'RedHat' => ['gcc', 'openldap-devel'],
    default  => undef,
  }
  ensure_packages($_dep_pkgs,
                  {
                    'ensure' => 'present',
                  })

  # dependencies
  Package<| tag == 'st2::server::packages' |>
  -> Package[$_dep_pkgs]
  ~> Service['st2auth']
}
