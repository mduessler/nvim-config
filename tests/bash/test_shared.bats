#!/usr/bin/env bats

@test "Test '${NVIM_HOME}/installs/shared' exists" {
    [ -f "${NVIM_HOME}"/installs/shared ]
}

source "${NVIM_HOME}/installs/shared"
