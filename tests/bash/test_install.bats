#!/usr/bin/env bats

SCRIPT_DIR="${NVIM_CONFIG}/installs"
DEPENDENCIES=${NVIM_CONFIG}/dependencies

@test "Test if script '${NVIM_CONFIG}/install' exists." {
    [ -f "${NVIM_CONFIG}/install" ]
}

SCRIPT="${NVIM_CONFIG}/install"

@test "Test if script '${NVIM_CONFIG}/install' is executable." {
    [ -x "${NVIM_CONFIG}/install" ]
}

@test "Test if script '${SCRIPT_DIR}/utils' exist." {
    [ -f "${SCRIPT_DIR}/utils" ]
}

@test "Test return value if script '${SCRIPT_DIR}/utils' do not exist." {
    local deps=${NVIM_CONFIG}/tests/bash/data/success

    SCRIPT_DIR=${deps} run source "${SCRIPT}"

    [ ${status} -eq 2 ]
}

@test "Test that '${DEPENDENCIES}' exist." {
    [ -f "${DEPENDENCIES}" ]
}

@test "Test return value if script '${DEPENDENCIES}' do not exist." {
    local deps=${NVIM_CONFIG}/tests/bash/data/deps

    DEPENDENCIES=${deps} run source "${SCRIPT}"

    [ ${status} -eq 1 ]
    [[ ${output} == *"Expected a dependency file at ${deps}. But not able to load the given path."* ]]
}

@test "Test if script '${SCRIPT_DIR}/prod' exist." {
    [ -f "${SCRIPT_DIR}/prod" ]
}

@test "Test return value if script '${SCRIPT_DIR}/prod' do not exist." {
    local deps=${NVIM_CONFIG}/tests/bash/data/

    SCRIPT_DIR=${deps} run source "${SCRIPT}"

    [ ${status} -eq 3 ]
    [[ ${output} == *"Not production installation script found in ${deps}."* ]]
}
