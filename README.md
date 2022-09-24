# nas-utils
Personal utilities for massive btrfs storage.

# Usage

## nas-rename

Bulk rename with hand specified map.

Create YAML with `nas-rename-gen.rb` on target directory.

```bash
nas-rename-gen.rb > /tmp/rename.yaml
```

Edit Rename file mapping.

`nas-rename-do.rb` with editted map YAML.

```bash
nas-rename-do.rb /tmp/rename.yaml
```

## encfs-filename-shoten

Shoten filename for EncFS.

## nas-merge

Copy to remote server with rsync and clear current directory for rrsync destination (instead of `mv`).

For example, write `~/.config/reasonset/nas-merge`:

```yaml
---
  NAS:
    /home/jrh/foo/bar: /archives/foo/bar/
```

When it run on `/home/jrh/foo/bar`, this script run `rsync -rlv ./ NAS:/archives/foo/bar/`, and `rm -r *` if rsync exit with `0`.

Destination path are able to include flags like `(#x,y,z)` on tail of path.
For example, `/archives/foo/bar(#del,ix)` means `rsync -rlv --delete --ignore-existing`.

|Flag|rsync Option|
|------|--------------|
|`u`|`-u`|
|`del`|`--delete`|
|`ix`|`--ignore-existing`|
|`fuz`|`-y`|
|`X`|`-X`|


