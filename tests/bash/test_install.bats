#!/usr/bin/env bats

SCRIPT_DIR="${NVIM_CONFIG}/installs"
DEPENDENCIES=${NVIM_CONFIG}/dependencies

@test "Test if script '${NVIM_CONFIG}/install' exists." {
    [ -f "${NVIM_CONFIG}/install" ]
}

@test "Test if script '${NVIM_CONFIG}/install' is executable." {
    [ -x "${NVIM_CONFIG}/install" ]
}

@test "Test if dependencies '${DEPENDENCIES}' exists." {
    [ -f "${DEPENDENCIES}" ]
}

@test "Test if script '${SCRIPT_DIR}/utils' exists." {
    [ -f "${SCRIPT_DIR}/utils" ]
}

@test "Test if script '${SCRIPT_DIR}/prod' exists." {
    [ -f "${SCRIPT_DIR}/prod" ]
}

@test "Test if script '${SCRIPT_DIR}/nerd-fonts' exists." {
    [ -f "${SCRIPT_DIR}/nerd-fonts" ]
}

@test "Test if script '${SCRIPT_DIR}/dev' exists." {
    [ -f "${SCRIPT_DIR}/dev" ]
}
