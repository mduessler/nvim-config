#!/usr/bin/env bats

@test "can run script 'utils'" {
    "${NVIM_HOME}"/installs/utils
}

source "${NVIM_HOME}/installs/utils"

@test "Test debug color" {
    run get_log_color "DEBUG"
    [ "$status" -eq 0 ]
    [ "$output" = $'\033[37m' ]
}

@test "Test info color" {
    run get_log_color "INFO"
    [ "$status" -eq 0 ]
    [ "$output" = $'\033[34m' ]
}

@test "Test success color" {
    run get_log_color "SUCCESS"
    [ "$status" -eq 0 ]
    [ "$output" = $'\033[32m' ]
}

@test "Test warning color" {
    run get_log_color "WARNING"
    [ "$status" -eq 0 ]
    [ "$output" = $'\033[33m' ]
}

@test "Test error color" {
    run get_log_color "ERROR"
    [ "$status" -eq 0 ]
    [ "$output" = $'\033[31m' ]
}

@test "Test wrong color" {
    run get_log_color "WRONG"
    [ "$status" -eq 0 ]
    [ "$output" = $'' ]
}
