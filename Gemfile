source 'https://rubygems.org'

puppetversion = ENV['PUPPET_VERSION']
test_kitchen_enabled = ENV['TEST_KITCHEN_ENABLED']

if puppetversion
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'puppet-lint',            '>= 0.3.2'
gem 'facter',                 '>= 1.7.0'

gem 'coveralls', :require => false

gem 'puppet-blacksmith',      '>= 3.1.1'

gem 'r10k'

# Gems for kitchen ci
if test_kitchen_enabled != 'false'
  gem 'test-kitchen'
  gem 'librarian-puppet'
  gem 'kitchen-puppet'
  gem 'kitchen-docker'
  gem 'kitchen-sync'
end

### ADD USER GEMS HERE ###

