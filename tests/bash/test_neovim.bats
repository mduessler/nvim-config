#!/usr/bin/env bats

@test "[TEST]: '${NVIM_HOME}/installs/neovim' exists " {
    [ -f "${NVIM_HOME}"/installs/neovim ]
}

setup() {
    source "${NVIM_HOME}/installs/neovim"
}
