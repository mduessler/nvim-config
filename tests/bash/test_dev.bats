#!/usr/bin/env bats

@test "Test if script '${NVIM_CONFIG}/installs/dev' exists." {
    [ -f "${NVIM_CONFIG}/installs/dev" ]
}
