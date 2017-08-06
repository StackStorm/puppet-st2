source 'https://rubygems.org'

build_name = ENV['BUILD_NAME']
puppetversion = ENV['PUPPET_VERSION']

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

if build_name and build_name == 'Ubuntu 16'
  gem 'syck'
end

### ADD USER GEMS HERE ###

