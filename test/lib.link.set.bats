setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  ROOT_TEST_DIR="/tmp/bats_test_data"
  DOTDIR="$ROOT_TEST_DIR/dot"
  SYSDIR="$ROOT_TEST_DIR/sys"

  mkdir -p "$DOTDIR"
  mkdir -p "$SYSDIR"
  cat > "$DOTDIR/file_a" <<EOL
This is a test file, the first of two
EOL
  cat > "$DOTDIR/file_b" <<EOL
This is a test file, the second of two
EOL
  ln -s "$DOTDIR/file_b" "$SYSDIR/file_b"

  cat > "$SYSDIR/file_c" <<EOL
This is a test file, the third of three
EOL

  source ./src/lib/ui/colors.sh
  source ./src/lib/ui/logging.sh
  source ./src/lib/fs.sh
  source ./src/lib/link.sh
}

teardown() {
  [ -d "$ROOT_TEST_DIR" ] && rm -rf "$ROOT_TEST_DIR"
}

@test "Set dotfile link" {
  run link_set "$DOTDIR/file_a" "$SYSDIR/file_a" ""
  assert_success
  assert_link_exists "$SYSDIR/file_a"
  assert_symlink_to "$DOTDIR/file_a" "$SYSDIR/file_a"
}

@test "Install dotfile link" {
  run link_install "$DOTDIR/file_a" "$SYSDIR/file_a" ""
  assert_success
  assert_file_exists "$SYSDIR/file_a"
}

@test "Import dotfile link" {
  run link_import "$SYSDIR/file_c" "$DOTDIR/file_c" ""
  assert_success
  assert_file_exists "$DOTDIR/file_c"
  assert_link_exists "$SYSDIR/file_c"
  assert_symlink_to "$DOTDIR/file_c" "$SYSDIR/file_c"
}

# vim:ft=sh
