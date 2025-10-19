#!/usr/bin/env bats

@test "Test if script '${NVIM_CONFIG}/install' exists." {
    [ -f "${NVIM_CONFIG}/install" ]
}
