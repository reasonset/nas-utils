#!/bin/ruby
require 'yaml'


CONFIG = YAML.load File.read "#{ENV["XDG_CONFIG_HOME"] || "#{ENV["HOME"]}/.config"}/reasonset/photoutils/photoutils.yaml"

ALBUM_NAME = ARGV.shift
raise unless ALBUM_NAME

raise unless CONFIG["album_dir"]

DIR_ALBUM = "#{CONFIG["album_dir"]}/photo"
DIR_THUMB = "#{CONFIG["album_dir"]}/photo-thumb/by-album"
DIR_VIDEO = CONFIG["video_dir"] || DIR_ALBUM
SETTINGS = {
  album_name: ALBUM_NAME,
  dir_album: DIR_ALBUM,
  dir_thumb: DIR_THUMB,
  dir_video: DIR_VIDEO,
  raw_files: %w:.png .dng .nef .raw:,
  video_files: %w:.mp4 .mov .webm .mkv:,
  convert_files: %w:.jpeg .jpg:
}

Dir.mkdir File.join(DIR_ALBUM, ALBUM_NAME) unless File.exist? File.join(DIR_ALBUM, ALBUM_NAME)
Dir.mkdir File.join(DIR_THUMB, ALBUM_NAME) unless File.exist? File.join(DIR_THUMB, ALBUM_NAME)
Dir.mkdir File.join(DIR_VIDEO, ALBUM_NAME) unless File.exist? File.join(DIR_VIDEO, ALBUM_NAME)

files = Dir.children(".")

master = Ractor.new files, SETTINGS, STDERR do |files, settings, stderr|
  loop do
    i = files.shift
    unless i
      Ractor.yield [nil, nil]
      next
    end

    ext = File.extname(i).downcase
    if settings[:convert_files].include? ext
      Ractor.yield [i, :avif]
    elsif settings[:raw_files].include? ext
      Ractor.yield [i, :raw]
    elsif settings[:video_files].include? ext
      Ractor.yield [i, :video]
    else
      stderr.puts "File #{i} is not known. Link it."
      Ractor.yield [i, :unknown]
    end
  end
end

rs = []

(CONFIG["workers"] || 8).times do
  rs.push(Ractor.new(master, SETTINGS, CONFIG) do |master, settings, config|
    loop do
      item = master.take
      break nil unless item[0]
      case item[1]
      when :avif
        system "avifenc", item[0], File.join(settings[:dir_album], settings[:album_name], (File.basename(item[0], ".*") + ".avif"))
      when :video
        system("cp", "-lv", item[0], File.join(settings[:dir_video], settings[:album_name]))
      when :raw, :unknown
        system("cp", "-lv", item[0], File.join(settings[:dir_album], settings[:album_name]))
      end

      case item[1]
      when :avif, :raw
        system "convert", "-resize", (config["thumbnail_size"] || "360x360"), item[0], File.join(settings[:dir_thumb], settings[:album_name], (File.basename(item[0], ".*") + ".jpeg"))
      end
    end
  end)
end

until rs.empty?
  r, msg = Ractor.select(*rs)
  rs.delete(r)
end

system "jpegoptim", *Dir.glob(File.join DIR_THUMB, ALBUM_NAME, "*.jpeg")
