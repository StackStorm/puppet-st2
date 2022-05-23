# @summary  Profile to install, configure and manage StackStorm web UI (st2web).
#
# @param nginx_ssl_ciphers
#   String or list of strings of acceptable SSL ciphers to configure nginx with.
#   @see http://nginx.org/en/docs/http/ngx_http_ssl_module.html
#   Note: the defaults are setup to restrict to TLSv1.2 and TLSv1.3 secure ciphers only
#         (secure by default). The secure ciphers for each protocol were obtained via:
#         @see https://wiki.mozilla.org/Security/Server_Side_TLS
# @param nginx_ssl_protocols
#   String or list of strings of acceptable SSL protocols to configure nginx with.
#   @see http://nginx.org/en/docs/http/ngx_http_ssl_module.html
#   Note: the defaults are setup to restrict to TLSv1.2 and TLSv1.3 only (secure by default)
# @param nginx_ssl_port
#   What port should nginx listen on publicly for new connections (default: 443)
# @param nginx_client_max_body_size
#   The maximum size of the body for a request allow through nginx.
#   We default this to '0' to allow for large messages/payloads/inputs/results
#   to be passed through nginx as is normal in the StackStorm context.
#   @see http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size
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
# @param web_root
#    Directory where the StackStorm WebUI site lives on the filesystem
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
#
# @example Change the SSL protocols and ciphers
#   class { 'st2::profile::web':
#     nginx_ssl_protocols => ['TLSv1.2'],
#     nginx_ssl_ciphers => [
#       'ECDHE-ECDSA-AES256-GCM-SHA384',
#       'ECDHE-ECDSA-AES256-SHA384',
#     ],
#   }
#
class st2::profile::web(
  Variant[Array[String], String] $nginx_ssl_ciphers   = $st2::nginx_ssl_ciphers,
  Variant[Array[String], String] $nginx_ssl_protocols = $st2::nginx_ssl_protocols,
  Stdlib::Port $nginx_ssl_port                        = $st2::nginx_ssl_port,
  String $nginx_client_max_body_size                  = $st2::nginx_client_max_body_size,
  Boolean $ssl_cert_manage                            = $st2::ssl_cert_manage,
  Stdlib::Absolutepath $ssl_dir                       = $st2::ssl_dir,
  String $ssl_cert                                    = $st2::ssl_cert,
  String $ssl_key                                     = $st2::ssl_key,
  String $version                                     = $st2::version,
  String $web_root                                    = $st2::web_root,
  Integer $basicstatus_port                           = $st2::nginx_basicstatus_port,
  Boolean $basicstatus_enabled                        = $st2::nginx_basicstatus_enabled,
) inherits st2 {
  # include nginx here only
  # if we include this in st2::profile::fullinstall Anchor['pre_reqs'] then
  # a dependency cycle is created because we must modify the nginx config
  # in this profile.
  include st2::profile::nginx
  include st2::params

  ## Install the packages
  package { $st2::params::st2_web_packages:
    ensure  => $version,
    tag     => ['st2::packages', 'st2::web::packages'],
    require => Package['nginx'],
    notify  => Service['nginx'], # notify to force a refresh if the package is updated
  }

  ## Create ssl cert directory
  file { $ssl_dir:
    ensure  => directory,
  }

  ## optionally manage the SSL certificate used by nginx
  if $ssl_cert_manage {
    # openssl only allows CNs with max length of 64, so we truncate to 64 chars
    $_truncated_certname = $trusted['certname'].length > 64 ? {
      true => $trusted['certname'][0,64],
      default => $trusted['certname'],
    }
    $_ssl_subj = "/C=US/ST=California/L=Palo Alto/O=StackStorm/OU=Information Technology/CN=${_truncated_certname}"
    ## Generate SSL certificates
    exec { "generate ssl cert ${ssl_cert}":
      command => "openssl req -x509 -newkey rsa:2048 -keyout ${ssl_key} -out ${ssl_cert} -days 365 -nodes -subj \"${_ssl_subj}\"",
      creates => $ssl_cert,
      path    => ['/usr/bin', '/bin'],
      require => File[$ssl_dir],
      notify  => Nginx::Resource::Server['st2webui'],
    }
  }

  # http redirect to https
  $add_header = {
    'Front-End-Https'           => 'on',
    'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains',
    'X-Content-Type-Options'    => 'nosniff',
  }
  nginx::resource::server { 'st2webui':
    ensure       => present,
    listen_port  => 80,
    access_log   => "${nginx::config::log_dir}/st2webui.access.log",
    error_log    => "${nginx::config::log_dir}/st2webui.error.log",
    ssl_redirect => true,
    add_header   => $add_header,
    tag          => ['st2', 'st2::frontend', 'st2::frontend::http'],
  }

  # convert arrays into strings if necessary
  $nginx_ssl_ciphers_str = $nginx_ssl_ciphers ? {
    Array[String] => $nginx_ssl_ciphers.join(':'),
    String        => $nginx_ssl_ciphers,
  }
  $nginx_ssl_protocols_str = $nginx_ssl_protocols ? {
    Array[String] => $nginx_ssl_protocols.join(' '),
    String        => $nginx_ssl_protocols,
  }

  $ssl_server = 'ssl-st2webui'
  nginx::resource::server { $ssl_server:
    ensure               => present,
    listen_port          => $nginx_ssl_port,
    index_files          => [ 'index.html' ],
    access_log           => "${nginx::config::log_dir}/${ssl_server}.access.log",
    error_log            => "${nginx::config::log_dir}/${ssl_server}.error.log",
    # disable the built-in 'location /' (in puppet-nginx) so we can define our own below
    use_default_location => false,
    ssl                  => true,
    ssl_cert             => $ssl_cert,
    ssl_key              => $ssl_key,
    ssl_port             => $nginx_ssl_port,
    ssl_ciphers          => $nginx_ssl_ciphers_str,
    ssl_protocols        => $nginx_ssl_protocols_str,
    client_max_body_size => $nginx_client_max_body_size,
    add_header           => $add_header,
    # For backward compatibility reasons, rewrite requests from "/api/stream"
    # to "/stream/v1/stream" and "/api/v1/stream" to "/stream/v1/stream"
    server_cfg_append    => {
      'rewrite' => [
        '^/api/stream/?$ /stream/v1/stream break',
        '^/api/(v\d)/stream/?$ /stream/$1/stream break',
      ],
    },
    tag                  => ['st2', 'st2::frontend', 'st2::frontend::https'],
  }

  # default settings for all locations
  $location_defaults = {
    ensure      => present,
    server      => $ssl_server,
    # need to ensure both ssl and ssl_true are set so that these locations are ONLY
    # added to the ssl site above
    ssl         => true,
    ssl_only    => true,
    index_files => [ ],
  }

  # the proxy locations contain all of the location settings plus some common
  # proxy settings used commonly across all of them, rather than copy paste
  # we use some hash merges to make this more compact and easier to add common
  # settings in the future
  $proxy_defaults = $location_defaults + {
    proxy_read_timeout    => '90',
    proxy_connect_timeout => '90',
    proxy_redirect        => 'off',
    proxy_set_header      => [
      'Host $host',
      'X-Real-IP $remote_addr',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'X-Forwarded-Proto "https"',
      'Connection \'\'',
    ],
    # Disable buffering and chunked encoding.
    # In the stream case we want to receive the whole payload at once, we don't
    # want multiple chunks.
    proxy_buffering       => 'off',
    proxy_cache           => 'off',
  }

  # root website location for st2webui
  nginx::resource::location { '/':
    * => $location_defaults + {
      index_files         => [ 'index.html' ],
      www_root            => $web_root,
      location_cfg_append => {
        'sendfile'    => 'on',
        'tcp_nopush'  => 'on',
        'tcp_nodelay' => 'on',
      },
      tag                 => ['st2', 'st2::backend', 'st2::backend::webui'],
    },
  }

  nginx::resource::location { '@apiError':
    * => $location_defaults + {
      add_header          => {
        'Content-Type' => 'application/json always',
      },
      location_cfg_append => {
        'return' => '503 \'{ "faultstring": "Nginx is unable to reach st2api. Make sure service is running." }\'',
      },
      tag                 => ['st2', 'st2::backend', 'st2::backend::apierror'],
    },
  }

  nginx::resource::location { '/api/':
    * => $proxy_defaults + {
      rewrite_rules       => [
        '^/api/(.*)  /$1 break',
      ],
      proxy               => "http://127.0.0.1:${st2::params::api_port}",
      location_cfg_append => {
        'error_page'                => '502 = @apiError',
        'chunked_transfer_encoding' => 'off',
      },
      tag                 => ['st2', 'st2::backend', 'st2::backend::api'],
    },
  }

  if $basicstatus_enabled {
    nginx::resource::location { '@basic_statusError':
      * => $location_defaults + {
        add_header          => {
          'Content-Type' => 'application/json always',
        },
        location_cfg_append => {
          'return' => '503 \'{ "faultstring": "Nginx is unable to reach basic_status. Make sure service is running." }\'',
        },
        tag                 => ['st2', 'st2::backend', 'st2::backend::basicstatuserror'],
      },
    }

    nginx::resource::location { '/basic_status/':
      * => $proxy_defaults + {
        rewrite_rules       => [
          '^/api/(.*)  /$1 break',
        ],
        proxy               => "http://127.0.0.1:${basicstatus_port}",
        location_cfg_append => {
          'error_page'  => '502 = @basic_statusError',
          'stub_status' => 'on',
        },
        tag                 => ['st2', 'st2::backend', 'st2::backend::basic_status'],
      },
    }
  }

  nginx::resource::location { '@streamError':
    * => $location_defaults + {
      add_header          => {
        'Content-Type' => 'text/event-stream',
      },
      location_cfg_append => {
        'return' => '200 "retry: 1000\n\n"',
      },
      tag                 => ['st2', 'st2::backend', 'st2::backend::streamerror'],
    },
  }

  nginx::resource::location { '/stream/':
    * => $proxy_defaults + {
      rewrite_rules       => [
        '^/stream/(.*)  /$1 break',
      ],
      proxy               => "http://127.0.0.1:${st2::params::stream_port}",
      location_cfg_append => {
        'error_page'                => '502 = @streamError',
        'chunked_transfer_encoding' => 'off',
        'sendfile'                  => 'off',
        'tcp_nopush'                => 'off',
        'tcp_nodelay'               => 'off',
      },
      tag                 => ['st2', 'st2::backend', 'st2::backend::stream'],
    },
  }

  nginx::resource::location { '@authError':
    * => $location_defaults + {
      add_header          => {
        'Content-Type' => 'application/json always',
      },
      location_cfg_append => {
        'return' => '503 \'{ "faultstring": "Nginx is unable to reach st2auth. Make sure service is running." }\'',
      },
      tag                 => ['st2', 'st2::backend', 'st2::backend::autherror'],
    },
  }

  nginx::resource::location { '/auth/':
    * => $proxy_defaults + {
      rewrite_rules       => [
        '^/auth/(.*)  /$1 break',
      ],
      proxy               => "http://127.0.0.1:${st2::params::auth_port}",
      proxy_pass_header   => [
        'Authorization',
      ],
      location_cfg_append => {
        'error_page'                => '502 = @authError',
        'chunked_transfer_encoding' => 'off',
      },
      tag                 => ['st2', 'st2::backend', 'st2::backend::auth'],
    },
  }

  ## Dependencies
  ## Note: nginx automatically configures the dependencies correctly for its configuration
}
