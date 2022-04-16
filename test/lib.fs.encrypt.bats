setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  ROOT_TEST_DIR="/tmp/bats_test_data"
  TEST_DIR="$ROOT_TEST_DIR/lib.fs"

  mkdir -p "$TEST_DIR"
  cat > "$TEST_DIR/file_a" <<EOL
This is a test file, the first of two
EOL
  cat > "$TEST_DIR/file_b" <<EOL
This is a test file, the second of two
EOL

  source ./src/lib/ui/colors.sh
  source ./src/lib/ui/logging.sh
  source ./src/lib/fs.sh
}

teardown() {
  [ -d "$ROOT_TEST_DIR" ] && rm -rf "$ROOT_TEST_DIR"
}

@test "Encrypt text files" {
  run --separate-stderr fs_encrypt "password123" "$TEST_DIR/file_a"
  assert_success
  assert_output "$TEST_DIR/file_a.enc"
  assert_file_exists "$TEST_DIR/file_a.enc"
  assert_not_equal "$(fs_hash "$TEST_DIR/file_a.enc")" "$(fs_hash "$TEST_DIR/file_a")"

  run --separate-stderr fs_encrypt "password123" "$TEST_DIR/file_b"
  assert_success
  assert_output "$TEST_DIR/file_b.enc"
  assert_file_exists "$TEST_DIR/file_b.enc"
  assert_not_equal "$(fs_hash "$TEST_DIR/file_b.enc")" "$(fs_hash "$TEST_DIR/file_b")"
}

@test "Encrypt file set destination path" {
  run --separate-stderr fs_encrypt "password123" "$TEST_DIR/file_a" "$TEST_DIR/enc_a.enc"
  assert_success
  assert_output "$TEST_DIR/enc_a.enc"
  assert_file_exists "$TEST_DIR/enc_a.enc"
  assert_file_not_exists "$TEST_DIR/file_a.enc"
  assert_not_equal "$(fs_hash "$TEST_DIR/enc_a.enc")" "$(fs_hash "$TEST_DIR/file_a")"
}

@test "Encryption round trip is consistent" {
  run --separate-stderr fs_encrypt "password123" "$TEST_DIR/file_a" "$TEST_DIR/enc_a.enc"
  assert_success
  assert_output "$TEST_DIR/enc_a.enc"
  assert_file_exists "$TEST_DIR/enc_a.enc"
  
  run --separate-stderr fs_decrypt "password123" "$TEST_DIR/enc_a.enc"
  assert_success
  assert_output "$TEST_DIR/enc_a"
  assert_file_exists "$TEST_DIR/enc_a"

  assert_equal "$(fs_hash "$TEST_DIR/file_a")" "$(fs_hash "$TEST_DIR/enc_a")"
}

# vim:ft=sh
