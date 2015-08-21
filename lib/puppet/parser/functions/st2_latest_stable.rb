require 'open-uri'

module Puppet::Parser::Functions
  newfunction(:st2_latest_stable, :type => :rvalue) do |args|
     page = open("https://downloads.stackstorm.net/deb/pool/trusty_stable/main/s/st2api/").read
     all_versions = page.split.select { |x| x =~ /href=\"st2api/ }.collect { |x| x.scan(/>(.*)</) }.flatten.collect { |x| x.scan(/_(.*)-/).first[0] }
     max_major = all_versions.max{|a, b| a.split('.')[0].to_i <=> b.split('.')[0].to_i}.split('.')[0]
     reduced_versions = all_versions.find_all{|x| x.split('.')[0] == max_major}
     max_minor = reduced_versions.max{|a, b| a.split('.')[1].to_i <=> b.split('.')[1].to_i}.split('.')[1]
     reduced_versions = all_versions.find_all{|x| x.split('.')[1] == max_minor}
     reduced_versions.max{|a, b| a.split('.')[2].to_i <=> b.split('.')[2].to_i}
  end
end
