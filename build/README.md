# Build System

The build system is based on Docker and is executed in two phases: unit testing 
and integration testing.

Unit testing and integration testing occur in their own separate containers.
This helps with reproducability and consistency. Also, because our unit testing
and our integration testing both rely on Ruby, this helps isolate them and
avoid cross-dependency issues. Example: there may be a dependency limit in
some component of the unit testing system that affects the integration testing
system. These types of conflicts plauged us previously and this new model
has made the testing system much more robust and less painful.


## Directory Structure

From the root of this repo:

``` shell
.fixtures.yml   # file contains modules for puppet_spec_helper used during unit testing
.kitchen.yml    # test-kitchen file describing our integration testing setups
build/          # contains all build files
build/README.md # this file
build/kitchen   # Files needed to setup the build environment for test-kitchen
build/kitchen/Gemfile # Gems that need to be installed for our test-kitchen build
build/scripts   # directory containing scripts that execute the tests
# below are the scripts used in our build environment
build/scripts/ci_docker_clean_all.sh 
build/scripts/ci_docker_clean.sh
build/scripts/ci_docker_integration.sh
build/scripts/ci_docker_unit.sh  # Executes our unit tests and integration test in Docker
build/scripts/ci_docker.sh
build/scripts/ci_docs_generate.sh
build/scripts/ci_install.sh
build/scripts/ci_pdk_unit.sh
build/scripts/ci.sh
build/scripts/install_puppet.sh
# below are the test environments we currently use
build/centos7-puppet6   # Files needed for the RHEL/CentOS 7 test environemnt on puppet 6
build/centos7-puppet7   # Files needed for the RHEL/CentOS 7 test environemnt on puppet 7
build/ubuntu16-puppet6   # Files needed for the Ubuntu 16.04 test environemnt on puppet 6
build/ubuntu16-puppet7   # Files needed for the Ubuntu 16.04 test environemnt on puppet 7
build/ubuntu18-puppet6  # Files needed for the Ubuntu 18.04 test environemnt on puppet 6
build/ubuntu18-puppet7  # Files needed for the Ubuntu 18.04 test environemnt on puppet 7
# below are files in each of the environments above
build/<env>/Dockerfile         # Dockerfile for unit testing
build/<env>/Dockerfile,kitchen # Dockerfile for test-kitchen integration testing
build/<env>/Puppetfile         # Puppet modules to install for test-kitchen integration testing
```

## Github Actions

The current CI/CD pipeline is setup with Github Actions in `.github/workflows/build.yaml`
This file details how to setup the test machine (see `matrix` section) and
which tests to run (see `script`) section.

We have two requirements for the testing environment:
 * Docker must be running, which is handled by Github Actions
 * Ruby must be installed on step "Setup Ruby" so we can setup `test-kitchen` - we use 2.5 for puppet 6 and 2.7 for other testing
 
For each build in the matrix we tell CI which version of Ruby to use. 
Since the unit testing is done in a container, we use the same version for all
builds. We also specify a Gemfile and CI is smart enough to take this
and use bundler to install all of the gems.

Even though our builds run in containers this Gemfile step is required because
our integration testing framework `test-kitchen` must be installed on the base
machine.

After the machine is setup the `script:` is executed: `build/scripts/ci_docker_unit.sh`.
We have several commands we run for our testing. Instead of specify them in
the list for `script:` in the config file we moved them into the shell script.

Up next we'll detail what's going on in our build script.

## Build Script

The build script is pretty straight forward, performing the following steps:
 * Build the docker container using Dockerfile: `build/<env>/Dockerfile`
 * Run the docker container
 * Execute unit tests in the container
 * Execute integration tests in another container


## Unit Testing

Unit testing is done in a container defined by `build/<env>/Dockerfile`.
This Dockerfile installs an isolated Ruby environment, gems from `build/<env>/Gemfile`,
along with Puppet from various sources depending on the environment.

After the environment is boot strapped we execute the following tests:
 * Validation of erb and metadata file using `puppet-lint` and `metadata-json-lint`
 * Linting of manifest files (*.pp) using `puppet-lint`
 * Unit testing using `rspec` and `puppet-rspec`

Unit testing consists of the following steps currently
  * rubocop syntax lint metadata_lint checks (ruby 2.7 + puppet 7)
  * unit tests for puppet 6 (ruby 2.5 + puppet 6)
  * unit tests for puppet 7 (ruby 2.7 + puppet 7)
  * documentation check (ruby 2.7 + puppet 7)

The environment (ruby and puppet) is defined the in matrix and setup in the build steps based on those values.

All of these tests happen inside the runner container.


## Integration Testing

Integration testing is performed by the `test-kitchen` (aka `kitchen`) system.
The testing environment setup requirements are:
  * Install Ruby (we use 2.7)
  * Install the gems in `build/kitchen/Gemfile`
  * Install Docker and have the daemon running
  
Once the environment is bootstrapped `kitchen` is executed from within the
`build/scripts/ci_docker_unit.sh` with the bundler command.
The `kitchen` configuration can be found in the `.kitchen.yml` file.
`kitchen` has its own terminology (reference: 
[https://docs.chef.io/config_yml_kitchen.html](https://docs.chef.io/config_yml_kitchen.html) ) :

 * `driver` : What will be used to create a resource to test in our case this
   is `docker` that creates a new Docker container.
 * `transport` : What method will be used to copy files into the resource
   created by the `driver`. In our case we use `sftp` (faster than default `transport`).
 * `provisioner` : This executes the test from within the `driver` resource. In our
   case this is the `puppet_apply` provisioner which executes `puppet apply` within 
   the container.
 * `platforms` : This is the test matrix. It enumerates the different OS's we're
   going to test, what Dockerfile to use for each OS, along with which `Puppetfile`
   to use for that OS. The `Puppetfile` is different for each OS because different
   modules versions are required for different old versions of `puppet` and `ruby`.
 * `suites` : Our test suite. In our case this is just `default`


## Testing environment setup

The following will install ruby 2.7 for testing purposes, then execute
all of the unit tests (rspec), execution tests (kitchen) and integration tests
(InSpec).

```shell
# install rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile

# install ruby-build so we can use: rbenv install
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

# install a modern version of ruby
rbenv install 2.7

# set the version of ruby in the current shell
rbenv shell 2.7
```
