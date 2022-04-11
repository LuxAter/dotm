#!/bin/bash

_log() {
  local key="$1"
  shift
  printf "[%b] %b\n" "$key" "$*" >&2
}

## Log an info message
## Usage: linfo msg
linfo() {
  _log "$(greenBold "I")" "$@"
}

## Log a warning message
## Usage: lwarn msg
lwarn() {
  _log "$(yellowBold "W")" "$@"
}

## Log an error message
## Usage: lerror msg
lerror() {
  _log "$(redBold "E")" "$@"
}

## Prompt for user confirmation, will always be false if not run in a tty
## Usage:
##   if confirm prompt; then ...
confirm() {
  local prompt="$(cyanBold ">>>") $1"
  if [[ -t 1 ]]; then
    while true; do
      read -u 1 -n 1 -rp "$prompt (y/n): "
      printf '\n'
      case "$REPLY" in 
        [Yy]*) return 0;;
        [Nn]*) return 1;;
        *) lwarn "Confirmation response must be 'y' or 'n'"
      esac
    done
  else
    return 1
  fi
}

## Prompt for a user password for encrypted files, will be disabled if not run
## in a tty
## Usage:
##   pswd="$(password prompt)"
PASSWORD=""
password() {
  local prompt="$(cyanBold ">>>") $1"
  if [[ -n "$PASSWORD" ]] ; then
    return 0
  fi

  if [[ -t 1 ]]; then
    while true; do
      read -srp "$prompt: " PASSWORD
      printf "\n"
      if [[ -z "$PASSWORD" ]]; then
        lwarn "Password must not be empty"
      else
        break
      fi
    done
  else
    return 1
  fi
}
get_password() {
  echo "$PASSWORD"
}
