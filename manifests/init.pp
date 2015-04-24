# == Class: st2
#
#  Base class for st2 module. Used as top-level to set parameters via Hiera
#  This class does not need to be called directly
#
# === Parameters
#
#  [*version*]            - Version of StackStorm to install
#  [*revision*]           - Revision of StackStorm to install
#  [*mistral_git_branch*] - Tagged branch of Mistral to download/install
#
#  Variables can be set in Hiera and take advantage of automatic data bindings:
#
#  Example:
#    st2::version: 0.6.0
#    st2::revison: 11
#
class st2(
  $version            = '0.8.3',
  $revision           = undef,
  $st2_api_url        = undef,
  $mistral_git_branch = 'st2-0.8.1',
  $web                = false,
  $auth               = false,
  $rabbit_user        = $::st2::params::rabbit_user,
  $rabbit_pass        = $::st2::params::rabbit_pass,
  $rabbit_host        = $::st2::params::rabbit_host,
  $rabbit_port        = $::st2::params::rabbit_port,
  $st2_api_url        = $::st2::params::st2_api_url,
  $mistral_api_url    = $::st2::params::mistral_api_url,
  $mistral_api_port   = $::st2::params::mistral_api_port,
) inherits ::st2::params { }
