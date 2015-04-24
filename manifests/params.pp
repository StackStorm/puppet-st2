# == Class: st2::params
#
#  Main parameters to manage the st2 module
#
# === Parameters
#  [*robots_group_name*] - The name of the group created to hold the st2 admin user
#  [*robots_group_id*] - The GID of the group created to hold the st2 admin user.
#
# === Variables
#  [*repo_url*] - The URL where the StackStorm project is hosted on GitHub
#  [*conf_dir*] - The local directory where st2 config is stored
#  [*st2_server_packages*] - A list of all upstream server packages to grab from upstream package server
#  [*st2_client_packages*] - A list of all upstream client packages to grab from upstream package server
#  [*debian_dependencies*] - Any dependencies needed to successfully run st2 server on the Debian OS Family
#  [*debian_client_dependencies*] - Any dependencies needed to successfully run st2 client on the Debian OS Family
#  [*debian_mongodb_dependencies*] - MongoDB Dependencies (if installed via this module)
#  [*redhat_dependencies*] - Any dependencies needed to successfully run st2 server on the RedHat OS Family
#  [*redhat_client_dependencies*] - Any dependencies needed to successfully run st2 client on the RedHat OS Family
#
# === Examples
#
#  include st2::params
#
#  class { 'st2::params':
#
#  }
#

class st2::params(
  $robots_group_name = 'st2robots',
  $robots_group_gid  = 800,
) {

  # Non-user configurable parameters
  $repo_url = 'https://github.com/StackStorm/st2'
  $conf_dir = '/etc/st2'

  $st2_server_packages = [
    'st2common',
    'st2reactor',
    'st2actions',
    'st2api',
    'st2auth',
    'st2debug',
  ]
  $st2_client_packages = $::osfamily ? {
    'RedHat' => 'st2client',
    'Debian' => 'python-st2client',
  }

  $db_host             = 'localhost'
  $db_port             = '27017'
  $db_name             = 'st2'
  $db_user             = ''
  $db_pass             = ''
  $db_mistral_host     = 'localhost'
  $db_mistral_user     = 'mistral'
  $db_mistral_password = 'StackStorm'
  $rabbit_user         = 'guest'
  $rabbit_pass         = 'guest'
  $rabbit_host         = 'localhost'
  $rabbit_port         = 5672
  $st2_api_url         = '0.0.0.0'
  $mistral_api_url     = $st2_api_url
  $mistral_api_port    = 8989
  $mistral_v2_base_url = "http://${mistral_api_url}:${mistral_api_port}/v2/"
  $workflow_url        = "http://${mistral_api_url}:${mistral_api_port}"
  $rabbit_connection_string = "amqp://${rabbit_user}:${rabbit_port}@${rabbit_host}:${rabbit_port}/"

  $rules_engine      = false
  $sensor_container  = false
  $st2api            = false
  $history           = false
  $resultstracker    = false
  $mistral           = false
  $mistral_executors = 10
  $actionrunners     = 10

  $github_oauth_token = ''
  $install_profile   = 'fullinstall'

  $syslog            = false
  $syslog_host       = 'localhost'

  # One off for RHEL 6. Custom built Python 2.7 should live in /usr/local
  # so, let's favor that one. Any OS with a custom python should change
  # this value to '/usr/local' for proper bootstrapping.
  if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == '6' {
    $system_python = '/usr/local'
  } else {
    $system_python = undef
  }

  ### Debian Specific Information ###
  $debian_dependencies = [
    'make',
    'realpath',
    'gcc',
    'python-yaml',
    'libssl-dev',
    'libyaml-dev',
    'libffi-dev',
    'libxml2-dev',
    'libxslt1-dev',
    'python-tox',
  ]
  $debian_client_dependencies = [
    'python-prettytable',
    'python-jsonpath-rw',
    'python-dateutil',
  ]
  $debian_mongodb_dependencies = [
    'mongodb-dev',
  ]
  ### END Debian Specific Information ###

  ### RedHat Specific Information ###
  $redhat_dependencies = [
    'gcc-c++',
    'openssl-devel',
    'libyaml-devel',
    'libffi-devel',
    'libxml2-devel',
    'libxslt-devel',
  ]
  $redhat_client_dependencies = [
    'python-prettytable',
  ]
  ### END RedHat Specific Information ###

}
