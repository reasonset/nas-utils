#!/usr/bin/ruby
require 'yaml'

list = {}

Dir.children(".").each do |k|
  list[k] = k
end

YAML.dump list, STDOUT