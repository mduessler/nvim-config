#!/usr/bin/env bats

TEST_DATA=${NVIM_CONFIG}/tests/bash/data

@test "Test if script '${NVIM_CONFIG}/installs/nerd-fonts' exists." {
    [ -f "${NVIM_CONFIG}"/installs/nerd-fonts ]
}

setup() {
    source "${NVIM_CONFIG}/dependencies"
    source "${NVIM_CONFIG}/installs/nerd-fonts"
    unset XDG_DATA_HOME
    mkdir -p "${HOME}/.local/share/src"
}

teardown() {
    rm -rf "${HOME}/.local/share/src/nerd-fonts"
}

@test "init_nerd_process: Function executed successfully - repo is pulled." {
    mkdir -p "${HOME}/.local/share/src/nerd-fonts"
    dir_is_git_repo() { return 0; }
    pull_git_dir() { return 0; }

    run init_nerd_process

    [ ${status} -eq 0 ]
    [[ ${output} == *"Nerd-fonts git repo exists. Pulling ..."* ]]
}

@test "init_nerd_process: Function executed successfully - repo is cloned." {

    read() { return 0; }
    clone_repo() { return 0; }

    run init_nerd_process

    [ ${status} -eq 0 ]
    [[ ${output} == *"Nerd-fonts git repo not exists. Cloning ..."* ]]
}

@test "init_nerd_process: Can not pull the git repo." {
    mkdir -p "${HOME}/.local/share/src/nerd-fonts"
    dir_is_git_repo() { return 0; }
    pull_git_dir() { return 1; }

    run init_nerd_process

    [ ${status} -eq 2 ]
}

@test "init_nerd_process: Can not clone the git repo." {
    read() { return 1; }
    clone_repo() { return 0; }

    NVIM_DEV=true run init_nerd_process

    [ ${status} -eq 3 ]
    [[ ${output} == *"Error occured during clone repo."* ]]
}

@test "init_nerd_process: Given directory is not a git repo." {
    mkdir -p "${HOME}/.local/share/src/nerd-fonts"
    dir_is_git_repo() { return 1; }

    run init_nerd_process

    [ ${status} -eq 4 ]
    [[ ${output} == *"Directory ${HOME}/.local/share/src/nerd-fonts already exists and is no git repo."* ]]
}

@test "kill_nerd_fonts_process: Function executed successfully." {
    kill() { return 0; }

    run kill_nerd_fonts_process

    [ ${status} -eq 0 ]
}

@test "kill_nerd_fonts_process: Can not kill nerd-fonts process." {
    kill() { return 1; }

    run kill_nerd_fonts_process

    [ ${status} -eq 2 ]
}

@test "install_nerd_fonts: Function executed successfully." {
    wait_for_clone_process() { return 0; }
    chmod() { return 0; }

    NERD_FONTS_DIR="${TEST_DATA}/success" run install_nerd_fonts

    [ ${status} -eq 0 ]
    [[ ${output} == *"Installed nerd-fonts."* ]]
}

@test "install_nerd_fonts: Function executed successfully." {
    wait_for_clone_process() { return 0; }
    chmod() { return 0; }

    NERD_FONTS_DIR="${TEST_DATA}/fail" run install_nerd_fonts

    [ ${status} -eq 1 ]
    [[ ${output} == *"Install nerd-fonts (instal.sh) exited (1) with: This test will fail.."* ]]
    [[ ${output} == *"Can not install nerd-fonts."* ]]
}

@test "install_nerd_fonts: Wait for clone process failed." {
    wait_for_clone_process() { return 1; }

    run install_nerd_fonts

    [ ${status} -eq 2 ]
}

@test "install_nerd_fonts: Nerd-fonts directory is not set." {
    wait_for_clone_process() { return 0; }

    NERD_FONTS_DIR="" run install_nerd_fonts

    [ ${status} -eq 3 ]
    [[ ${output} == *"Not Nerd-fonts directory defined."* ]]
}

@test "install_nerd_fonts: Can not change directory" {
    wait_for_clone_process() { return 0; }
    cd() { return 1; }

    run install_nerd_fonts

    [ ${status} -eq 4 ]
}

@test "install_nerd_fonts: Can not make file executable" {
    wait_for_clone_process() { return 0; }
    cd() { return 0; }
    chmod() { return 1; }

    run install_nerd_fonts

    [ ${status} -eq 4 ]
}
