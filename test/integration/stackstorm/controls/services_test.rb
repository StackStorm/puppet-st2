# encoding: utf-8

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

# List of available `st2` services:
# https://github.com/StackStorm/st2/blob/master/st2common/bin/st2ctl#L5
ST2_SERVICES = ['st2actionrunner', 'st2api', 'st2stream',
                'st2auth', 'st2garbagecollector', 'st2notifier',
                'st2resultstracker', 'st2rulesengine', 'st2sensorcontainer',
                'st2workflowengine', 'st2timersengine', 'st2scheduler'].freeze

control 'st2-services' do
  title 'verify stackstorm services'
  desc '
    Ensure that stackstorm services are shipped, enabled, started and listening on network ports.
  '

  ST2_SERVICES.each do |service_name|
    describe service(service_name) do
      it { should be_installed }
      it { should be_enabled }
      it { should be_running }
    end
  end

  # st2auth
  describe port(9100) do
    it { should be_listening }
    its('addresses') { should include '127.0.0.1' }
    its('protocols') { should cmp 'tcp' }
  end

  # st2api
  describe port(9101) do
    it { should be_listening }
    its('addresses') { should include '127.0.0.1' }
    its('protocols') { should cmp 'tcp' }
  end

  # st2stream
  describe port(9102) do
    it { should be_listening }
    its('addresses') { should include '127.0.0.1' }
    its('protocols') { should cmp 'tcp' }
  end
end
