# encoding: utf-8
# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

control 'system-settings' do
  title 'Verify system settings'
  desc '
    Verify that system settings like Timezone and Locale are correct.
  '

  describe file('/etc/timezone') do
    it { should exist }
    it { should be_file }
    its('content') { should cmp /UTC/ }
  end

  describe command('locale') do
    its('stdout') { should include 'en_US.UTF-8' }
  end

  describe os_env('LANG') do
    its('content') { should eq 'en_US.UTF-8' }
  end
end
