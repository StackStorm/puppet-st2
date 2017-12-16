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
.travis.yml     # details our travis build matrix, this configures the "base" system
build/          # contains all build files
build/README.md # this file
build/kitchen   # Files needed to setup the build environment for test-kitchen
build/kitchen/Gemfile # Gems that need to be installed for our test-kitchen build
build/scripts   # directory containing scripts that execute the tests
build/scripts/ci_docker_unit.sh  # Executes our unit tests and integration test in Docker
build/centos6   # Files needed for the RHEL/CentOS 6 test environemnt
build/centos7   # Files needed for the RHEL/CentOS 7 test environemnt
build/puppet4   # Files needed for the Puppet 4 test environemnt
build/puppet5   # Files needed for the Puppet 5 test environemnt
build/ubuntu14  # Files needed for the Ubuntu 14.04 test environemnt
build/ubuntu15  # Files needed for the Ubuntu 16.06 test environemnt
# below are files in each of the environments above
build/<env>/Dockerfile         # Dockerfile for unit testing
build/<env>/Dockerfile,kitchen # Dockerfile for test-kitchen integration testing
build/<env>/Gemfile            # Gems to install in the Docker container for unit testing
build/<env>/Gemfile.lock       # Bundler Gemfile.lock of the last "known good" run
build/<env>/Puppetfile         # Puppet modules to install for test-kitchen integration testing
```

## Travis

The travis build checks out the `puppet-st2` repo and reads the file `.travis.yml`.
This file details how to setup the test machine (see `matrix` section) and
which tests to run (see `script` section.

We have two requirements for the testing environment:
 * Docker must be running, so we specify `services: docker`
 * Ruby must be installed so we can setup `test-kitchen`
 
For each build in the matrix we tell Travis which version of Ruby to use. 
Since the unit testing is done in a container, we use the same version for all
builds. We also specify a Gemfile and Travis is smart enough to take this
and use bundler to install all of the gems.

Even though our builds run in containers this Gemfile step is required because
our integration testing framework `test-kitchen` must be installed on the base
machine.

After the machine is setup the `script:` is executed: `build/scripts/ci_docker_unit.sh`.
We have several commands we run for our testing. Instead of specify them in
the list for `script:` in the `.travis.yml` we moved them into the shell script.
We do this because Travis will not stop on failures if you specify more than
one option in the `script:` list.

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

All of these tests happen inside the container.


## Integration Testing

Integration testing is performed by the `test-kitchen` (aka `kitchen`) system.
The testing environment setup requirements are:
  * Install Ruby (we use 2.4)
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
