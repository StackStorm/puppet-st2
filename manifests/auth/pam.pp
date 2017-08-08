# Class: st2::auth::pam
#
#  ** BROKEN **
#  TODO: Fix this.
#  Auth class to configure and setup PAM authentication
#
# Parameters:
#
# [*version*] - version of PAM module
#
# Usage:
#
#  include ::st2::auth::pam
#
class st2::auth::pam(
  $version = '0.1.0',
  $host_ip = '127.0.0.1',
) {
  $_st2api_port = '9101'
  $_api_url = "https://${host_ip}:${_st2api_port}"

  # TODO: This belongs in a package
  $distro_path = $::osfamily ? {
    'Debian' => "apt/${::lsbdistcodename}",
    'Ubuntu' => "apt/${::lsbdistcodename}",
    'RedHat' => "yum/el/${::operatingsystemmajrelease}"
  }

  wget::fetch { 'Download auth pam backend':
    source             => "${::st2::repo_base}/st2community/${distro_path}/auth_backends/st2_auth_backend_pam-${version}-py2.7.egg",
    cache_dir          => '/var/cache/wget',
    nocheckcertificate => true,
    destination        => "/tmp/st2_auth_backend_pam-${version}-py2.7.egg"
  }

  exec { 'install pam auth backend':
    command => "easy_install-2.7 \
                /tmp/st2_auth_backend_pam-${version}-py2.7.egg",
    path    => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
    require => Wget::Fetch['Download auth pam backend'],
    before  => Class['::st2::helper::auth_manager'],
  }

  class { '::st2::helper::auth_manager':
    auth_mode    => 'standalone',
    auth_backend => 'pam',
    debug        => false,
    syslog       => true,
    api_url      => $_api_url,
  }
}
