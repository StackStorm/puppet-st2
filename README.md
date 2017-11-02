# puppet-st2

[![Build Status](https://travis-ci.org/StackStorm/puppet-st2.svg)](https://travis-ci.org/StackStorm/puppet-st2)
[![Coverage Status](https://coveralls.io/repos/StackStorm/puppet-st2/badge.svg?branch=master&service=github)](https://coveralls.io/github/StackStorm/puppet-st2?branch=master)
[![Puppet Forge Version](https://img.shields.io/puppetforge/v/stackstorm/st2.svg)](https://forge.puppet.com/stackstorm/st2)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/stackstorm/st2.svg)](https://forge.puppet.com/stackstorm/st2)

Module to manage [StackStorm](http://stackstorm.com)

## Supported platforms
* Ubuntu 14.04/16.04
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

## Configuration

This module aims to provide sane default configurations, but also stay
out of your way in the event you need something more custom. To accomplish
this, this module uses the Roles/Profiles pattern. Included in this module
are several modules that come with sane defaults that you can use directly
or use to compose your own site-specific profile for StackStorm installation.

Configuration can be done directly via code composition, or set via
Hiera data bindings. A few notable parameters to take note of:

* `st2::version` - Version of ST2 to install. (Latest version w/o value)

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

### Configuring Hubot (ChatOps)

Configuration via Hiera:
```yaml
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

## Known Limitations

### MongoDB (all OSes)

When running the initial install of st2 you will see an error from the 
MongoDB module :

```
Error: Could not prefetch mongodb_database provider 'mongodb': Could not evaluate MongoDB shell command: load('/root/.mongorc.js'); printjson(db.getMongo().getDBs())
```

This error is caused by a deficiency in this module trying to use authentication
in its prefetch step when authentication hasn't been configured yet on
the database. The error can be safely ignored. Auth and databases will be 
configured normally. Subsequent runs of puppet will not show this error.


### Ubuntu 16.04

Due to a known bug in st2 [3290](https://github.com/StackStorm/st2/issues/3290) 
when first running the installation with this puppet module the `st2` pack
will fail to install. Simply invoking puppet a second time will produce
a fully running st2 installation with the `st2` pack installed.


## Module Dependencies

### RHEL 7 Notes (Ruby 2.0.0, Puppet 3.8.7)

The following modules need to have their versions locked in your
Puppetfile because future versions dropped support for Puppet 3.x.
All other dependencies are compatible with Puppet 3 (as of 2017-08-03).
``` ruby
mod 'puppet/nginx', '0.6.0'
mod 'puppetlabs/vcsrepo', '1.5.0'
mod 'puppet/nodejs', '2.3.0'
```


### RHEL 6 Notes (Ruby 1.8.7, Puppet 3.8.6)

The following modules need to have their versions locked in your
Puppetfile because future versions dropped support for Puppet 3.x.
All other dependencies are compatible with Puppet 3 (as of 2017-08-03).


``` ruby
mod 'puppet/nginx', '0.6.0'
mod 'puppetlabs/vcsrepo', '1.5.0'
mod 'puppet/nodejs', '1.3.0'
```


**Note** that `puppet/nodejs` is an older version than for RHEL 7. This is
because 1.3.0 dropped compatibility with Ruby 1.8.7 in future versions.
If you run a version >1.3.0 on with Ruby 1.8.7, then you'll encounter
the following error.

``` shell

Error: Could not autoload puppet/provider/package/npm: /var/lib/puppet/lib/puppet/provider/package/npm.rb:3: syntax error, unexpected ':', expecting $end
...package).provide :npm, parent: Puppet::Provider::Package do
                              ^
Error: Could not retrieve local facts: Could not autoload puppet/provider/package/npm: /var/lib/puppet/lib/puppet/provider/package/npm.rb:3: syntax error, unexpected ':', expecting $end
...package).provide :npm, parent: Puppet::Provider::Package do
                              ^
Error: Failed to apply catalog: Could not retrieve local facts: Could not autoload puppet/provider/package/npm: /var/lib/puppet/lib/puppet/provider/package/npm.rb:3: syntax error, unexpected ':', expecting $end
...package).provide :npm, parent: Puppet::Provider::Package do
                              ^
```

### Ubuntu Notes (Puppet 3.8.7)

The following modules need to have their versions locked in your
Puppetfile because future versions dropped support for Puppet 3.x.
All other dependencies are compatible with Puppet 3 (as of 2017-08-03).

``` shell
mod 'puppet/nginx', '0.6.0'
mod 'puppetlabs/vcsrepo', '1.5.0'
mod 'puppet/nodejs', '2.3.0'
mod 'puppetlabs/apt', '2.4.0'
```

## Dev Notes

### Ubuntu dev environment

``` shell
sudo apt-get install ruby-dev git gcc g++ make
gem install bundler

# 14.04 trusty
# By default this ships with puppet 3.4.x (very old), need a newer version to work
# with any of the required puppet modules (minimum version = 3.8.x)
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get update
sudo apt-get install puppet=3.8.7-1puppetlabs1

# 16.04 xenial
# Note: because the version of ruby shipped with Xenail is 2.3.x and the version
# of puppet shipped (3.8.x) is incompatible, we have to run our tests using
# a newer version of puppet (4.10 at a minimum) that supports the new version of
# ruby.
# Note - this is ONLY a unit testing deficiency, the usage of this module runs
# just fine with the default version of puppet.
wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
sudo dpkg -i puppetlabs-release-pc1-xenial.deb
sudo apt-get update
sudo apt-get install puppet-agent

```

### RHEL dev environment

``` shell
sudo yum -y install puppet ruby-devel git gcc g++ make
gem install bundler
```

### Dev testing (standalone box)

The file `docs/Puppetfile` is an r10k Puppetfile that downloads all of the
dependencies required for this module and allows you to perform standalone
testing without a puppet master. To utilize this file and form of testing
perform the following

``` shell
# assuming you already have your dev environment setup from above (puppet must be installed)

# install r10k
gem install puppet_forge:2.2.6 r10k

# run r10k to download all of our module dependencies defined in ./docs/Puppetfile
r10k puppetfile install -v --moduledir=./modules --puppetfile=./docs/Puppetfile

# run StackStorm full install using puppet
puppet apply --modulepath=./modules -e "include ::st2::profile::fullinstall"

```


### How to generate Gemfile.lock.x.y.x

**TODO** Install and switch to the proper versions of ruby before each call (chruby)

``` shell
gem install bundler
PUPPET_VERSION=3.8.7 bundle package; mv Gemfile.lock Gemfile.lock.3.8.7
PUPPET_VERSION=4.10 bundle package; mv Gemfile.lock Gemfile.lock.4.10
PUPPET_VERSION=5.0 bundle package; mv Gemfile.lock Gemfile.lock.5.0
```
