#!/bin/zsh

if [[ -n "$1" ]]
then
  cd "$1"
fi

yad --list --multiple --separator="" --column=tag --width=800 --height=800 $(< ~/.config/reasonset/photoutils/tags.list) >| .tags