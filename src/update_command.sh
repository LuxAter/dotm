#!/bin/bash

remote_source=""
remote_source="$(curl -s "${args[--url]}/dotm")"
if [ $? -ne 0 ]; then
  lerror "Failed to fetch remote version of dotm from $(magentaBold "${args[--url]}/dotm")"
fi

remote_version="$(echo "$remote_source" | grep "^\s*version=")"
remote_version="${remote_version##*=}"
remote_version="${remote_version//\"/}"

dotm_path="${args[--path]}"
dotm_path="${dotm_path:-$SCRIPT_DIR}/dotm"
dotm_path="${dotm_path//\/\//\/}"
if [ -e "$dotm_path" ]; then
  local_version="$(grep "^\s*version=" "$dotm_path")"
  local_version="${local_version##*=}"
  local_version="${local_version//\"/}"
else
  local_version="0.0.0"
fi

can_update=false
if semver_eq "$remote_version" "$local_version"; then
  linfo "$(bold "dotm") is already up to date $(yellowBold "v$remote_version")"
elif semver_gt "$remote_version" "$local_version"; then
  linfo "A newer version of $(bold "dotm") is available $(yellowBold "v$local_version") -> $(yellowBold "v$remote_version")"
  can_update=true
else
  linfo "A newer version of $(bold "dotm") is already installed $(yellowBold "v$local_version") -> $(yellowBold "v$remote_version")"
fi

if [ -n "${args[--check]}" ]; then
  exit 0
fi

if [ -n "${args[--force]}" ]; then
  can_update=true
fi

if [ "$can_update" == true ] && [ -z "${args[--no - dotm]}" ]; then
  if [ -n "${args[--force]}" ] || pconfirm "Are you sure you want to update dotm"; then
    ldebug "Installing $(bold "dotm") into $(lscolor "$dotm_path")"
    [ -f "$dotm_path" ] && rm -f "$dotm_path"
    echo "$remote_source" >"$dotm_path"
    chmod +x "$dotm_path"

    linfo "Updated $(bold "dotm") $(yellowBold "v$local_version") -> $(yellowBold "v$remote_version")"
  fi
fi

if [ "$can_update" == true ] && [ -z "${args[--no - completion]}" ]; then
  if [ -n "${args[--force]}" ] || pconfirm "Are you sure you want to update dotm completions"; then
    completion_path="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completions/completions/dotm.bash"
    ldebug "Installing $(bold "dotm completions") into $(lscolor "$completion_path")"
    [ -f "$completion_path" ] && rm -f "$completion_path"
    curl -s "${args[--url]}/completions.bash" -o "$completion_path"

    linfo "Updated $(bold "dotm completions") $(yellowBold "v$local_version") -> $(yellowBold "v$remote_version")"
  fi
fi
