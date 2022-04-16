setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  UNIT_TESTS=true

  source ./src/lib/ui/colors.sh
  source ./src/lib/ui/prompts.sh
  configure_prompts true
}

@test "Password prompt accepts any text input" {
  run --separate-stderr bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "hello world" | ppassword "Sample password"
EOL
  assert_success
  assert_output "hello world"
}

@test "Password validates input must not be empty" {
  run --separate-stderr bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo -e "\nhello world" | ppassword "Sample password"
EOL
  assert_success
  assert_output "hello world"
  output="$stderr"
  assert_output --partial "> Input must not be empty"
}

@test "Password prompt is skipped when not interactive" {
  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
ppassword "Sample password"
EOL
  assert_success
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
echo "Hello" | ppassword "Sample password"
EOL
  assert_success
  assert_output ""
}

# vim:ft=sh
