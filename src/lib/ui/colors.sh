#!/bin/bash

ENABLE_COLOR=false

configure_color() {
  if [ -z ${NO_COLOR+x} ] && [ "$1" == "true" ]; then
    ENABLE_COLOR=true
  else
    ENABLE_COLOR=false
  fi
}

print_in_color() {
  local color="$1"
  shift
  if [ "$ENABLE_COLOR" == true ]; then
    if [ "$UNIT_TESTS" == true ]; then
      printf "\\$color%b\\\e[0m\n" "$*"
    else
      printf "$color%b\e[0m\n" "$*"
    fi
  else
    printf "%b\n" "$*"
  fi
}

red() { print_in_color "\e[31m" "$*"; }
green() { print_in_color "\e[32m" "$*"; }
yellow() { print_in_color "\e[33m" "$*"; }
blue() { print_in_color "\e[34m" "$*"; }
magenta() { print_in_color "\e[35m" "$*"; }
cyan() { print_in_color "\e[36m" "$*"; }
bold() { print_in_color "\e[1m" "$*"; }
underline() { print_in_color "\e[4m" "$*"; }
redBold() { print_in_color "\e[1;31m" "$*"; }
greenBold() { print_in_color "\e[1;32m" "$*"; }
yellowBold() { print_in_color "\e[1;33m" "$*"; }
blueBold() { print_in_color "\e[1;34m" "$*"; }
magentaBold() { print_in_color "\e[1;35m" "$*"; }
cyanBold() { print_in_color "\e[1;36m" "$*"; }
redUnderline() { print_in_color "\e[4;31m" "$*"; }
greenUnderline() { print_in_color "\e[4;32m" "$*"; }
yellowUnderline() { print_in_color "\e[4;33m" "$*"; }
blueUnderline() { print_in_color "\e[4;34m" "$*"; }
magentaUnderline() { print_in_color "\e[4;35m" "$*"; }
cyanUnderline() { print_in_color "\e[4;36m" "$*"; }
redBoldUnderline() { print_in_color "\e[4;31m" "$*"; }
greenBoldUnderline() { print_in_color "\e[1;4;32m" "$*"; }
yellowBoldUnderline() { print_in_color "\e[1;4;33m" "$*"; }
blueBoldUnderline() { print_in_color "\e[1;4;34m" "$*"; }
magentaBoldUnderline() { print_in_color "\e[1;4;35m" "$*"; }
cyanBoldUnderline() { print_in_color "\e[1;4;36m" "$*"; }

lscolor() {
  if [ "$ENABLE_COLOR" == true ]; then
    while IFS= read -r line; do
      local key="${line%%=*}"
      local value="${line##*=}"
      if [[ "$1" == $key ]]; then
        if [ "$UNIT_TESTS" == true ]; then
          printf '%b%s%b\n' "\\\e[${value}m" "$1" "\\\e[0m"
        else
          printf '%b%s%b\n' "\e[${value}m" "$1" "\e[0m"
        fi
        return 0
      fi
    done <<<"$(echo "$LS_COLORS" | tr ":" "\n")"
    green "$1"
  else
    printf '%s\n' "$1"
  fi
}
