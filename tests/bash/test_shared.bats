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

@test "[TEST]: install_lua_pkg - lua is not installed" {
    check_command() { return 1; }
    run install_lua_pkg lpeglabel

    [ "$status" -eq 3 ]
    [[ "$output" =~ "Lua is not installed or rust and cargo not in '\$PATH'." ]]
}

@test "[TEST]: install_lua_pkg - lua no package is given" {
    check_command() { return 0; }
    run install_lua_pkg

    [ "$status" -eq 2 ]
    [[ "$output" =~ "No package given. Please provide at least one packge." ]]
}

@test "[TEST]: install_lua_pkg - lua package is already installed." {
    local pkg="lpeglabel"
    check_command() { return 0; }
    luarocks() {
        case "$1" in
            show) return 0 ;;
            install) return 0 ;;
        esac
    }
    run install_lua_pkg "${pkg}"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "${pkg} is already installed, skipping..." ]]
}

@test "[TEST]: install_lua_pkg - lua package installation is successful." {
    local pkg="lpeglabel"
    check_command() { return 0; }
    luarocks() {
        case "$1" in
            show) return 1 ;;
            install) return 0 ;;
        esac
    }
    run install_lua_pkg "${pkg}"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Installed ${pkg}." ]]
}

@test "[TEST]: install_lua_pkg - lua package installation fails." {
    local pkg="lpeglabel"
    check_command() { return 0; }
    luarocks() {
        case "$1" in
            show) return 1 ;;
            install) return 1 ;;
        esac
    }
    run install_lua_pkg "${pkg}"

    [ "$status" -eq 1 ]
    [[ "$output" =~ "Failed to install ${pkg}." ]]
}

@test "[TEST]: install_cargo_pkg - rust is not installed" {
    check_command() { return 1; }
    run install_cargo_pkg selene

    [ "$status" -eq 3 ]
    [[ "$output" =~ "Rust is not installed or rust and cargo not in '\$PATH'." ]]
}

@test "[TEST]: install_cargo_pkg - No package is given" {
    check_command() { return 0; }
    run install_cargo_pkg

    [ "$status" -eq 2 ]
    [[ "$output" =~ "No package given. Please provide at least one packge." ]]
}

@test "[TEST]: install_cargo_pkg - rust package is already installed." {
    local pkg="lpeglabel"
    check_command() { return 0; }
    cargo() {
        case "$2" in
            --list) return 0 ;;
            install) return 1 ;;
        esac
    }
    grep() { return 0; }
    run install_cargo_pkg "${pkg}"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "${pkg} is already installed, skipping..." ]]
}

@test "[TEST]: install_cargo_pkg - rust package installation is successful." {
    local pkg="lpeglabel"
    check_command() { return 0; }
    cargo() {
        case "$2" in
            --list) return 1 ;;
            "${pkg}") return 0 ;;
        esac
    }
    grep() { return 1; }
    run install_cargo_pkg "${pkg}"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Installed ${pkg}." ]]
}

@test "[TEST]: install_cargo_pkg - rust package installation fails." {
    local pkg="lpeglabel"
    check_command() { return 0; }
    cargo() {
        case "$2" in
            --list) return 1 ;;
            "${pkg}") return 1 ;;
        esac
    }
    grep() { return 1; }
    run install_cargo_pkg "${pkg}"

    [ "$status" -eq 1 ]
    [[ "$output" =~ "Failed to install ${pkg}." ]]
}
