# Synopsis

My local photo util.

# Dependency

* Ruby >=3.1
* 

# Usage

## Prepare

* Create photo album directory has `photo`, `photo-thumb` and optional `photo-thumb-mini` directories.
* Make config file at `{XDG_CONFIG_HOME:-$HOME/.config}/reasonset/photoutils/photoutils.yaml`

## Config File

|key|type|description|
|----------|-----|------------------|
|`album_dir`|String|Photo album directory|
|`video_dir`|String|Video album directory (link destination)|
|`video_thumbnail_dir`|String|Video thumbnail directory. If null, don't generate video thumbnail|
|`workers`|Integer|Number of workers (8 by default)|
|`thumbnail_size`|String|Thumbnail limit size (ImageMagick option, 500x500 by default)|
|`mini_thumbnail_size`|String|Sub thumbnail limit size (ImageMagick option.) If null, don't generate mini thumbnail.|
|`use_gm`|Boolean|Use GraphicMagick instread of ImageMagick for generating thumbnail|


## Compress

Do `photocompress.zsh` on album directory.

## Write tag

Write tag lines to `photo-thumb/by-album/${album}/.tags`.

Tags should be written on each line.

Tag started with "#" is a special. Hash tag can specfic list with `phototag-search.rb "#"`.

## Create DB

Do `phototag-update.rb` on `photo-thumb/by-album` directory.

## List tags

Do `phototag-search.rb` on `photo-thumb/by-album` directory.

## Search albums

Do `phototag-search.rb ${tag}` on `photo-thumb/by-album` directory.

## Right click for Nemo

Copy `photoutils.nemo_action` and `photoutils.zsh` to `~/.local/share/nemo/actions/`.

## Config nemo action script

Write `${XDG_CONFIG_DIR:-$HOME/.config}/reasonset/photoutils.rc` like thus:

```zsh
PU_EDITOR=xed
PU_TERMINAL=(gnome-terminal --)
PU_USEVP9=no
PU_VP9CRF=30
PU_X265CRF=23
PU_OPUSABR=128k
PU_THUMBNAIL_SIZE=500x500
```
