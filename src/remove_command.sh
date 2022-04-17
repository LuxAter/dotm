#!/bin/bash

section="$(config_get "$CONFIG_FILE" "${args[--package]}" || true)"
depends="$(section_get "$section" "depends" || true)"

for file in ${args[files]}; do
  file="${file//\"/}"
  file="$(fs_expanduser "$file")"

  if [[ " $depends " = *" $file "* ]]; then
    depends="${depends/"$file "/}"
    section="$(section_set "$section" "depends" "$depends")"
    linfo "Removed the dependency $(bold "$file") from the $(bold "${args[--package]}") package"
  else
    if [ -d "$file" ]; then type="directory"; else type="file"; fi

    sysfile="$file"
    dotfile="$(fs_dotfile "$file" "${args[--package]}")"

    if ! [[ "$(realpath "$sysfile")" = "$DOTFILES/"* ]]; then
      lwarn "The $type $(lscolor "$file") is not set in the dotfiles"
      continue
    fi

    if ! link_install "$dotfile" "$sysfile" "${args[--force]}"; then
      continue
    fi

    if [ -e "$dotfile" ]; then
      rm -rf "$dotfile"
    fi

    section="$(section_del "$section" "$(fs_reldot "$dotfile")")"
    linfo "Removed the $type $(lscolor "$file") from the $(bold "${args[--package]}") package"
  fi
done

config_set "$CONFIG_FILE" "${args[--package]}" "$section"
