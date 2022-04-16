## Code here runs inside the initialize() function
## Use it for anything that you need to run before any other function, like
## setting environment vairables:
## CONFIG_FILE=settings.ini
##
## Feel free to empty (but not delete) this file.

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

[ -t 1 ] && configure_color true
[ -t 1 ] && configure_prompts true
configure_logging info
[ -t 1 ] || configure_logging debug


