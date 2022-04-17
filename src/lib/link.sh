#!/bin/bash

## Set the links to the file/directory
## Usage:
##   link_set "dotfile" "sysfile" "force"
link_set() {
  local dotfile="$1"
  local sysfile="$2"
  local force="$3"

  [ -d "$(dirname "$sysfile")" ] || mkdir -p "$(dirname "$sysfile")"

  if [ -e "$sysfile" ] && [ -z "$force" ]; then
    if ! [ "$(fs_hash "$sysfile")" == "$(fs_hash "$dotfile")" ]; then
      lwarn "There is a conflict etween $(lscolor "$dotfile") and $(lscolor "$sysfile")"
      while true; do
        action="$(pselect "How do you want to resolve the conflict" "Skip the file;Keep the original;Take the new file;Compare the files")"
        if [ -z "$action" ] || [ "$action" == "Skip the file" ]; then
          return 0
        elif [ "$action" == "Keep the original" ]; then
          rm -rf "$dotfile"
          link_import "$sysfile" "$dotfile" "$force"
          return $?
        elif [ "$action" == "Take the new file" ]; then
          break
        elif [ "$action" == "Compare the files" ]; then
          diff --minimal --recursive --color=auto "$sysfile" "$dotfile" 1>&2
        fi
      done
    fi
  fi

  [ -e "$sysfile" ] && rm -rf "$sysfile"

  # TODO: Implement support for archives and encryption
  ln -s "$dotfile" "$sysfile"

  linfo "Set the dotfile link $(lscolor "$sysfile")"
  return 0
}

## Install file/directory from the dotfiles
## Usage:
##   link_install "dotfile" "sysfile" "force"
link_install() {
  local dotfile="$1"
  local sysfile="$2"
  local force="$3"

  [ -d "$(dirname "$sysfile")" ] || mkdir -p "$(dirname "$sysfile")"

  if [ -e "$sysfile" ] && [ -z "$force" ]; then
    if ! [ "$(fs_hash "$sysfile")" == "$(fs_hash "$dotfile")" ]; then
      lwarn "There is a conflict etween $(lscolor "$dotfile") and $(lscolor "$sysfile")"
      while true; do
        action="$(pselect "How do you want to resolve the conflict" "Skip the file;Take the new file;Compare the files")"
        if [ -z "$action" ] || [ "$action" == "Skip the file" ]; then
          return 0
        elif [ "$action" == "Take the new file" ]; then
          break
        elif [ "$action" == "Compare the files" ]; then
          diff --minimal --recursive --color=auto "$sysfile" "$dotfile" 1>&2
        fi
      done
    fi
  fi

  [ -e "$sysfile" ] && rm -rf "$sysfile"

  # TODO: Implement support for archives and encryption
  cp -r "$dotfile" "$sysfile"

  linfo "Installed the dotfile to $(lscolor "$sysfile")"
  return 0
}

## Import file/directory into the dotfiles
## Usage:
##   link_import "sysfile" "dotfile" "force"
link_import() {
  local sysfile="$1"
  local dotfile="$2"
  local force="$3"

  [ -d "$(dirname "$dotfile")" ] || mkdir -p "$(dirname "$dotfile")"

  if [ -e "$dotfile" ] && [ -z "$force" ]; then
    if ! [ "$(fs_hash "$dotfile")" == "$(fs_hash "$sysfile")" ]; then
      lwarn "There is a conflict between $(lscolor "$sysfile") and $(lscolor "$dotfile")"
      while true; do
        action="$(pselect "How do you want to resolve the conflict" "Skip the file;Keep the original;Take the new file;Compare the files")"
        if [ -z "$action" ] || [ "$action" == "Skip the file" ]; then
          return 0
        elif [ "$action" == "Keep the original" ]; then
          rm -rf "$sysfile"
          link_set "$dotfile" "$sysfile" "$force"
          return $?
        elif [ "$action" == "Take the new file" ]; then
          break
        elif [ "$action" == "Compare the files" ]; then
          diff --minimal --recursive --color=auto "$dotfile" "$sysfile" 1>&2
        fi
      done
    fi
  fi

  [ -e "$dotfile" ] && rm -rf "$dotfile"

  # TODO: Implement support for archives and encryption
  mv "$sysfile" "$dotfile"
  ln -s "$dotfile" "$sysfile"
  return 0
}
