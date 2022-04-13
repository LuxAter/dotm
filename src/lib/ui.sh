#!/bin/bash

IS_TTY=false
if [ -t 1 ]; then
  IS_TTY=true
fi

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
  if [[ $IS_TTY == true ]] || [[ $UNIT_TESTS == true ]]; then
    while true; do
      read -t 10 -n 1 -rp "$prompt (y/n): "
      printf '\n' 1>&2
      if [ -z "$REPLY" ]; then
        lwarn "No user input after 10s, assuming 'n'"
        return 1
      fi
      case "$REPLY" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) lwarn "Confirmation response must be 'y' or 'n'" ;;
      esac
    done
  else
    return 1
  fi
}

## Prompt user for text intput
## Usage:
##   value="$(input prompt)"
input() {
  local prompt="$(cyanBold ">>>") $1"
  if [[ $IS_TTY == true ]] || [[ $UNIT_TESTS == true ]]; then
    read -t 30 -rp "$prompt: "
    if [ -z "$REPLY" ]; then
      lwarn "No user input after 30s or input is empty"
      return 1
    fi
    echo "$REPLY"
  else
    return 1
  fi
}

## Prompt user to select option from a list of choices
## Usage:
##   value="$(choose prompt opt1 opt2 ...)"
choose() {
  local prompt="$(cyanBold ">>>") $1"
  shift
  local options=()
  while [ $# -ne 0 ]; do
    options+=("$1")
    shift
  done
  local count=${#options[@]}
  if [[ $IS_TTY == true ]] || [[ $UNIT_TESTS == true ]]; then
    for i in $(seq 0 $((count-1))); do
      printf " %b%b %b\n" "$(yellowBold "$((i+1))")" "$(bold ")")" "${options[$i]}" 1>&2
    done
    while true; do
      read -t 10 -n 1 -rp "$prompt: "
      printf '\n' 1>&2
      if [ -z "$REPLY" ]; then
        lwarn "No user input after 10s"
        return 1
      elif ! [[ "$REPLY" =~ ^[0-9]$ ]] || [ "$REPLY" -eq 0 ] || [ "$REPLY" -gt ${#options[@]} ]; then
        lwarn "Input must be a number for one of the above choices"
      else
        break
      fi
    done
    REPLY=$((REPLY-1))
    echo "${options[$REPLY]}"
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
  if [[ -n "$PASSWORD" ]]; then
    echo "$PASSWORD"
    return 0
  fi

  if [[ $IS_TTY == true ]] || [[ $UNIT_TESTS == true ]]; then
    while true; do
      read -t 30 -srp "$prompt: " PASSWORD
      printf "\n" 1>&2
      if [[ -z "$PASSWORD" ]]; then
        lwarn "No user input after 30s or password was empty"
        return 1
      else
        break
      fi
    done
    echo "$PASSWORD"
  else
    return 1
  fi
}
