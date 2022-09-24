#!/bin/ruby

require 'oj'
require 'depot'

lib = Hash.new

Dir.glob("**/.tags") do |fp|
  album = File.basename(File.dirname(fp))
  File.foreach(fp) do |line|
    tag = line.chomp
    lib[tag] ||= []
    lib[tag].push album
  end
end

Depot.new("index.qdbm", Depot::OWRITER | Depot::OCREAT) do |dbm|
  lib.each do |k, v|
    dbm[k] = Oj.dump(v)
  end
end
