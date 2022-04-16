setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  UNIT_TESTS=true
  LS_COLORS='*.tgz=38;5;40:*.zsh=38;5;172:*.zshenv=1:';

  source ./src/lib/ui/colors.sh
  configure_color true
}

@test "Base color functions apply correct escape codes" {
  run red "Foo Bar"
  assert_output "\e[31mFoo Bar\e[0m"

  run green "Foo Bar"
  assert_output "\e[32mFoo Bar\e[0m"

  run yellow "Foo Bar"
  assert_output "\e[33mFoo Bar\e[0m"

  run blue "Foo Bar"
  assert_output "\e[34mFoo Bar\e[0m"

  run magenta "Foo Bar"
  assert_output "\e[35mFoo Bar\e[0m"

  run cyan "Foo Bar"
  assert_output "\e[36mFoo Bar\e[0m"

  run bold "Foo Bar"
  assert_output "\e[1mFoo Bar\e[0m"

  run underline "Foo Bar"
  assert_output "\e[4mFoo Bar\e[0m"
}

@test "When disabled escape sequences aren't applied" {
  configure_color false

  run red "Foo Bar"
  assert_output "Foo Bar"

  run green "Foo Bar"
  assert_output "Foo Bar"

  run yellow "Foo Bar"
  assert_output "Foo Bar"

  run blue "Foo Bar"
  assert_output "Foo Bar"

  run magenta "Foo Bar"
  assert_output "Foo Bar"

  run cyan "Foo Bar"
  assert_output "Foo Bar"

  run bold "Foo Bar"
  assert_output "Foo Bar"

  run underline "Foo Bar"
  assert_output "Foo Bar"
}

@test "NO_COLOR overrides color settings" {
  NO_COLOR=true
  configure_color true

  run red "Hello World"
  assert_output "Hello World"
}

@test "Uses LS_COLORS when set" {
  run lscolor "/home/user/testing.tgz"
  assert_output "\e[38;5;40m/home/user/testing.tgz\e[0m"

  run lscolor "/home/user/testing.zsh"
  assert_output "\e[38;5;172m/home/user/testing.zsh\e[0m"

  run lscolor "/home/user/.zshenv"
  assert_output "\e[1m/home/user/.zshenv\e[0m"

  run lscolor "/home/user/testing.md"
  assert_output "\e[32m/home/user/testing.md\e[0m"
}

@test "LS_COLORS is ignored when colors are disabled" {
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
