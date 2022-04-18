#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
CONFIG_FILE="${DOTFILES:-$HOME/.dotfiles}/dot.ini"

[ -t 1 ] && configure_color true
[ -t 1 ] && configure_prompts true
configure_logging info
[ -t 1 ] || configure_logging debug
