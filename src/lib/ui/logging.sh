#!/bin/bash

LOG_LEVEL=0

configure_logging() {
  case "$1" in
    trace) LOG_LEVEL=0;;
    debug) LOG_LEVEL=1;;
    info) LOG_LEVEL=2;;
    warning) LOG_LEVEL=3;;
    error) LOG_LEVEL=4;;
  esac
}

_log() {
  local prefix=""
  case "$1" in
    trace) [ $LOG_LEVEL -gt 0 ] && return 0; prefix="$(cyanBold "T")";;
    debug) [ $LOG_LEVEL -gt 1 ] && return 0; prefix="$(magentaBold "D")";;
    info) [ $LOG_LEVEL -gt 2 ] && return 0; prefix="$(greenBold "I")";;
    warning) [ $LOG_LEVEL -gt 3 ] && return 0; prefix="$(yellowBold "W")";;
    error) [ $LOG_LEVEL -gt 4 ] && return 0; prefix="$(redBold "E")";;
  esac
  shift
  printf "[%b] %b\n" "$prefix" "$*" >&2
}

ltrace() { _log trace "$@"; }
ldebug() { _log debug "$@"; }
linfo() { _log info "$@"; }
lwarn() { _log warning "$@"; }
lerror() { _log error "$@"; }
