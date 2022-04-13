#!/bin/bash

config_init "${DOTFILES}/dotm.ini"

for sysfile in ${args[FILE]}; do
  sysfile="${sysfile//\"/}"
  sysfile="$(fs_expanduser "$sysfile")"

  # Check if file exists
  if ! [ -e "$sysfile" ]; then
    lwarn "File or directory $(lscolor "$sysfile") does not exist, it will be skipped"
    continue
  fi

  # Determine file type for logging and attributes
  if [ -d "$sysfile" ]; then type="directory"; else type="file"; fi

  # If file is already a symlink find the real file
  fpath="$sysfile"
  [ -L "$sysfile" ] && fpath="$(realpath "$sysfile")"

  # If the real file is already part of the dotfiles then skip
  if [[ "$fpath" = $DOTFILES/* ]]; then
    lwarn "The $type $(lscolor "$sysfile") is already tracked in the dotfiles"
    continue
  fi

  # Check that the dotfile doesn't already exist
  dotfile="$(fs_dotfile "$sysfile" "${args[--package]}")"
  if [ -e "$dotfile" ]; then
    lwarn "The dotfile $type $(lscolor "$dotfile") already exists"
    continue
  fi

  linfo "Added $type $(lscolor "$sysfile") into the $(bold "${args[--package]}") dotfiles"
done
#
#   dotfile="$(fs_dotfile "$sysfile" "${args[--package]}")"
#   if [[ "$realfile" = $DOTFILES/* ]]; then
#     lwarn "The $type $(lscolor "$sysfile") is already tracked in the dotfiles"
#     continue
#   elif [[ -e "$dotfile" ]]; then
#     if [[ -z "${args[--force]}" ]] && ! confirm "The dotfile $(lscolor "$dotfile") already exists, do you want to overwrite it"; then
#       lwarn "The $type $(lscolor "$sysfile") would overwrite an existing dotfile, skipping"
#       continue
#     else
#       lwarn "Overwriting $type $(lscolor "$dotfile") with $(lscolor "$sysfile")"
#     fi
#   fi
#
#   linfo "Added $type $(lscolor "$sysfile") to the dotfiles"
# done
