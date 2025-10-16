#!/usr/bin/env bats

@test "Test '${NVIM_HOME}/installs/shared' exists" {
    [ -f "${NVIM_HOME}"/installs/shared ]
}

setup() {
    source "${NVIM_HOME}/installs/shared"
}

teardown() {
    unset PKG_MGR
}

@test "Test 'apt-get' pkg manager is identified" {
    check_command() { [ "$1" = "apt-get" ] && return 0 || return 1; }
    identify_system_pkg_mgr
    status=$?

    [ "$status" -eq 0 ]
    [  "${PKG_MGR}" = "apt-get" ]
}
