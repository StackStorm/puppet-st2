# st2

[![Build Status](https://travis-ci.org/StackStorm/puppet-st2.svg)](https://travis-ci.org/StackStorm/puppet-st2)
[![Coverage Status](https://coveralls.io/repos/StackStorm/puppet-st2/badge.svg?branch=master&service=github)](https://coveralls.io/github/StackStorm/puppet-st2?branch=master)

Module to manage [StackStorm](http://stackstorm.com)

Currently tested with:
* Ubuntu 14.04

Compatability currently being tested:
* Debian 7
* Ubuntu 12.04
* RHEL/Centos 6/7

## Maintainers

* James Fryman <james@stackstorm.com>
* Patrick Hoolboom <patrick@stackstorm.com>

## Quick Start

For a full installation on a single node, a profile already exists to
get you setup and going with minimal effort. Simply:

```
include ::st2::profile::fullinstall
```

## Configuration

This module aims to provide sane default configurations, but also stay
out of your way in the event you need something more custom. To accomplish
this, this module uses the Roles/Profiles pattern. Included in this module
are several modules that come with sane defaults that you can use directly
or use to compose your own site-specific profile for StackStorm installation.

Configuration can be done directly via code composition, or set via
Hiera data bindings. A few notable parameters to take note of:

* `st2::version` - Version of ST2 to install. (Latest version w/o value)
* `st2::release` - Release of ST2 to install (Latest version w/o value)

All other classes are documented with Puppetdoc. Please refer to specific
classes for use and configuration.

## NG-Init

As of StackStorm v0.12.0, the transition to init scripts has begun. To enable
init scripts (Upstart only, currently. SystemD in progress), add the following flag
to hiera or via code composition.

* `st2::ng_init` - Boolean

This will apply init scripts to be managed by the OS.

Each of the network services has an environment variable that can be passed
that will disable the spawning of the stand-alone service. This is useful
when setting up uWSGI or other services. This is necessary to remain
compatability with `st2ctl` during the transition period to init scripts.

* `ST2_DISABLE_HTTPSERVER` - Disable SimpleHTTPServer for WebUI
* `ST2_DISABLE_API` - Disable StandAlone API Server
* `ST2_DISABLE_AUTH` - Disable StandAlone Auth Server

### Profiles:

* `st2::profile::client` - Profile to install all client libraries for st2
* `st2::profile::fullinstall` - Full installation of StackStorm and dependencies
* `st2::profile::mistral` - Install of OpenStack Mistral
* `st2::profile::mongodb` - st2 configured MongoDB installation
* `st2::profile::nodejs` - st2 configured NodeJS installation
* `st2::profile::python` - Python installed and configured for st2
* `st2::profile::rabbitmq` - st2 configured RabbitMQ installation
* `st2::proflle::server` - st2 server components
* `st2::profile::web` - st2 web components

### Installing and configuring Packs

StackStorm packs can be installed and configured directly from Puppet. This
can be done via the `st2::pack` and `st2::pack::config` defined types.

Installation/Configuration via modules:
```ruby
  st2::pack { 'linux': }
  st2::pack { ['librato', 'consul']:
    repo_url => 'https://github.com/StackStorm/st2incubator.git',
  }
  st2::pack { 'slack':
    repo_url => 'https://github.com/StackStorm/st2incubator.git',
    config   => {
      'post_message_action' => {
        'webhook_url' => 'XXX',
      },
    },
  }
```

Installation/Configuration via Hiera:
```yaml
st2::packs:
  linux:
    ensure: present
  cicd:
    ensure: present
    repo_url: https://github.com/StackStorm/st2incubator.git
  slack:
    ensure: present
    repo_url: https://github.com/StackStorm/st2incubator.git
    config:
      post_message_action:
        webhook_url: XXX
```
