# puppet-st2

[![Build Status](https://github.com/StackStorm/puppet-st2/workflows/build/badge.svg?branch=master)](https://github.com/StackStorm/puppet-st2/actions)
[![Coverage Status](https://coveralls.io/repos/StackStorm/puppet-st2/badge.svg?branch=master&service=github)](https://coveralls.io/github/StackStorm/puppet-st2?branch=master)
[![Puppet Forge Endorsement](https://img.shields.io/puppetforge/e/stackstorm/st2.svg)](https://forge.puppet.com/stackstorm/st2)
[![Puppet Forge Version](https://img.shields.io/puppetforge/v/stackstorm/st2.svg)](https://forge.puppet.com/stackstorm/st2)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/stackstorm/st2.svg)](https://forge.puppet.com/stackstorm/st2)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/stackstorm-st2)
[![Join our community Slack](https://stackstorm-community.herokuapp.com/badge.svg)](https://stackstorm.com/community-signup)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with st2](#setup)
    * [What st2 affects](#what-st2-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with st2](#beginning-with-st2)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Reference Documentation](#reference-documentation)
    * [Configuration](#configuration)
        * [Profiles](#profiles)
        * [Installing and Configuring Packs](#installing-and-configuring-packs)
        * [Configuring Authentication](#configuring-authentication)
        * [Configuring ChatOps](#configuring-chatops)
    * [Tasks](#tasks)
        * [Task List](#task-list)
        * [Task Authentication](#task-authentication)
        * [Using Tasks With API Key](#using-tasks-with-api-key)
        * [Using Tasks With Auth Tokens](#using-tasks-with-auth-tokens)
        * [Using Tasks With Username and Password](#using-tasks-with-username-and-password)
4. [Limitations - OS compatibility, etc.](#limitations)
    * [Supported Platforms](#supported-platforms)
    * [Supported Puppet versions](#supported-puppet-versions)
    * [Upgrading StackStorm](#upgrading-stackstorm)
5. [Development - Guide for contributing to the module](#development)
    * [Maintainers](#maintainers)
    * [Help](#help)

## Description

Module to manage [StackStorm](http://stackstorm.com) with Puppet.

## Setup

### What st2 Affects

The `st2` module configures the existing into a complete and dedicated StackStorm node with the following components:
 * StackStorm
 * MongoDB
 * Postgres
 * RabbitMQ
 * Nginx
 * NodeJS

### Setup Requirements

This module, similar to normal StackStorm installs, expects to be run on
a _blank_ system without any existing configurations. The only hard requirements
are on the Operating System and machine specs. See [Limitations](#limitations) and
the official StackStorm [system requirements](https://docs.stackstorm.com/install/system_requirements.html).

#### Module Dependencies

This module installs and configures all of the components required for StackStorm.
In order to not repeat others work, we've utilized many existing modules from the
forge. We manage the module dependenies using a `Puppetfile` for each OS we support.
These `Puppetfile` can be used both with [r10k](https://github.com/puppetlabs/r10k)
and [librarian-puppet](http://librarian-puppet.com/).

 * RHEL/CentOS 7 - Puppet 6 - [build/centos7-puppet6/Puppetfile](build/centos7-puppet6/Puppetfile)
 * RHEL/CentOS 7 - Puppet 7 - [build/centos7-puppet7/Puppetfile](build/centos7-puppet7/Puppetfile)
 * Ubuntu 16.04 - Puppet 6 - [build/ubuntu16-puppet6/Puppetfile](build/ubuntu16-puppet6/Puppetfile)
 * Ubuntu 16.04 - Puppet 7 - [build/ubuntu16-puppet7/Puppetfile](build/ubuntu16-puppet7/Puppetfile)
 * Ubuntu 18.04 - Puppet 6 - [build/ubuntu18-puppet6/Puppetfile](build/ubuntu18-puppet6/Puppetfile)
 * Ubuntu 18.04 - Puppet 7 - [build/ubuntu18-puppet7/Puppetfile](build/ubuntu18-puppet7/Puppetfile)

### Beginning with st2

For a full installation on a single node, a profile already exists to
get you setup and going with minimal effort. Simply:

```
puppet module install stackstorm-st2
puppet apply -e "include st2::profile::fullinstall"
```

## Usage

### Reference Documentation

This module uses [Puppet Strings](https://puppet.com/docs/puppet/latest/puppet_strings.html)
as the documentation standard. An live version is available online at
[puppetmodule.info/m/stackstorm-st2](http://www.puppetmodule.info/m/stackstorm-st2).
A markdown version is available directly in this repo in [REFERENCE.md](REFERENCE.md).

### Configuration

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
* `st2::python_version` - Version to Python to use. The default is `'system'` and the
  system `python` package will be installed, whatever version that is for your OS.
  To explicitly install Python 3.6 specify `'3.6'` if on RHEL/CentOS 7.
  If on Ubuntu 16.04 specify `'python3.6'`.
  **Notes**
    * RHEL 7 - The Red Hat subscription repo `'rhel-7-server-optional-rpms'`
      will need to be enabled prior to running this module.
    * :warning: Ubuntu 16.04 -
      The python3.6 package is a required dependency for the StackStorm `st2` package
      but that is not installable from any of the default Ubuntu 16.04 repositories.
      We recommend switching to Ubuntu 18.04 LTS (Bionic) as a base OS. Support for
      Ubuntu 16.04 will be removed with future StackStorm versions.
      Alternatively the Puppet will try to add python3.6 from the 3rd party 'deadsnakes' repository: https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa.
      Only set to true, if you are aware of the support and security risks associated
      with using unofficial 3rd party PPA repository, and you understand that StackStorm
      does NOT provide ANY support for python3.6 packages on Ubuntu 16.04.
      The unsafe PPA `'ppa:deadsnakes/ppa'` https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa
      can be enabled if you specify the `st2::python_enable_unsafe_repo: true` (default: `false`)

  ```puppet
  # CentOS/RHEL 7
  class { 'st2':
    python_version => '3.6',
  }

  # Ubuntu 16.04 (unsafe deadsnakes PPA will be enabled because of boolean flag)
  class { 'st2':
    python_version            => 'python3.6',
    python_enable_unsafe_repo => true,
  }

  contain st2::profile::fullinstall
  ```

All other classes are documented with Puppetdoc. Please refer to specific
classes for use and configuration.

#### Profiles

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

#### Installing and Configuring Packs

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

#### Configuring Authentication

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
          [link](https://docs.stackstorm.com/authentication.html#ldap)
* `mongodb` - Authenticates against a collection named `users` in MongoDB [link](https://github.com/StackStorm/st2-auth-backend-mongodb)
* `pam` - Authenticates against the PAM Linux service [link](https://github.com/StackStorm/st2-auth-backend-pam)


By default the `flat_file` backend is used. To change this you can configure it
when instantiating the `st2` class in a manifest file:

``` ruby
class { 'st2':
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
the `st2` class in a manifest file:

``` ruby
class { 'st2':
  auth_backend        => 'ldap',
  auth_backend_config => {
    host            => 'ldap.domain.tld',
    bind_dn         => 'cn=ldap_stackstorm,ou=service accounts,dc=domain,dc=tld',
    base_dn         => 'dc=domain,dc=tld',
    scope           => 'subtree',
    id_attr         => 'username',
    bind_pw         => 'some_password',
    group_dns       => ['"cn=stackstorm_users,ou=groups,dc=domain,dc=tld"'],
    account_pattern => 'userPrincipalName={username}',
  },
}
```

Or in Hiera:

``` yaml
st2::auth_backend: "ldap"
st2::auth_backend_config:
  host: "ldaps.domain.tld"
  use_tls: false
  use_ssl: true
  port: 636
  bind_dn: 'cn=ldap_stackstorm,ou=service accounts,dc=domain,dc=tld'
  bind_pw: 'some_password'
  chase_referrals: false
  base_dn: 'dc=domain,dc=tld'
  group_dns:
    - '"cn=stackstorm_users,ou=groups,dc=domain,dc=tld"'
  scope: "subtree"
  id_attr: "username"
  account_pattern: "userPrincipalName={username}"
```


#### Configuring ChatOps

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

  # install and configure hubot adapter (rocketchat, nodejs module installed by nodejs)
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

### Tasks

This module provides several tasks for interacting with StackStorm. These tasks
are modeled after the `st2` CLI command, names of the tasks and parameters reflect this.
Under the hood, the tasks invoke the `st2` CLI command so they must be executed on
a node where StackStorm is installed.

#### Task List

- `st2::key_decrypt` - Decrypts an encrypted key/value pair
- `st2::key_get` - Retrieves the value for a key from the datastore
- `st2::key_load` - Loads a list of key/value pairs into the datastore
- `st2::pack_install` - Installs a list of packs
- `st2::pack_list` - Get a list of installed packs
- `st2::pack_register`: Registers a list of packs based from paths on the filesystem
- `st2::pack_remove` - Removes a list of packs
- `st2::rule_disable`: Disables a rule
- `st2::rule_list`: Lists all rules, or just the rules in a given pack
- `st2::run`: Runs a StackStorm action

#### Task Authentication

Tasks that interact with the `st2` CLI command require authentication with the StackStorm
instance. There are three options for authentication:

- API Key
- Auth token
- Username/password

#### Using Tasks With API Key

API keys are the recommended way for systems to authenticate with StackStorm.
To do this via a task, you would first create an API key in StackStorm:

``` shell
$ st2 apikey create -m '{"used_by": "bolt"}'
```

Copy the API `key` parameter in the output, and then use it when invoking one of
the tasks in this module via the `api_key` parameter:

Usage via command line:
``` shell

bolt task run st2::key_get key="testkey" api_key='xyz123'
```

Usage in a plan:
``` puppet
$res = run_task('st2::key_get', $stackstorm_target,
                key        => 'testkey',
                api_key    => $api_key)
```

#### Using Tasks With Auth Tokens

Auth tokens can be used by `bolt` to communicate with StackStorm. First, the user
needs to create an auth token, then pass it in via the `auth_token` parameter

``` shell
$ st2 auth myuser
```

Copy the auth token in the output, and then use it when invoking one of
the tasks in this module:

Usage via command line:
``` shell
bolt task run st2::key_get key="testkey" auth_token='xyz123'
```

Usage in a plan:
``` puppet
$res = run_task('st2::key_get', $stackstorm_target,
                key        => 'testkey',
                auth_token => $auth_token)
```

#### Using Tasks With Username and Password

Finally `bolt` can accept username/passwords to communicate with StackStorm.

Usage via command line:
``` shell
bolt task run st2::key_get key="testkey" username="myuser" password="xyz123"
```

Usage in a plan:
``` puppet
$res = run_task('st2::key_get', $stackstorm_target,
                key      => 'testkey',
                username => $username,
                password => $password)
```

## Limitations

### Supported platforms

* Ubuntu 16.04
* Ubuntu 18.04
* RHEL/CentOS 7

### Supported Puppet versions

* Puppet 6
* Puppet 7

#### :warning: End-of-Support Notice - Mistral

Support for Mistral has been dropped as of StackStorm `3.3.0`.

As of version `1.8` this module no longer supports Mistral (and subsequently PostgreSQL)
Neither Mistral nor Postgresql will be installed or managed by this module.

#### :warning: End-of-Support Notice - CentOS 6

Support for CentOS 6 has been dropped as of StackStorm `3.3.0`.

As of version `1.8` this module no longer supports CentOS 6, so changes will not be tested against this platform.

#### :warning: Deprecation Notice - Puppet 5

Puppet 5 reaches End of Life on 2021-12-31. As of version `2.0` use of Puppet 5 with this module
is officially deprecated.

* This module no longer tests against Puppet 5 in its build matrix.
* The next major release of the module will drop support for Puppet 5 by adjusting the
  minimum supported Puppet version in `metadata.json`.

#### :warning: Deprecation Notice - Puppet 4

Puppet 4 reached End of Life on 2018-12-31. As of version `1.4` use of Puppet 4 with this module
is officially deprecated.

* As of version `1.5.0` this module no longer tests against Puppet 4 in its build matrix.
* The next major release of the module will drop support for Puppet 4 by adjusting the
  minimum supported Puppet version in `metadata.json`.

#### :warning: Deprecation Notice - Puppet 3

**This module no longer supports Puppet 3 as of version `1.1`**

### Upgrading StackStorm

By default this module does NOT handle upgrades of StackStorm. It is the
responsiblity of the end user to upgrade StackStorm according to the
[upgrade documenation](https://docs.stackstorm.com/install/upgrades.html).

In a future release a Puppet task may be included to perform these update
on demand using [bolt](https://github.com/puppetlabs/bolt).

## Development

Contributions to this module are more than welcome! If you have a problem with the module or
would like to see a new feature, please raise an [issue](https://github.com/StackStorm/puppet-st2/issues).
If you are amazing, find a bug or implement a new feature and want to add it to the module,
please submit a [Pull Request](https://github.com/StackStorm/puppet-st2/pulls).

### Maintainers

* Nick Maludy
  * GitHub - [@nmaludy](https://github.com/nmaludy)
* StackStorm <info@stackstorm.com>
* James Fryman
* Patrick Hoolboom

### Help

If you're in stuck, our community always ready to help, feel free to:
* Ask questions in our [public Slack channel](https://stackstorm.com/community-signup) in channel `#puppet`
* [Report bug](https://github.com/StackStorm/puppet-st2/issues), provide [feature request](https://github.com/StackStorm/puppet-st2/pulls) or just give us a ✮ star

Your contribution is more than welcome!
