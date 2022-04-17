#!/bin/bash

section="$(config_get "$CONFIG_FILE" "${args[--package]}" || true)"

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

    if ! link_import "$sysfile" "$dotfile" "${args[--force]}"; then
      continue
    fi

    section="$(section_set "$section" "$(fs_reldot "$dotfile")" "$(fs_reluser "$file")")"
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
