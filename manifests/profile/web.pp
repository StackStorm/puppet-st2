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
  $_version = $autoupdate ? {
    true    => st2_latest_stable(),
    default => $version,
  }
  $_bootstrapped = $::st2web_bootstrapped ? {
    undef   => false,
    default => str2bool($::st2web_bootstrapped),
  }

  file { [
      '/opt/stackstorm/static',
      '/opt/stackstorm/static/webui',
    ]:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  if $autoupdate or ! $_bootstrapped {
    wget::fetch { 'st2web':
      source      => "http://downloads.stackstorm.net/releases/st2/${_version}/webui/webui-${_version}.tar.gz",
      cache_dir   => '/var/cache/wget',
      destination => '/tmp/st2web.tar.gz',
      before      => Exec['extract webui'],
    }
  }

  exec { 'extract webui':
    command => 'tar -xzvf /tmp/st2web.tar.gz -C /opt/stackstorm/static/webui --strip-components=1 --owner root --group root --no-same-owner',
    creates => '/opt/stackstorm/static/webui/index.html',
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    require => File['/opt/stackstorm/static/webui'],
    before  => File['/etc/facter/facts.d/st2web_bootstrapped.txt'],
  }

  # This is crude... get some augeas on
  ## Manage connection list currently
  file { '/opt/stackstorm/static/webui/config.js':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('st2/opt/st2web/config.js.erb'),
    require => Exec['extract webui'],
  }

  file { '/etc/facter/facts.d/st2web_bootstrapped.txt':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => 'st2web_bootstrapped=true',
  }
}
