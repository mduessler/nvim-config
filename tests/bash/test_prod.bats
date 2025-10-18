#!/usr/bin/env bats

@test "Test if script '${NVIM_CONFIG}/installs/prod' exists" {
    [ -f "${NVIM_CONFIG}/installs/prod" ]
}

setup() {
    source "${NVIM_CONFIG}/installs/prod"
}

@test "install_prod: Function executed successfully - returns 0" {
    install_prod_depnendencies() { return 0; }
    install_prod_requirements() { return 0; }
    run install_prod

    [ ${status} -eq 0 ]
    [[ ${output} = "Installed production dependencies and requirements." ]]
}
