# encoding: utf-8
# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

control 'st2-user' do
  title 'stanley system user check'
  desc '
    Check that st2 system user (default is stanley) is added, exists, enabled in sudoers
    and has the SSH keys generated with correct file permissions and is authorized.
  '

  describe group('stanley') do
    it { should exist }
  end

  describe user('stanley') do
    it { should exist }
    its('group') { should eq 'stanley' }
    its('home') { should eq '/home/stanley' }
  end

  describe passwd.users(/stanley/) do
    its('homes') { should eq ['/home/stanley'] }
  end

  describe directory('/home/stanley/.ssh') do
    it { should exist }
    its('owner') { should eq 'stanley' }
    its('group') { should eq 'stanley' }
    it { should be_readable.by('owner') }
    it { should_not be_readable.by('group') }
    it { should be_writable.by('owner') }
    it { should_not be_writable.by('group') }
    it { should be_executable.by('owner') }
    it { should_not be_executable.by('group') }
  end

  describe file('/home/stanley/.ssh/stanley_rsa') do
    it { should exist }
    its('owner') { should eq 'stanley' }
    its('group') { should eq 'stanley' }
    it { should be_readable.by('owner') }
    it { should_not be_readable.by('group') }
    it { should_not be_readable.by('other') }
    it { should be_writable.by('owner') }
    it { should_not be_writable.by('group') }
    it { should_not be_writable.by('other') }
    it { should_not be_executable }
  end

  describe file('/home/stanley/.ssh/stanley_rsa.pub') do
    it { should exist }
    its('owner') { should eq 'stanley' }
    its('group') { should eq 'stanley' }
    it { should be_readable.by('owner') }
    it { should be_readable.by('group') }
    it { should be_readable }
    it { should be_writable.by('owner') }
    it { should_not be_writable.by('group') }
    it { should_not be_executable.by('owner') }
    it { should_not be_executable.by('group') }
  end

  describe file('/home/stanley/.ssh/authorized_keys') do
    it { should exist }
    its('owner') { should eq 'stanley' }
    its('group') { should eq 'stanley' }
    it { should be_readable.by('owner') }
    it { should_not be_readable.by('group') }
    it { should_not be_readable.by('other') }
    it { should be_writable.by('owner') }
    it { should_not be_writable.by('group') }
    it { should_not be_writable.by('other') }
    it { should_not be_executable }
  end

  describe file('/etc/sudoers.d/st2') do
    it { should exist }
    its('content') { should match(%r{stanley\s.*?ALL\=\(ALL\)\s.*?NOPASSWD:\s.*?SETENV:\s.*?ALL}) }
  end
end
