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

@test "Archive compresses text files" {
  run --separate-stderr fs_archive "$TEST_DIR/file_a"
  assert_success
  assert_output "$TEST_DIR/file_a.gz"
  assert_file_exists "$TEST_DIR/file_a.gz"

  run --separate-stderr fs_archive "$TEST_DIR/file_b"
  assert_success
  assert_output "$TEST_DIR/file_b.gz"
  assert_file_exists "$TEST_DIR/file_b.gz"
}

@test "Archive file set destination path" {
  run --separate-stderr fs_archive "$TEST_DIR/file_a" "$TEST_DIR/archive_a.gz"
  assert_success
  assert_output "$TEST_DIR/archive_a.gz"
  assert_file_exists "$TEST_DIR/archive_a.gz"
  assert_file_not_exists "$TEST_DIR/fila_a.gz"
}

@test "Archive compresses directories" {
  run --separate-stderr fs_archive "$TEST_DIR/"
  assert_success
  assert_output "$ROOT_TEST_DIR/lib.fs.tgz"
  assert_file_exists "$ROOT_TEST_DIR/lib.fs.tgz"
}

@test "Archive directory set destination path" {
  run --separate-stderr fs_archive "$TEST_DIR/" "$ROOT_TEST_DIR/archive_lib.fs.tgz"
  assert_success
  assert_output "$ROOT_TEST_DIR/archive_lib.fs.tgz"
  assert_file_exists "$ROOT_TEST_DIR/archive_lib.fs.tgz"
  assert_file_not_exists "$ROOT_TEST_DIR/lib.fs.tgz"
}

@test "Archive file round trip is consistent" {
  run --separate-stderr fs_archive "$TEST_DIR/file_a" "$TEST_DIR/archive_a.gz"
  assert_success
  assert_output "$TEST_DIR/archive_a.gz"
  assert_file_exists "$TEST_DIR/archive_a.gz"

  run --separate-stderr fs_unarchive "$TEST_DIR/archive_a.gz"
  assert_success
  assert_output "$TEST_DIR/archive_a"
  assert_file_exists "$TEST_DIR/archive_a"

  assert_equal "$(fs_hash "$TEST_DIR/file_a")" "$(fs_hash "$TEST_DIR/archive_a")"
}

@test "Archive directory round trip is consistent" {
  run --separate-stderr fs_archive "$TEST_DIR" "$ROOT_TEST_DIR/archive_lib.fs.tgz"
  assert_output "$ROOT_TEST_DIR/archive_lib.fs.tgz"
  assert_success
  assert_file_exists "$ROOT_TEST_DIR/archive_lib.fs.tgz"

  run --separate-stderr fs_unarchive "$ROOT_TEST_DIR/archive_lib.fs.tgz"
  assert_success
  assert_output "$ROOT_TEST_DIR/archive_lib.fs"
  assert_dir_exists "$ROOT_TEST_DIR/archive_lib.fs"

  assert_equal "$(fs_hash "$ROOT_TEST_DIR/lib.fs")" "$(fs_hash "$ROOT_TEST_DIR/archive_lib.fs")"
}

# vim:ft=sh
