#!/bin/bash

CONFIG_FILE=""

## Initialize the config file
## Usage: config_init myfile.ini
config_init() {
  CONFIG_FILE="$1"
  if ! [[ -f "$CONFIG_FILE" ]]; then
    if ! [[ -d "$(dirname "$CONFIG_FILE")" ]]; then
      linfo "Creating new local dotfiles repo $(lscolor "$(dirname "$CONFIG_FILE")")"
      mkdir -p "$(dirname "$CONFIG_FILE")"
    fi
    linfo "Creating new empty config file $(lscolor "$CONFIG_FILE")"
    touch "$CONFIG_FILE"
  fi
}

CONFIG_SECTION_KEY=""
CONFIG_SECTION=""

## Get a section from the config file
## Usage: 
##   config_get key
##   section="$(config_get key)"
config_get() {
  CONFIG_SECTION_KEY="$1"
  CONFIG_SECTION=""

  local found=false
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ $line =~ ^\[(.+)\]$ ]]; then
      if [[ "${BASH_REMATCH[1]}" == "$1" ]]; then
        found=true
      elif [[ $found == true ]]; then
        break
      fi
    elif [[ $found == true ]]; then
      CONFIG_SECTION="$CONFIG_SECTION$line\n"
    fi
  done < "$CONFIG_FILE"

  echo "$CONFIG_SECTION"
  if [[ $found == true ]]; then return 0; else return 1; fi
}

## Write a section to the config file
## Usage:
##   config_set
##   config_set key
##   config_set key body
config_set() {
  local key="${1:-$CONFIG_SECTION_KEY}"
  local body="${2:-$CONFIG_SECTION}"

  local copy=true
  local found=false
  local output=""
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ $line =~ ^\[(.+)\]$ ]]; then
      if [[ "${BASH_REMATCH[1]}" == "$key" ]]; then
        found=true
        copy=false
        output="${output}[$key]\n$body"
      else
        output="$output$line\n"
        copy=true
      fi
    elif [[ $copy == true ]]; then
      output="$output$line\n"
    fi
  done < "$CONFIG_FILE"

  if [[ $found == false ]]; then
    if [[ "$key" =~ ^host/* ]]; then
      output="[$key]\n$body$output"
    else
      output="${output}[$key]\n$body"
    fi
  fi

  printf "%b" "$output" > "$CONFIG_FILE"
}

## Delete a section from the config file
## Usage: config_del key
config_del() {
  local key="$1"

  local output=""
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ $line =~ ^\[(.+)\]$ ]]; then
      if [[ "${BASH_REMATCH[1]}" == "$key" ]]; then
        copy=false
      else
        output="$output$line\n"
        copy=true
      fi
    elif [[ $copy == true ]]; then
      output="$output$line\n"
    fi
  done < "$CONFIG_FILE"

  printf "%b" "$output" > "$CONFIG_FILE"
}

## Return an array of sections in the config file
## Usage:
##   for k in $(config_keys); do ...
config_keys() {
  local keys=()
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ $line =~ ^\[([A-Za-z0-9/]+)\]$ ]]; then
      keys+=("${BASH_REMATCH[1]}")
    fi
  done < "$CONFIG_FILE"
  echo "${keys[@]}"
}

## Returns true if the specified section exists in the config file
## Usage:
##  if config_has "key"; then ...
config_has() {
  [[ " $(config_keys) " =~ " $1 " ]]
}

## Get a value from the config section
## Usage: 
##   value="$(section_get key)"
##   value="$(section_get key "$section")"
section_get() {
  local key="$1"
  local body="${2:-$CONFIG_SECTION}"

  local found=false
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ $line =~ ^$key\s*=\s*(.+)\s*$ ]]; then
      found=true
      echo "${BASH_REMATCH[1]}"
      break
    fi
  done < <(echo -e "$body")
  if [[ $found == true ]]; then return 0; else return 1; fi
}

## Add or update a key=value pair in the config section
## Usage:
##   section_set key value
##   section_set key value "$section"
##   section="$(section_set key value)"
##   section="$(section_set key value "$section")"
section_set() {
  local key="$1"
  local value="$2"
  local body="${3:-$CONFIG_SECTION}"

  local found=false
  local output=""
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ $line =~ ^$key\s*=\s*.+$ ]]; then
      found=true
      output="$output$key=$value\n"
    elif [[ -n "$line" ]]; then
      output="$output$line\n"
    fi
  done < <(echo -e "$body")

  if [[ $found == false ]]; then
    output="$output$key=$value\n"
  fi

  CONFIG_SECTION="$output\n"
  echo "$output"
}

## Delete a value from the config section
## Usage: 
##   section_del key
##   section_del key "$section"
##   section="$(section_del key)"
##   section="$(section_del key "$section")"
section_del() {
  local key="$1"
  local body="${2:-$CONFIG_SECTION}"

  local output=""
  while IFS= read -r line || [ -n "$line" ]; do
    if ! [[ $line =~ ^$key\s*=\s*.+$ ]] && [[ -n "$line" ]]; then
      output="$output$line\n"
    fi
  done < <(echo -e "$body")

  CONFIG_SECTION="$output\n"
  echo "$output"
}

## Return an array of keys in the config section
## Usage:
##   for k in $(section_keys); do ...
##   for k in $(section_keys "$section"); do ...
section_keys() {
  local body="${1:-$CONFIG_SECTION}"
  local keys=()
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ $line =~ ^(.*)\s*= ]]; then
      keys+=("${BASH_REMATCH[1]}")
    fi
  done < <(echo -e "$body")
  echo -e "${keys[@]}"
}

## Returns true if the specified key exists in the config section
## Usage:
##  if section_has "key"; then ...
##  if section_has "key" "$section"; then ...
section_has() {
  [[ " $(section_keys "$2") " =~ " $1 " ]]
}
