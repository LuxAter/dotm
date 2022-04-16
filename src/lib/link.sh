#!/bin/bash

## Create a new dotfile link
## Usage: link_set "attrib" "dotfile" "sysfile" "force"
link_set() {
  local attrib="$1"
  local dotfile="$DOTFILES/$2"
  local sysfile="$(fs_expanduser "$3")"
  local tmpfile="$sysfile"
  local force="$4"

  [ -d "$(dirname "$sysfile")" ] || mkdir -p "$(dirname "$sysfile")"

  if [[ "$attrib" = *X* ]]; then
    tmpfile="$tmpfile.tgz"
  fi
  if [[ "$attrib" = *E* ]]; then
    tmpfile="$tmpfile.tgz"
  fi

  ## Handle the file copy or link creation
  # TODO: Improve choices for overwriting. Pick from a list of overwrite, skip, compare diff, and backup
  if [[ "$attrib" = *C* ]]; then
    if ! [ -e "$tmpfile" ]; then
      cp -r "$dotfile" "$tmpfile"
    elif ! [[ "$(fs_hash "$dotfile")" = "$(fs_hash "$tmpfile")" ]]; then
      if [ -z "$force" ] && ! confirm "Do you want to overwrite $(lscolor "$tmpfile")"; then
        return 0
      fi
      rm -rf "$tmpfile"
      cp -r "$dotfile" "$tmpfile"
    fi
  else
    if ! [ -e "$tmpfile" ]; then
      ln -s "$dotfile" "$tmpfile"
    elif ! [ "$(realpath "$tmpfile")" = "$dotfile" ]; then
      if [ -z "$force" ] && ! confirm "Do you want to overwrite $(lscolor "$tmpfile")"; then
        return 0
      fi
      rm -rf "$tmpfile"
      ln -s "$dotfile" "$tmpfile"
    fi
  fi

  # If the file was encrypted handle the decryption
  if [[ "$attrib" = *E* ]]; then
    pswd="$(password "Enter encryption password")"
    if [ -z "$pswd" ]; then
      [ -e "$tmpfile" ] && rm -f "$tmpfile"
      return 0
    fi
    if ! openssl enc -aes-256-cbc -pass "pass:$pswd" -d -in "$tmpfile" -out "${tmpfile%.enc}" &>/dev/null; then
      lerror "Failed to decrypt $(lscolor "$tmpfile")"
      return 1
    fi
    tmpfile="${tmpfile%.enc}"
  fi

  # If the file was an archive remove the original and extract the archive.
  if [[ "$attrib" = *X* ]]; then
    if [ -e "${tmpfile%.tgz}" ]; then
      if [ -z "$force" ] && ! confirm "Do you want to overwrite $(lscolor "$sysfile")"; then
        return 0
      fi
      rm -rf "${tmpfile%.tgz}"
    fi
    if ! tar -xzf "$tmpfile" "${tmpfile%.tgz}" &>/dev/null; then
      lerror "Failed to extract archive $(lscolor "$tmpfile")"
      return 1
    fi
    rm -f "$tmpfile"
  fi
}

## Unset an existing dotfile link (remove the system file)
## Usage: link_unset "attrib" "dotfile" "sysfile"
link_unset() {
  echo "HI"
}

## Install a dotfile (remove the link to the dotfile)
## Usage: link_install "attrib" "dotfile" "sysfile"
link_install() {
  echo "HI"
}
