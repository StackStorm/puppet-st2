# encoding: utf-8
# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

control 'mongodb' do
  title 'Database availability check'
  desc '
    Ensure that MongoDB is installed, bindng on network ports and actually works & available.
  '

  describe package 'mongodb-org' do
    it { should be_installed }
  end

  describe file('/etc/mongod.conf') do
    it { should exist }
  end

  describe yaml('/etc/mongod.conf') do
    # Security auth should be enabled for mongo
    # @link: https://github.com/StackStorm/st2-packages/blob/a93701d98a130f50f7cb551e842889212ece3b11/scripts/st2bootstrap-deb.sh#L483-L484
    its(['security','authorization']) { should eq 'enabled' }

    # Mongo should listen on localhost only
    # @link: https://github.com/StackStorm/st2-packages/blob/a93701d98a130f50f7cb551e842889212ece3b11/scripts/st2bootstrap-deb.sh#L446-L447
    its(['net','bindIp']) { should eq '127.0.0.1' }
    its(['net','port']) { should eq 27017 }
  end

  describe service('mongod') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe port(27017) do
    it { should be_listening }
    its('processes') { should include 'mongod' }
    its('addresses') { should eq ['127.0.0.1'] }
    its('protocols') { should cmp 'tcp' }
  end

  # TODO: Security check that 'mongod' is not listening on any other ports & IPs
end
