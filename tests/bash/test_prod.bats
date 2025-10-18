#!/usr/bin/env bats

@test "Test if script '${NVIM_CONFIG}/installs/prod' exists" {
    [ -f "${NVIM_CONFIG}/installs/prod" ]
}

setup() {
    source "${NVIM_CONFIG}/installs/prod"
    source "${NVIM_CONFIG}/dependencies"
}

@test "install_prod: Function executed successfully" {
    install_prod_dependencies() { return 0; }
    install_prod_requirements() { return 0; }

    run install_prod

    [ ${status} -eq 0 ]
    [[ ${output} == *"Installed production dependencies and requirements."* ]]
}

@test "install_prod: Function cannot install production dependencies" {
    install_prod_dependencies() { return 1; }
    install_prod_requirements() { return 0; }

    run install_prod

    [ ${status} -eq 2 ]
    [[ ${output} == *"Can not install production dependencies."* ]]
}

@test "install_prod: Function cannot install production requirements" {
    install_prod_dependencies() { return 0; }
    install_prod_requirements() { return 1; }

    run install_prod

    [ ${status} -eq 3 ]
    [[ ${output} == *"Can not install production requirements."* ]]
}

@test "rust_installer: Function executed successfully - rust has been installed" {
    check_command() { return 1; }
    curl() { return 0; }
    sh() { return 0; }

    run install_rust

    [ ${status} -eq 0 ]
    [[ ${output} == *"Rust has been successfully installed."* ]]
}

@test "rust_installer: Function executed successfully - rust is already installed" {
    check_command() { return 0; }
    curl() { return 1; }
    sh() { return 0; }

    run install_rust

    [ ${status} -eq 0 ]
    [[ ${output} == *"Rust is already installed."* ]]
}

@test "rust_installer: Function can not download rust installer." {
    check_command() { return 1; }
    curl() { return 1; }
    sh() { return 1; }

    run install_rust

    [ ${status} -eq 2 ]
    [[ ${output} == *"Curl exited with 1 and sh exited with 1."* ]]
}

@test "rust_installer: Function can not execute rustup.rs with sh." {
    check_command() { return 1; }
    curl() { return 0; }
    sh() { return 1; }

    run install_rust

    [ ${status} -eq 2 ]
    [[ ${output} == *"Curl exited with 0 and sh exited with 1."* ]]
}

@test "install_prod_dependencies: Function executed successfully" {
    identify_system_pkg_mgr() { return 0; }
    install_packages_with_pkg_mgr() { return 0; }
    install_dependencies_independent_of_pkg_mgr() { return 0; }
    check_nvim_version() { return 0; }

    PKG_MGR="apt-get" run install_prod_dependencies

    [ ${status} -eq 0 ]
    [[ ${output} == *"Dependencies has been successfully installed."* ]]

    PKG_MGR="dnf" run install_prod_dependencies

    [ ${status} -eq 0 ]
    [[ ${output} == *"Dependencies has been successfully installed."* ]]
}

@test "install_prod_dependencies: Function can not idenify system package manager" {
    identify_system_pkg_mgr() { return 1; }
    install_packages_with_pkg_mgr() { return 0; }
    install_dependencies_independent_of_pkg_mgr() { return 0; }
    check_nvim_version() { return 0; }

    run install_prod_dependencies

    [ ${status} -eq 2 ]
    [[ ${output} == *"Can not identify system package manager."* ]]
}

@test "install_prod_dependencies: Function can not install packages with package manager" {
    identify_system_pkg_mgr() { return 0; }
    install_packages_with_pkg_mgr() { return 1; }
    install_dependencies_independent_of_pkg_mgr() { return 0; }
    check_nvim_version() { return 0; }

    PKG_MGR="pacman" run install_prod_dependencies

    [ ${status} -eq 3 ]
    [[ ${output} == *"Unsupported package manager: pacman"* ]]
}

@test "install_prod_dependencies: Function can not install packages without package manager" {
    identify_system_pkg_mgr() { return 0; }
    install_packages_with_pkg_mgr() { return 0; }
    install_dependencies_independent_of_pkg_mgr() { return 1; }
    check_nvim_version() { return 0; }

    PKG_MGR="apt-get" run install_prod_dependencies

    [ ${status} -eq 4 ]
    [[ ${output} == *"Can not install dependencies independent of package manager."* ]]

    PKG_MGR="dnf" run install_prod_dependencies

    [ ${status} -eq 4 ]
    [[ ${output} == *"Can not install dependencies independent of package manager."* ]]
}

@test "install_prod_dependencies: Function can not install neovim." {
    identify_system_pkg_mgr() { return 0; }
    install_packages_with_pkg_mgr() { return 0; }
    install_dependencies_independent_of_pkg_mgr() { return 0; }
    check_nvim_version() { return 1; }
    install_vim() { return 1; }

    PKG_MGR="apt-get" run install_prod_dependencies

    [ ${status} -eq 5 ]
    [[ ${output} == *"Can not install neovim."* ]]

    PKG_MGR="dnf" run install_prod_dependencies

    [ ${status} -eq 5 ]
    [[ ${output} == *"Can not install neovim."* ]]
}

@test "install_dependencies_independent_of_pkg_mgr: Function executed successfully" {
    install_rust() { return 0; }
    DEPS=(rust)
    DEPS=${DEPS[*]} run install_dependencies_independent_of_pkg_mgr

    [ ${status} -eq 0 ]
    [[ ${output} == *"Installed all production dependencies defined in \$DEPS"* ]]
}

@test "install_dependencies_independent_of_pkg_mgr: Dependency function failed." {
    install_rust() { return 1; }
    DEPS=(rust)
    DEPS=${DEPS[*]} run install_dependencies_independent_of_pkg_mgr

    [ ${status} -eq 2 ]
    [[ ${output} == *"Failed to install dependency: ${DEPS[0]}"* ]]
}
