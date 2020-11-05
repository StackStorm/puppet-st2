require 'spec_helper'

describe 'st2::profile::web' do
  on_supported_os.each do |os, os_facts|
    let(:facts) { os_facts }
    let(:ssl_dir) { '/etc/ssl/st2' }
    let(:add_header) do
      {
        'Front-End-Https' => 'on',
        'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains',
        'X-Content-Type-Options' => 'nosniff',
      }
    end
    let(:ssl_ciphers) do
      [
        # TLSv1.3
        'TLS_AES_128_GCM_SHA256',
        'TLS_AES_256_GCM_SHA384',
        'TLS_CHACHA20_POLY1305_SHA256',
        # TLSv1.2
        'ECDHE-ECDSA-AES128-GCM-SHA256',
        'ECDHE-ECDSA-AES128-SHA256',
        'ECDHE-ECDSA-AES256-GCM-SHA384',
        'ECDHE-ECDSA-AES256-SHA384',
        'ECDHE-ECDSA-CHACHA20-POLY1305',
        'ECDHE-RSA-AES128-GCM-SHA256',
        'ECDHE-RSA-AES128-SHA256',
        'ECDHE-RSA-AES256-GCM-SHA384',
        'ECDHE-RSA-AES256-SHA384',
        'ECDHE-RSA-CHACHA20-POLY1305',
      ].join(':')
    end
    let(:ssl_protocols) do
      [
        'TLSv1.2',
        'TLSv1.3',
      ].join(' ')
    end

    context "on #{os}" do
      context 'with default options' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('st2::profile::nginx') }
        it do
          is_expected.to contain_package('st2web')
            .with(ensure: 'present',
                  tag: ['st2::packages', 'st2::web::packages'])
            .that_requires('Package[nginx]')
            .that_notifies('Service[nginx]')
        end
        it { is_expected.to contain_file(ssl_dir).with(ensure: 'directory') }
        it do
          is_expected.to contain_exec('generate ssl cert /etc/ssl/st2/st2.crt')
            .with(creates: '/etc/ssl/st2/st2.crt',
                  path: ['/usr/bin', '/bin'])
            .that_requires('File[/etc/ssl/st2]')
            .that_notifies('Nginx::Resource::Server[st2webui]')
        end
        it do
          is_expected.to contain_nginx__resource__server('st2webui')
            .with(ensure: 'present',
                  listen_port: 80,
                  access_log: '/var/log/nginx/st2webui.access.log',
                  error_log: '/var/log/nginx/st2webui.error.log',
                  ssl_redirect: true,
                  add_header: add_header,
                  tag: ['st2', 'st2::frontend', 'st2::frontend::http'])
        end
        it do
          is_expected.to contain_nginx__resource__server('ssl-st2webui')
            .with(ensure: 'present',
                  listen_port: 443,
                  index_files: ['index.html'],
                  access_log: '/var/log/nginx/ssl-st2webui.access.log',
                  error_log: '/var/log/nginx/ssl-st2webui.error.log',
                  use_default_location: false,
                  ssl: true,
                  ssl_cert: '/etc/ssl/st2/st2.crt',
                  ssl_key: '/etc/ssl/st2/st2.key',
                  ssl_port: 443,
                  ssl_ciphers: ssl_ciphers,
                  ssl_protocols: ssl_protocols,
                  client_max_body_size: '0',
                  add_header: add_header,
                  server_cfg_append: {
                    'rewrite' => [
                      '^/api/stream/?$ /stream/v1/stream break',
                      '^/api/(v\d)/stream/?$ /stream/$1/stream break',
                    ],
                  },
                  tag: ['st2', 'st2::frontend', 'st2::frontend::https'])
        end
        it do
          is_expected.to contain_nginx__resource__location('/')
            .with(ensure: 'present',
                  server: 'ssl-st2webui',
                  ssl: true,
                  ssl_only: true,
                  index_files: ['index.html'],
                  www_root: '/opt/stackstorm/static/webui/',
                  location_cfg_append: {
                    'sendfile'    => 'on',
                    'tcp_nopush'  => 'on',
                    'tcp_nodelay' => 'on',
                  },
                  tag: ['st2', 'st2::backend', 'st2::backend::webui'])
        end
        it do
          is_expected.to contain_nginx__resource__location('@apiError')
            .with(ensure: 'present',
                  server: 'ssl-st2webui',
                  ssl: true,
                  ssl_only: true,
                  index_files: [],
                  add_header: {
                    'Content-Type' => 'application/json always',
                  },
                  location_cfg_append: {
                    'return' => '503 \'{ "faultstring": "Nginx is unable to reach st2api. Make sure service is running." }\'',
                  },
                  tag: ['st2', 'st2::backend', 'st2::backend::apierror'])
        end
        it do
          is_expected.to contain_nginx__resource__location('/api/')
            .with(ensure: 'present',
                  server: 'ssl-st2webui',
                  ssl: true,
                  ssl_only: true,
                  index_files: [],
                  proxy_read_timeout: '90',
                  proxy_connect_timeout: '90',
                  proxy_redirect: 'off',
                  proxy_set_header: [
                    'Host $host',
                    'X-Real-IP $remote_addr',
                    'X-Forwarded-For $proxy_add_x_forwarded_for',
                    'X-Forwarded-Proto "https"',
                    'Connection \'\'',
                  ],
                  proxy_buffering: 'off',
                  proxy_cache: 'off',
                  rewrite_rules: [
                    '^/api/(.*)  /$1 break',
                  ],
                  proxy: 'http://127.0.0.1:9101',
                  location_cfg_append: {
                    'error_page'                => '502 = @apiError',
                    'chunked_transfer_encoding' => 'off',
                  },
                  tag: ['st2', 'st2::backend', 'st2::backend::api'])
        end
        it do
          is_expected.to contain_nginx__resource__location('@streamError')
            .with(ensure: 'present',
                  server: 'ssl-st2webui',
                  ssl: true,
                  ssl_only: true,
                  index_files: [],
                  add_header: {
                    'Content-Type' => 'text/event-stream',
                  },
                  location_cfg_append: {
                    'return' => '200 "retry: 1000\n\n"',
                  },
                  tag: ['st2', 'st2::backend', 'st2::backend::streamerror'])
        end
        it do
          is_expected.to contain_nginx__resource__location('/stream/')
            .with(ensure: 'present',
                  server: 'ssl-st2webui',
                  ssl: true,
                  ssl_only: true,
                  index_files: [],
                  proxy_read_timeout: '90',
                  proxy_connect_timeout: '90',
                  proxy_redirect: 'off',
                  proxy_set_header: [
                    'Host $host',
                    'X-Real-IP $remote_addr',
                    'X-Forwarded-For $proxy_add_x_forwarded_for',
                    'X-Forwarded-Proto "https"',
                    'Connection \'\'',
                  ],
                  proxy_buffering: 'off',
                  proxy_cache: 'off',
                  rewrite_rules: [
                    '^/stream/(.*)  /$1 break',
                  ],
                  proxy: 'http://127.0.0.1:9102',
                  location_cfg_append: {
                    'error_page'                => '502 = @streamError',
                    'chunked_transfer_encoding' => 'off',
                    'sendfile'                  => 'off',
                    'tcp_nopush'                => 'off',
                    'tcp_nodelay'               => 'off',
                  },
                  tag: ['st2', 'st2::backend', 'st2::backend::stream'])
        end
        it do
          is_expected.to contain_nginx__resource__location('@authError')
            .with(ensure: 'present',
                  server: 'ssl-st2webui',
                  ssl: true,
                  ssl_only: true,
                  index_files: [],
                  add_header: {
                    'Content-Type' => 'application/json always',
                  },
                  location_cfg_append: {
                    'return' => '503 \'{ "faultstring": "Nginx is unable to reach st2auth. Make sure service is running." }\'',
                  },
                  tag: ['st2', 'st2::backend', 'st2::backend::autherror'])
        end
        it do
          is_expected.to contain_nginx__resource__location('/auth/')
            .with(ensure: 'present',
                  server: 'ssl-st2webui',
                  ssl: true,
                  ssl_only: true,
                  index_files: [],
                  proxy_read_timeout: '90',
                  proxy_connect_timeout: '90',
                  proxy_redirect: 'off',
                  proxy_set_header: [
                    'Host $host',
                    'X-Real-IP $remote_addr',
                    'X-Forwarded-For $proxy_add_x_forwarded_for',
                    'X-Forwarded-Proto "https"',
                    'Connection \'\'',
                  ],
                  proxy_buffering: 'off',
                  proxy_cache: 'off',
                  rewrite_rules: [
                    '^/auth/(.*)  /$1 break',
                  ],
                  proxy: 'http://127.0.0.1:9100',
                  proxy_pass_header: [
                    'Authorization',
                  ],
                  location_cfg_append: {
                    'error_page'                => '502 = @authError',
                    'chunked_transfer_encoding' => 'off',
                  },
                  tag: ['st2', 'st2::backend', 'st2::backend::auth'])
        end
      end # context 'on #{os} with default options'

      context 'when specifying custom nginx_ssl_ciphers and nginx_ssl_protocols as strings' do
        let(:params) do
          {
            nginx_ssl_ciphers: 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384',
            nginx_ssl_protocols: 'TLSv1.1 TLSv1.2',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_nginx__resource__server('ssl-st2webui')
            .with(ensure: 'present',
                  listen_port: 443,
                  index_files: ['index.html'],
                  access_log: '/var/log/nginx/ssl-st2webui.access.log',
                  error_log: '/var/log/nginx/ssl-st2webui.error.log',
                  use_default_location: false,
                  ssl: true,
                  ssl_cert: '/etc/ssl/st2/st2.crt',
                  ssl_key: '/etc/ssl/st2/st2.key',
                  ssl_port: 443,
                  ssl_ciphers: 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384',
                  ssl_protocols: 'TLSv1.1 TLSv1.2',
                  client_max_body_size: '0',
                  add_header: add_header,
                  server_cfg_append: {
                    'rewrite' => [
                      '^/api/stream/?$ /stream/v1/stream break',
                      '^/api/(v\d)/stream/?$ /stream/$1/stream break',
                    ],
                  },
                  tag: ['st2', 'st2::frontend', 'st2::frontend::https'])
        end
      end # context 'when specifying custom nginx_ssl_ciphers and nginx_ssl_protocols as strings'

      context 'when specifying custom nginx_ssl_ciphers and nginx_ssl_protocols as arrays' do
        let(:params) do
          {
            nginx_ssl_ciphers: ['ECDHE-ECDSA-AES128-GCM-SHA256', 'ECDHE-ECDSA-AES256-SHA384'],
            nginx_ssl_protocols: ['TLSv1.1', 'TLSv1.2'],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_nginx__resource__server('ssl-st2webui')
            .with(ensure: 'present',
                  listen_port: 443,
                  index_files: ['index.html'],
                  access_log: '/var/log/nginx/ssl-st2webui.access.log',
                  error_log: '/var/log/nginx/ssl-st2webui.error.log',
                  use_default_location: false,
                  ssl: true,
                  ssl_cert: '/etc/ssl/st2/st2.crt',
                  ssl_key: '/etc/ssl/st2/st2.key',
                  ssl_port: 443,
                  ssl_ciphers: 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384',
                  ssl_protocols: 'TLSv1.1 TLSv1.2',
                  client_max_body_size: '0',
                  add_header: add_header,
                  server_cfg_append: {
                    'rewrite' => [
                      '^/api/stream/?$ /stream/v1/stream break',
                      '^/api/(v\d)/stream/?$ /stream/$1/stream break',
                    ],
                  },
                  tag: ['st2', 'st2::frontend', 'st2::frontend::https'])
        end
      end # context 'when specifying custom nginx_ssl_ciphers and nginx_ssl_protocols as arrays'

      context 'when specifying custom nginx_ssl_port and nginx_client_max_body_size' do
        let(:params) do
          {
            nginx_ssl_port: 8443,
            nginx_client_max_body_size: '8k',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_nginx__resource__server('ssl-st2webui')
            .with(ensure: 'present',
                  listen_port: 8443,
                  index_files: ['index.html'],
                  access_log: '/var/log/nginx/ssl-st2webui.access.log',
                  error_log: '/var/log/nginx/ssl-st2webui.error.log',
                  use_default_location: false,
                  ssl: true,
                  ssl_cert: '/etc/ssl/st2/st2.crt',
                  ssl_key: '/etc/ssl/st2/st2.key',
                  ssl_port: 8443,
                  ssl_ciphers: ssl_ciphers,
                  ssl_protocols: ssl_protocols,
                  client_max_body_size: '8k',
                  add_header: add_header,
                  server_cfg_append: {
                    'rewrite' => [
                      '^/api/stream/?$ /stream/v1/stream break',
                      '^/api/(v\d)/stream/?$ /stream/$1/stream break',
                    ],
                  },
                  tag: ['st2', 'st2::frontend', 'st2::frontend::https'])
        end
      end # context 'when specifying custom nginx_ssl_port and nginx_client_max_body_size'

      context 'with web_root=/some/other/dir/' do
        let(:params) { { web_root: '/some/other/dir/' } }

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_nginx__resource__location('/')
            .with(ensure: 'present',
                  server: 'ssl-st2webui',
                  ssl: true,
                  ssl_only: true,
                  index_files: ['index.html'],
                  www_root: '/some/other/dir/',
                  location_cfg_append: {
                    'sendfile'    => 'on',
                    'tcp_nopush'  => 'on',
                    'tcp_nodelay' => 'on',
                  },
                  tag: ['st2', 'st2::backend', 'st2::backend::webui'])
        end
      end # context 'with web_root=/some/other/dir/'

      context 'with ssl_cert_manage=false' do
        let(:params) { { ssl_cert_manage: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_exec('generate ssl cert /etc/ssl/st2/st2.crt') }
      end # context 'with ssl_cert_manage=false'
    end # context 'on #{os}'
  end # on_supported_os(all_os)
end # describe 'st2::profile::server'
