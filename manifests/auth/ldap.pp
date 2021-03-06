# @summary Auth class to configure and setup LDAP Based Authentication
#
# For information on parameters see the
# {backend documentation}[https://github.com/StackStorm/st2-auth-backend-ldap#configuration-options]
#
# @param conf_file
#    The path where st2 config is stored
# @param ldap_uri
#    URI of the LDAP server.
#    Format: <code><protocol>://<hostname>[:port]</code> (protocol: ldap or ldaps)
# @param use_tls
#    Boolean parameter to set if tls is required.
#    Should be set to false using ldaps in the uri. (default: false)
# @param bind_dn
#    DN user to bind to LDAP. If an empty string, an anonymous bind is performed.
#    To use the user supplied username in the bind_dn, use the <code>{username}</code> placeholder
#    in string.
# @param bind_pw
#    DN password. Use the <code>{password}</code> placeholder in the string to use the user supplied password.
# @param user
#   Search parameters for user authentication
#
#   * base_dn - Base DN on the LDAP server to be used when looking up the user account.
#   * search_filter - LDAP search filter for finding the user in the directory.
#     Should contain the placeholder <code>{username}</code> for the username.
#   * scope - The scope of the search to be performed.
#     Available choices: base, onelevel, subtree
#
# @param group
#   Search parameters for user's group membership:
#
#   * base_dn - Base DN on the LDAP server to be used when looking up the group.
#   * search_filter - DAP search filter for finding the group in the directory.
#     Should contain the placeholder <code>{username}</code> for the username.
#   * scope - The scope of the search to be performed.
#     Available choices: base, onelevel, subtree
# @param chase_referrals
#    Boolean parameter to set whether to chase referrals. (default: true)
# @param ref_hop_limit
#    The maximum number to refer Referrals recursively (default: 0)
#
# @example Instantiate via st2 (Active Directory)
#  class { 'st2':
#    auth_backend        => 'ldap',
#    auth_backend_config => {
#      ldap_uri      => 'ldaps://ldap.domain.tld',
#      bind_dn       => 'cn=ldap_stackstorm,ou=service accounts,dc=domain,dc=tld',
#      bind_pw       => 'some_password',
#      ref_hop_limit => 100,
#      user          => {
#        base_dn       => "ou=domain_users,dc=domain,dc=tld",
#        search_filter => "(&(objectClass=user)(sAMAccountName={username})(memberOf=cn=stackstorm_users,ou=groups,dc=domain,dc=tld))",
#        scope         => "subtree"
#      },
#    },
#  }
#
# @example Instantiate via Hiera (Active Directory)
#  st2::auth_backend: "ldap"
#  st2::auth_backend_config:
#    ldap_uri: "ldaps://ldap.domain.tld"
#    bind_dn: "cn=ldap_stackstorm,ou=service accounts,dc=domain,dc=tld"
#    bind_pw: "some_password"
#    ref_hop_limit: 100
#    user:
#      base_dn: "ou=domain_users,dc=domain,dc=tld"
#      search_filter: "(&(objectClass=user)(sAMAccountName={username})(memberOf=cn=stackstorm_users,ou=groups,dc=domain,dc=tld))"
#      scope: "subtree"
#
class st2::auth::ldap (
  $conf_file       = $::st2::conf_file,
  $ldap_host       = '',
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
  $account_pattern  = undef,
) inherits st2 {
  include st2::auth::common

  $_use_tls = bool2str($use_tls)
  $_use_ssl = bool2str($use_ssl)
  $_chase_refs = bool2str($chase_referrals)
  $_kwargs = "{\"host\": \"${ldap_host}\", \"use_tls\": ${_use_tls}, \
    \"bind_dn\": \"${bind_dn}\", \"bind_password\": \"${bind_pw}\", \
    \"chase_referrals\": ${_chase_refs}, \"base_ou\": \"${base_dn}\", \
    \"group_dns\": ${group_dns}, \"use_ssl\": ${_use_ssl}, \"port\": ${port}}, \
    \"scope\": \"${scope}\", \"id_attr\": \"${id_attr}\", \
    \"account_pattern\": \"${account_pattern}\""

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
