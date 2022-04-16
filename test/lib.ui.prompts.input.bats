setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  UNIT_TESTS=true

  source ./src/lib/ui/colors.sh
  source ./src/lib/ui/prompts.sh
  configure_prompts true
}

@test "Input prompt accepts any text input" {
  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "hello world" | pinput "Sample input"
EOL
  assert_success
  assert_output "hello world"

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "" | pinput "Sample input"
EOL
  assert_success
  assert_output ""
}

@test "Input uses default value when empty" {
  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "hello world" | pinput "Sample input" "default value"
EOL
  assert_success
  assert_output "hello world"

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "" | pinput "Sample input" "default value"
EOL
  assert_success
  assert_output "default value"
}

@test "Input validates input with provided validator" {
  run --separate-stderr bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo -e "hello world\n123" | pinput "Sample input" "" pv_integer
EOL
  assert_success
  assert_output "123"
  output="$stderr"
  assert_output --partial "> Input must be an integer"

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts true
echo "" | pinput "Sample input" "456" pv_integer
EOL
  assert_success
  assert_output "456"
}

@test "Builtin validators" {
  run pv_integer "123"
  assert_output ""

  run pv_integer "123.4"
  assert_output "Input must be an integer"

  run pv_integer "-123"
  assert_output "Input must be an integer"

  run pv_integer "-123.4"
  assert_output "Input must be an integer"

  run pv_not_empty "hello world"
  assert_output ""

  run pv_not_empty " "
  assert_output ""

  run pv_not_empty ""
  assert_output "Input must not be empty"
}

@test "Input prompt is skipped when not interactive" {
  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
pinput "Sample input"
EOL
  assert_success
  assert_output ""

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
echo "Hello" | pinput "Sample input"
EOL
  assert_success
  assert_output ""
}

@test "Input prompt uses default values when not interactive" {
  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
pinput "Sample input" "Default value"
EOL
  assert_success
  assert_output "Default value"

  run bash <<EOL
source ./src/lib/ui/colors.sh
source ./src/lib/ui/prompts.sh
configure_prompts false
echo "Hello" | pinput "Sample input" "Default value"
EOL
  assert_success
  assert_output "Default value"
}

# vim:ft=sh
