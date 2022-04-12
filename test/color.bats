setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  UNIT_TESTS=true
  source ./src/lib/color.sh
}

@test "Enable color for tty" {
  configure_color true
  run red "Hello World"
  assert_output "\e[31mHello World\e[0m"
}

@test "Disable color for non-tty" {
  configure_color false
  run red "Hello World"
  assert_output "Hello World"
}

@test "Disable color when NO_COLOR is set" {
  NO_COLOR=true
  configure_color true
  run red "Hello World"
  assert_output "Hello World"
}

@test "Use LS_COLOR for tty" {
  LS_COLORS='*.tgz=38;5;40:*.zsh=38;5;172:*.zshenv=1:';
  configure_color true

  run lscolor "/home/user/testing.tgz"
  assert_output "\e[38;5;40m/home/user/testing.tgz\e[0m"

  run lscolor "/home/user/testing.zsh"
  assert_output "\e[38;5;172m/home/user/testing.zsh\e[0m"

  run lscolor "/home/user/.zshenv"
  assert_output "\e[1m/home/user/.zshenv\e[0m"

  run lscolor "/home/user/testing.md"
  assert_output "\e[32m/home/user/testing.md\e[0m"
}

@test "Disable LS_COLOR for non-tty" {
  LS_COLORS='*.tgz=38;5;40:*.zsh=38;5;172:*.zshenv=1:';
  configure_color false

  run lscolor "/home/user/testing.tgz"
  assert_output "/home/user/testing.tgz"

  run lscolor "/home/user/testing.zsh"
  assert_output "/home/user/testing.zsh"

  run lscolor "/home/user/.zshenv"
  assert_output "/home/user/.zshenv"

  run lscolor "/home/user/testing.md"
  assert_output "/home/user/testing.md"
}

@test "Disable LS_COLOR when NO_COLOR is set" {
  NO_COLOR=true
  LS_COLORS='*.tgz=38;5;40:*.zsh=38;5;172:*.zshenv=1:';
  configure_color false

  run lscolor "/home/user/testing.tgz"
  assert_output "/home/user/testing.tgz"

  run lscolor "/home/user/testing.zsh"
  assert_output "/home/user/testing.zsh"

  run lscolor "/home/user/.zshenv"
  assert_output "/home/user/.zshenv"

  run lscolor "/home/user/testing.md"
  assert_output "/home/user/testing.md"
}

# vim:ft=sh
