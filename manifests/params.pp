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
  ]
  $st2_client_packages = [
    'st2client',
  ]

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
  ]
  $debian_client_dependencies = [
    'python-prettytable',
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
