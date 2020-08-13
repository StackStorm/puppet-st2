# encoding: utf-8

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

ST2_API_SERVICES = ['api', 'auth', 'stream'].freeze

control 'st2web' do
  title 'Integrity check'
  desc '
    Check that st2web is installed, dependant service nginx is running with the correct st2.conf
    web config, stackstorm REST API URL endpoints are available and Web UI actually works.
  '

  # Only one of the 2 expressions should succeed
  describe.one do
    describe package('st2web') do
      it { should be_installed }
    end
    describe package('bwc-ui') do
      it { should be_installed }
    end
  end

  # TODO: Extract nginx rules into a separated control
  describe package('nginx') do
    it { should be_installed }
  end

  # nginx version should be >= '1.7.5' for st2web to work
  describe nginx do
    its('version') { should cmp >= '1.7.5' }
  end

  describe service('nginx') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe port(80) do
    it { should be_listening }
    its('processes') { should include 'nginx' }
    its('addresses') { should include '0.0.0.0' }
    its('protocols') { should cmp 'tcp' }
  end

  describe port(443) do
    it { should be_listening }
    its('processes') { should include 'nginx' }
    its('addresses') { should include '0.0.0.0' }
    its('protocols') { should cmp 'tcp' }
  end

  describe directory('/etc/ssl/st2') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
  end

  describe file('/etc/ssl/st2/st2.crt') do
    it { should exist }
  end

  describe file('/etc/ssl/st2/st2.key') do
    it { should exist }
  end

  describe x509_certificate('/etc/ssl/st2/st2.crt') do
    its('validity_in_days') { should be > 90 }
  end

  describe file('/etc/nginx/conf.d/sites-available/st2webui.conf') do
    it { should exist }
  end
  describe file('/etc/nginx/conf.d/sites-available/ssl-st2webui.conf') do
    it { should exist }
  end
  describe file('/etc/nginx/conf.d/sites-enabled/st2webui.conf') do
    it { should exist }
  end
  describe file('/etc/nginx/conf.d/sites-enabled/ssl-st2webui.conf') do
    it { should exist }
  end

  # TODO: redo with https://www.inspec.io/docs/reference/resources/nginx_conf/
  # Doesn't work now
  # describe nginx_conf.http do
  # should match: include /etc/nginx/conf.d/*.conf;
  # end

  describe file('/etc/nginx/nginx.conf') do
    its('content') { should match 'include /etc/nginx/conf.d/\*.conf;' }
  end

  describe http('http://localhost/', enable_remote_worker: true) do
    its('status') { should eq 301 }
  end

  describe http('https://localhost/', ssl_verify: false, enable_remote_worker: true) do
    its('status') { should cmp 200 }
    its('body') { should match %r{st2constants} }
  end

  # StackStorm API URL endpoints check, defined in nginx
  ST2_API_SERVICES.each do |service|
    describe http("https://localhost/#{service}/", ssl_verify: false, enable_remote_worker: true) do
      its('headers.content-type') { should cmp 'application/json' }
      its('headers.access-control-allow-headers') { should match %r{St2-Api-Key} }
    end
  end
end
