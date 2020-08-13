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
  Variant[Array[String], String] $nginx_ssl_ciphers   = $::st2::nginx_ssl_ciphers,
  Variant[Array[String], String] $nginx_ssl_protocols = $::st2::nginx_ssl_protocols,
  Stdlib::Port $nginx_ssl_port       = $::st2::nginx_ssl_port,
  String $nginx_client_max_body_size = $::st2::nginx_client_max_body_size,
  Boolean $ssl_cert_manage      = $::st2::ssl_cert_manage,
  Stdlib::Absolutepath $ssl_dir = $::st2::ssl_dir,
  String $ssl_cert              = $::st2::ssl_cert,
  String $ssl_key               = $::st2::ssl_key,
  String $version               = $::st2::version,
  String $web_root              = $::st2::web_root,
) inherits st2 {
  # include nginx here only
  # if we include this in st2::profile::fullinstall Anchor['pre_reqs'] then
  # a dependency cycle is created because we must modify the nginx config
  # in this profile.
  include st2::profile::nginx
  include st2::params

  ## Install the packages
  package { $::st2::params::st2_web_packages:
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
    ## Generate SSL certificates
    $_ssl_subj = "/C=US/ST=California/L=Palo Alto/O=StackStorm/OU=Information Technology/CN=${$trusted['certname']}"
    exec { "generate ssl cert ${ssl_cert}":
      command => "openssl req -x509 -newkey rsa:2048 -keyout ${ssl_key} -out ${ssl_cert} -days 365 -nodes -subj \"${_ssl_subj}\"",
      creates => $ssl_cert,
      path    => ['/usr/bin', '/bin'],
      require => File[$ssl_dir],
      notify  => Nginx::Resource::Server['st2webui'],
    }
  }

  # http redirect to https
  nginx::resource::server { 'st2webui':
    ensure       => present,
    listen_port  => 80,
    access_log   => "${nginx::config::log_dir}/st2webui.access.log",
    error_log    => "${nginx::config::log_dir}/st2webui.error.log",
    ssl_redirect => true,
    add_header   => {
      'Front-End-Https'        => 'on',
      'X-Content-Type-Options' => 'nosniff',
    },
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
    add_header           => {
      'Front-End-Https'        => 'on',
      'X-Content-Type-Options' => 'nosniff',
    },
    # For backward compatibility reasons, rewrite requests from "/api/stream"
    # to "/stream/v1/stream" and "/api/v1/stream" to "/stream/v1/stream"
    server_cfg_append    => {
      'rewrite' => [
        '^/api/stream/?$ /stream/v1/stream break',
        '^/api/(v\d)/stream/?$ /stream/$1/stream break'
      ],
    },
  }

  # root website location for st2webui
  nginx::resource::location { '/':
    ensure              => present,
    server              => $ssl_server,
    ssl                 => true,
    ssl_only            => true,
    index_files         => [ 'index.html' ],
    www_root            => $web_root,
    location_cfg_append => {
      'sendfile'    => 'on',
      'tcp_nopush'  => 'on',
      'tcp_nodelay' => 'on',
    }
  }

  nginx::resource::location { '@apiError':
    ensure              => present,
    server              => $ssl_server,
    ssl                 => true,
    ssl_only            => true,
    index_files         => [],
    add_header          => {
      'Content-Type' => 'application/json always',
    },
    location_cfg_append => {
      'return' => '503 \'{ "faultstring": "Nginx is unable to reach st2api. Make sure service is running." }\'',
    }
  }

  nginx::resource::location { '/api/':
    ensure                => present,
    server                => $ssl_server,
    ssl                   => true,
    ssl_only              => true,
    index_files           => [],
    rewrite_rules         => [
      '^/api/(.*)  /$1 break',
    ],
    proxy                 => "http://127.0.0.1:${st2::params::api_port}",
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
    proxy_buffering       => 'off',
    proxy_cache           => 'off',
    location_cfg_append   => {
      'error_page'                => '502 = @apiError',
      'chunked_transfer_encoding' => 'off',
    }
  }

  nginx::resource::location { '@streamError':
    ensure              => present,
    server              => $ssl_server,
    ssl                 => true,
    ssl_only            => true,
    index_files         => [],
    add_header          => {
      'Content-Type' => 'text/event-stream',
    },
    location_cfg_append => {
      'return' => '200 "retry: 1000\n\n"',
    }
  }

  nginx::resource::location { '/stream/':
    ensure                => present,
    server                => $ssl_server,
    ssl                   => true,
    ssl_only              => true,
    index_files           => [],
    rewrite_rules         => [
      '^/stream/(.*)  /$1 break',
    ],
    proxy                 => "http://127.0.0.1:${st2::params::stream_port}",
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
    location_cfg_append   => {
      'error_page'                => '502 = @streamError',
      'chunked_transfer_encoding' => 'off',
      'sendfile'                  => 'off',
      'tcp_nopush'                => 'off',
      'tcp_nodelay'               => 'off',
    }
  }

  nginx::resource::location { '@authError':
    ensure              => present,
    server              => $ssl_server,
    ssl                 => true,
    ssl_only            => true,
    index_files         => [],
    add_header          => {
      'Content-Type' => 'application/json always',
    },
    location_cfg_append => {
      'return' => '503 \'{ "faultstring": "Nginx is unable to reach st2auth. Make sure service is running." }\'',
    }
  }

  nginx::resource::location { '/auth/':
    ensure                => present,
    server                => $ssl_server,
    ssl                   => true,
    ssl_only              => true,
    index_files           => [],
    rewrite_rules         => [
      '^/auth/(.*)  /$1 break',
    ],
    proxy                 => "http://127.0.0.1:${st2::params::auth_port}",
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
    proxy_pass_header     => [
      'Authorization',
    ],
    proxy_buffering       => 'off',
    proxy_cache           => 'off',
    location_cfg_append   => {
      'error_page'                => '502 = @authError',
      'chunked_transfer_encoding' => 'off',
    }
  }

  ## Dependencies
  ## Note: nginx automatically configures the dependencies correctly for its configuration
}
