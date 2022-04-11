#!/bin/bash

## Expand the user component of a given path
## Usage: fs_expanduser "~/.zshrc"
fs_expanduser() {
  echo "${1/~/$HOME}"
}

## Get the path relative to the user home dir
## Usage: fs_reluser "/home/user/.zshrc"
fs_reluser() {
  echo "${1/$HOME/~}"
}

## Get the dotfile equivalent of a system path
## Usage: fs_dotfile "/home/user/.zshrc"
fs_dotfile() {
  local rel="$(fs_reluser "$1")"
  local pkg="$2"
  local fname="$(basename "$rel")"
  rel="${rel#~/}"
  fname="${fname#.}"

  local res=""
  if [ -n "$pkg" ]; then
    res="$DOTFILES$(dirname "$rel")/$pkg.$fname"
  else
    res="$DOTFILES$(dirname "$rel")/$fname"
  fi
  echo "${res/\/.\//\/}"
}
