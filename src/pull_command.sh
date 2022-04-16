#!/bin/bash

ldebug "Pulling changes from remote dotfiles repo"
if ! git -C "$DOTFILES" pull --rebase &>/dev/null; then
  lerror "Failed to pull remote changes into local dotfiles repo $(lscolor "$DOTFILES")"
  exit 1
fi
