#!/bin/bash

# TODO: Implement frequency cache to limit sync occurances

has_local_commit=false
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

  has_local_commit=true
else
  lwarn "No local changes, no new commit will be made"
fi

if ! git -C "$DOTFILES" pull --rebase; then
  lerror "Failed to pull remote changes into local dotfiles $(lscolor "$DOTFILES")"
  exit 1
fi

# TODO: Add configuration to run the set command to update dotfiles

if [ "$has_local_commit" == true ]; then
  if ! git -C "$DOTFILES" push; then
    lerror "Failed to push local commits to remote repository"
    exit 1
  fi
fi
