source 'https://rubygems.org'

puppet_version = ENV['PUPPET_VERSION']
test_kitchen_enabled = ENV['TEST_KITCHEN_ENABLED']
r10k_version = ENV['R10K_VERSION']
kitchen_sync_version = ENV['KITCHEN_SYNC_VERSION']
puppetlabs_spec_helper_version = ENV['PUPPETLABS_SPEC_HELPER_VERSION']

if puppet_version
  gem 'puppet', puppet_version, :require => false
else
  gem 'puppet', :require => false
end

if puppetlabs_spec_helper_version
  gem 'puppetlabs_spec_helper', puppetlabs_spec_helper_version
else
  gem 'puppetlabs_spec_helper',                                  '>= 0.1.0'
end
gem 'puppet-lint',                                               '>= 0.3.2'
gem 'facter',                                                    '>= 1.7.0'
gem 'puppet-lint-absolute_classname-check',                      '>= 0.2.4'
gem 'puppet-lint-absolute_template_path',                        '>= 1.0.1'
gem 'puppet-lint-alias-check',                                   '>= 0.1.1'
gem 'puppet-lint-classes_and_types_beginning_with_digits-check', '>= 0.1.2'
gem 'puppet-lint-concatenated_template_files-check',             '>= 0.1.1'
gem 'puppet-lint-file_ensure-check',                             '>= 0.3.1'
gem 'puppet-lint-file_source_rights-check',                      '>= 0.1.1'
gem 'puppet-lint-leading_zero-check',                            '>= 0.1.1'
gem 'puppet-lint-resource_reference_syntax',                     '>= 1.0.10'
gem 'puppet-lint-trailing_comma-check',                          '>= 0.3.2'
gem 'puppet-lint-unquoted_string-check',                         '>= 0.3.0'
gem 'puppet-lint-version_comparison-check',                      '>= 0.2.1'

gem 'coveralls', :require => false

gem 'puppet-blacksmith',                                         '>= 3.1.1'

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
  if kitchen_sync_version
    gem 'kitchen-sync', kitchen_sync_version
  else
    gem 'kitchen-sync'
  end
end

### ADD USER GEMS HERE ###

