#!/usr/bin/env bats

@test "Test if script '${NVIM_CONFIG}/installs/dev' exists." {
    [ -f "${NVIM_CONFIG}/installs/dev" ]
}

setup() {
    source "${NVIM_CONFIG}/installs/dev"
    source "${NVIM_CONFIG}/dependencies"
}

@test "install_dev: Function executed successfully." {
    install_dev_dependencies() { return 0; }
    install_dev_requirements() { return 0; }

    run install_dev

    [ ${status} -eq 0 ]
    [[ ${output} == *"Installed development dependencies and requirements."* ]]
}

@test "install_dev: Function cannot install development dependencies." {
    install_dev_dependencies() { return 1; }
    install_dev_requirements() { return 0; }

    run install_dev

    [ ${status} -eq 2 ]
    [[ ${output} == *"Can not install development dependencies."* ]]
}

@test "install_dev: Function cannot install development requirements." {
    install_dev_dependencies() { return 0; }
    install_dev_requirements() { return 1; }

    run install_dev

    [ ${status} -eq 3 ]
    [[ ${output} == *"Can not install development requirements."* ]]
}

@test "install_dev_dependencies: Function executed successfully." {
    identify_system_pkg_mgr() { return 0; }
    install_docker_ubuntu() { return 0; }
    install_docker_fedora() { return 0; }

    PKG_MGR="apt-get" run install_dev_dependencies

    [ ${status} -eq 0 ]
    [[ ${output} == *"Dependencies have been successfully installed."* ]]

    PKG_MGR="dnf" run install_dev_dependencies

    [ ${status} -eq 0 ]
    [[ ${output} == *"Dependencies have been successfully installed."* ]]
}

@test "install_dev_dependencies: Function can not install docker." {
    identify_system_pkg_mgr() { return 0; }
    install_docker_ubuntu() { return 1; }
    install_docker_fedora() { return 1; }

    PKG_MGR="apt-get" run install_dev_dependencies

    [ ${status} -eq 1 ]
    [[ ${output} == *"Can not install docker with apt-get"* ]]

    PKG_MGR="dnf" run install_dev_dependencies

    [ ${status} -eq 1 ]
    [[ ${output} == *"Can not install docker with dnf"* ]]
}

@test "install_dev_dependencies: Function can not idenify system package manager." {
    identify_system_pkg_mgr() { return 1; }

    run install_dev_dependencies

    [ ${status} -eq 2 ]
    [[ ${output} == *"Can not identify system package manager."* ]]
}

@test "install_dev_dependencies: Function can not install packages with package manager." {
    identify_system_pkg_mgr() { return 1; }
    local pkg_mgr="pacman"

    PKG_MGR="${pkg_mgr}" run install_dev_dependencies

    [ ${status} -eq 3 ]
    [[ ${output} == *"Unsupported package manager: ${pkg_mgr}"* ]]
}

@test "install_dev_requirements: Function executed successfully." {
    install_lua_pkg() { return 0; }

    run install_dev_requirements

    [ ${status} -eq 0 ]
    [[ ${output} == *"Installed development requirements successfully."* ]]
}

@test "install_dev_requirements: Can not install lua requirements." {
    install_lua_pkg() { return 1; }

    run install_dev_requirements

    [ ${status} -eq 1 ]
    [[ ${output} == *"Can not install lua requirements."* ]]
}
