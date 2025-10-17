#!/usr/bin/env bats

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
