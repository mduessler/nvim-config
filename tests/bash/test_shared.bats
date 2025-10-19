#!/usr/bin/env bats

@test "Test if script '${NVIM_CONFIG}/installs/shared' exists." {
    [ -f "${NVIM_CONFIG}"/installs/shared ]
}

setup() {
    source "${NVIM_CONFIG}/installs/shared"
}

@test "identify_system_pkg_mgr: Function executed successfully – case apt-get pkg manager identified." {
    local pkg_mgr="apt-get"
    check_command() { [ "$1" = "${pkg_mgr}" ] && return 0 || return 1; }

    run identify_system_pkg_mgr

    [ ${status} -eq 0 ]
    [[ ${output} == *"Identified '${pkg_mgr}' as package manager."* ]]
}

@test "identify_system_pkg_mgr: Function executed successfully – case dnf pkg manager identified." {
    local pkg_mgr="dnf"
    check_command() { [ "$1" = "${pkg_mgr}" ] && return 0 || return 1; }

    run identify_system_pkg_mgr

    [ ${status} -eq 0 ]
    [[ ${output} == *"Identified '${pkg_mgr}' as package manager."* ]]
}

@test "identify_system_pkg_mgr: Function executed successfully – case pacman pkg manager identified." {
    local pkg_mgr="pacman"
    check_command() { [ "$1" = "dnf" ] && return 0 || return 1; }

    PKG_MGR=$pkg_mgr run identify_system_pkg_mgr

    [ ${status} -eq 0 ]
    [[ ${output} == *"Identified '${pkg_mgr}' as package manager."* ]]
    [[ ${output} == *"Package manager was already defined as '${pkg_mgr}'"* ]]
}

@test "identify_system_pkg_mgr: Can not idenify a system pkg manager." {
    local pkg_mgr="apk"
    check_command() { [ "$1" = "${pkg_mgr}" ] && return 0 || return 1; }

    run identify_system_pkg_mgr

    [ ${status} -eq 2 ]
    [[ ${output} == *"No valid package manager found."* ]]
}

@test "install_lua_pkg: Function executed successfully – pkg is alreay installed." {
    local pkg="lpeglabel"
    check_command() { return 0; }
    luarocks() {
        case "$1" in
            show) return 0 ;;
            install) return 0 ;;
        esac
    }

    run install_lua_pkg "${pkg}"

    [ ${status} -eq 0 ]
    [[ ${output} == *"${pkg} is already installed, skipping ..."* ]]
    [[ ${output} == *"Finished package installation."* ]]
}

@test "install_lua_pkg: Function executed successfully – pkg succssfully installed." {
    local pkg="lpeglabel"
    check_command() { return 0; }
    luarocks() {
        case "$1" in
            show) return 1 ;;
            install) return 0 ;;
        esac
    }

    run install_lua_pkg "${pkg}"

    [ ${status} -eq 0 ]
    [[ ${output} == *"Installing ${pkg} ..."* ]]
    [[ ${output} == *"Installed ${pkg}."* ]]
    [[ ${output} == *"Finished package installation."* ]]
}
@test "install_lua_pkg: Can not install package - lua is not installed." {
    check_command() { return 1; }

    run install_lua_pkg lpeglabel

    [ ${status} -eq 2 ]
    [[ ${output} == *"Lua is not installed or rust and cargo not in '\$PATH'."* ]]
}

@test "install_lua_pkg: Can not install package - no package is given." {
    check_command() { return 0; }

    run install_lua_pkg

    [ ${status} -eq 3 ]
    [[ ${output} == *"No package given. Please provide at least one packge."* ]]
}

@test "install_lua_pkg: Package cannot be installed – Installation of pkg with luarocks failed." {
    local pkg="lpeglabel"
    check_command() { return 0; }
    luarocks() {
        case "$1" in
            show) return 1 ;;
            install) return 1 ;;
        esac
    }

    run install_lua_pkg "${pkg}"

    [ ${status} -eq 4 ]
    [[ ${output} == *"Installing ${pkg} ..."* ]]
    [[ ${output} == *"Failed to install ${pkg}."* ]]
}

@test "install_cargo_pkg: Function executed successfully – pkg is alreay installed." {
    local pkg="selene"
    check_command() { return 0; }
    cargo() {
        case "$2" in
            --list) return 0 ;;
            install) return 1 ;;
        esac
    }
    grep() { return 0; }

    run install_cargo_pkg "${pkg}"

    [ ${status} -eq 0 ]
    [[ ${output} == *"${pkg} is already installed, skipping ..."* ]]
    [[ ${output} == *"Finished package installation."* ]]
}

@test "install_cargo_pkg: Function executed successfully – pkg succssfully installed." {
    local pkg="selene"
    check_command() { return 0; }
    cargo() {
        case "$2" in
            --list) return 1 ;;
            install) return 0 ;;
        esac
    }
    grep() { return 1; }

    run install_cargo_pkg "${pkg}"

    [ ${status} -eq 0 ]
    [[ ${output} == *"Installing ${pkg} ..."* ]]
    [[ ${output} == *"Installed ${pkg}."* ]]
    [[ ${output} == *"Finished package installation."* ]]
}
@test "install_cargo_pkg: Can not install package - rust is not installed." {
    check_command() { return 1; }

    run install_cargo_pkg lpeglabel

    [ ${status} -eq 2 ]
    [[ ${output} == *"Rust is not installed or rust and cargo not in '\$PATH'."* ]]
}

@test "install_cargo_pkg: Can not install package - no package is given." {
    check_command() { return 0; }

    run install_cargo_pkg

    [ ${status} -eq 3 ]
    [[ ${output} == *"No package given. Please provide at least one packge."* ]]
}

@test "install_cargo_pkg: Package cannot be installed – Installation of pkg with luarocks failed." {
    local pkg="selene"
    check_command() { return 0; }
    cargo() {
        case "$2" in
            --list) return 1 ;;
            "${pkg}") return 1 ;;
        esac
    }
    grep() { return 1; }

    run install_cargo_pkg "${pkg}"

    [ ${status} -eq 4 ]
    [[ ${output} == *"Installing ${pkg} ..."* ]]
    [[ ${output} == *"Failed to install ${pkg}."* ]]
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
