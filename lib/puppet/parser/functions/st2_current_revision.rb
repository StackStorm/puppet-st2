require 'open-uri'

module Puppet::Parser::Functions
  newfunction(:st2_current_revision, :type => :rvalue) do |args|
    version = args[0]
    type    = args[1]
    auto_update = args[2] || true

    # Move this external to this function
    sticky_versions = {
      '0.5.1' => '351'
    }

    if auto_update
      revision = open("https://downloads.stackstorm.net/releases/st2/#{version}/#{type}/current/VERSION.txt").read.chomp
    else
      revision = sticki_versions[version]
    end
  end
end
