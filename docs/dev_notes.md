# Dev Notes

This document is used as a repository of useful information for developers and
maintainers of this module. It's been extracted into this document to de-clutter
the main README.md.

## Build System

The build system has been recently revamped. Please see details in the file
[build/README.md](../build/README.md).

## Testing Matrix

### Unit Testing (rspec, puppet-lint, etc)

| OS           | Ruby  | Puppet |
|--------------|-------|--------|
| RHEL 6       | 1.8.7 | 3.8.7  |
| RHEL 7       | 2.0.0 | 3.8.7  |
| Ubuntu 14.04 | 1.9.3 | 3.8.7  |
| Ubuntu 16.06 | 2.3.1 | 3.8.5  |


### Integration Testing (test-kitchen)

Note: "Base" specs are for the Travis CI container that test-kitchen is
being run on. All other columns are details about the guest OS that is 
created by test-kitchen that puppet-st2 is run against.

| Base OS (travis) | Base Ruby | Guest OS     | Guest Ruby | Guest Puppet |
|------------------|-----------|--------------|------------|--------------|
| Ubuntu 14.04     | 2.4       | RHEL 6       | 1.8.7      | 3.8.7        |
| Ubuntu 14.04     | 2.4       | RHEL 7       | 2.0.0      | 3.8.7        |
| Ubuntu 14.04     | 2.4       | Ubuntu 14.04 | 1.9.3      | 3.8.7        |
| Ubuntu 14.04     | 2.4       | Ubuntu 16.06 | 2.3.1      | 3.8.5        |

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

**Note** These are now also printed out in the travis build. What i've been
been doing is executing the Travis test and copying out the Gemfile.lock 
information from the build output, then updating the `build/<env>/Gemfile.lock`.

``` shell
gem install bundler
# ruby 1.8.7
PUPPET_VERSION="~> 3.0" TEST_KITCHEN_ENABLED=false R10K_VERSION="~> 1.0" PUPPETLABS_SPEC_HELPER_VERSION="~> 1.0" bundle package; mv Gemfile.lock .travis-gemfile/Gemfile.lock.rhel6
# ruby 2.0.0
PUPPET_VERSION="~> 3.0" bundle package; mv Gemfile.lock .travis-gemfile/Gemfile.lock.rhel7
# ruby 1.9.3
PUPPET_VERSION="~> 3.0" KITCHEN_SYNC_VERSION="2.1.0" bundle package; mv Gemfile.lock .travis-gemfile/Gemfile.lock.ubuntu14
# ruby 2.3.1
PUPPET_VERSION="~> 4.0" bundle package; mv Gemfile.lock .travis-gemfile/Gemfile.lock.ubuntu16
# ruby 2.1.x
PUPPET_VERSION="~> 4.0" TEST_KITCHEN_ENABLED=false bundle package; mv Gemfile.lock .travis-gemfile/Gemfile.lock.puppet4
# ruby 2.4.x
PUPPET_VERSION="~> 5.0" TEST_KITCHEN_ENABLED=false bundle package; mv Gemfile.lock .travis-gemfile/Gemfile.lock.puppet5

```

