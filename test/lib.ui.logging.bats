setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  UNIT_TESTS=true

  source ./src/lib/ui/colors.sh
  source ./src/lib/ui/logging.sh

  configure_logging trace
}

@test "Log functions include appropriate prefix" {
  run ltrace "Hello World"
  assert_output "[T] Hello World"

  run ldebug "Hello World"
  assert_output "[D] Hello World"

  run linfo "Hello World"
  assert_output "[I] Hello World"

  run lwarn "Hello World"
  assert_output "[W] Hello World"

  run lerror "Hello World"
  assert_output "[E] Hello World"
}

@test "Log output is written to stderr" {
  run --separate-stderr linfo "Hello World"
  assert_equal "$stderr" "[I] Hello World"
  assert_equal "$output" ""
}

@test "Log level trace shows all logs" {
  configure_logging trace
  run ltrace "Hello World"
  assert_output "[T] Hello World"

  run ldebug "Hello World"
  assert_output "[D] Hello World"

  run linfo "Hello World"
  assert_output "[I] Hello World"

  run lwarn "Hello World"
  assert_output "[W] Hello World"

  run lerror "Hello World"
  assert_output "[E] Hello World"
}

@test "Log level debug hides trace logs" {
  configure_logging debug
  run ltrace "Hello World"
  refute_output "[T] Hello World"

  run ldebug "Hello World"
  assert_output "[D] Hello World"

  run linfo "Hello World"
  assert_output "[I] Hello World"

  run lwarn "Hello World"
  assert_output "[W] Hello World"

  run lerror "Hello World"
  assert_output "[E] Hello World"
}

@test "Log level info hides debug and trace logs" {
  configure_logging info
  run ltrace "Hello World"
  refute_output "[T] Hello World"

  run ldebug "Hello World"
  refute_output "[D] Hello World"

  run linfo "Hello World"
  assert_output "[I] Hello World"

  run lwarn "Hello World"
  assert_output "[W] Hello World"

  run lerror "Hello World"
  assert_output "[E] Hello World"
}

@test "Log level warning only shows warning and error logs" {
  configure_logging warning
  run ltrace "Hello World"
  refute_output "[T] Hello World"

  run ldebug "Hello World"
  refute_output "[D] Hello World"

  run linfo "Hello World"
  refute_output "[I] Hello World"

  run lwarn "Hello World"
  assert_output "[W] Hello World"

  run lerror "Hello World"
  assert_output "[E] Hello World"
}

@test "Log level error only shows error logs" {
  configure_logging error
  run ltrace "Hello World"
  refute_output "[T] Hello World"

  run ldebug "Hello World"
  refute_output "[D] Hello World"

  run linfo "Hello World"
  refute_output "[I] Hello World"

  run lwarn "Hello World"
  refute_output "[W] Hello World"

  run lerror "Hello World"
  assert_output "[E] Hello World"
}

# vim:ft=sh
