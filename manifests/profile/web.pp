# == Class: st2::profile::web
#
#  Profile to install StackStorm web UI (st2web).
#
# === Parameters
#
#  [*version*]      - Version of StackStorm WebUI to install
#
# === Variables
#
#  This class has no variables
#
# === Examples
#
#  class { '::st2::profile::web': }
#
class st2::profile::web(
  $ssl_dir  = $st2::st2web_ssl_dir,
  $ssl_cert = $st2::st2web_ssl_cert,
  $ssl_key  = $st2::st2web_ssl_key,
  $version  = $st2::version,
) inherits st2 {
  # include nginx here only
  # if we include this in ::st2::profile::fullinstall Anchor['pre_reqs'] then
  # a dependency cycle is created because we must modify the nginx config
  # in this profile.
  include ::st2::profile::nginx

  ## Install the packages
  package { $st2::params::st2_web_packages:
    ensure => $version,
    tag    => 'st2::web::packages',
  }

  ## Create ssl cert directory
  file { $ssl_dir:
    ensure => directory,
  }

  ## Generate SSL certificates
  $_ssl_subj = "/C=US/ST=California/L=Palo Alto/O=StackStorm/OU=Information Technology/CN=${::fqdn}"
  exec { "generate ssl cert ${ssl_cert}":
    command => "openssl req -x509 -newkey rsa:2048 -keyout ${ssl_key} -out ${ssl_cert} -days 365 -nodes -subj \"${_ssl_subj}\"",
    creates => $ssl_cert,
    path    => ['/usr/bin', '/bin'],
  }

  ## st2 nginx config
  file { "${st2::params::nginx_conf_d}/st2.conf":
    ensure    => 'present',
    source    => $st2::params::nginx_st2_conf,
    subscribe => Package['st2'],
    notify    => Service['nginx'],
  }

  ## Modify default nginx config
  case $::osfamily  {
    'RedHat': {
      # remove 'default_server' string from default nginx config
      exec { $st2::params::nginx_default_conf:
        command => "sed -i 's/default_server//g' ${st2::params::nginx_default_conf}",
        unless  => "test `grep 'default_server' ${st2::params::nginx_default_conf} | wc -l` > 0",
        path    => ['/usr/bin', '/bin'],
        require => Package['nginx'],
        notify  => Service['nginx'],
      }
    }
    'Debian': {
      # remove the default nginx config
      file { $st2::params::nginx_default_conf:
        ensure  => 'absent',
        require => Package['nginx'],
        notify  => Service['nginx'],
      }
    }
    default : {
      notify{'Unsupported OS': }
    }
  }

  ## Dependencies
  Package['nginx']
  -> Package<| tag == 'st2::web::packages' |>
  -> File[$ssl_dir]
  -> Exec["generate ssl cert ${ssl_cert}"]
  -> File["${st2::params::nginx_conf_d}/st2.conf"]
  ~> Service['nginx'] # notify to force a refresh
}
