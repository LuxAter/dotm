#!/bin/bash

section="$(config_resolve "$CONFIG_FILE" "${args[packages]}")"
PSWD=""

for key in $(section_keys "$section"); do
  should_extract=false
  should_decrypt=false
  should_copy=false

  extension=""

  attributes="${key%%:*}"
  dotfile="${key#*:}"
  dotfile="$DOTFILES/$dotfile"

  if [[ "$attributes" = *X* ]]; then
    should_extract=true
    tmp="${dotfile%%"$extension"}"
    extension="${extension}.${tmp##*.}"
  fi
  if [[ "$attributes" = *E* ]]; then
    should_decrypt=true
    tmp="${dotfile%%"$extension"}"
    extension="${extension}.${dotfile##*.}"
  fi
  if [[ "$attributes" = *C* ]]; then should_copy=true; fi

  sysfile="$(section_get "$section" "$key")"
  sysfile="$(fs_expanduser "$sysfile")"

  if [ -L "$sysfile" ] && [ "$should_copy" == false ] && [ "$(realpath "$sysfile")" == "$dotfile" ]; then
    continue
  fi

  action=""
  if [ -z "${args[--force]}" ] && [ -e "$sysfile" ]; then
    lwarn "There is a conflict between $(lscolor "$dotfile") and $(lscolor "$sysfile")"
    action="$(fs_resolve "$sysfile" "$dotfile")"
    if [ "$action" == "skip" ] || [ -z "$action" ]; then
      continue
    elif [ "$action" == "dotfile" ]; then
      rm -rf "$sysfile"
    elif [ "$action" == "sysfile" ]; then
      rm -rf "$dotfile"
      lerror "To take the system file, run 'dotm add \"$sysfile\""
      exit 1
    fi
  fi

  [ -d "$(dirname "$sysfile")" ] || mkdir -p "$(dirname "$sysfile")"

  if [ "$should_copy" == true ]; then
    copied="$sysfile$extension"
    sysfile="$copied"
    cp -r "$dotfile" "$sysfile"

    decrypted=""
    if [ "$should_decrypt" == true ]; then
      if [ -z "$PSWD" ]; then
        PSWD="$(ppassword "Enter decryption password")"
      fi
      decrypted="$(fs_decrypt "$PSWD" "$sysfile")"
      if [ $? -ne 0 ]; then
        [ -e "$copied" ] && rm -f "$copied"
        continue
      fi
      sysfile="$decrypted"
    fi

    if [ "$should_extract" == true ]; then
      sysfile="$(fs_unarchive "$sysfile")"
      if [ $? -ne 0 ]; then
        [ -e "$copied" ] && rm -f "$copied"
        [ -e "$decrypted" ] && rm -f "$decrypted"
        continue
      fi
    fi
  else
    ln -s "$dotfile" "$sysfile"
  fi

  linfo "Set link $(lscolor "$dotfile") -> $(lscolor "$sysfile")"
done
