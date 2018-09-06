# encoding: utf-8

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

control 'st2-repo' do
  title 'StackStorm apt repository check'
  desc '
    Ensure that StackStorm package repository (apt or yum) is installed, enabled and actually works.
  '

  if os.debian?
    describe file '/etc/apt/sources.list.d/StackStorm_stable.list' do
      it { should exist }
    end
  elsif os.redhat?
    describe file '/etc/yum.repos.d/StackStorm_stable.repo' do
      it { should exist }
    end
  end

  if os.debian?
    describe apt('https://packagecloud.io/StackStorm/stable/ubuntu') do
      it { should exist }
      it { should be_enabled }
    end
  elsif os.redhat?
    describe yum.repo('StackStorm_stable') do
      it { should exist }
      it { should be_enabled }
    end
  end
end
