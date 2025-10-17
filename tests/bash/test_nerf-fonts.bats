#!/usr/bin/env bats

@test "[TEST]: '${NVIM_CONFIG}/installs/nerd-fonts' exists " {
    [ -f "${NVIM_CONFIG}"/installs/nerd-fonts ]
}
