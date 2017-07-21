# == Class: st2::profile::web
#
#  Profile to install StackStorm web client (st2web). This feature is
#  currently under active development, and limited to early access users.
#  If you would like to try this out, please send an email to support@stackstorm.com
#  and let us know!
#
# === Parameters
#
#  [*st2_api_url*]  - URL of st2_api service -- ex: http://127.0.0.1:9101
#  [*version*]      - Version of StackStorm WebUI to install
#
# === Variables
#
#  This class has no variables
#
# === Examples
#
#  include ::nginx
#
class st2::profile::web(
  $api_url    = $::st2::api_url,
  $auth       = $::st2::auth,
  $auth_url   = $::st2::auth_url,
  $flow_url   = $::st2::flow_url,
  $version    = $::st2::version,
  $autoupdate = $::st2::autoupdate,
) inherits st2 {

  # This is crude... get some augeas on
  ## Manage connection list currently
  file { '/opt/stackstorm/static/webui/config.js':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('st2/opt/st2web/config.js.erb'),
  }

  file { "${st2::params::nginx_conf_d}/st2.conf":
    ensure => 'present',
    source => $st2::params::nginx_st2_conf,
    notify => Service['nginx'],
  }

  case $::osfamily  {
    'RedHat': {
      # remove 'default_server' string from default nginx config
      exec { $st2::params::nginx_default_conf:
        command => "sed -i 's/default_server//g' ${st2::params::nginx_default_conf}",
        onlyif  => "test `grep -q 'default_server' ${st2::params::nginx_default_conf} | wc -l` > 0",
        path    => ['/usr/bin', '/bin'],
        notify  => Service['nginx'],
      }
    }
    'Debian': {
      file { $st2::params::nginx_default_conf:
        ensure => 'absent',
        notify => Service['nginx'],
      }
    }
    default : {
      notify{'Unsupported OS': }
    }
  }


}
