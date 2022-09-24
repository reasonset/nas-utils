#!/usr/bin/ruby
require 'yaml'

confdir = ENV["XDG_CONFIG_HOME"] && !ENV["XDG_CONFIG_HOME"].empty? ? ENV["XDG_CONFIG_HOME"] : "#{ENV["HOME"]}/.config"
conffile = "#{confdir}/reasonset/nas-merge.yaml"

if not File.exist? conffile
  abort "No configuration file found."
end

config = YAML.load File.read conffile
cdir = Dir.pwd

config.each do |server, map|
  map.each do |dir, dest|
    if cdir == dir
      opts = ["-rlv"]
      if dest =~ /\(\#([a-z,]*)\)/
        dest = $`
        options = $1.split(",")
        options.each do |o|
          case o
          when "u"
            opts.push("-u")
          when "del"
            opts.push("--delete")
          when "ix"
            opts.push("--ignore-existing")
          when "fuz"
            opts.push("-y")
          when "X"
            opts.push("-X")
          end
        end
      end
      system("rsync", *opts, "./", "#{server}:#{dest}", exception: true)
      system("rm", "-r", *Dir.glob("*"))
      exit true
    end
  end
end
