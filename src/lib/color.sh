#!/bin/bash

print_in_color() {
  local color="$1"
  shift
  if [[ -z ${NO_COLOR+x} ]] && [[ -t 1 ]]; then
    printf "$color%b\e[0m\n" "$*";
  else
    printf "%b\n" "$*";
  fi
}

red() { print_in_color "\e[31m" "$*"; }
green() { print_in_color "\e[32m" "$*"; }
yellow() { print_in_color "\e[33m" "$*"; }
blue() { print_in_color "\e[34m" "$*"; }
magenta() { print_in_color "\e[35m" "$*"; }
cyan() { print_in_color "\e[36m" "$*"; }
bold() { print_in_color "\e[1m" "$*"; }
underlined() { print_in_color "\e[4m" "$*"; }
redBold() { print_in_color "\e[1;31m" "$*"; }
greenBold() { print_in_color "\e[1;32m" "$*"; }
yellowBold() { print_in_color "\e[1;33m" "$*"; }
blueBold() { print_in_color "\e[1;34m" "$*"; }
magentaBold() { print_in_color "\e[1;35m" "$*"; }
cyanBold() { print_in_color "\e[1;36m" "$*"; }
redUnderlined() { print_in_color "\e[4;31m" "$*"; }
greenUnderlined() { print_in_color "\e[4;32m" "$*"; }
yellowUnderlined() { print_in_color "\e[4;33m" "$*"; }
blueUnderlined() { print_in_color "\e[4;34m" "$*"; }
magentaUnderlined() { print_in_color "\e[4;35m" "$*"; }
cyanUnderlined() { print_in_color "\e[4;36m" "$*"; }
redBoldUnderlined() { print_in_color "\e[4;31m" "$*"; }
greenBoldUnderlined() { print_in_color "\e[1;4;32m" "$*"; }
yellowBoldUnderlined() { print_in_color "\e[1;4;33m" "$*"; }
blueBoldUnderlined() { print_in_color "\e[1;4;34m" "$*"; }
magentaBoldUnderlined() { print_in_color "\e[1;4;35m" "$*"; }
cyanBoldUnderlined() { print_in_color "\e[1;4;36m" "$*"; }

lscolor() {
  if [[ -z ${NO_COLOR+x} ]] && [[ -t 1 ]]; then
    while IFS= read -r line; do
      local key="${line%%=*}"
      local value="${line##*=}"
      if [[ "$1" == $key ]]; then
        printf '%b%s%b\n' "\e[${value}m" "$1" "\e[0m"
        return 0
      fi
    done <<<"$(echo "$LS_COLORS" | tr ":" "\n")"
    printf '%s\n' "$1"
  else
    printf '%s\n' "$1"
  fi
}

