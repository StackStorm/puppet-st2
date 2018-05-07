# encoding: utf-8
# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

control 'st2chatops' do
  title 'Minimal package integrity check'
  desc '
    Basic check that st2chatops package is installed. Not doing any further tests, since st2chatops
    requires correct hubot adapter settings to be configured for running.
  '

  describe package('st2chatops') do
    it { should be_installed }
  end

  describe service('st2chatops') do
    it { should be_installed }
    it { should be_enabled }
  end

  describe file('/opt/stackstorm/chatops/st2chatops.env') do
    it { should exist }
  end
end
