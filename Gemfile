source 'https://rubygems.org'

puppet_version = ENV['PUPPET_VERSION']
test_kitchen_enabled = ENV['TEST_KITCHEN_ENABLED']
r10k_version = ENV['R10K_VERSION']

if puppet_version
  gem 'puppet', puppet_version, :require => false
else
  gem 'puppet', :require => false
end

gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'puppet-lint',            '>= 0.3.2'
gem 'facter',                 '>= 1.7.0'

gem 'coveralls', :require => false

gem 'puppet-blacksmith',      '>= 3.1.1'

if r10k_version
  gem 'r10k', r10k_version
else
  gem 'r10k', '>= 2.0.0'
end

# Gems for kitchen ci
if test_kitchen_enabled != 'false'
  gem 'test-kitchen'
  gem 'librarian-puppet'
  gem 'kitchen-puppet'
  gem 'kitchen-docker'
  gem 'kitchen-sync'
end

### ADD USER GEMS HERE ###

