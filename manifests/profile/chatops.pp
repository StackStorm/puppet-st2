# == Class: st2::profile::chatops
#
#  Profile to install and configure chatops for st2
#
# === Parameters
#
#  [*version*]                      - Version of StackStorm to install
#  [*hubot_log_level*]              - Hubot log level
#  [*hubot_express_port*]           - Express port hubot listens to
#  [*tls_cert_reject_unauthorized*] - Set to 1 when using self signed certs
#  [*hubot_name*]                   - Hubot's name
#  [*npm_packages*]                 - Nodejs packages to be installed (hubot adapter)
#  [*adapter_config*]               - Configuration parameters for Hubot adapter (hash)
#
# === Variables
#
#  [*_chatops_packages*] - Local scoped variable to store st2 chatops packages.
#                          Sources from st2::params
#  [*_chatops_dir*]      - Local scoped variable for full path of chatops directory.
#  [*_chatops_env_file*] - Local scoped variable for full path of st2chatops env file.
#
# === Examples
#
#  include st2::profile::chatops
#

class st2::profile::chatops (
  $version                      = $::st2::version,
  $hubot_log_level              = $::st2::params::hubot_log_level,
  $hubot_express_port           = $::st2::params::hubot_express_port,
  $tls_cert_reject_unauthorized = $::st2::params::tls_cert_reject_unauthorized,
  $hubot_name                   = $::st2::params::hubot_name,
  $npm_packages                 = $::st2::chatops_adapter,
  $adapter_config               = $::st2::chatops_adapter_conf,
) inherits st2 {
  include '::st2::params'

  $_chatops_packages = $::st2::params::st2_chatops_packages
  $_chatops_dir  = '/opt/stackstorm/chatops'
  $_chatops_env_file = "${_chatops_dir}/st2chatops.env"

  ########################################
  ## Packages
  package { $_chatops_packages:
    ensure => $version,
    tag    => 'st2::chatops::packages',
  }

  ########################################
  ## Config
  file { $_chatops_env_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('st2/st2chatops.env.erb'),
  }

  ########################################
  ## Additional nodejs packages
  include ::st2::profile::nodejs

  $npm_package_defaults = {
    ensure  => present,
    target  => $_chatops_dir,
    require => Class['St2::Profile::Nodejs'],
    tag     => 'st2::chatops::npm_package',
  }

  create_resources('::nodejs::npm', $npm_packages, $npm_package_defaults)

  ########################################
  ## Services
  service { $::st2::params::st2_chatops_services:
    ensure => 'running',
    enable => true,
    tag    => 'st2::chatops::service',
  }

  ########################################
  ## Dependencies
  Package<| tag == 'st2::chatops::packages' |>
  -> File[$_chatops_env_file]
  ~> Service<| tag == 'st2::chatops::service' |> # notify to force a refresh

  Service<| tag == 'st2::service' |>
  -> Service<| tag == 'st2::chatops::service' |>

  Nodejs::Npm<| tag == 'st2::chatops::npm_package' |>
  -> Service<| tag == 'st2::chatops::service' |>
}
