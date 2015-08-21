require 'open-uri'

module Puppet::Parser::Functions
  newfunction(:st2_latest_stable_revision, :type => :rvalue) do |args|
    version = args[0]
    type    = args[1]
    auto_update = args[2] || true
    revision = open("https://downloads.stackstorm.net/releases/st2/#{version}/#{type}/current/VERSION.txt").read.chomp
  end
end
