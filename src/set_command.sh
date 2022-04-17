#!/bin/bash

section="$(config_resolve "$CONFIG_FILE" "${args[packages]}")"

for key in $(section_keys "$section"); do
  dotfile="${key#*:}"
  dotfile="$DOTFILES/$dotfile"

  sysfile="$(section_get "$section" "$key")"
  sysfile="$(fs_expanduser "$sysfile")"

  if [ -L "$sysfile" ] && [ "$(realpath "$sysfile")" == "$dotfile" ]; then
    continue
  fi

  if ! link_set "$dotfile" "$sysfile" "${args[--force]}"; then
    continue
  fi
done
