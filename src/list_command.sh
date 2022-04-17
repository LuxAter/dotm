#!/bin/bash

section=""
if [ -z "${args[--all]}" ]; then
  section="$(config_resolve "$CONFIG_FILE" "${args[packages]}")"
else
  for key in $(config_keys "$CONFIG_FILE"); do
    section="${section}$(config_get "$CONFIG_FILE" "$key")\n"
  done
fi

for key in $(section_keys "$section"); do
  pdotfile="${key#*:}"
  dotfile="$DOTFILES/$pdotfile"

  psysfile="$(section_get "$section" "$key")"
  sysfile="$(fs_expanduser "$psysfile")"

  if [ -z "${args[--raw]}" ]; then
    if ! [ -e "$sysfile" ]; then
      lwarn "$(lscolor "$pdotfile") $(redBold "->") $(lscolor "$psysfile")"
    elif [ -L "$sysfile" ] && [ "$(realpath "$sysfile")" == "$dotfile" ]; then
      linfo "$(lscolor "$pdotfile") $(greenBold "->") $(lscolor "$psysfile")"
    elif [ "$(fs_hash "$sysfile")" == "$(fs_hash "$dotfile")" ]; then
      linfo "$(lscolor "$pdotfile") $(blueBold "->") $(lscolor "$psysfile")"
    else
      linfo "$(lscolor "$pdotfile") $(yellowBold "->") $(lscolor "$psysfile")"
    fi
  else
    if [ -L "$sysfile" ] && [ "$(realpath "$sysfile")" == "$dotfile" ]; then
      printf '%s\n' "$sysfile"
    elif [ "$(fs_hash "$sysfile")" == "$(fs_hash "$dotfile")" ]; then
      printf '%s\n' "$sysfile"
    fi
  fi
done
