#!/bin/ruby
require 'yaml'

library = nil
booksdir = ARGV.shift

if !booksdir || !File.exist?(booksdir)
  abort "Books directory #{booksdir} is not exist."
end

unless File.exist? "booklib.yaml"
  print "Book library is not exist. Do you want to create new library? [y/N] "
  ans = gets
  print "\n"
  unless ans && ans =~ /^[Yy]/
    abort "Exiting..."
  end
  library = {}
else
  library = YAML.load File.read "booklib.yaml"
end

books = Dir.children(booksdir).sort
books.each do |i|
  next unless File.directory?("#{booksdir}/#{i}")
  unless library[i]
    library[i] = {
      "title" => i,
      "volume" => nil,
      "edition" => nil,
      "authors" => [],
      "publisher" => "",
      "year" => 0,
      "label" => "",
      "shelf" => "",
      "tags" => []
    }
    puts i
  end
end

File.open("booklib.yaml", "w") do |f|
  YAML.dump library, f
end