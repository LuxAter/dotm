#!/bin/bash

## Get the md5 hash of a given file or directory
## Usage:
##   hash="$(fs_hash "source_file.txt")"
fs_hash() {
  if [ -f "$1" ]; then
    openssl md5 "$1" | cut -d' ' -f2
  elif [ -d "$1" ]; then
    find "$1" -type f | sort | xargs cat | openssl md5 | cut -d' ' -f2
  else
    echo "d41d8cd98f00b204e9800998ecf8427e"
  fi
}

## Archive/compress a given file or directory into the destination path
## Usage: 
##   dest_file="$(fs_archive "source_file.txt")"
##   fs_archive "source_file.txt" "dest_file.tgz"
fs_archive() {
  local src="$1"
  local dest="$2"
  if ! [ -e "$src" ]; then
    lwarn "File or directory $(lscolor "$src") not found"
    return 1
  fi

  if [ -d "$src" ]; then
    dest="${dest:-${src%/}.tgz}"
    ldebug "Archiving the directory $(lscolor "$src") to $(lscolor "$dest")"

    if ! tar -czf "$dest" -C "$src" "." &>/dev/null; then
      lerror "Failed to create archive of $(lscolor "$src")"
      return 1
    fi
  elif [ -f "$src" ]; then
    dest="${dest:-$src.gz}"
    ldebug "Archiving the file $(lscolor "$src") to $(lscolor "$dest")"

    if ! gzip -9c "$src" 1>"$dest" 2>/dev/null; then
      lerror "Failed to create archive of $(lscolor "$src")"
      return 1
    fi
  else
    lwarn "Cannot archive $(lscolor "$src"), must be a file or directory"
    return 1
  fi
  echo "$dest"
  return 0
}

## Unarchive/decompress a given file into the destination file or directory
## Usage:
##   dest_file="$(fs_unarchive "source_file.txt.gz")"
##   fs_unarchive "source_file.txt.gz" "source_file.txt"
fs_unarchive() {
  local src="$1"
  local dest="$2"
  if ! [ -e "$src" ]; then
    lwarn "File or directory $(lscolor "$src") not found"
    return 1
  fi

  if [ -f "$src" ]; then
    if [[ "$src" = *.gz ]]; then
      dest="${dest:-${src%.gz}}"
      ldebug "Extracing the file $(lscolor "$src") to $(lscolor "$dest")"

      if ! gzip -cd "$src" 1>"$dest" 2>/dev/null; then
        lerror "Failed to extract archive of $(lscolor "$src")"
        return 1
      fi
    elif [[ "$src" = *.tgz ]]; then
      dest="${dest:-${src%.tgz}}"
      ldebug "Extracing the directory $(lscolor "$src") to $(lscolor "$dest")"

      if ! mkdir -p "$dest"; then
        lerror "Failed to extract archive of $(lscolor "$src")"
        return 1
      elif ! tar -xzf "$src" -C "$dest" &>/dev/null; then
        lerror "Failed to extract archive of $(lscolor "$src")"
        return 1
      fi
    fi
  else
    lwarn "Cannot unarchive $(lscolor "$src"), must be a file"
    return 1
  fi
  echo "$dest"
  return 0
}

## Encrypt give file with the provided password
## Usage:
##   dest_file="$(fs_encrypt "password" "source_file.txt")"
##   fs_encrypt "password" "source_file.txt" "dest_file.txt.enc"
fs_encrypt() {
  local pswd="$1"
  local src="$2"
  local dest="$3"

  if ! [ -e "$src" ]; then
    lwarn "File $(lscolor "$src") not found"
    return 1
  fi

  if [ -f "$src" ]; then
    dest="${dest:-$src.enc}"
    ldebug "Encrypting the file $(lscolor "$src") to $(lscolor "$dest")"
    if ! openssl enc -aes-256-cbc -pass "pass:$pswd" -in "$src" -out "$dest" &>/dev/null; then
      lerror "Failed to encrypt $(lscolor "$src")"
      return 1
    fi
  else
    lwarn "Cannot encrypt $(lscolor "$src"), must be a file"
    return 1
  fi
  echo "$dest"
  return 0
}

## Decrypt the give file with the provided password
## Usage:
##   dest_file="$(fs_decrypt "password" "source_file.txt")"
##   fs_decrypt "password" "source_file.txt" "dest_file.txt.enc"
fs_decrypt() {
  local pswd="$1"
  local src="$2"
  local dest="$3"

  if ! [ -e "$src" ]; then
    lwarn "File $(lscolor "$src") not found"
    return 1
  fi

  if [ -f "$src" ]; then
    dest="${dest:-${src%.enc}}"
    ldebug "Decrypting the file $(lscolor "$src") to $(lscolor "$dest")"
    if ! openssl enc -aes-256-cbc -d -pass "pass:$pswd" -in "$src" -out "$dest" &>/dev/null; then
      lerror "Failed to decrypt $(lscolor "$src")"
      return 1
    fi
  else
    lwarn "Cannot decrypt $(lscolor "$src"), must be a file"
    return 1
  fi
  echo "$dest"
  return 0
}
