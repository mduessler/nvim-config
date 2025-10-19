#!/usr/bin/env bats

@test "Test if script '${NVIM_CONFIG}/install' exists." {
    [ -f "${NVIM_CONFIG}/install" ]
}

@test "Test if script '${NVIM_CONFIG}/install' is executable." {
    [ -x "${NVIM_CONFIG}/install" ]
}
