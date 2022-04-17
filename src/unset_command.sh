#!/bin/bash

section="$(config_resolve "$CONFIG_FILE" "${args[packages]}")"

for key in $(section_keys "$section"); do
  dotfile="${key#*:}"
  dotfile="$DOTFILES/$dotfile"

  sysfile="$(section_get "$section" "$key")"
  sysfile="$(fs_expanduser "$sysfile")"

  if [ -L "$sysfile" ] && [ "$(realpath "$sysfile")" == "$dotfile" ]; then
    rm -rf "$sysfile"
    linfo "Unset the dotfile link to $(lscolor "$sysfile")"
  else
    lwarn "The system path $(lscolor "$sysfile") is not part of the dotfiles"
  fi
done
