#!/bin/ruby
require 'yaml'
require 'optparse'
require 'fileutils'

CONFIG = YAML.load File.read "#{ENV["XDG_CONFIG_HOME"] || "#{ENV["HOME"]}/.config"}/reasonset/photoutils/photoutils.yaml"

# OPTIONS
op = OptionParser.new
OPTS = {}

op.on("-A", "--noavif")
op.parse!(ARGV, into: OPTS)

FARG = ARGV.shift
raise unless FARG
Dir.chdir FARG
ALBUM_NAME = File.basename Dir.pwd
raise if ALBUM_NAME.empty?

raise unless CONFIG["album_dir"]

DIR_ALBUM = "#{CONFIG["album_dir"]}/photo"
DIR_THUMB = "#{CONFIG["album_dir"]}/photo-thumb/by-album"
DIR_MTHUMB = CONFIG["mini_thumbnail_size"] && "#{CONFIG["album_dir"]}/photo-thumb-mini/by-album"
DIR_VIDEO = CONFIG["video_dir"] || DIR_ALBUM
DIR_VIDEO_THUMB = CONFIG["video_thumbnail_dir"] || DIR_ALBUM
THUMBNAIL_SIZE = CONFIG["thumbnail_size"] || "500x500"
MINI_THUMBNAIL_SIZE = CONFIG["mini_thumbnail_size"]
IM_COMMAND = CONFIG["use_gm"] ? ["gm", "magick"] : ["magick"]

SETTINGS = {
  options: OPTS,
  album_name: ALBUM_NAME,
  dir_album: DIR_ALBUM,
  dir_thumb: DIR_THUMB,
  dir_thumb_mini: DIR_MTHUMB,
  dir_video: DIR_VIDEO,
  dir_vthumb: DIR_VIDEO_THUMB,
  thumb_size: THUMBNAIL_SIZE,
  mthumb_size: MINI_THUMBNAIL_SIZE,
  im_command: IM_COMMAND,
  raw_files: %w:.png .dng .nef .raw:,
  video_files: %w:.mp4 .mov .webm .mkv:,
  magick_files: %w:.jpeg .jpg:
}

FileUtils.mkdir_p File.join(DIR_ALBUM, ALBUM_NAME) unless File.exist? File.join(DIR_ALBUM, ALBUM_NAME)
FileUtils.mkdir_p File.join(DIR_THUMB, ALBUM_NAME) unless File.exist? File.join(DIR_THUMB, ALBUM_NAME)
FileUtils.mkdir_p File.join(DIR_MTHUMB, ALBUM_NAME) if MINI_THUMBNAIL_SIZE && !File.exist?(File.join(DIR_MTHUMB, ALBUM_NAME))
FileUtils.mkdir_p File.join(DIR_VIDEO_THUMB, ALBUM_NAME) if DIR_VIDEO_THUMB && !File.exist?(File.join(DIR_VIDEO_THUMB, ALBUM_NAME))
FileUtils.mkdir_p File.join(DIR_VIDEO, ALBUM_NAME) unless File.exist? File.join(DIR_VIDEO, ALBUM_NAME)

files = Dir.children(".")

master = Ractor.new files, SETTINGS, STDERR do |files, settings, stderr|
  loop do
    i = files.shift
    unless i
      Ractor.yield [nil, nil]
      next
    end

    ext = File.extname(i).downcase
    if settings[:magick_files].include? ext
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
        if settings[:options][:noavif]
          system("cp", "-lv", item[0], File.join(settings[:dir_album], settings[:album_name]))            
        else
          system "avifenc", item[0], File.join(settings[:dir_album], settings[:album_name], (File.basename(item[0], ".*") + ".avif"))
        end
      when :video
        system("cp", "-lv", item[0], File.join(settings[:dir_video], settings[:album_name]))
      when :raw, :unknown
        system("cp", "-lv", item[0], File.join(settings[:dir_album], settings[:album_name]))
      end

      case item[1]
      when :avif, :raw # Generate thumbnail file
        system *settings[:im_command], item[0], "-resize", settings[:thumb_size], File.join(settings[:dir_thumb], settings[:album_name], (File.basename(item[0], ".*") + ".jpeg"))

        # And generate mini thumbnail if mini thumbnail size is set.
        if settings[:mthumb_size]
          system *settings[:im_command], item[0], "-resize", settings[:mthumb_size], File.join(settings[:dir_thumb_mini], settings[:album_name], (File.basename(item[0], ".*") + ".jpeg"))
        end
      when :video
        if settings[:dir_vthumb] # Generate video thumb if video thumbnail directory is set.
          system "ffmpeg", "-y", "-ss", "0:05", "-i", item[0], "-vframes", "1", File.join(settings[:dir_vthumb], settings[:album_name], (File.basename(item[0], ".*") + ".jpeg"))
        end
      end
    end
  end)
end

until rs.empty?
  r, msg = Ractor.select(*rs)
  rs.delete(r)
end

system "jpegoptim", "--max=80", *Dir.glob(File.join DIR_THUMB, ALBUM_NAME, "*.jpeg")
system "jpegoptim", "--max=65", *Dir.glob(File.join DIR_MTHUMB, ALBUM_NAME, "*.jpeg") if MINI_THUMBNAIL_SIZE
