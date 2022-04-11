#!/bin/bash
inspect_args

config_init "${DOTFILES}dotm.ini"

for sysfile in ${args[FILE]}; do
  sysfile="${sysfile//\"/}"
  sysfile="$(fs_expanduser "$sysfile")"
  realfile="$sysfile"
  type="file"
  [ -e "$sysfile" ] || continue
  if [ -d "$sysfile" ]; then
    type="directory"
  fi

  if [[ -L "$sysfile" ]]; then
    realfile="$(realpath "$sysfile")"
  fi

  dotfile="$(fs_dotfile "$sysfile" "${args[--package]}")"
  if [[ "$realfile" = $DOTFILES/* ]]; then
    lwarn "The $type $(lscolor "$sysfile") is already tracked in the dotfiles"
    continue
  elif [[ -e "$dotfile" ]]; then
    if [[ -z "${args[--force]}" ]] && ! confirm "The dotfile $(lscolor "$dotfile") already exists, do you want to overwrite it"; then
      lwarn "The $type $(lscolor "$sysfile") would overwrite an existing dotfile, skipping"
      continue
    else
      lwarn "Overwriting $type $(lscolor "$dotfile") with $(lscolor "$sysfile")"
    fi
  fi

  linfo "Added $type $(lscolor "$sysfile") to the dotfiles"
done
