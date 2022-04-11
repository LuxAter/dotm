validate_file_or_dir_exists() {
  [[ -d "$1" ]] || [[ -f "$1" ]] || echo "must be an existing file or directory"
}
