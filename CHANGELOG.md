# Changelog

## Development

- Upgraded NodeJS to 6.x when installing StackStorm >= 2.4.0.
  If you're currently running a version of StackStorm 2.4.0 with NodeJS 4.x
  installed, the repo will be updated to point at 6.x. 
  To upgrade NodeJS go through the normal upgrade process on your system,
  example for RHEL: `yum clean all; yum upgrade -y`
  Contributed by @nmaludy

- Upgraded MongoDB to 3.4 when installing StackStorm >= 2.4.0.
  If you're currently running a version of StackStorm 2.4.0 with MongoDB 3.2
  installed, the repo will be updated to point at 3.4. 
  To upgrade MongoDB go through the normal upgrade process on your system,
  example for RHEL: `yum clean all; yum upgrade -y`
  Contributed by @nmaludy

- New type and provider for managing st2 packs: `st2_pack`.
  Added new parameter `index_url` to `::st2` allowing custom st2 Exchange
  index file location.
  Profile `fullinstall` does not force installation of package `st2` anymore.

- Added a new class `chatops` to manage the chatops package, service and configuration.
  Added new parameters `chatops_adapter` and `chatops_adapter_conf` to `::st2` for allowing user to manage the hubot adapter packages and configuration. #187
  Contributed by @ruriky

- Added new parameter `mongodb_manage_repo` to `::st2` so that the `mongodb` install
  will not manage the repository files, allowing for installations from locally
  cached repos. #184
  Contributed by @ruriky
  
- Added new parameter `nginx_manage_repo` to `::st2` so that the `nginx` install
  will not manage the repository files, allowing for installations from locally
  cached repos. #182
  Contributed by @ruriky
  
- Make sure key type is defined for user public ssh key. #189 (Bugfix)
  Contributed by @bdandoy
  
- Ensure group creation. #188 (Enhancement)
  Contributed by @bdandoy
  
- Added more puppet-lint checks. #181
  Contributed by @bdandoy

- Added Slack notifications to https://stackstorm-community.slack.com `#puppet`
  for Travis build failures. #180
  Contributed by @armab

## 1.0.0-beta (Aug 14, 2017)

#### files/repo/nodesource/NODESOURCE-GPG-SIGNING-KEY-EL

- Removed unused file after cleaning up nodejs profiel (Enhancement)

#### manifests/auth/standalone.pp

- Did not have access to the `::st2` variables (Bugfix).
- Had a dependency issue where (on some platforms) allowed the `htpasswd` file to be created after the st2 services were starting (Bugfix)
- Created an unnecessary "test user" (Bugfix)

#### manifests/auth_user.pp

- Dependency issues here where the `htpasswd` file was sometimes trying to be created before the `/etc/st2` directory was created, and other times it was trying to be created after the st2 services had started.  (Bugfix)

#### manifests/init.pp

- Needed extra variables for SSL setup in st2web. (Feature)
- Needed extra variables for proper database setup (mongodb and postgres) (Enhancement)
- Needed path to the st2auth logging config file (Enhancement)
- Needed variables about the datastore encryption keys (Feature)

#### manifests/kv.pp

- Some puppet lint problems (notice the whitespace fix and reordering of class params) (Bugfix)
- Dependency issues where the tag being used for the `Service` resource was incorrect (Bugfix)
- Dependency issues where sometimes st2 hadn't been reloaded so the k/v loads would fail (Bugfix)

#### manifests/notices.pp

- Puppet lint fixes for using double quotes without variable interpolation in the string. (Bugfix)

#### manifests/pack.pp

- Unit tests revealed that many of the dependencies of this resource were not declared (group and directories) (Bugfix)
- Pointing at old location for config directory (Bugfix)
- Needed lots of dependency work to ensure resources were created in the proper order (Bugfix)

#### manifests/params.pp

- Broke down the old `st2_server_packages` variable into various components to align more with what ansible-st2 and the "one liner" shell scripts do in their functions. (Enhancement)
- Removed some unused code in the "init provider" section (Enhancement)
- Broke down the old `st2_services` into its components similar to `st2_server_packages`. FYI: The mistral services are handled by the mistral install instead of being grouped together into `st2 server`. (Enhancement)
- Added lots of new parameters for services that were not configured in the past like (nginx, st2web, mongodb, rabbitmq) (Feature)

#### manifests/profile/client.pp

- Removed stale comment (Enhancement)

#### manifests/profile/fullinstall.pp

