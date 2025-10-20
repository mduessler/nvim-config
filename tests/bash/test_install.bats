#!/usr/bin/env bats

SCRIPT_DIR="${NVIM_CONFIG}/installs"
DEPENDENCIES=${NVIM_CONFIG}/dependencies

setup() {
    source "${NVIM_CONFIG}/install"
}

@test "Test if script '${NVIM_CONFIG}/install' exists." {
    [ -f "${NVIM_CONFIG}/install" ]
}

@test "Test if script '${NVIM_CONFIG}/install' is executable." {
    [ -x "${NVIM_CONFIG}/install" ]
}

@test "Test if dependencies '${DEPENDENCIES}' exists." {
    [ -f "${DEPENDENCIES}" ]
}

@test "Test if script '${NVIM_CONFIG}/utils' exists." {
    [ -f "${NVIM_CONFIG}/utils" ]
}

@test "Test if script '${NVIM_CONFIG}/prod' exists." {
    [ -f "${NVIM_CONFIG}/prod" ]
}

@test "Test if script '${NVIM_CONFIG}/nerd-fonts' exists." {
    [ -f "${NVIM_CONFIG}/nerd-fonts" ]
}

@test "Test if script '${NVIM_CONFIG}/dev' exists." {
    [ -f "${NVIM_CONFIG}/dev" ]
}
