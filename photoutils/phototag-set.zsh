#!/bin/zsh

yad --list --multiple --separator="" --column=tag --width=800 --height=800 $(< ~/.config/reasonset/photoutils/tags.list) >| .tags