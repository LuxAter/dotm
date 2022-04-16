#!/usr/bin/env bash

curl 'https://raw.githubusercontent.com/LuxAter/dotm/blob/main/dotm' -o /tmp/dotm
bash /tmp/dotm update --path "$HOME/.local/bin"
rm -f /tmp/dotm
