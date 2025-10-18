#!/usr/bin/env bats

@test "Test if script '${NVIM_CONFIG}/installs/shared' exists." {
    [ -f "${NVIM_CONFIG}"/installs/shared ]
}

setup() {
    source "${NVIM_CONFIG}/installs/shared"
    unset PKG_MGR
}

teardown() {
    unset PKG_MGR
}

@test "identify_system_pkg_mgr: Function executed successfully – case apt-get pkg manager identified" {
    local pkg_mgr="apt-get"
    check_command() { [ "$1" = "${pkg_mgr}" ] && return 0 || return 1; }

    run identify_system_pkg_mgr

    [ ${status} -eq 0 ]
    [ "${PKG_MGR}" = "${pkg_mgr}" ]
    [[ ${output} == *"Identified '${pkg_mgr}' as package manager."* ]]
}

@test "identify_system_pkg_mgr: Function executed successfully – case dnf pkg manager identified" {
    local pkg_mgr="dnf"
    check_command() { [ "$1" = "${pkg_mgr}" ] && return 0 || return 1; }

    run identify_system_pkg_mgr

    [ ${status} -eq 0 ]
    [ "${PKG_MGR}" = "${pkg_mgr}" ]
    [[ ${output} == *"Identified '${pkg_mgr}' as package manager."* ]]
}

@test "identify_system_pkg_mgr: Function executed successfully – case pacman pkg manager identified" {
    local pkg_mgr="pacman"
    check_command() { [ "$1" = "dnf" ] && return 0 || return 1; }

    run identify_system_pkg_mgr

    [ ${status} -eq 0 ]
    [ "${PKG_MGR}" = "${pkg_mgr}" ]
    [[ ${output} == *"Identified '${pkg_mgr}' as package manager."* ]]
}

@test "[TEST]: 'no' pkg manager is identified" {
    check_command() { [ "$1" = "apk" ] && return 0 || return 1; }
    run identify_system_pkg_mgr

    [ "$status" -eq 1 ]
    [[ "$output" =~ "No valid package manager found." ]]
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

@test "[TEST]: install_packages_with_pkg_mgr - PKG_MGR is not set" {
    unset PKG_MGR
    run install_packages_with_pkg_mgr neovim

    [ "$status" -eq 3 ]
    [[ "$output" =~ "Need to set 'PKG_MGR', or call 'identify_system_pkg_mgr'." ]]
}

@test "[TEST]: install_packages_with_pkg_mgr - No package is given." {
    identify_system_pkg_mgr
    run install_packages_with_pkg_mgr

    [ "$status" -eq 2 ]
    [[ "$output" =~ "No package given. Please provide at least one packge." ]]
}

@test "[TEST]: install_packages_with_pkg_mgr - package installation is successful." {
    sudo() { return 0; }
    identify_system_pkg_mgr
    run install_packages_with_pkg_mgr neovim

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Installed packages: neovim" ]]
}

@test "[TEST]: install_packages_with_pkg_mgr - package installation fails." {
    sudo() { return 1; }
    identify_system_pkg_mgr
    run install_packages_with_pkg_mgr neovim

    [ "$status" -eq 1 ]
    [[ "$output" =~ "Can not install package(s)." ]]
}
