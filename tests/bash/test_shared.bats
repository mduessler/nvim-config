#!/usr/bin/env bats

@test "Test '${NVIM_HOME}/installs/shared' exists" {
    [ -f "${NVIM_HOME}"/installs/shared ]
}

setup() {
    source "${NVIM_HOME}/installs/shared"
}

@test "Test 'apt-get' pkg manager is identified" {
    check_command() { [ "$1" = "apt-get" ] && return 0 || return 1; }
    run identify_system_pkg_mgr
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Identified 'apt-get' as package manager." ]]
}
