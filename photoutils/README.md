# Synopsis

My local photo util.

# Usage

## Prepare

* Make `photo` and `photo-thumb` directory on same directory.
* Stock your pictures on `photo/${album}`.

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

## Compress and move video

Do `videocompress.zsh` on your album directory.

Compressed video is output on `${VIDEO_DIR}/by-album/${album}`.
`$VIDEO_DIR` is XDG Video directory. You can override it with `$PU_VIDEODIR`.

*It remove original videos when complete.*

This script supports options:

* `PU_USEVP9` : If set `yes`, use libvpx-vp9 instead of libx265.
* `PU_X265CRF` : Set libx265 CRF value (default 23)
* `PU_VP9CRF` : Set libvpx-vp9 CRF value (default 30)
* `PU_OPUSABR` : Set libopus audio bitrate (default 128k)
* `PU_THUMBNAIL_SIZE` : Set resize paramater generating thumbnail with ImageMagick.
