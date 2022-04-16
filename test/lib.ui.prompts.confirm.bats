setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  UNIT_TESTS=true

  source ./src/lib/ui/colors.sh
  source ./src/lib/ui/prompts.sh
  configure_prompts true
}

@test "Confirm accepts y/n input" {
  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "y" | pconfirm "Sample confirmation"
EOL
  assert_success
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "Y" | pconfirm "Sample confirmation"
EOL
  assert_success
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "n" | pconfirm "Sample confirmation"
EOL
  assert_failure
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "N" | pconfirm "Sample confirmation"
EOL
  assert_failure
  assert_output ""

}

@test "Confirm reprompts on invalid argument" {
  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "hy" | pconfirm "Sample confirmation"
EOL
  assert_success
  assert_output --partial "> Input must be 'y' or 'n', not 'h'"

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "hn" | pconfirm "Sample confirmation"
EOL
  assert_failure
  assert_output --partial "> Input must be 'y' or 'n', not 'h'"

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo -e "\ny" | pconfirm "Sample confirmation"
EOL
  assert_success
  assert_output --partial "> An input is required, enter 'y' or 'n'"
}

@test "Confirm accepts uses default options" {
  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo -e "\n" | pconfirm "Sample confirmation" true
EOL
  assert_success
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo -e "h\n" | pconfirm "Sample confirmation" true
EOL
  assert_success
  assert_output --partial "> Input must be 'y' or 'n', not 'h'"

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo -e "\n" | pconfirm "Sample confirmation" false
EOL
  assert_failure
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo -e "h\n" | pconfirm "Sample confirmation" false
EOL
  assert_failure
  assert_output --partial "> Input must be 'y' or 'n', not 'h'"
}

@test "Confirm default options can be overridden" {
  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "y" | pconfirm "Sample confirmation" true
EOL
  assert_success
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "n" | pconfirm "Sample confirmation" true
EOL
  assert_failure
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "y" | pconfirm "Sample confirmation" false
EOL
  assert_success
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "n" | pconfirm "Sample confirmation" false
EOL
  assert_failure
  assert_output ""
}

@test "Confirm prompt is skipped if not interactive" {
  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
pconfirm "Sample confirmation"
EOL
  assert_failure
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
echo "y" | pconfirm "Sample confirmation"
EOL
  assert_failure
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
echo "n" | pconfirm "Sample confirmation"
EOL
  assert_failure
  assert_output ""
}

@test "Confirm prompt uses default value when not interactive" {
  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
pconfirm "Sample confirmation" false
EOL
  assert_failure
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
echo "y" | pconfirm "Sample confirmation" false
EOL
  assert_failure
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
echo "n" | pconfirm "Sample confirmation" false
EOL
  assert_failure
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
pconfirm "Sample confirmation" true
EOL
  assert_success
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
echo "y" | pconfirm "Sample confirmation" true
EOL
  assert_success
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
echo "n" | pconfirm "Sample confirmation" true
EOL
  assert_success
  assert_output ""
}

# vim:ft=sh
