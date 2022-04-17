#!/bin/bash

section="$(config_get "$CONFIG_FILE" "${args[--package]}" || true)"
PSWD=""

for file in ${args[files]}; do
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

    [ -d "$(dirname "$dotfile")" ] || mkdir -p "$(dirname "$dotfile")"
    mv "$sysfile" "$dotfile"

    if [ -e "$file" ] && [ "$action" == "dotfile" ]; then
      rm -rf "$file"
    elif ! [ -e "$file" ]; then
      ln -s "$dotfile" "$file"
    fi

    section="$(section_set "$section" "$(fs_reldot "$dotfile")" "$(fs_reluser "$file")")"
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
