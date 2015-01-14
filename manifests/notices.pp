# == Class: st2::notices
#
# This is a private class used to store long strings to limit down on lint problems.
# Please do not call directly
#
# === Parameters
#
# This class takes no parameters
#
# === Variables
#
# This class takes no variables
#
class st2::notices {
  include '::st2::params'

  $user_missing_client_keys = "ssh_public_key and ssh_key_type need to be supplied for this resource. Help can be found in INSTALL.md if needed"
  $user_missing_private_key = "ssh_private_key needs to be supplied for this resource. Help can be found in INSTALL.md if needed"
  $unsupported_os = "Your platform is not yet supported. Please file a bug or submit a bug to $st2::params::repo_url"
  $web_no_oauth_token = "The Web Interface is currently in limited beta. You will need a key to test this out. Please email us at XXX@stackstorm.com if you are interested in trying it out and providing feedback"

}
