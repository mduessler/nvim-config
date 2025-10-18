#!/usr/bin/env bats

TEST_DATA=${NVIM_CONFIG}/tests/bash/data

@test "[TEST]: '${NVIM_CONFIG}/installs/nerd-fonts' exists " {
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

@test "[TEST]: init_nerd_process - test success pull" {
    mkdir -p "${HOME}/.local/share/src/nerd-fonts"
    dir_is_git_repo() { return 0; }
    pull_git_dir() { return 0; }

    run init_nerd_process
    [ "$status" -eq 0 ]
}

@test "[TEST]: init_nerd_process - test success clone" {
    read() { return 0; }
    clone_repo() { return 0; }

    run init_nerd_process
    [ "$status" -eq 0 ]
}

@test "[TEST]: init_nerd_process - can not clone or pull" {
    mkdir -p "${HOME}/.local/share/src/nerd-fonts"
    dir_is_git_repo() { return 1; }

    run init_nerd_process
    [ "$status" -eq 1 ]
}

@test "[TEST]: init_nerd_process - test fail pull" {
    mkdir -p "${HOME}/.local/share/src/nerd-fonts"
    dir_is_git_repo() { return 0; }
    pull_git_dir() { return 1; }

    run init_nerd_process
    [ "$status" -eq 2 ]
}

@test "[TEST]: init_nerd_process - test fail clone" {
    read() { return 1; }
    clone_repo() { return 0; }

    run init_nerd_process
    [ "$status" -eq 3 ]
}

@test "[TEST]: kill_nerd_fonts_process - kill success" {
    kill() { return 0; }

    run kill_nerd_fonts_process
    [ "$status" -eq 0 ]
}

@test "[TEST]: kill_nerd_fonts_process - kill fails" {
    kill() { return 1; }

    run kill_nerd_fonts_process
    [ "$status" -eq 1 ]
}

@test "[TEST]: install_nerd_fonts - install success" {
    wait_for_clone_process() { return 0; }
    chmod() { return 0; }

    NERD_FONTS_DIR="${TEST_DATA}/success" run install_nerd_fonts
    [ "$status" -eq 0 ]
}

@test "[TEST]: install_nerd_fonts - install fails" {
    wait_for_clone_process() { return 0; }
    chmod() { return 0; }

    NERD_FONTS_DIR="${TEST_DATA}/fail" run install_nerd_fonts
    [ "$status" -eq 1 ]
    [[ "$output" == *"Install nerd-fonts (instal.sh) exited (${status}) with: This test will fail."* ]]
}

@test "[TEST]: install_nerd_fonts - can not make file executable" {
    wait_for_clone_process() { return 0; }
    cd() { return 0; }
    chmod() { return 1; }

    run install_nerd_fonts
    [ "$status" -eq 2 ]
}

@test "[TEST]: install_nerd_fonts - can not change dir" {
    wait_for_clone_process() { return 0; }
    cd() { return 1; }

    run install_nerd_fonts
    [ "$status" -eq 2 ]
}

@test "[TEST]: install_nerd_fonts - wait for clone process fails" {
    wait_for_clone_process() { return 1; }

    run install_nerd_fonts
    [ "$status" -eq 3 ]
}
