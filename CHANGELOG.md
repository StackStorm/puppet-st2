# Changelog

## 0.9.16 (Oct 14, 2015)
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
