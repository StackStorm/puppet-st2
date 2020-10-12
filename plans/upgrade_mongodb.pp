# @summary Upgrades a standalone MongoDB database between versions.
# The default upgrade for this plan goes from 3.4 to 3.6 and ultimately to 4.0
#
# High level steps:
# - stop stackstorm
# ## https://docs.mongodb.com/manual/release-notes/3.6-upgrade-standalone/
# - set MongoDB feature compatibility to 3.4
# - change Yum repo to 3.6
# - upgrade packages
# - set MongoDB feature compatibility to 3.6
# ## https://docs.mongodb.com/manual/release-notes/4.0-upgrade-standalone/
# - change Yum repo to 4.0
# - upgrade packages
# - set MongoDB feature compatibility to 4.0
# - start stackstorm
#
# @param [TargetSpec] targets
#   Set of targets (MongoDB hosts) that this plan will be executed on.
#
# @param [String] mongo_admin_db
#   Name of the admin database for MongoDB
#
# @param [String] mongo_username
#   Name of the admin user on the admin database
#
# @param [String] mongo_password
#   Password of the admin user on the admin database
#
# @param [Array[String]] mongo_packages
#   List of MongoDB packages that will be upgraded
#
# @param [String] upgrade_version_start
#   Version of MongoDB that the database is currently on, ie. where we are starting from.
#
# @param [Array[String]] upgrade_version_path
#   List of versions that we will upgrade through along our path to success!
#
# @example Basic usage
#   bolt plan run st2::upgrade_mongodb --targets ssh_nodes --params '{"mongo_password": "xxx"}'
#
# @example Upgrading enterprise packages
#   bolt plan run st2::upgrade_mongodb --targets ssh_nodes --params '{"mongo_password": "xxx", "mongo_packages": ["mongodb-enterprise-server", "mongodb-enterprise-shell", "mongodb-enterprise-tools"]}'
#
# @example Upgrading from 3.6 to 4.0
#   bolt plan run st2::upgrade_mongodb --targets ssh_nodes --params '{"mongo_password": "xxx", "upgrade_version_start": "3.6", "upgrade_version_path": ["4.0"]}'
#
# @example Upgrading from 3.4 to 3.6 to 4.0
#   bolt plan run st2::upgrade_mongodb --targets ssh_nodes --params '{"mongo_password": "xxx", "upgrade_version_start": "3.4", "upgrade_version_path": ["3.6", "4.0"]}'
#
plan st2::upgrade_mongodb (
  String $mongo_admin_db = 'admin',
  String $mongo_username = 'admin',
  String $mongo_password,
  Array[String] $mongo_packages  = ['mongodb-org-server', 'mongodb-org-shell', 'mongodb-org-tools'],
  String $upgrade_version_start = '3.4',
  Array[String] $upgrade_version_path = ['3.6', '4.0'],
  TargetSpec $targets,
) {
  # stop stackstorm
  run_command('st2ctl stop', $targets)

  $mongo_cmd = "mongo ${mongo_admin_db} --username ${mongo_username} --password ${mongo_password} --quiet"

  # set MongoDB feature compatibility to 3.4
  $start_ver = $upgrade_version_start
  run_command("$mongo_cmd --eval \"db.adminCommand( { setFeatureCompatibilityVersion: '$start_ver' } )\"",
              $targets,
              "Mongodb - Set Feature Compatibility Version $start_ver")

  $upgrade_version_path.each |$ver| {
    # Chnage Yum repo to this version
    apply($targets) {
      yumrepo { 'mongodb':
        descr    => 'MongoDB Repository',
        baseurl  => "https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/${ver}/\$basearch/",
        gpgcheck => '0',
        enabled  => '1',
      }
    }

    # rebuild yum cache since we just changed repositories
    run_command('yum clean all', $targets)
    run_command('yum makecache fast', $targets)

    # Upgrade packages
    $mongo_packages.each |$package| {
      run_task('package::linux', $targets,
               name => $package,
               action => 'upgrade')
    }

    # Set compatibility level to this version
    run_command("$mongo_cmd --eval \"db.adminCommand( { setFeatureCompatibilityVersion: '$ver' } )\"",
                $targets,
                "Mongodb - Set Feature Compatibility Version $ver")
  }

  # start stackstorm
  run_command('st2ctl start', $targets)
}
