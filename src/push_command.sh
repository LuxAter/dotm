#!/bin/bash

if [ -n "$(git -C "$DOTFILES" status --porcelain)" ]; then
  ldebug "Commiting local changes"
  if ! git -C "$DOTFILES" add -A &>/dev/null; then
    lerror "Failed to add local changes to the git repo"
    exit 1
  fi

  if ! git -C "$DOTFILES" commit -m "${args[--message]}"; then
    lerror "Failed to create commit local changes"
    exit 1
  fi

  if ! git -C "$DOTFILES" push; then
    lerror "Failed to push local commits to remote repository"
    exit 1
  fi
else
  lwarn "No local changes, no commit will be made"
fi
