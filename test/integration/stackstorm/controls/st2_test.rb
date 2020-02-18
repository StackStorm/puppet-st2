# encoding: utf-8

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

control 'st2' do
  title 'Package integrity check'
  desc '
    Ensure st2 package integrity: its installed and shipped
    with the expected directories, files and correct permissions.
  '

  describe package 'st2' do
    it { should be_installed }
  end

  describe group('st2') do
    it { should exist }
  end

  describe user('st2') do
    it { should exist }
    its('group') { should eq 'st2' }
  end

  describe directory('/etc/st2') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
  end

  describe file('/etc/st2/st2.conf') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    # ensure that passwords with special characters are escaped for RabbitMQ URL
    its('content') { should match %r{url = amqp://st2admin:Ch%40ngeMe@127.0.0.1:5672/} }
  end

  describe file('/etc/st2/htpasswd') do
    it { should exist }
    its('owner') { should eq 'st2' }
    its('group') { should eq 'st2' }
    it { should be_readable.by('owner') }
    it { should be_writable.by('owner') }
    it { should_not be_readable.by('group') }
    it { should_not be_writable.by('group') }
    it { should_not be_executable.by('owner') }
    it { should_not be_executable.by('group') }
  end

  describe file('/opt/stackstorm/configs') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'st2' }
    its('mode') { should cmp '0755' }
  end

  describe file('/opt/stackstorm/packs') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'st2packs' }
    its('mode') { should cmp '0775' }
  end

  describe file('/opt/stackstorm/virtualenvs') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'st2packs' }
    its('mode') { should cmp '0755' }
  end
end
