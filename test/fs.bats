setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  HOME="/home/user"
  DOTFILES="/home/user/.dotfile"
  source ./src/lib/fs.sh

  mkdir -p ./test_data
  cat > ./test_data/a <<EOL
this is a test file
with lots of content
EOL
  cat > ./test_data/b <<EOL
this is a different test
file with different content
EOL
}

teardown() {
  rm -rf ./test_data
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

@test "Get dotfile path of system file" {
  run fs_dotfile "~/.zshrc"
  assert_output "/home/user/.dotfile/zshrc"

  run fs_dotfile "/etc/zshrc"
  assert_output "/home/user/.dotfile/etc/zshrc"

  run fs_dotfile "~/.zshrc" "zsh"
  assert_output "/home/user/.dotfile/zsh.zshrc"

  run fs_dotfile "/etc/zshrc" "zsh"
  assert_output "/home/user/.dotfile/etc/zsh.zshrc"
}

@test "Hash generates correct file hash" {
  run fs_hash "./test_data/a"
  assert_output "a62da3d1ecd524a9b451f7820f5f7466"

  run fs_hash "./test_data/b"
  assert_output "870ce94be5e8999d430b64d789e86254"
}

@test "Hash generates correct directory hash" {
  run fs_hash "./test_data"
  assert_output --regexp "[0-9a-f]{32}"
}

# vim:ft=sh
