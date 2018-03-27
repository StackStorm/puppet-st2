# Class: st2::auth::ldap
#
#  Auth class to configure and setup Ldap Based Authentication
#
# Parameters:
#
# [*db_host*] - Ldap Host to connect to (default: 127.0.0.1)
# [*db_port*] - Ldap Port to connect to (default: 27017)
# [*db_name*] - Ldap DB storing credentials (default: st2auth)
#
# Usage:
#
#  # basic usage, accepting all defaults in ::st2::auth
#  include ::st2::auth::ldap
#
#  # advanced usage for overriding defaults in ::st2::auth
#  class { '::st2::auth':
#    backend        => 'ldap',
#    backend_config => {
#      db_host => 'ldap.stackstorm.net',
#      db_port => '1234',
#      db_name => 'myauthdb',
#    },
#  }
class st2::auth::ldap (
  $ldap_uri        = '',
  $use_tls         = true,
  $bind_dn         = '',
  $bind_pw         = '',
  $user            = undef,
  $group           = undef,
  $chase_referrals = true,
  $ref_hop_limit   = 0,
) {
  include ::st2::auth

  $_use_tls = $use_tls ? {
    true  => 'True',
    false => 'False',
  }
  $_chase_refs = $chase_referrals ? {
    true  => 'True',
    false => 'False',
  }

  if $user != undef and $group != undef {
    $_kwargs = "{\"ldap_uri\": \"${ldap_uri}\", \"use_tls\": ${_use_tls}, "\
      "\"bind_dn\": \"${bind_dn}\", \"bind_pw\": \"${bind_pw}\", "\
      "\"chase_referrals\": ${_chase_refs}, \"ref_hop_limit\": ${ref_hop_limit}, "\
      "\"user\": {\"base_dn\": \"${user['base_dn']}\", "\
      "\"search_filter\": \"${user['search_filter']}\", "\
      "\"scope\": \"${user['scope']}\"}, "\
      "\"group\": {\"base_dn\": \"${group['base_dn']}\", "\
      "\"search_filter\": \"${group['search_filter']}\", "\
      "\"scope\": \"${group['scope']}\"}}"
  }
  elsif $user != undef {
    $_kwargs = "{\"ldap_uri\": \"${ldap_uri}\", \"use_tls\": ${_use_tls}, "\
      "\"bind_dn\": \"${bind_dn}\", \"bind_pw\": \"${bind_pw}\", "\
      "\"chase_referrals\": ${_chase_refs}, \"ref_hop_limit\": ${ref_hop_limit}, "\
      "\"user\": {\"base_dn\": \"${user['base_dn']}\", "\
      "\"search_filter\": \"${user['search_filter']}\", "\
      "\"scope\": \"${user['scope']}\"}}"
  }
  elsif $group != undef {
    $_kwargs = "{\"ldap_uri\": \"${ldap_uri}\", \"use_tls\": ${_use_tls}, "\
      "\"bind_dn\": \"${bind_dn}\", \"bind_pw\": \"${bind_pw}\", "\
      "\"chase_referrals\": ${_chase_refs}, \"ref_hop_limit\": ${ref_hop_limit}, "\
      "\"group\": {\"base_dn\": \"${group['base_dn']}\", "\
      "\"search_filter\": \"${group['search_filter']}\", "\
      "\"scope\": \"${group['scope']}\"}}"
  }

  # config
  ini_setting { 'auth_backend':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'backend',
    value   => 'ldap',
    tag     => 'st2::config',
  }
  ini_setting { 'auth_backend_kwargs':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
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
                    'tag'    => 'st2::auth::ldap',
                  })

  # install the backend package
  python::pip { 'st2-auth-backend-ldap':
    ensure     => 'latest',
    pkgname    => 'st2-auth-backend-ldap',
    url        => 'git+https://github.com/StackStorm/st2-auth-backend-ldap.git@master#egg=st2_auth_backend_ldap',
    owner      => 'root',
    virtualenv => '/opt/stackstorm/st2/bin',
    timeout    => 1800,
  }

  # dependencies
  Package<| tag == 'st2::server::packages' |>
  -> Package[$_dep_pkgs]
  -> Python::Pip['st2-auth-backend-ldap']
  ~> Service['st2auth']
}
