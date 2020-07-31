# @summary  Profile to install, configure and manage StackStorm web UI (st2web).
#
# @param ssl_cert_manage
#   Boolean to determine if this module should manage the SSL certificate used by nginx.
# @param ssl_dir
#   Directory where st2web will look for its SSL info.
#   (default: /etc/ssl/st2)
# @param ssl_cert
#   Path to the file where the StackStorm SSL cert will
#   be generated. (default: /etc/ssl/st2/st2.crt)
# @param ssl_key
#   Path to the file where the StackStorm SSL key will
#   be generated. (default: /etc/ssl/st2/st2.key)
# @param version
#    Version of StackStorm WebUI to install
#
# @example Basic Usage
#   include st2::profile::web'
#
# @example Managing your own certificate
#   # create your own certificate and key in the correct locations
#   file { '/etc/ssl/st2/st2.crt':
#     content => 'my cert data',
#   }
#   file { '/etc/ssl/st2/st2.key':
#     content => 'my privatekey data',
#   }
#
#   # instantiate this profile with ssl_cert_manage false
#   class { 'st2::profile::web':
#     ssl_cert_manage => false,
#   }
#
class st2::profile::web(
  $ssl_cert_manage = $::st2::ssl_cert_manage,
  $ssl_dir         = $::st2::ssl_dir,
  $ssl_cert        = $::st2::ssl_cert,
  $ssl_key         = $::st2::ssl_key,
  $version         = $::st2::version,
) inherits st2 {
  # include nginx here only
  # if we include this in st2::profile::fullinstall Anchor['pre_reqs'] then
  # a dependency cycle is created because we must modify the nginx config
  # in this profile.
  include st2::profile::nginx
  include st2::params

  ## Install the packages
  package { $::st2::params::st2_web_packages:
    ensure => $version,
    tag    => ['st2::packages', 'st2::web::packages'],
  }

  ## Create ssl cert directory
  file { $ssl_dir:
    ensure  => directory,
  }

  ## optionally manage the SSL certificate used by nginx
  if $ssl_cert_manage {
    ## Generate SSL certificates
    $_ssl_subj = "/C=US/ST=California/L=Palo Alto/O=StackStorm/OU=Information Technology/CN=${::fqdn}"
    exec { "generate ssl cert ${ssl_cert}":
      command => "openssl req -x509 -newkey rsa:2048 -keyout ${ssl_key} -out ${ssl_cert} -days 365 -nodes -subj \"${_ssl_subj}\"",
      creates => $ssl_cert,
      path    => ['/usr/bin', '/bin'],
      require => File[$ssl_dir],
      notify  => File["${::st2::params::nginx_conf_d}/st2.conf"],
    }
  }

  ## st2 nginx config
  file { "${::st2::params::nginx_conf_d}/st2.conf":
    ensure    => 'file',
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    source    => "file:///${::st2::params::nginx_st2_conf}",
    subscribe => Package[$::st2::params::st2_server_packages],
    notify    => Service['nginx'],
  }

  ## Remove the default nginx config
  file { $::st2::params::nginx_default_conf:
    ensure  => 'absent',
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  ## Dependencies
  Package['nginx']
  -> Package<| tag == 'st2::web::packages' |>
  -> File[$ssl_dir]
  -> File["${::st2::params::nginx_conf_d}/st2.conf"]
  ~> Service['nginx'] # notify to force a refresh
}
