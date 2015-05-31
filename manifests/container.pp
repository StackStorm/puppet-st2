# Class: st2::container
#
#  Class used to assemble containers using tiller
#
# Description
#
#  This class downloads all the necessary bits for
#  StackStorm in source format, and sets up Tiller
#  to be a single entry point for deployment.
#
#  Configuration is set by an erb template compiled at
#  runtime and populated by environment variables. File
#  is located at st2/files/etc/st2/st2.conf.erb
#
# Parameters:
#
# [*subsystem*] - Which container to build based on subsystem
#                 See st2::params::subsystems for known types
# [*code_dir*]  - Location to put source code run on the system.
#
# Usage:
#  class { '::st2::container':
#    subsystem => 'actionrunner',
#  }
class st2::container (
  $subsystem = undef,
  $code_dir  = '/opt/stackstorm/src',
) inherits st2::params {
  include ::st2::profile::source

  $_approved_subsystems = $::st2::params::subsystems
  $_component_map       = $::st2::params::component_map
  $_component           = $_component_map[$subsystem]

  if ! member($_approved_subsystems, $subsystem) {
    fail("[st2::contianer]: Unknown subsystem ${subsystem}")
  }

  $_config = {
    env_st2_conf_root => $code_dir,
  }

  # Determine code load paths for source runtime
  $_python_dirs = prefix($::st2::params::st2_server_packages, "${code_dir}/")
  $_python_paths = ["\$PYTHONPATH", $_python_dirs]
  $_python_path = join($_python_paths, ':')

  ## And setup tiller config templates needed to be filled out.
  tiller::bootstrap { 'st2.conf.erb':
    target             => '/etc/st2/st2.conf',
    source             => 'puppet:///modules/st2/etc/st2/st2.conf.erb',
    development_config => $_config,
    staging_config     => $_config,
    production_config  => $_config,
  }

  ## Setup tiller with the entry point
  class { '::tiller':
    run => [
      "PYTHONPATH=${_python_path}",
      "${code_dir}/virtualenv/bin/python",
      "${code_dir}/${_component}/bin/st2${subsystem}",
      '--config-file',
      '/etc/st2/st2.conf',
    ]
  }
}
