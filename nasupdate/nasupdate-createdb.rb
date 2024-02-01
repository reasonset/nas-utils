#!/usr/bin/ruby
require 'find'

db = {}

File.open(".inomap.rbm", "w") do |f|
  Find.find(".") do |i|
    stat = File::Stat.new(i)
    name = i.sub(%r:^\./:, "")

    next if name[0] == "."

    db[stat.ino] = name
  end
  Marshal.dump(db, f)
end