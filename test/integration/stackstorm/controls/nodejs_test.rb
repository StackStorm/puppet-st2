# encoding: utf-8

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

control 'nodejs' do
  title 'Minimal package integrity check'
  desc '
    Basic check that NodeJS  package is installed.
  '

  describe package('nodejs') do
    it { should be_installed }
    its('version') { should cmp >= '10.0' }
  end
end
