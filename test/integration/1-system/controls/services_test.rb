# encoding: utf-8
# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

control 'system-services' do
  title 'Verify system services'
  desc '
    Ensure that required services like cron, SSH are running properly.
  '

  describe service('cron') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe service('ssh') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe port(22) do
    it { should be_listening }
    its('addresses') { should include '0.0.0.0' }
    its('processes') { should include 'sshd' }
    its('protocols') { should include 'tcp' }
  end
end
