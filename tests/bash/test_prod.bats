#!/usr/bin/env bats

@test "Test if script '${NVIM_CONFIG}/installs/prod' exists" {
    [ -f "${NVIM_CONFIG}/installs/prod" ]
}

setup() {
    source "${NVIM_CONFIG}/installs/prod"
}

@test "install_prod: Function executed successfully" {
    install_prod_depnendencies() { return 0; }
    install_prod_requirements() { return 0; }
    run install_prod

    [ ${status} -eq 0 ]
    [[ ${output} = "Installed production dependencies and requirements." ]]
}

@test "install_prod: Function cannot install production dependencies" {
    install_prod_depnendencies() { return 1; }
    install_prod_requirements() { return 0; }
    run install_prod

    [ ${status} -eq 2 ]
    [[ ${output} = "Can not install production dependencies." ]]
}

@test "install_prod: Function cannot install production requirements" {
    install_prod_depnendencies() { return 0; }
    install_prod_requirements() { return 1; }
    run install_prod

    [ ${status} -eq 3 ]
    [[ ${output} = "Can not install production requirements." ]]
}

@test "rust_installer: Function executed successfully - rust has been installed" {
    check_command() { return 1; }
    curl() { return 0; }
    sh() { return 0; }

    run install_prod

    [ ${status} -eq 0 ]
    [[ ${output} = "Rust has been successfully installed." ]]
}

@test "rust_installer: Function executed successfully - rust is already installed" {
    check_command() { return 0; }
    curl() { return 1; }
    sh() { return 0; }

    run install_prod

    [ ${status} -eq 0 ]
    [[ ${output} = "Rust is already installed." ]]
}

@test "rust_installer: Function can not download rust installer." {
    check_command() { return 1; }
    curl() { return 1; }
    sh() { return 0; }

    run install_prod

    [ ${status} -eq 2 ]
    [[ ${output} = "Curl exited with 1 and sh exited with 0." ]]
}
