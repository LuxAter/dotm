setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load' 
  load 'test_helper/bats-file/load' 

  source ./src/lib/semver.sh
}

@test "Semver equality comparison" {
  run semver_eq "0.0.0" "0.0.0"
  assert_success

  run semver_eq "0.0.1" "0.0.1"
  assert_success

  run semver_eq "0.2.1" "0.2.1"
  assert_success

  run semver_eq "3.2.1" "3.2.1"
  assert_success
}

@test "Semver not equal comparison" {
  run semver_eq "1.0.0" "0.0.0"
  assert_failure

  run semver_eq "0.1.1" "0.0.0"
  assert_failure

  run semver_eq "0.0.1" "0.2.1"
  assert_failure
}

@test "Semver greater than comparison" {
  run semver_gt "1.0.0" "0.0.0"
  assert_success

  run semver_gt "0.1.0" "0.0.0"
  assert_success

  run semver_gt "0.0.1" "0.0.0"
  assert_success
}

# vim:ft=sh
