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
