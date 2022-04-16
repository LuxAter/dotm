setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  TEST_DIR="/tmp/bats_test_data"

  mkdir -p "$TEST_DIR"
  cat > "$TEST_DIR/file_a" <<EOL
This is a test file, the first of two
EOL
  cat > "$TEST_DIR/file_b" <<EOL
This is a test file, the second of two
EOL

  source ./src/lib/fs.sh
}

teardown() {
  [ -d "$TEST_DIR" ] && rm -rf "$TEST_DIR"
}

@test "Hash is correct for files" {
  run fs_hash "$TEST_DIR/file_a"
  assert_output "6a2229507b069e1f64e3a4555b8992eb"

  run fs_hash "$TEST_DIR/file_b"
  assert_output "85e124a1a05cc9a7ad2c12a467ca63c8"
}

@test "Hash is correct for directories" {
  run fs_hash "$TEST_DIR"
  assert_output "0ac6df644cb2f98ef6826123269b443c"
}

# vim:ft=sh
