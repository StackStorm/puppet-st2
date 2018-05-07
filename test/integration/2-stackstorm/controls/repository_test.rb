# encoding: utf-8
# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

control 'st2-repo' do
  title 'StackStorm apt repository check'
  desc '
    Ensure that stackstorm apt package repository is installed, enabled and actually works.
  '

  describe file '/etc/apt/sources.list.d/StackStorm_stable.list' do
    it { should exist }
  end

  describe apt('https://packagecloud.io/StackStorm/stable/ubuntu/') do
    it { should exist }
    it { should be_enabled }
  end
end
