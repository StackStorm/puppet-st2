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
puppet apply --modulepath=./modules -e "include st2::profile::fullinstall"

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

## Adding support for a new OS or Puppet version

### 1. Create new build/<os>-<puppet> environments

In the `build/` directory, create new directories for your OS (or copy from existing).
Directory naming format is `build/<os>-<puppet>` (example: `build/centos8-puppet6`).

**TIP** Start from the previous major release of the OS you're using and just copy those, then edit.

#### build/<os>-<puppet>/Dockerfile

This file is used for unit testing. You'll need to edit the following things:

- Change the `FROM` container to the appropriate OS version from `st2packaging-dockerfiles` repo: https://github.com/StackStorm/st2packaging-dockerfiles
- Change the `Ruby` version installed by `rvm` to match whatever is used by that Puppet version
- Change the `yum` repo to install the proper Puppet version for that OS
- Change `ENV PUPPET_GEM_VERSION "~> 6.0"` to match your Puppet version

#### build/<os>-<puppet>/Dockerfile.kitchen

This file is used by Kitchen for integration testing.

- Change the `FROM` container to the appropriate OS version from `st2packaging-dockerfiles` repo: https://github.com/StackStorm/st2packaging-dockerfiles
- Change the `yum` repo to install the proper Puppet version for that OS

#### build/<os>-<puppet>/Puppetfile

You probably won't have to do anything here, but if you want:

- Spin up a vagrant box for the OS you're testing.
- Follow the instructions in the Puppetfile to generate the module list
```shell
# In the puppet-st2 repo
pdk build

# upload the package to Vagrant box


# install the module
puppet module install ./pkg/stackstorm-st2-x.y.z.tar.gz
# list the module dependencies
puppet module list --tree
```

### 2. Edit .travis.yml

`.travis.yml` contains the build matrix for Travis.

Create new integration testing `jobs` for your OS.

The `TEST_NAME` environment variable should match your `<os>-<puppet>` pattern from above.

Example:
```yaml
    - name: "RHEL/CentOS 8 - Puppet 5"
      rvm: 2.5
      gemfile: build/kitchen/Gemfile
      env:
        - TEST_NAME="centos8-puppet5"
    - name: "RHEL/CentOS 8 - Puppet 6"
      rvm: 2.5
      gemfile: build/kitchen/Gemfile
      env:
        - TEST_NAME="centos8-puppet6"
```

If you're adding a new Puppet version, copy an existing `Unit Testing` job.
 - Make sure the `rvm` version matches the suppred Ruby version for that version of Puppet
 - Edit `PUPPET_GEM_VERSION` environment variable to match your major version of Puppet

Example:
```yaml
    - name: "Unit Testing - Puppet 6"
      rvm: 2.5
      # use default Gemfile in repo root (from PDK)
      env:
        - UNIT_TEST="true"
        - PUPPET_GEM_VERSION="~> 6.0"
        - CHECK="syntax lint metadata_lint check:symlinks check:git_ignore check:dot_underscore check:test_file rubocop parallel_spec"
```

### 3. Edit .kitchen.yml

`.kitchen.yml` contains the test matrix for integation testing used by Travis.

Create new integration test platforms (copy some existing ones) and change the following:

- `name` This should be your new `<os>-<puppet>` name
- `driver.dockerfile` This should be the path to your `Dockerfile.kitchen`, example `build/centos8-puppet5/Dockerfile.kitchen`
- `provisioner.puppetfile_path` This should be the path to your `Puppetfil`, example `build/centos8-puppet5/Puppetfile`

Example:
```yaml
  # CentOS8 with Systemd - Puppet 6
  - name: centos8-puppet6
    driver:
      platform: centos
      dockerfile: build/centos8-puppet6/Dockerfile.kitchen
      run_command: /sbin/init
      volume:
        - /sys/fs/cgroup:/sys/fs/cgroup:ro
    provisioner:
      puppetfile_path: build/centos8-puppet6/Puppetfile
```

### 4. Edit test/integration/stackstorm/inspec.yml

`test/integration/stackstorm/inspec.yml` contains the supported OS versions for Inspec testing

Add a new `supports` platform. On CentOS you can do `8.*` or whatever your major version is.
On Ubuntu you need to match the version exactly, example `18.04`.

Example:
```
supports:
  - os-name: centos
    release: 8.*
```

### 5. Edit metadata.json

`metadata.json` describes the OSes and Puppet versions that are supported by this module.

If you're adding support for a new OS, add it to `operatingsystem_support`, example:

```json
  "operatingsystem_support": [
    {
      "operatingsystem": "RedHat",
      "operatingsystemrelease": [
        "6",
        "7",
        "8"
      ]
    },
    ...
```

If you're adding support for a new Puppet version, change the version restrictions for `puppet` in `requirements`, example:

```json
  "requirements": [
    {
      "name": "puppet",
      "version_requirement": ">= 4.7.0 < 7.0.0"
    }
  ],
```

### 6. Add supported platforms to README

Edit the `Supported Platforms` section in `README.md` to include your new version.

### 7. Make code changes in the manifests/ directory

Places to check for new OS compatability (basically grep for `$facts['os']`):
- manifests/init.pp
- manifests/repo.pp
- manifests/profile/mongodb.pp


