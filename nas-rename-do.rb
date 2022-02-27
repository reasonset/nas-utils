#!/usr/bin/ruby
require 'yaml'

list = YAML.load ARGF

list.each do |source, dest|
  next if source == dest
  puts "#{source} --> #{dest}"
  File.rename source, dest
end