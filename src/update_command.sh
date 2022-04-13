#!/usr/bash

REMOTE_URL="https://raw.githubusercontent.com/LuxAter/dotm/main/dotm"

source_code="$(curl -s "$REMOTE_URL")"
remote_version="$(echo "$source_code" | grep "^\s*version=")"
remote_version="${remote_version##*=}"
remote_version="${remote_version//\"/}"
remote_major="${remote_version%%.*}"
remote_minor_patch="${remote_version#*.}"
remote_minor="${remote_minor_patch%%.*}"
remote_patch="${remote_minor_patch#*.}"

current_major="${version%%.*}"
current_minor_patch="${version#*.}"
current_minor="${current_minor_patch%%.*}"
current_patch="${current_minor_patch#*.}"

if [ "$current_major" -gt "$remote_major" ]; then
  lerror "A newer version of dotm is already installed $(yellowBold "v$version")"
  return 0
elif [ "$current_major" -eq "$remote_major" ]; then
  if [ "$current_minor" -gt "$remote_minor" ]; then
    lerror "A newer version of dotm is already installed $(yellowBold "v$version")"
    return 0
  elif [ "$current_minor" -eq "$remote_minor" ]; then
    if [ "$current_patch" -gt "$remote_patch" ]; then
      lerror "A newer version of dotm is already installed $(yellowBold "v$version")"
      return 0
    elif [ "$current_patch" -eq "$remote_patch" ]; then
      lerror "The current version of dotm is up to date $(yellowBold "v$version")"
      return 0
    fi
  fi
fi

if confirm "Do you want to upgrade dotm $(yellowBold "v$version") $(bold "->") $(yellowBold "v$remote_version")"; then
  rm -f "$SCRIPT_DIR/dotm"
  echo "$source_code" >"$SCRIPT_DIR/dotm"
  chmod +x "$SCRIPT_DIR/dotm"
  linfo "Upgraded dotm $(yellowBold "v$version") $(bold "->") $(yellowBold "v$remote_version")"

  COMPLETION_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completions/completions/dotm.bash"
  if [ -f "$COMPLETION_FILE" ]; then
    rm -f "$COMPLETION_FILE"
    curl "https://raw.githubusercontent.com/LuxAter/dotm/main/completions.bash" -o "$COMPLETION_FILE"

    linfo "Upgraded bash completions for dotm"
  fi
fi
