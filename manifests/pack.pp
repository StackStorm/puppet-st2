# @summary Manages a StackStorm Pack
#
# @param pack
#    Name of the pack to install.
# @param repo_url
#    URL of the package to install when not installing from the exchange.
# @param config
#    Hash that will be translated into YAML in the pack's config file after installation.
#
# @example Basic Usage
#  st2::pack { 'puppet': }
#
# @example Install from a custom URL
#  st2::pack { 'custom':
#    repo_url => 'http://github.com/myorg/stackstorm-custom.git',
#  }
#
define st2::pack (
  $ensure   = present,
  $pack     = $name,
  $repo_url = undef,
  $config   = undef,
) {
  include st2
  $_cli_username = $::st2::cli_username
  $_cli_password = $::st2::cli_password

  st2_pack { $pack:
    ensure   => $ensure,
    name     => $pack,
    user     => $_cli_username,
    password => $_cli_password,
    source   => $repo_url,
  }

  if $config {
    validate_hash($config)
    file { "/opt/stackstorm/configs/${pack}.yaml":
      ensure  => file,
      mode    => '0640',
      owner   => 'st2',
      group   => 'root',
      content => template('st2/config.yaml.erb'),
    }

    # Register package after it is downloaded and configured
    St2_pack<| name == $pack |>
    -> File["/opt/stackstorm/configs/${pack}.yaml"]
    ~> Exec<| tag == 'st2::register-configs' |>
  }

  Service<| tag == 'st2::service' |> -> St2_pack<||>
  Exec<| tag == 'st2::reload' |> -> St2_pack<||>
}
