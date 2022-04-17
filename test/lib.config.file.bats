setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  TEST_DIR="/tmp/bats_test_data"

  mkdir -p "$TEST_DIR"
  cat > "$TEST_DIR/dot.ini" <<EOL
[section1]
key1=value1
key2=value2

[section2]
key3=value3
key4=value4
EOL

  source ./src/lib/config.sh
}

teardown() {
  [ -d "$TEST_DIR" ] && rm -rf "$TEST_DIR"
}

@test "Read section from config file" {
  run config_get "$TEST_DIR/dot.ini" "section1"
  assert_success
  assert_line -n 0 "key1=value1"
  assert_line -n 1 "key2=value2"

  run config_get "$TEST_DIR/dot.ini" "section2"
  assert_success
  assert_line -n 0 "key3=value3"
  assert_line -n 1 "key4=value4"
}

@test "Read invalid section from config" {
  run config_get "$TEST_DIR/dot.ini" "section3"
  assert_failure
  assert_output ""
}

@test "Write new section into the config" {
  local sec="key_a=valuea\nkey_b=valueb"
  run config_set "$TEST_DIR/dot.ini" "section3" "$sec"
  assert_success

  assert_file_exists "$TEST_DIR/dot.ini"
  assert_file_contains "$TEST_DIR/dot.ini" "key_a=valuea"
  assert_file_contains "$TEST_DIR/dot.ini" "key_b=valueb"
}

@test "Delete section from config" {
  run config_del "$TEST_DIR/dot.ini" "section1"
  assert_success

  run config_get "$TEST_DIR/dot.ini" "section1" 
  assert_failure
  assert_output ""
}

@test "Get section keys" {
  run config_keys "$TEST_DIR/dot.ini"
  assert_success
  assert_output "section1 section2"

  run config_has "$TEST_DIR/dot.ini" "section1"
  assert_success

  run config_has "$TEST_DIR/dot.ini" "section3"
  assert_failure
}

# vim:ft=sh
