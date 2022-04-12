setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  UNIT_TESTS=true
  source ./src/lib/color.sh
  source ./src/lib/ui.sh
}

@test "Logs are written to stderr" {
  run linfo "Hello World"
  assert_output "[I] Hello World"

  run lwarn "Hello World"
  assert_output "[W] Hello World"

  run lerror "Hello World"
  assert_output "[E] Hello World"
}

@test "Log arguments are concatinated" {
  run linfo Hello World
  assert_output "[I] Hello World"

  run lwarn Hello World
  assert_output "[W] Hello World"

  run lerror Hello World
  assert_output "[E] Hello World"
}

@test "Confirm prompt accepts yYnN" {
  run bash -c "export UNIT_TESTS=true; source ./src/lib/color.sh && source ./src/lib/ui.sh && echo 'y' | confirm 'Test confirm'"
  assert_success

  run bash -c "export UNIT_TESTS=true; source ./src/lib/color.sh && source ./src/lib/ui.sh && echo 'Y' | confirm 'Test confirm'"
  assert_success

  run bash -c "export UNIT_TESTS=true; source ./src/lib/color.sh && source ./src/lib/ui.sh && echo 'n' | confirm 'Test confirm'"
  assert_failure

  run bash -c "export UNIT_TESTS=true; source ./src/lib/color.sh && source ./src/lib/ui.sh && echo 'N' | confirm 'Test confirm'"
  assert_failure
}

@test "Confirm retries prompt on invalid input" {
  run bash -c "export UNIT_TESTS=true; source ./src/lib/color.sh && source ./src/lib/ui.sh && echo 'hy' | confirm 'Test confirm'"
  assert_success
  assert_output --partial "[W] Confirmation response must be 'y' or 'n'"
}

@test "Confirm timeout after 10s" {
  run bash -c "export UNIT_TESTS=true; source ./src/lib/color.sh && source ./src/lib/ui.sh && confirm 'Test confirm'"
  assert_failure
  assert_output --partial "[W] No user input after 10s, assuming 'n'"
}

@test "Confirm prompt is skipped for non-tty" {
  UNIT_TESTS=false
  run confirm "Test confirm"
  assert_failure
}

@test "Password prompt saves user password" {
  run bash -c "export UNIT_TESTS=true; source ./src/lib/color.sh && source ./src/lib/ui.sh && echo 'password123' | password 'Test password'"
  assert_success
  assert_output --partial "password123"
}

@test "Password prompt timeout after 30s" {
  run bash -c "export UNIT_TESTS=true; source ./src/lib/color.sh && source ./src/lib/ui.sh && password 'Test password'"
  assert_failure
  assert_output --partial "[W] No user input after 30s or password was empty"
}

@test "Password is skipped for non-tty" {
  UNIT_TESTS=false
  run password "Test confirm"
  assert_failure
}

# vim:ft=sh
