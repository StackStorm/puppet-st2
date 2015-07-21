require 'open-uri'

module Puppet::Parser::Functions
  newfunction(:st2_latest_stable, :type => :rvalue) do |args|
     page = open("https://downloads.stackstorm.net/deb/pool/trusty_stable/main/s/st2api/").read
     page.split.select { |x| x =~ /href=\"st2api/ }.collect { |x| x.scan(/>(.*)</) }.flatten.collect { |x| x.scan(/_(.*)-/).first[0] }.sort_by { |x| x.split('.')[2].to_i * -1 }.sort_by { |x| x.split('.')[1].to_i * -1}.sort_by { |x| x.split('.')[0].to_i * -1}
  end
end
