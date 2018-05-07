# encoding: utf-8
# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

control 'vagrant' do
  title 'Vagrant settings'
  desc '
    Ensure Vagrant-related OS changes are in place: user, sudoers, workarounds,
  '

  describe user('vagrant') do
    it { should exist }
    its('uid') { should eq 900 }
    its('gid') { should eq 900 }
    its('group') { should eq 'vagrant' }
    its('groups') { should eq ['vagrant', 'sudo']}
    its('home') { should eq '/home/vagrant' }
    its('shell') { should eq '/bin/bash' }
  end

  describe file('/etc/sudoers.d/vagrant') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'root' }
    it { should be_readable.by('owner') }
    it { should_not be_readable.by('others') }
    it { should_not be_writable.by('others') }
    it { should_not be_executable }
    its('content') { should include 'vagrant ALL=(ALL) NOPASSWD: ALL' }
    its('content') { should include 'Defaults:vagrant !requiretty' }
  end

  describe file('/home/vagrant/.ssh/authorized_keys') do
    it { should exist }
    it { should be_file }
    it { should be_readable.by('owner') }
    it { should_not be_readable.by('others') }
    it { should_not be_writable.by('others') }
    its('content') { should include 'vagrant' }
  end

  # Check if fix for Vagrant provision "stdin/tty" is in place
  describe file('/root/.profile') do
    its('content') { should include 'test -t 0 && mesg n' }
  end
end
