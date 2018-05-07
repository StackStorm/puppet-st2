# encoding: utf-8
# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

control 'motd-welcome-msg' do
  title 'StackStorm Welcome Message check in console'
  desc '
    Ensure that motd changes with StackStorm welcome message are in place, appearing after logging in to console.
  '

  describe file('/etc/issue') do
    it { should exist }
    its('content') { should include 'StackStorm' }
  end

  describe command('/etc/update-motd.d/00-header') do
    it { should exist }
    its('stdout') { should include 'StackStorm' }
    its('stdout') { should match /v\d+\.\d+\.\d+/ }
  end

  describe command('/etc/update-motd.d/10-help-text') do
    it { should exist }
    its('stdout') { should include 'Documentation: https://docs.stackstorm.com/' }
    its('stdout') { should include 'Community: https://stackstorm.com/community-signup' }
    its('stdout') { should include 'Forum: https://forum.stackstorm.com/' }
    its('stdout') { should include 'Enterprise: https://stackstorm.com/#product' }
  end
end
