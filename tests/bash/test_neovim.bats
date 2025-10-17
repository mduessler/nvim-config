#!/usr/bin/env bats

@test "[TEST]: '${NVIM_CONFIG}/installs/neovim' exists " {
    [ -f "${NVIM_CONFIG}"/installs/neovim ]
}

setup() {
    source "${NVIM_CONFIG}/installs/neovim"
}
