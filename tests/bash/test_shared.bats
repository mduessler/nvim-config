#!/usr/bin/env bats

@test "[TEST]: '${NVIM_CONFIG}/installs/shared' exists" {
    [ -f "${NVIM_CONFIG}"/installs/shared ]
}

setup() {
    unset PKG_MGR
    source "${NVIM_CONFIG}/installs/shared"
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

@test "[TEST]: clone_repo - two arguments needed" {
    run clone_repo

    [ "$status" -eq 2 ]
    [[ "$output" == *"Function needs exactly two arguments, 'repo-url' and 'dest-dir'."* ]]
}

@test "[TEST]: clone_repo - clone success" {
    git() {
        echo "mock git called with: $*"
        sleep 1
        return 0
    }
    run clone_repo "https://github.com/mduessler/nvim-config.git" "simply-the-best"

    echo "$output"
    pid=$(echo "$output" | awk '{print $1}' | xargs)
    tmpfile=$(echo "$output" | awk '{print $2}' | xargs)

    [ "$status" -eq 0 ]
    [[ ${pid} =~ ^[0-9]+$ ]]
    [[ -f "${tmpfile}" ]]
}


@test "[TEST]: clone_repo - clone fails" {
    git() {
        echo "mock git called with: $*"
        sleep 1
        return 1
    }
    run clone_repo "https://github.com/mduessler/nvim-config.git" "simply-the-best"

    echo "$output"
    pid=$(echo "$output" | awk '{print $1}' | xargs)
    tmpfile=$(echo "$output" | awk '{print $2}' | xargs)

    [ "$status" -eq 0 ]
    [[ ${pid} =~ ^[0-9]+$ ]]
    [[ -f "${tmpfile}" ]]
}
