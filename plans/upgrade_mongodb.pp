# @summary Upgrades a standalone MongoDB database between versions.
# The default upgrade for this plan goes from 3.4 to 3.6 and ultimately to 4.0
#
# High level steps:
# - stop stackstorm
# ## https://docs.mongodb.com/manual/release-notes/3.6-upgrade-standalone/
# - set MongoDB feature compatibility to 3.4
# - change package repo to 3.6
# - upgrade packages
# - set MongoDB feature compatibility to 3.6
# ## https://docs.mongodb.com/manual/release-notes/4.0-upgrade-standalone/
# - change package repo to 4.0
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
# @param [Enum['enterprise', 'org']] mongo_edition
#   What edition of MongoDB should be setup from a repo perspective,
#   either 'org' for community edition, or 'enterprise' for enterprise edition.
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
#   bolt plan run st2::upgrade_mongodb --targets ssh_nodes --params '{"mongo_password": "xxx", "mongo_packages": ["mongodb-enterprise-server", "mongodb-enterprise-shell", "mongodb-enterprise-tools"], "mongo_edition": "enterprise"}'
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
  Enum['enterprise', 'org'] $mongo_edition = 'org',
  String $upgrade_version_start = '3.4',
  Array[String] $upgrade_version_path = ['3.6', '4.0'],
  TargetSpec $targets,
) {
  # stop stackstorm
  run_command('st2ctl stop', $targets)

  $mongo_cmd = "mongo ${mongo_admin_db} --username ${mongo_username} --password ${mongo_password} --quiet"

  # set MongoDB feature compatibility to 3.4
  $start_ver = $upgrade_version_start
  run_command("${mongo_cmd} --eval \"db.adminCommand( { setFeatureCompatibilityVersion: '${start_ver}' } )\"",
              $targets,
              "Mongodb - Set Feature Compatibility Version ${start_ver}")

  # gather facts on the targets so that we can determine RHEL/CentOS vs Ubuntu
  run_plan('facts', $targets)

  $upgrade_version_path.each |$ver| {
    # Change Yum repo to this version
    apply($targets) {
      if $mongo_edition == 'enterprise' {
        $repo_domain = 'repo.mongodb.com'
        $repo_path   = 'mongodb-enterprise'
      } else {
        $repo_domain = 'repo.mongodb.org'
        $repo_path   = 'mongodb-org'
      }

      if ($facts['os']['family'] == 'RedHat') {
        yumrepo { 'mongodb':
          descr    => 'MongoDB Repository',
          baseurl  => "https://${repo_domain}/yum/redhat/\$releasever/${repo_path}/${ver}/\$basearch/",
          gpgcheck => '0',
          enabled  => '1',
          notify   => Exec['yum_clean_all'],
        }

        # rebuild yum cache since we just changed repositories
        exec { 'yum_clean_all':
          command     => '/usr/bin/yum clean all',
          refreshonly => true,
          notify      => Exec['yum_makecache_fast'],
        }
        exec { 'yum_makecache_fast':
          command     => '/usr/bin/yum makecache fast',
          refreshonly => true,
        }
      }
      else {
        $location = $facts['os']['name'] ? {
          'Debian' => "https://${repo_domain}/apt/debian",
          'Ubuntu' => "https://${repo_domain}/apt/ubuntu",
          default  => undef
        }
        $release     = "${facts['os']['distro']['codename']}/${repo_path}/${ver}"
        $repos       = $facts['os']['name'] ? {
          'Debian' => 'main',
          'Ubuntu' => 'multiverse',
          default => undef
        }
        $key = $ver ? {
          '4.4'   => '20691EEC35216C63CAF66CE1656408E390CFB1F5',
          '4.2'   => 'E162F504A20CDF15827F718D4B7C549A058F8B6B',
          '4.0'   => '9DA31620334BD75D9DCB49F368818C72E52529D4',
          '3.6'   => '2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5',
          '3.4'   => '0C49F3730359A14518585931BC711F9BA15703C6',
          '3.2'   => '42F3E95A2C4F08279C4960ADD68FA50FEA312927',
          default => '492EAFE8CD016A07919F1D2B9ECBEC467F0CEB10'
        }
        $key_server = 'hkp://keyserver.ubuntu.com:80'

        apt::source { 'mongodb':
          location => $location,
          release  => $release,
          repos    => $repos,
          key      => {
            'id'     => $key,
            'server' => $key_server,
          },
          notify   => Exec['apt-get-clean'],
        }

        # rebuild apt cache since we just changed repositories
        exec { 'apt-get-clean':
          command     => '/usr/bin/apt-get -y clean',
          refreshonly => true,
          notify      => Exec['apt-get-update'],
        }
        exec { 'apt-get-update':
          command     => '/usr/bin/apt-get -y update',
          refreshonly => true,
        }
      }
    }


    # Upgrade packages
    $mongo_packages.each |$package| {
      run_task('package::linux', $targets,
                name => $package,
                action => 'upgrade')
    }

    # Set compatibility level to this version
    run_command("${mongo_cmd} --eval \"db.adminCommand( { setFeatureCompatibilityVersion: '${ver}' } )\"",
                $targets,
                "Mongodb - Set Feature Compatibility Version ${ver}")
  }

  # start stackstorm
  run_command('st2ctl start', $targets)
}
