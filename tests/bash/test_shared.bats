#!/usr/bin/env bats

@test "[TEST]: '${NVIM_HOME}/installs/shared' exists" {
    [ -f "${NVIM_HOME}"/installs/shared ]
}

setup() {
    unset PKG_MGR
    source "${NVIM_HOME}/installs/shared"
}

teardown() {
    unset PKG_MGR
}

@test "[TEST]: 'apt-get' pkg manager is identified" {
    check_command() { [ "$1" = "apt-get" ] && return 0 || return 1; }
    identify_system_pkg_mgr
    status=$?

    [ "$status" -eq 0 ]
    [ "${PKG_MGR}" = "apt-get" ]
}

@test "[TEST]: 'dnf' pkg manager is identified" {
    check_command() { [ "$1" = "dnf" ] && return 0 || return 1; }
    identify_system_pkg_mgr
    status=$?

    [ "$status" -eq 0 ]
    [ "${PKG_MGR}" = "dnf" ]
}

@test "[TEST]: 'no' pkg manager is identified" {
    check_command() { [ "$1" = "apk" ] && return 0 || return 1; }
    run identify_system_pkg_mgr

    [ "$status" -eq 1 ]
    [[ "$output" =~ "No valid package manager found." ]]
}

@test "[TEST]: pkg manager is set" {
    check_command() { [ "$1" = "dnf" ] && return 0 || return 1; }
    PKG_MGR="pacman"
    identify_system_pkg_mgr
    status=$?

    [ "$status" -eq 0 ]
    [ "${PKG_MGR}" = "pacman" ]
}