- Mainly dependency cleanup here. (Bugfix)
- Ensure that packages are installed in the correct order and that there are meaningful anchors in place in case others need to execute tasks at certain points during the install. (Bugfix)

#### manifests/profile/mistral.pp

- This was completely re-written (Enhancement)
- Previously it was performing a lot of tasks manually that i believe st2mistral package now handles for us  (Enhancement)

#### manifests/profile/mongodb.pp

- Completely re-written (Enhancement)
- It now handles auth (did not previously) (Enhancement)
- It also deals with several deficiencies in the puppetlabs-mongodb module. This module has lots of annoying bugs. I'm not at the point where i want to code up a new module myself yet, but we do have to work around several quirks for this to even work (sorry!). (Bugfix)

#### manifests/profile/nginx.pp

- New profile that installs and configures nginx (does not setup st2web config, that is left to the st2web profile) (Feature)
- Utilizes the nginx puppet module to do all of the heavy lifting here (Feature)

#### manifests/profile/nodejs.pp

- Completely re-written (Enhancement)
- Utilizes the nodejs puppet module to do all of the heavy lifting instead of doing it ourselves  (Enhancement)
- Works around a small quirk of the module on RedHat distributions  (BugFix)

#### manifests/profile/postgresql.pp

- Expanded this to properly configure postgres for listening according to the standard installs (shell scripts and ansible-st2) (Enhancement)
- Also ensured that 9.4 is installed on RHEL6 (Bugfix)

#### manifests/profile/rabbitmq.pp

- Greatly simplified by allowing the rabbitmq module to do all of the heavy lifting for us (Enhancement)

#### manifests/profile/repos.pp

- Fixed a bug where we were pointing to an all lowercase URL which caused st2 package installs to fail (Bugfix)

#### manifests/profile/selinux.pp

- Added a class that configures SELinux on RHEL hosts (Feature)

#### manifests/profile/server.pp

- Small changes here related to adding database auth capability (Enhancement)
- Added stanley user creation  (Feature)
- Added datastore crypto creation  (Feature)
- Added additional dependency management (Bugfix)

#### manifests/profile/web.pp

- Completely re-written (Enhancement)
- I don't believe that st2web was complete when this module was last touched, so this class got a complete overhaul (Enhancement)

#### manifests/rbac.pp

- Fixed a few puppet lint errors (Bugfix)
- Fixed an error where the RBAC rules were executed every puppet run (Bugfix)

#### manifests/server/datastore_keys.pp

- New manifest that manages the datastore crypto keys (Feature)

#### manifests/stanley.pp

- Removed unnecessary warning about ssh keys (Bugfix)

#### manifests/user.pp

- Fixed a couple small bugs related to a legacy "robots" group.  (Bugfix)
- This got a pretty big overhaul with regards to SSH key creation. Now, if SSH keys are not present new ones will be created (just like the shell scripts and  ansible-st2) (Bugfix)

#### metadata.json

- Reformatted the whole file to standard JSON formatting scheme (Enhancement)
- Updated module dependencies (some were missing) (Bugfix)
- Added supported OS block (Enhancement)
- Added supported puppet versions block (Enhancement)

#### spec/*

- Lots of small fixes here related to running the tests on various versions of ruby. (Bugfix)
- Finally found a happy medium where all tests now pass  (Bugfix)
- Removed tests for the "st2::package::debian" type that no longer exists  (Bugfix)

#### templates/*

- Removed the following unused templates due to code cleanup and modernizaiton (Enhancement)
  - templates/etc/init.d/mistral-api.erb
  - templates/etc/init.d/mistral.erb
  - templates/etc/init/mistral-api.conf.erb
  - templates/etc/init/mistral.conf.erb
  - templates/etc/init/st2actionrunner-worker.conf.erb
  - templates/etc/systemd/system/mistral-api.service.erb
  - templates/etc/systemd/system/mistral.service.erb
  - templates/etc/systemd/system/st2actionrunner.service.erb
  - templates/etc/systemd/system/st2service_multi.service.erb
  - templates/etc/systemd/system/st2service_single.service.erb
  - templates/opt/st2web/config.js.erb
    

## 0.14.1 (Jan 15, 2015)
* Fix typo - st2garbagecollector is part of st2reactor package.

## 0.14.0 (Jan 15, 2015)
* Add services files for the new ``st2garbagecollector`` service.

