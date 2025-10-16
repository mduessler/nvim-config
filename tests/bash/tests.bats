#!/usr/bin/env bats

TEST_DIR="${NVIM_HOME}/tests"
BASH_TEST_DIR="${TEST_DIR}/bash"

@test "run test_utils.bats" {
    run bats "${BASH_TEST_DIR}/test_utils.bats"
    [ "$status" -eq 0 ]
}
