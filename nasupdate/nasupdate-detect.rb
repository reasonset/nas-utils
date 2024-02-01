#!/usr/bin/ruby
require 'find'
require 'yaml'

map = {}

File.open(".inomap.rbm") do |f|
  db = Marshal.load(f)
  Find.find(".") do |i|
    stat = File::Stat.new(i)
    name = i.sub(%r:^\./:, "")

    next if name[0] == "."

    entity = db[stat.ino]
    next unless entity
    if entity != name
      map[entity] = name
    end
  end
end

YAML.dump(map, $stdout)