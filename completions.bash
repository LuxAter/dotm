#!/usr/bin/env bash

# This bash completions script was generated by
# completely (https://github.com/dannyben/completely)
# Modifying it manually is not recommended
_dotm_completions() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local comp_line="${COMP_WORDS[@]:1}"

  case "$comp_line" in
    'completions'*) COMPREPLY=($(compgen -W "--help -h" -- "$cur")) ;;
    'install'*) COMPREPLY=($(compgen -W "--force --help -f -h" -- "$cur")) ;;
    'update'*) COMPREPLY=($(compgen -W "--check --force --help --no-completion --no-dotm --path --url -C -D -U -c -f -h -p" -- "$cur")) ;;
    'remove'*) COMPREPLY=($(compgen -W "--force --help --package -f -h -p" -- "$cur")) ;;
    'unset'*) COMPREPLY=($(compgen -W "--force --help -f -h" -- "$cur")) ;;
    'list'*) COMPREPLY=($(compgen -W "--all --help --raw -a -h -r" -- "$cur")) ;;
    'pull'*) COMPREPLY=($(compgen -W "--help -h" -- "$cur")) ;;
    'push'*) COMPREPLY=($(compgen -W "--help --message -h -m" -- "$cur")) ;;
    'sync'*) COMPREPLY=($(compgen -W "--help --max-frequnecy --message -f -h -m" -- "$cur")) ;;
    'add'*) COMPREPLY=($(compgen -W "--archive --copy --encrypt --force --help --package -a -c -e -f -h -p" -- "$cur")) ;;
    'set'*) COMPREPLY=($(compgen -W "--force --help -f -h" -- "$cur")) ;;
    ''*) COMPREPLY=($(compgen -W "--help --version -h -v add completions install list pull push remove set sync unset update" -- "$cur")) ;;
  esac
}

complete -F _dotm_completions dotm
