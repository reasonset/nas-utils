#!/usr/bin/ruby

Dir.children(".").sort.each do |i|
  next unless File.directory? i
  puts i unless File.exist?("#{i}/.tags")
end
