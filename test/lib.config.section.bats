setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  SECTION="key1=value1\nkey2=value2\n"

  source ./src/lib/config.sh
}

@test "Get value from section" {
  run section_get "$SECTION" "key1"
  assert_success
  assert_output "value1"

  run section_get "$SECTION" "key2"
  assert_success
  assert_output "value2"
}

@test "Read invalid value from the section" {
  run section_get "$SECTION" "key3"
  assert_failure
  assert_output ""
}

@test "Write new value into the section" {
  run section_set "$SECTION" "key3" "value3"
  assert_success
  assert_line -n 0 "key1=value1"
  assert_line -n 1 "key2=value2"
  assert_line -n 2 "key3=value3"
}

@test "Updating an existing value in the section" {
  run section_set "$SECTION" "key2" "newvalue"
  assert_success
  assert_line -n 0 "key1=value1"
  assert_line -n 1 "key2=newvalue"
}

@test "Delete value from section" {
  run section_del "$SECTION" "key1"
  assert_success
  assert_line -n 0 "key2=value2"
}

@test "Get keys in section" {
  run section_keys "$SECTION"
  assert_success
  assert_output "key1 key2"

  run section_has "$SECTION" "key1"
  assert_success

  run section_has "$SECTION" "key3"
  assert_failure
}

# vim:ft=sh
