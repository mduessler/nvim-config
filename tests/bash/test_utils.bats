#!/usr/bin/env bats

@test "can run script 'utils'" {
    "${NVIM_HOME}"/installs/utils
}

setup() {
    source "${NVIM_HOME}/installs/utils"
}

@test "color_debug" {
    run get_log_color "DEBUG"
    [ "$status" -eq 0 ]
    [ "$output" = $'\033[37m' ]
}

@test "color_info" {
    run get_log_color "INFO"
    [ "$status" -eq 0 ]
    [ "$output" = $'\033[34m' ]
}

@test "color_success" {
    run get_log_color "SUCCESS"
    [ "$status" -eq 0 ]
    [ "$output" = $'\033[32m' ]
}

@test "color_warning" {
    run get_log_color "WARNING"
    [ "$status" -eq 0 ]
    [ "$output" = $'\033[33m' ]
}

@test "color_error" {
    run get_log_color "ERROR"
    [ "$status" -eq 0 ]
    [ "$output" = $'\033[33m' ]
}
