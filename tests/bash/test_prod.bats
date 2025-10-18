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
