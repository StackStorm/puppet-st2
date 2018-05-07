# encoding: utf-8
# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

control 'rabbitmq' do
  title 'MQ availability check'
  desc '
    Ensure that RabbitMQ is installed, bindng on network ports and has specific configuration set.
  '

  describe package 'rabbitmq-server' do
    it { should be_installed }
  end

  describe file('/etc/rabbitmq/rabbitmq-env.conf') do
    it { should exist }
    # RabbitMQ should listen on localhost only
    # @link: https://github.com/StackStorm/st2-packages/blob/a93701d98a130f50f7cb551e842889212ece3b11/scripts/st2bootstrap-deb.sh#L425-L426
    its('content') { should match /^RABBITMQ_NODE_IP_ADDRESS=127.0.0.1$/ }
  end

  describe service('rabbitmq-server') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe port(5672) do
    it { should be_listening }
    its('processes') { should include 'beam.smp' }
    its('addresses') { should eq ['127.0.0.1'] }
    its('protocols') { should cmp 'tcp' }
  end

  # TODO: Security check that 'beam.smp' is not listening on any other ports & IPs
end
