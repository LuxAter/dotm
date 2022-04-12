setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 


  source ./src/lib/config.sh
  CONFIG_FILE="/tmp/dot.ini"
  cat >"$CONFIG_FILE" <<EOL
[section1]
keya=value1
keyb=value2

[section2]
keyc=value3
keyd=value4
EOL
}

teardown() {
    rm -f /tmp/dot.ini
}

@test "Read configuration file" {
  run config_keys
  assert_success
  assert_output "section1 section2"

  run config_get "section1"
  assert_success
  assert_output "keya=value1\nkeyb=value2\n\n"
  local section="$output"

  run section_keys "$section"
  assert_success
  assert_output "keya keyb"

  run section_get "keya" "$section"
  assert_success
  assert_output "value1"

  run section_get "keyb" "$section"
  assert_success
  assert_output "value2"

  run config_get "section2"
  assert_success
  assert_output "keyc=value3\nkeyd=value4\n"
  local section="$output"

  run section_keys "$section"
  assert_success
  assert_output "keyc keyd"

  run section_get "keyc" "$section"
  assert_success
  assert_output "value3"

  run section_get "keyd" "$section"
  assert_success
  assert_output "value4"
}

@test "Read invalid key/section" {
  run config_keys
  assert_success
  assert_output "section1 section2"

  run config_get "section1"
  assert_success
  assert_output "keya=value1\nkeyb=value2\n\n"
  local section="$output"

  run section_get "keyc" "$section"
  assert_failure
  assert_output ""

  run config_get "section3"
  assert_failure
  assert_output ""
}

@test "Set existing config value" {
  run config_keys
  assert_success
  assert_output "section1 section2"

  run config_get "section1"
  assert_success
  assert_output "keya=value1\nkeyb=value2\n\n"
  local section="$output"

  run section_set "keya" "newvalue" "$section"
  assert_success
  assert_output "keya=newvalue\nkeyb=value2\n"
  local section="$output"

  run config_set "section1" "$section"
  assert_success

  assert_exists "$CONFIG_FILE"
  local file="$(cat "$CONFIG_FILE")"
  assert_equal "$file" "$(printf "[section1]\nkeya=newvalue\nkeyb=value2\n[section2]\nkeyc=value3\nkeyd=value4\n")"
}

@test "Set new value in config section" {
  run config_keys
  assert_success
  assert_output "section1 section2"

  run config_get "section1"
  assert_success
  assert_output "keya=value1\nkeyb=value2\n\n"
  local section="$output"

  run section_set "keye" "newvalue" "$section"
  assert_success
  assert_output "keya=value1\nkeyb=value2\nkeye=newvalue\n"
  local section="$output"

  run config_set "section1" "$section"
  assert_success

  assert_exists "$CONFIG_FILE"
  local file="$(cat "$CONFIG_FILE")"
  assert_equal "$file" "$(printf "[section1]\nkeya=value1\nkeyb=value2\nkeye=newvalue\n[section2]\nkeyc=value3\nkeyd=value4\n")"
}

@test "Set new value new config section" {
  run config_keys
  assert_success
  assert_output "section1 section2"

  run section_set "keye" "newvalue" ""
  assert_success
  assert_output "keye=newvalue\n"
  local section="$output"

  run config_set "section3" "$section"
  assert_success

  assert_exists "$CONFIG_FILE"
  local file="$(cat "$CONFIG_FILE")"
  assert_equal "$file" "$(printf "[section1]\nkeya=value1\nkeyb=value2\n\n[section2]\nkeyc=value3\nkeyd=value4\n[section3]\nkeye=newvalue\n")"
}

@test "Config delete key and section" {
  run config_keys
  assert_success
  assert_output "section1 section2"

  run config_get "section1"
  assert_success
  assert_output "keya=value1\nkeyb=value2\n\n"
  local section="$output"

  run section_del "keya" "$section"
  assert_success
  assert_output "keyb=value2\n"
  local section="$output"

  run config_del "section1"
  assert_success

  assert_exists "$CONFIG_FILE"
  local file="$(cat "$CONFIG_FILE")"
  # echo "$BASE_CONFIG" >"$CONFIG_FILE"
  assert_equal "$file" "$(printf "[section2]\nkeyc=value3\nkeyd=value4\n")"
}

@test "Config check section/key exist" {
  run config_has "section1"
  assert_success

  run config_has "section3"
  assert_failure

  run config_get "section2"
  assert_success
  assert_output "keyc=value3\nkeyd=value4\n"
  local section="$output"

  run section_has "keyc" "$section"
  assert_success

  run section_has "keye" "$section"
  assert_failure
}

# vim:ft=sh
