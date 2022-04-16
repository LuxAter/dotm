#!/bin/bash

config_init "${DOTFILES}/dotm.ini"

section="$(config_get "${args[--package]}" || true)"

for sysfile in ${args[FILE]}; do
  sysfile="${sysfile//\"/}"
  sysfile="$(fs_expanduser "$sysfile")"

  ## Check if file exists
  if ! [ -e "$sysfile" ]; then
    lwarn "File or directory $(lscolor "$sysfile") does not exist, it will be skipped"
    continue
  fi

  ## Determine file type for logging and attributes
  if [ -d "$sysfile" ]; then type="directory"; else type="file"; fi

  ## If file is already a symlink find the real file
  fpath="$sysfile"
  [ -L "$sysfile" ] && fpath="$(realpath "$sysfile")"

  ## If the real file is already part of the dotfiles then skip
  if [[ "$fpath" = $DOTFILES/* ]]; then
    lwarn "The $type $(lscolor "$sysfile") is already tracked in the dotfiles"
    continue
  fi

  ## Check that the dotfile doesn't already exist
  dotfile="$(fs_dotfile "$sysfile" "${args[--package]}")"
  if [ -e "$dotfile" ] && ! [ "$(fs_hash "$dotfile")" = "$(fs_hash "$fpath")" ]; then
    lwarn "The dotfile $type $(lscolor "$dotfile") already exists"

    if [ -z "${args[--force]}" ] && ! confirm "Do you want to overwrite the dotfile $(lscolor "$dotfile")"; then
      continue
    fi
  fi

  attrib=""

  if [[ -n "${args[--copy]}" || -n "${args[--archive]}" || -n "${args[--encrypt]}" ]]; then
    attrib="C"
  fi

  ## Handle the archive attribute first
  ## Also archive if doing encryption on a directory
  if [[ -n "${args[--archive]}" || (-n "${args[--encrypt]}" && -d "$sysfile") ]]; then
    if ! tar -czf "$fpath.tgz" "$fpath" &>/dev/null; then
      lerror "Failed to create archive for $(lscolor "$fpath")"
      continue
    fi
    fpath="$fpath.tgz"
    attrib="${attrib}X"
  fi

  ## Handle the encryption attribute second
  if [ -n "${args[--encrypt]}" ]; then
    pswd="$(password "Enter encryption password")"
    [ -z "$pswd" ] && continue
    if ! openssl enc -aes-256-cbc -pass "pass:$pswd" -in "$fpath" -out "$fpath.enc" &>/dev/null; then
      lerror "Failed to encrypt $(lscolor "$fpath")"
      continue
    fi
    fpath="$fpath.enc"
    attrib="${attrib}E"
  fi

  # Copy the file into the dotfiles
  [ -d "$(dirname "$dotfile")" ] || mkdir -p "$(dirname "$dotfile")"
  cp "$fpath" "$dotfile"

  ## Add the new file into the configuration
  section="$(section_set ":$attrib:$(fs_reldot "$dotfile")" "$(fs_reluser "$sysfile")" "$section")"

  ## Clenup any temporary .enc or .tgz files created
  if [[ -n "${args[--encrypt]}" && "$fpath" = *.enc && -e "$fpath" ]]; then
    rm -rf "$fpath"
    fpath="${fpath%.enc}"
  fi

  if [[ -n "${args[--archive]}" && "$fpath" = *.tgz && -e "$fpath" ]]; then
    rm -rf "$fpath"
    fpath="${fpath%.tgz}"
  fi

  ## Create the link if neccessary
  if [ -z "$attrib" ]; then
    rm -rf "$fpath"
    link_set "$attrib" "$(fs_reldot "$dotfile")" "$(fs_reluser "$sysfile")" "${args[--force]}" || continue
  fi

  linfo "Added $type $(lscolor "$sysfile") into the $(bold "${args[--package]}") dotfiles"
done

config_set "${args[--package]}" "$section"
