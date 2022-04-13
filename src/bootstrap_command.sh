#!/usr/bash

INSTALL_DIR="$HOME/.local/bin"

install_dotm() {
  if [ "$SCRIPT_DIR" == "$INSTALL_DIR" ]; then
    linfo "dotm is already installed in $(lscolor "$INSTALL_DIR")"
    exit 0
  fi

  if ! [ -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
  fi

  if [ -e "$INSTALL_DIR/dotm" ]; then
    installed_version="$("$INSTALL_DIR/dotm" --version)"
    installed_major="${installed_version%%.*}"
    installed_minor_patch="${installed_version#*.}"
    installed_minor="${installed_minor_patch%%.*}"
    installed_patch="${installed_minor_patch#*.}"

    current_major="${version%%.*}"
    current_minor_patch="${version#*.}"
    current_minor="${current_minor_patch%%.*}"
    current_patch="${current_minor_patch#*.}"

    if [ "$installed_major" -gt "$current_major" ]; then
      lerror "A newer version of dotm is already installed $(yellowBold "v$installed_version")"
      return 0
    elif [ "$installed_major" -eq "$current_major" ]; then
      if [ "$installed_minor" -gt "$current_minor" ]; then
        lerror "A newer version of dotm is already installed $(yellowBold "v$installed_version")"
        return 0
      elif [ "$installed_minor" -eq "$current_minor" ]; then
        if [ "$installed_patch" -gt "$current_patch" ]; then
          lerror "A newer version of dotm is already installed $(yellowBold "v$installed_version")"
          return 0
        elif [ "$installed_patch" -eq "$current_patch" ]; then
          lerror "The version of dotm installed is the same as the one being bootstraped $(yellowBold "v$version")"
          return 0
        fi
      fi
    fi

    linfo "Upgrading dotm $(yellowBold "v$installed_version") $(bold "->") $(yellowBold "v$version")"
    rm -f "$INSTALL_DIR/dotm" || return 1
  else
    linfo "Installing dotm $(yellowBold "v$version")"
  fi

  cp "$SCRIPT_DIR/$(basename -- "${BASH_SOURCE[0]}")" "$INSTALL_DIR/dotm" || return 1
  chmod +x "$INSTALL_DIR/dotm" || return 1
  return 0
}

setup_dotfiles() {
  if confirm "Do you have an existing git repo"; then
    repo="$(input "Enter the git url for the dotfiles repo")"
    [ -z "$repo" ] && return 1

    git clone --depth=1 --no-single-branch "$repo" "$DOTFILES" || return 1

    linfo "Cloned existing dotfies repo into $(lscolor "$DOTFILES"), remember to run 'dotm set'"
  else
    mkdir -p "$DOTFILES" || return 1
    touch "$DOTFILES/dotm.ini" || return 1

    linfo "Created new dotfiles repo in $(lscolor "$DOTFILES")"
  fi
}

if confirm "Do you want to install dotm into $(lscolor "$INSTALL_DIR")"; then
  install_dotm || exit 1
fi

if confirm "Do you want to install bash completions for dotm"; then
  COMPLETIONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completions/completions"
  [ -d "${COMPLETIONS_DIR}" ] || mkdir -p "$COMPLETIONS_DIR"
  curl "https://raw.githubusercontent.com/LuxAter/dotm/main/completions.bash" -o "$COMPLETIONS_DIR/dotm.bash"

  linfo "Added bash completions for dotm"
fi

if confirm "Do you want to setup a dotfiles repo in $(lscolor "$DOTFILES")"; then
  setup_dotfiles || exit 1
fi
