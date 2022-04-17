#!/bin/bash

section="$(config_get "$CONFIG_FILE" "${args[--package]}" || true)"
PSWD=""

for file in ${args[FILE]}; do
  file="${file//\"/}"
  file="$(fs_expanduser "$file")"

  if [ -e "$file" ]; then
    if [ -d "$file" ]; then type="directory"; else type="file"; fi

    sysfile="$(realpath "$file")"
    dotfile="$(fs_dotfile "$file" "${args[--package]}")"

    if [[ "$sysfile" = "$DOTFILES/"* ]]; then
      lwarn "The $type $(lscolor "$file") is already tracked in the dotfiles, it will be skipped"
      continue
    fi

    action=""
    if [ -e "$dotfile" ]; then
      if [ -n "${args[--force]}" ]; then
        rm -rf "$dotfile"
      elif [ "$(fs_hash "$dotfile")" = "$(fs_hash "$sysfile")" ]; then
        lwarn "A duplicate of this $type is already in the dotfiles"
        continue
      else
        lwarn "The $type $(lscolor "$dotfile") in the dotfiles differs from $type $(lscolor "$file")"
        action="$(fs_resolve "$dotfile" "$sysfile")"
        if [ "$action" == "skip" ] || [ -z "$action" ]; then
          continue
        elif [ "$action" == "sysfile" ]; then
          rm -rf "$dotfile"
        fi
      fi
    fi

    attributes=""
    should_copy=false
    should_archive=false
    should_encrypt=false
    if [ -n "${args[--copy]}" ]; then
      should_copy=true
      attributes="${attributes}C"
    fi
    if [ -n "${args[--archive]}" ]; then
      should_archive=true
      should_copy=true
      attributes="${attributes}X"
    fi
    if [ -n "${args[--encrypt]}" ]; then
      should_encrypt=true
      should_copy=true
      attributes="${attributes}E"
      if [ -d "$sysfile" ]; then
        should_archive=true
      fi
    fi

    archived=""
    if [ "$should_archive" == true ]; then
      archived="$(fs_archive "$sysfile")"
      if [ $? -ne 0 ]; then
        continue
      fi
      sysfile="$archived"
    fi

    encrypted=""
    if [ "$should_encrypt" == true ]; then
      if [ -z "$PSWD" ]; then
        PSWD="$(ppassword "Enter encryption password")"
      fi
      encrypted="$(fs_encrypt "$PSWD" "$sysfile")"
      if [ $? -ne 0 ]; then
        [ -e "$archived" ] && rm -f "$archived"
        continue
      fi
      sysfile="$encrypted"
    fi

    if [ "$should_copy" == true ]; then
      cp -r "$sysfile" "$dotfile"
    else
      mv -r "$sysfile" "$dotfile"

      if [ -e "$file" ] && [ "$action" == "dotfile" ]; then
        rm -rf "$file"
      elif ! [ -e "$file" ]; then
        ln -s "$dotfile" "$file"
      fi
    fi

    [ -e "$encrypted" ] && rm -f "$encrypted"
    [ -e "$archived" ] && rm -f "$archived"

    if [ -n "$attributes" ]; then attributes="${attributes}:"; fi

    section="$(section_set "$section" "${attributes}$(fs_reldot "$dotfile")" "$(fs_reluser "$file")")"
    linfo "Added the $type $(lscolor "$file") to the $(bold "${args[--package]}") package"
  elif config_has "$CONFIG_FILE" "$file"; then
    depends="$(section_get "$section" "depends" || true)"
    if [[ " $depends " = *" $file "* ]]; then
      lwarn "Package $(bold "$file") is already a dependency of $(bold "${args[--package]}")"
    else
      section="$(section_set "$section" "depends" "$depends $file")"
      linfo "Added $(bold "$file") as a dependency of $(bold "${args[--package]}")"
    fi
  else
    lwarn "File or directory $(lscolor "$file") does not exist, it will be skipped"
  fi
done

config_set "$CONFIG_FILE" "${args[--package]}" "$section"