## 0.13.0 (Jan 8, 2015)
* Don't install a default SSH key for ``stanley`` user if one is not explicitly provided.

## 0.12.3 (Dec 15, 2015)
* Adding tests around bintray repo feature

## 0.12.2 (Dec 11, 2015)
* Fixing error where WebUI fails because of missing resource

## 0.12.1 (Dec 9, 2015)
* Adding ability to download packages from testing bintray repos

## 0.11.1 (Dec 9, 2015)
* Extract a new version of st2web on update

## 0.11.0 (Dec 4, 2015)
* Force rewrite of webui/config.js on every provision

## 0.10.18 (Nov 11, 2015)
* Disable upstart logging for st2 services.
* Make sure that st2web logs on Ubuntu under upstart are written to /var/log/st2web.log

## 0.10.17 (Nov 2, 2015)
* Parameterized download server to CI

## 0.10.16 (Oct 30, 2015)
* Set sticky bit on Group, not User for stackstorm packs dir

## 0.10.15 (Oct 28, 2015)
* Remove DAG errors with fullinstall profile

## 0.10.14 (Oct 26, 2015)
* Ensure /opt/stackstorm/packs directory is SGID for pack group

## 0.10.13 (Oct 22, 2015)
* Add st2packs to default deploy and ensure Stanley exists
* Limit setting of `api_url` to st2::helper::auth_manager

## 0.10.8 (Oct 21, 2015)
* Adding api_url parameter to server profile

## 0.10.7 (Oct 21, 2015)
* Adding backend kwargs attribute to st2::helper::auth_manager
* Disable static UID for auto-generated users

## 0.10.4 (Oct 19. 2015)
* Fix for RHEL 6 client package installation
* Re-enable `ng_init` env flag to compat with `st2ctl`
* Fix issue with actionrunners outputting to STDOUT/STDERR
* All SysV init scripts ensure sourcing from /etc/environment

## 0.10.1 (Oct 16. 2015)
* Init scripts default install now

## 0.10.0 (Oct 15, 2015)
* Bug fixes
* Service restart with `Ini_setting { tag => 'st2::config' }`

## 0.9.19 (Oct 14, 2015)
* Repair init scripts for Mistral on RHEL 6/7 and Debian

## 0.9.17 (Oct 14, 2015)
* Repair package map with CentOS 7 systems

## 0.9.15 (Oct 13, 2015)
* Support for SysV and SystemD Init types

## 0.9.14 (Oct 2, 2015)
* Ensure postgresql is setup and running before starting Mistral service.

## 0.9.12 (Oct 1, 2015)
* Refresh services on ini setting change.

## 0.9.11 (Oct 1, 2015)
* Add ability for user to change SSH key location in /etc/st2/st2.conf

## 0.9.10 (Sept 28, 2015)
* Fix typo in RBAC type.

## 0.9.8 (Sept 25, 2015)
* Add ability to manage StackStorm RBAC roles (*improvement*)

## 0.9.7 (Sept 22, 2015)
* Restart mistral on init script update

## 0.9.6 (Sept 22, 2015)
* Add ``silence_ssl_warnings`` option to the client profile.

## 0.9.5 (Sept 21, 2015)
* pin stahnma-epel to 1.1.0

## 0.9.4 (Sept 18, 2015)
* Restart services on package update (*bugfix*)

## 0.9.3 (Sept 17, 2015)
* Fix condition where `autoupdate: false` would result in missing resources (*bugfix*)

## 0.9.2 (Sept 17, 2015)
* Configure WebUI to integrate with Flow (*feature*)
* Configure st2client CLI settings for any user (*improvement*)

## 0.9.0 (Sept 16, 2015)
* Add support for RHEL/CentOS 6 & 7

## 0.8.0 (Sept 10, 2015)
* Release StackStorm v0.13.2
* Stop `st2::pack` resource restarting StackStorm (*improvement*)

## 0.7.10 (Sept 2, 2015)
* Fix `manage_mysql` -> `manage_postgresql` in st2::profile::server (*bugfix*)
* Fix error with stanley user UID change (*bugfix*)

## 0.7.9 (Sept 1, 2015)
* Fix path for logging config with st2auth subsystem (*bugfix*)

## 0.7.8 (Aug 30, 2015)
* Allow user to adjust username of 'st2::stanley' resource (*improvement*)

## 0.7.7 (Aug 29, 2015)

* Bump default StackStorm version to 0.13.1 (*upgrade*)
