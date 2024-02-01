require 'yaml'
require 'fileutils'

map = YAML.load(ARGF.read)
map.each do |k, v|
  unless File.exist? File.dirname v
    FileUtils.mkpath File.dirname v
  end

  if File.exist? v
    abort "File path #{v} is alread exist."
  end

  File.rename k, v
end