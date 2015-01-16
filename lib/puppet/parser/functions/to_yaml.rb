require 'yaml'

module Puppet::Parser::Functions
  newfunction(:to_yaml, :type => :rvalue) do |args|
    args[0].to_yaml
  end
end
