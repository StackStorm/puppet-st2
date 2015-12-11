# Changelog

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
