setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  UNIT_TESTS=true
  OPTIONS="Option 1;Option 2;Option C;Option D"

  source ./src/lib/ui/colors.sh
  source ./src/lib/ui/prompts.sh
  configure_prompts true
}

@test "Select prompt accepts a valid choice" {
  run --separate-stderr bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "1" | pselect "Sample select" "$OPTIONS"
EOL
  assert_success
  assert_output "Option 1"

  run --separate-stderr bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "2" | pselect "Sample select" "$OPTIONS"
EOL
  assert_success
  assert_output "Option 2"

  run --separate-stderr bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "3" | pselect "Sample select" "$OPTIONS"
EOL
  assert_success
  assert_output "Option C"

  run --separate-stderr bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "4" | pselect "Sample select" "$OPTIONS"
EOL
  assert_success
  assert_output "Option D"
}

@test "Select prompt reprompts on invalid input" {
  run --separate-stderr bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo -e "hey\n1" | pselect "Sample select" "$OPTIONS"
EOL
  assert_success
  assert_output "Option 1"
  output="$stderr"
  assert_output --partial "> Input must be an integer between 1 and 4"

  run --separate-stderr bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo -e "0\n1" | pselect "Sample select" "$OPTIONS"
EOL
  assert_success
  assert_output "Option 1"
  output="$stderr"
  assert_output --partial "> Input must be an integer between 1 and 4"

  run --separate-stderr bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo -e "5\n1" | pselect "Sample select" "$OPTIONS"
EOL
  assert_success
  assert_output "Option 1"
  output="$stderr"
  assert_output --partial "> Input must be an integer between 1 and 4"
}

@test "Select prompt uses default when provided" {
  run --separate-stderr bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "" | pselect "Sample select" "$OPTIONS" 1
EOL
  assert_success
  assert_output "Option 2"
}

@test "Select default can be overriden" {
  run --separate-stderr bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "3" | pselect "Sample select" "$OPTIONS" 1
EOL
  assert_success
  assert_output "Option C"
}

@test "Select prompt is skipped when not interactive" {
  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
pselect "Sample select" "$OPTIONS"
EOL
  assert_success
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
echo "1" | pselect "Sample select" "$OPTIONS"
EOL
  assert_success
  assert_output ""
}

@test "Select prompt uses default value when not interactive" {
  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
pselect "Sample select" "$OPTIONS" 3
EOL
  assert_success
  assert_output "Option D"

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
echo "1" | pselect "Sample select" "$OPTIONS" 3
EOL
  assert_success
  assert_output "Option D"
}

# vim:ft=sh
