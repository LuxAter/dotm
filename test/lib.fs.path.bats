#!/bin/bash

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  HOME="/home/user"
  DOTFILES="/home/user/.dotfile"
  source ./src/lib/fs.sh
}

@test "Expand user directories" {
  run fs_expanduser "~/.zshrc"
  assert_output "/home/user/.zshrc"

  run fs_expanduser "/etc/zshrc"
  assert_output "/etc/zshrc"
}

@test "Get relative user directories" {
  run fs_reluser "~/.zshrc"
  assert_output "~/.zshrc"

  run fs_reluser "/etc/zshrc"
  assert_output "/etc/zshrc"

  run fs_reluser "/home/user/.zshrc"
  assert_output "~/.zshrc"
}

@test "Get relative dotfile directories" {
  run fs_reldot "/home/user/.dotfile/zsh.zshrc"
  assert_output "zsh.zshrc"

  run fs_reldot "/home/user/.dotfile/etc/zsh.zshrc"
  assert_output "etc/zsh.zshrc"
}

@test "Get dotfile path of system file" {
  run fs_dotfile "~/.zshrc"
  assert_output "/home/user/.dotfile/zshrc"

  run fs_dotfile "/etc/zshrc"
  assert_output "/home/user/.dotfile/etc/zshrc"

  run fs_dotfile "~/.zshrc" "zsh"
  assert_output "/home/user/.dotfile/zsh.zshrc"

  run fs_dotfile "/etc/zshrc" "zsh"
  assert_output "/home/user/.dotfile/etc/zsh.zshrc"

  run fs_dotfile "/home/user/.config/starship.toml" "starship"
  assert_output "/home/user/.dotfile/config/starship.starship.toml"

  run fs_dotfile "/home/user/Documents/.config/config.ini" "pkg"
  assert_output "/home/user/.dotfile/Documents/config/pkg.config.ini"

}

# vim:ft=sh
