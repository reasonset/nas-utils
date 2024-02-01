#!/bin/ruby
require 'yaml'
require 'set'

attr = ARGV.shift

unless attr
  abort <<-EOF
books-pickattr.rb [attr]

Attrs are avilable:
  publisher
  label
  shelf
  tags
  EOF
end

lib = YAML.load File.read "booklib.yaml"

attrs = Set.new

lib.each do |k, i|
  next unless i[attr]
  if Array === i[attr]
    attrs += i[attr]
  else
    attrs << i[attr]
  end
end

puts attrs.to_a.sort