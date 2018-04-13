# puppet-st2

[![Build Status](https://travis-ci.org/StackStorm/puppet-st2.svg)](https://travis-ci.org/StackStorm/puppet-st2)
[![Coverage Status](https://coveralls.io/repos/StackStorm/puppet-st2/badge.svg?branch=master&service=github)](https://coveralls.io/github/StackStorm/puppet-st2?branch=master)
[![Puppet Forge Version](https://img.shields.io/puppetforge/v/stackstorm/st2.svg)](https://forge.puppet.com/stackstorm/st2)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/stackstorm/st2.svg)](https://forge.puppet.com/stackstorm/st2)
[![Join our community Slack](https://stackstorm-community.herokuapp.com/badge.svg)](https://stackstorm.com/community-signup)

Module to manage [StackStorm](http://stackstorm.com)

## Supported platforms

* Ubuntu 14.04/16.04
* RHEL/Centos 6/7

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

* `st2::version` - Version of ST2 to install. This will be set as the `ensure`
  value on the `st2` packages. The default is `present` resulting in the most
  up to date packages being installed initially. If you would like to hard code
  to an older version you can specify that here (ex: `2.6.0`).
  **Note** Setting this to `latest` is NOT recommended. It will cause the 
  StackStorm packages to be automatically updated without the proper upgrade steps
  being taken (proper steps detailed here: https://docs.stackstorm.com/install/upgrades.html)

All other classes are documented with Puppetdoc. Please refer to specific
classes for use and configuration.

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
* `st2::profile::chatops` - st2 chatops components

### Installing and configuring Packs

StackStorm packs can be installed and configured directly from Puppet. This
can be done via the `st2::pack` and `st2::pack::config` defined types.

Installation/Configuration via modules:

```ruby
  # install pack from the exchange
  st2::pack { 'linux': }
  
  # install pack from a git URL
  st2::pack { 'private':
    repo_url => 'https://private.domain.tld/git/stackstorm-private.git',
  }
  
  # install pack and apply configuration
  st2::pack { 'slack':
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
  private:
    ensure: present
    repo_url: https://private.domain.tld/git/stackstorm-private.git
  slack:
    ensure: present
    config:
      post_message_action:
        webhook_url: XXX
```

### Configuring Authentication (st2auth)

StackStorm uses a pluggable authentication system where auth is delegated to
an external service called a "backend". The `st2auth` service can be configured
to use various backends (only one active). For more information on StackStorm
authentication see the
[authentication documentation](https://docs.stackstorm.com/authentication.html)
page.

The following backends are currently available:

* `flat_file` - Authenticates against an htpasswd file (default) [link](https://github.com/StackStorm/st2-auth-backend-flat-file)
* `keystone` - Authenticates against an OpenStack Keystone service [link](https://github.com/StackStorm/st2-auth-backend-keystone)
* `ldap` - Authenticates against an LDAP server such as OpenLDAP or Active Directory 
          [link](https://github.com/StackStorm/st2-auth-backend-ldap)
* `mongodb` - Authenticates against a collection named `users` in MongoDB [link](https://github.com/StackStorm/st2-auth-backend-mongodb)
* `pam` - Authenticates against the PAM Linux service [link](https://github.com/StackStorm/st2-auth-backend-pam)


By default the `flat_file` backend is used. To change this you can configure it
when instantiating the `::st2` class in a manifest file:

``` ruby
class { '::st2':
  auth_backend => 'ldap',
}
```

Or in Hiera:

``` yaml
st2::auth_backend: ldap
```


Each backend has their own custom configuration settings. The settings can be
found by looking at the backend class in the `manifests/st2/auth/` directory.
These parameters map 1-for-1 to the configuration options defined in each
backends GitHub page (links above). Backend configurations are passed in as a hash
using the `auth_backend_config` option. This option can be changed when instantiating
the `::st2` class in a manifest file:

``` ruby
class { '::st2':
  auth_backend        => 'ldap',
  auth_backend_config => {
    ldap_uri      => 'ldaps://ldap.domain.tld',
    bind_dn       => 'cn=ldap_stackstorm,ou=service accounts,dc=domain,dc=tld',
    bind_pw       => 'some_password',
    ref_hop_limit => 100,
    user          => {
      base_dn       => 'ou=domain_users,dc=domain,dc=tld',
      search_filter => '(&(objectClass=user)(sAMAccountName={username})(memberOf=cn=stackstorm_users,ou=groups,dc=domain,dc=tld))',
      scope         => 'subtree'
    },
  },
}
```

Or in Hiera:

``` yaml
st2::auth_backend: ldap
st2::auth_backend_config:
  ldap_uri: "ldaps://ldap.domain.tld"
  bind_dn: "cn=ldap_stackstorm,ou=service accounts,dc=domain,dc=tld"
  bind_pw: "some_password"
  ref_hop_limit: 100
  user:
    base_dn: "ou=domain_users,dc=domain,dc=tld"
    search_filter: "(&(objectClass=user)(sAMAccountName={username})(memberOf=cn=stackstorm_users,ou=groups,dc=domain,dc=tld))"
    scope: "subtree"
```


### Configuring ChatOps (Hubot)

Configuration via Hiera:

```yaml
  # character to trigger the bot that the message is a command
  # example: !help
  st2::chatops_hubot_alias: "'!'"
  
  # name of the bot in chat, sometimes requires special characters like @
  st2::chatops_hubot_name: '"@RosieRobot"'
  
  # API key generated by: st2 apikey create
  st2::chatops_api_key: '"xxxxyyyyy123abc"'
 
  # Public URL used by ChatOps to offer links to execution details via the WebUI.
  st2::chatops_web_url: '"stackstorm.domain.tld"'
  
  # install and configure hubot adapter (rocketchat, nodejs module installed by ::nodejs)
  st2::chatops_adapter:
    hubot-adapter:
      package: 'hubot-rocketchat'
      source: 'git+ssh://git@git.company.com:npm/hubot-rocketchat#master'

  # adapter configuration (hash)
  st2::chatops_adapter_conf:
    HUBOT_ADAPTER: rocketchat
    ROCKETCHAT_URL: "https://chat.company.com:443"
    ROCKETCHAT_ROOM: 'stackstorm'
    LISTEN_ON_ALL_PUBLIC: true
    ROCKETCHAT_USER: st2
    ROCKETCHAT_PASSWORD: secret123
    ROCKETCHAT_AUTH: password
    RESPOND_TO_DM: true
```

## Module Dependencies

This module installs and configures all of the components required for StackStorm.
In order to not repeat others work, we've utilized many existing modules from the
foge. We manage the module dependenies using a `Puppetfile` for each OS we support.
These `Puppetfile` can be used both with [r10k](https://github.com/puppetlabs/r10k)
and [librarian-puppet](http://librarian-puppet.com/).

### Puppetfiles

 * RHEL/CentOS 6 - [build/centos6/Puppetfile](build/centos6/Puppetfile)
 * RHEL/CentOS 7 - [build/centos7/Puppetfile](build/centos7/Puppetfile)
 * Puppet 4.0 - [build/puppet4/Puppetfile](build/puppet4/Puppetfile)
 * Puppet 5.0 - [build/puppet5/Puppetfile](build/puppet5/Puppetfile)
 * Ubuntu 14.04 - [build/ubuntu14/Puppetfile](build/ubuntu14/Puppetfile)
 * Ubuntu 16.06 [build/ubuntu16/Puppetfile](build/ubuntu16/Puppetfile)

## Upgrading StackStorm

By default this module does NOT handle upgrades of StackStorm. It is the 
responsiblity of the end user to upgrade StackStorm according to the 
[upgrade documenation](https://docs.stackstorm.com/install/upgrades.html).

In a future release a Puppet task may be included to perform these update 
on demand using [bolt](https://github.com/puppetlabs/bolt).

## Known Limitations

### MongoDB (Puppet < 4.0)

When running the initial install of `st2` you will see an error from the 
MongoDB module :

```
Error: Could not prefetch mongodb_database provider 'mongodb': Could not evaluate MongoDB shell command: load('/root/.mongorc.js'); printjson(db.getMongo().getDBs())
```

This error is caused by a deficiency in this module trying to use authentication
in its prefetch step when authentication hasn't been configured yet on
the database. The error can be safely ignored. Auth and databases will be 
configured normally. Subsequent runs of puppet will not show this error.

### MongoDB (Puppet >= 4.0)

When running the initial install of `st2` you will see an error from the 
MongoDB module :

```
Error: Could not prefetch mongodb_database provider 'mongodb': Could not evaluate MongoDB shell command: load('/root/.mongorc.js'); printjson(db.getMongo().getDBs())
```

This error is caused by a deficiency in this module trying to use authentication
in its prefetch step when authentication hasn't been configured yet on
the database. This results in a failure and stops processing.

In these cases we need to disable auth for MongoDB using the `mondob_auth` variabe.
This can be accomplished when declaring the `::st2` class:

``` puppet
class { '::st2':
  mongodb_auth => false,
}
```

Or in hiera:

``` yaml
st2:
  mongodb_auth: false
```

### Ubuntu 14.04

Because 14.04 ships with a very old version of puppet (3.4) and most puppet modules
no longer support this version of puppet, we recommend upgrading to 3.8.7 at a
minimum.

``` shell
# 14.04 trusty
# By default this ships with puppet 3.4.x (very old), need a newer version to 
# work with with of the required puppet module dependencies for this module. 
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get update
sudo apt-get install puppet=3.8.7-1puppetlabs1
```

### Ubuntu 16.04

In StackStorm < `2.4.0` there is a known bug [#3290](https://github.com/StackStorm/st2/issues/3290) 
that when first running the installation with this puppet module the `st2` pack
will fail to install. Simply invoking puppet a second time will produce
a fully running st2 installation with the `st2` pack installed. This has
been fixed in st2 version `2.4.0`.


## Maintainers

* Nick Maludy 
  * GitHub - [@nmaludy](https://github.com/nmaludy)
  * Email - <nick.maludy@encore.tech>
* StackStorm <info@stackstorm.com>
* James Fryman
* Patrick Hoolboom

## Help

If you're in stuck, our community always ready to help, feel free to:
* Ask questions in our [public Slack channel](https://stackstorm.com/community-signup) in channel `#puppet`
* [Report bug](https://github.com/StackStorm/puppet-st2/issues), provide [feature request](https://github.com/StackStorm/puppet-st2/pulls) or just give us a ✮ star

Your contribution is more than welcome!
