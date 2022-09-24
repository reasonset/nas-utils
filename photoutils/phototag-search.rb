#!/bin/ruby

require 'oj'
require 'depot'

tag = ARGV.shift

if tag
  if tag == "#"
    Depot.new("index.qdbm", Depot::OREADER) do |dbm|
      dbm.keys.each do |key|
        next unless key[0] == "#"
        entries = Oj.load(dbm[key])
        puts "#{key}: #{entries.join(", ")}"
      end
    end
  else
    Depot.new("index.qdbm", Depot::OREADER) do |dbm|
      puts Oj.load(dbm[tag]) rescue abort "No such tag."
    end
  end
else
  Depot.new("index.qdbm", Depot::OREADER) do |dbm|
    puts dbm.keys.reject {|i| i[0] == "#"}
  end
end

