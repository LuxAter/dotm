#!/bin/bash

IS_TTY=false
[ -t 1 ] && IS_TTY=true
INTERACTIVE=false

configure_prompts() {
  if [ "$1" == true ]; then
    INTERACTIVE=true
  else
    INTERACTIVE=false
  fi
}

pconfirm() {
  local default=""
  if [ -n "$2" ]; then
    if [ "$2" == true ]; then
      default=true
    else
      default=false
    fi
  fi

  if [ "$INTERACTIVE" == false ]; then
    if [ "$default" == true ]; then
      return 0
    else
      return 1
    fi
  fi

  local prompt="$(cyanBold ">>>") $1"
  if [ "$default" == true ]; then
    prompt="$prompt $(bold "[Y/n]")"
  elif [ "$default" == false ]; then
    prompt="$prompt $(bold "[y/N]")"
  else
    prompt="$prompt $(bold "[y/n]")"
  fi

  while true; do
    read -n 1 -rp "$prompt: "
    case "$REPLY" in
    [YyNn]*) break ;;
    '')
      [ -n "$default" ] && break
      printf "    %b An input is required, enter 'y' or 'n'\n" "$(redBold ">")" 1>&2
      ;;
    *) printf "\n    %b Input must be 'y' or 'n', not '%s'\n" "$(redBold ">")" "$REPLY" 1>&2 ;;
    esac

    if [ "$IS_TTY" == true ]; then
      printf "\e[2A\e[2K" 1>&2
    fi
  done
  [ -n "$REPLY" ] && printf '\n' 1>&2
  [ "$IS_TTY" == true ] && printf "\e[2K" 1>&2

  case "$REPLY" in
  [Yy]*) return 0 ;;
  [Nn]*) return 1 ;;
  *) [ "$default" == true ] && return 0 || return 1 ;;
  esac
}

pv_not_empty() {
  [ -z "$1" ] && echo "Input must not be empty"
}

pv_integer() {
  [[ "$1" =~ ^[0-9]+$ ]] || echo "Input must be an integer"
}

pinput() {
  local prompt="$(cyanBold ">>>") $1"
  local default="$2"
  local validation="$3"

  if [ "$INTERACTIVE" == false ]; then
    echo "$default"
    return 0
  fi

  if [ -n "$default" ]; then
    prompt="$prompt $(bold "[$default]")"
  fi

  while true; do
    read -rp "$prompt: "

    if [ -z "$REPLY" ] && [ -n "$default" ]; then
      break
    elif [ -n "$validation" ]; then
      response="$($validation "$REPLY")"
      if [ -z "$response" ]; then
        break
      else
        printf "    %b %s\n" "$(redBold ">")" "$response" 1>&2
      fi
    else
      break
    fi

    if [ "$IS_TTY" == true ]; then
      printf "\e[2A\e[2K" 1>&2
    fi
  done
  [ "$IS_TTY" == true ] && printf "\e[2K" 1>&2

  if [ -z "$REPLY" ] && [ -n "$default" ]; then
    echo "$default"
  else
    echo "$REPLY"
  fi
}

ppassword() {
  local prompt="$(cyanBold ">>>") $1"

  if [ "$INTERACTIVE" == false ]; then
    return 0
  fi

  while true; do
    read -srp "$prompt: "

    if [ -z "$REPLY" ]; then
      printf "\n    %b %s\n" "$(redBold ">")" "Input must not be empty" 1>&2
    else
      break
    fi

    if [ "$IS_TTY" == true ]; then
      printf "\e[2A\e[2K" 1>&2
    fi
  done
  printf "\n" 1>&2
  [ "$IS_TTY" == true ] && printf "\e[2K" 1>&2

  echo "$REPLY"
}

pselect() {
  local prompt="$(cyanBold ">>>") $1"
  IFS=';' read -ra options <<<"$2"
  local default="$3"

  if [ "$INTERACTIVE" == false ]; then
    [ -n "$default" ] && echo "${options[$default]}"
    return 0
  fi

  if [ -n "$default" ]; then
    prompt="$prompt $(bold "[$((default + 1))]")"
  fi

  for i in $(seq 1 ${#options[@]}); do
    local id=$((i - 1))
    printf "    %b%b %b\n" "$(blueBold "$i")" "$(bold ")")" "${options[$id]}" 1>&2
  done

  while true; do
    read -rp "$prompt: "

    if [ -z "$REPLY" ] && [ -n "$default" ]; then
      break
    elif ! [[ "$REPLY" =~ ^[0-9]+$ ]]; then
      printf "    %b %s\n" "$(redBold ">")" "Input must be an integer between 1 and ${#options[@]}" 1>&2
    elif [ "$REPLY" -le 0 ] || [ "$REPLY" -gt "${#options[@]}" ]; then
      printf "    %b %s\n" "$(redBold ">")" "Input must be an integer between 1 and ${#options[@]}" 1>&2
    else
      break
    fi

    if [ "$IS_TTY" == true ]; then
      printf "\e[2A\e[2K" 1>&2
    fi
  done
  [ "$IS_TTY" == true ] && printf "\e[2K" 1>&2

  if [ -z "$REPLY" ] && [ -n "$default" ]; then
    echo "${options[$default]}"
  else
    REPLY=$((REPLY - 1))
    echo "${options[$REPLY]}"
  fi
}
