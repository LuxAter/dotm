#!/usr/bash

REMOTE_URL="https://raw.githubusercontent.com/LuxAter/dotm/main/dotm"

source_code="$(curl -s "$REMOTE_URL")"
remote_version="$(echo "$source_code" | grep "^\s*version=")"
remote_version="${remote_version##*=}"
remote_version="${remote_version//\"/}"

if semver_eq "$installed_version" "$version"; then
  lerror "The current version of dotm is up to date $(yellowBold "v$version")"
  return 0
elif semver_gt "$installed_version" "$version"; then
  lerror "A newer version of dotm is already installed $(yellowBold "v$installed_version")"
  return 0
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
