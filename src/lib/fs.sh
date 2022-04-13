#!/bin/bash

## Expand the user component of a given path
## Usage: fs_expanduser "~/.zshrc"
fs_expanduser() {
  echo "${1/"~"/$HOME}"
}

## Get the path relative to the user home dir
## Usage: fs_reluser "/home/user/.zshrc"
fs_reluser() {
  echo "${1/$HOME/"~"}"
}

## Get the dotfile equivalent of a system path
## Usage: fs_dotfile "/home/user/.zshrc"
fs_dotfile() {
  local rel="$(fs_reluser "$1")"
  local pkg="$2"
  local fname="$(basename "$rel")"
  rel="${rel#"~/"}"
  rel="${rel#"/"}"
  fname="${fname#.}"

  local res=""
  if [ -n "$pkg" ]; then
    res="$DOTFILES/$(dirname "$rel")/$pkg.$fname"
  else
    res="$DOTFILES/$(dirname "$rel")/$fname"
  fi
  echo "${res/\/.\//\/}"
}

## Get the md5 hash of a file or directory
## Usage: hash="$(fs_hash "/home/user/.zshrc")"
fs_hash() {
  if [ -f "$1" ]; then
    openssl md5 "$1" | cut -d' ' -f2
  elif [ -d "$1" ]; then
    find "$1" -type f -exec cat {} \; | openssl md5 | cut -d' ' -f2
  else
    echo "d41d8cd98f00b204e9800998ecf8427e"
  fi
}
