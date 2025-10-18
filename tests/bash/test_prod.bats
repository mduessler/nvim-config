#!/usr/bin/env bats

@test "Test if script '${NVIM_CONFIG}/installs/prod' exists" {
    [ -f "${NVIM_CONFIG}/installs/prod" ]
}

setup() {
    source "${NVIM_CONFIG}/installs/prod"
}
