#!/bin/zsh
cat **/.tags | grep -v '^#' | sort -u

