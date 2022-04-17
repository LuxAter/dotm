#!/bin/bash

## Get a specific section from the config file
## Usage:
##   section="$(config_get "file" "key")"
config_get() {
  local file="$1"

  [ -e "$file" ] || return 1

  local found=false
  local body=""
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^\[(.+)\]$ ]]; then
      if [ "${BASH_REMATCH[1]}" == "$2" ]; then
        found=true
      elif [ "$found" == true ]; then
        break
      fi
    elif [ "$found" == true ] && [ -n "$line" ]; then
      body="$body$line\n"
    fi
  done <"$file"

  printf "%b" "$body"
  if [ "$found" == true ]; then return 0; else return 1; fi
}

## Wrtie a specific section to the config file
## Usage:
##   config_set "file" "key" "section"
config_set() {
  local file="$1"
  local key="$2"
  local body="$3"

  [ -d "$(dirname "$file")" ] || mkdir -p "$(dirname "$file")"

  local found=false
  local copy=false
  local output=""
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^\[(.+)\]$ ]]; then
      if [ "${BASH_REMATCH[1]}" == "$key" ]; then
        found=true
        copy=false
        output="${output}[$key]\n$body"
      elif [ "$found" == true ]; then
        output="$output$line\n"
        copy=true
      fi
    elif [ "$copy" == true ]; then
      output="$output$line\n"
    fi
  done <"$file"

  if [ "$found" == false ]; then
    output="${output}[$key]\n$body"
  fi

  printf "%b" "$output" >"$file"
}

## Delete a section from the config file
## Usage:
##   config_del "file" "key"
config_del() {
  local file="$1"
  local key="$2"

  local output=""
  local copy=true
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^\[(.+)\]$ ]]; then
      if [ "${BASH_REMATCH[1]}" == "$key" ]; then
        copy=false
      else
        output="$output$line\n"
        copy=true
      fi
    elif [ "$copy" == true ]; then
      output="$output$line\n"
    fi
  done <"$file"

  printf "%b" "$output" >"$file"
}

## Get a list of sections in the config file
## Usage:
##   for k in $(config_keys "file"); do
config_keys() {
  local file="$1"
  local keys=()
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^\[([A-Za-z0-9\/]+)\]$ ]]; then
      keys+=("${BASH_REMATCH[1]}")
    fi
  done <"$file"

  echo -e "${keys[@]}"
}

## Check if the given section is present in the config file
## Usage:
##   if config_has "file" "key"; then
config_has() {
  [[ " $(config_keys "$1")" = *" $2 "* ]]
}

## Get value from the config section
## Usage:
##   value="$(section_get "$section" "key")"
section_get() {
  local section="$1"
  local key="$2"

  local found=false
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^$key\s*=\s*(.+)\s*$ ]]; then
      found=true
      echo "${BASH_REMATCH[1]}"
      break
    fi
  done < <(echo -e "$section")

  if [ "$found" == true ]; then return 0; else return 1; fi
}

## Set a value in the config section
## Usage:
##   section="$(section_set "$section" "key" "value")"
section_set() {
  local section="$1"
  local key="$2"
  local value="$3"

  local found=false
  local output=""
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^$key\s*=\s*.+$ ]]; then
      found=true
      output="$output$key=$value\n"
    elif [ -n "$line" ]; then
      output="$output$line\n"
    fi
  done < <(echo -e "$section")

  if [ "$found" == false ]; then output="$output$key=$value\n"; fi
  printf '%b' "$output"
}

## Delete a value from the config section
## Usage:
##   section="$(section_del "$section" "key")"
section_del() {
  local section="$1"
  local key="$2"

  local output=""
  while IFS= read -r line || [ -n "$line" ]; do
    if ! [[ "$line" =~ ^$key\s*=\s*.+$ ]] && [ -n "$line" ]; then
      output="$output$line\n"
    fi
  done < <(echo -e "$section")

  printf '%b' "$output"
}

## Get a list of keys in the config section
## Usage:
##   for k in $(section_keys "$section"); do
section_keys() {
  local section="$1"
  local keys=()
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^(.*)\s*= ]]; then
      keys+=("${BASH_REMATCH[1]}")
    fi
  done < <(echo -e "$section")

  echo -e "${keys[@]}"
}

## Check if the given value is present in the config section
## Usage:
##   if section_has "$section" "key"; then
section_has() {
  [[ " $(section_keys "$1")" = *" $2 "* ]]
}
