# encoding: utf-8
# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

control 'system-packages' do
  title 'Verify system packages'
  desc '
    Ensure that required packages are installed.
  '

  describe package('curl') do
    it { should be_installed }
  end

  describe package('git') do
    it { should be_installed }
  end
end
