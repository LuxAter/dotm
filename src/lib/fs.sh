#!/bin/bash

## Expand the user component of a given path
## Usage:
##   path="$(fs_expanduser "path")"
fs_expanduser() {
  local path="${1/"~"/$HOME}"
  echo "${path/"./"/"$PWD/"}"
}

## Get the relative path to the user home directory
## Usage:
##   path="$(fs_reluser "path")"
fs_reluser() {
  echo "${1/$HOME/"~"}"
}

## Get the path relative to the dotfiles dir
## Usage:
##  path="$(fs_reldot "path")"
fs_reldot() {
  echo "${1/$DOTFILES\//}"
}

## Get the dotfile equivalent of the path
## Usage:
##   path="$(fs_dotfile "path" "pkg")"
fs_dotfile() {
  local rel="$(fs_reluser "$1")"
  local pkg="$2"
  local fname="$(basename "$rel")"
  rel="${rel#"~/"}"
  rel="${rel#"/"}"
  rel="${rel//\/\//\/}"
  rel="${rel//\/./\/}"
  rel="${rel#.}"
  fname="${fname#.}"

  local res=""
  if [ -n "$pkg" ]; then
    res="$DOTFILES/$(dirname "$rel")/$pkg.$fname"
  else
    res="$DOTFILES/$(dirname "$rel")/$fname"
  fi
  echo "${res//\/.\//\/}"
}

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

## Prompt user for resolution in a file/directory conflict
## Usage:
##   result="$(fs_resolve "path_a" "path_b")"
fs_resolve() {
  while true; do
    action="$(pselect "How do you want to resolve the conflict" "Keep the dotfile version;Keep the system version;Compare the two for differences;Skip it")"
    if [ -z "$action" ]; then
      return 0
    elif [ "$action" == "Keep the dotfile version" ]; then
      echo "dotfile"
      return 0
    elif [ "$action" == "Keep the system version" ]; then
      echo "sysfile"
      return 0
    elif [ "$action" == "Compare the two for differences" ]; then
      diff --minimal --recursive --color=auto "$1" "$2" 1>&2
    elif [ "$action" == "Skip it" ]; then
      echo "skip"
      return 0
    fi
  done
}
