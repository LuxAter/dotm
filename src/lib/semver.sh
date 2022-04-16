#!/usr/bash

semver_eq() {
  vera="$1"
  verb="$2"

  majora="${vera%%.*}"
  majorb="${verb%%.*}"

  minora="${vera#*.}"
  minora="${minora%%.*}"
  minorb="${verb#*.}"
  minorb="${minorb%%.*}"
  patcha="${vera##*.}"
  patchb="${verb##*.}"

  if [ "$majora" -eq "$majorb" ] && [ "$minora" -eq "$minorb" ] && [ "$patcha" -eq "$patchb" ]; then
    return 0
  else
    return 1
  fi
}

semver_gt() {
  vera="$1"
  verb="$2"

  majora="${vera%%.*}"
  majorb="${verb%%.*}"

  minora="${vera#*.}"
  minora="${minora%%.*}"
  minorb="${verb#*.}"
  minorb="${minorb%%.*}"
  patcha="${vera##*.}"
  patchb="${verb##*.}"

  if [ "$majora" -gt "$majorb" ]; then
    return 0
  elif [ "$majora" -eq "$majorb" ] && [ "$minora" -gt "$minorb" ]; then
    return 0
  elif [ "$majora" -eq "$majorb" ] && [ "$minora" -eq "$minorb" ] && [ "$patcha" -gt "$patchb" ]; then
    return 0
  else
    return 1
  fi
}
