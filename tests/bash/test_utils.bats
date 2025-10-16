#!/usr/bin/env bats

@test "Test '${NVIM_HOME}/installs/utils' is executeable" {
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

@test "Test debug log NVIM_DEV=false" {
    local msg="This is a test message"
    NVIM_DEV=false
    run debug "${msg}"
    [ "$status" -eq 0 ]
    [ "$output" == $'' ]
}

@test "Test debug log NVIM_DEV=true" {
    local msg="This is a test message"
    NVIM_DEV=true
    run debug "${msg}"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "${msg}" ]]
    [[ "$output" =~ "DEBUG" ]]
}

@test "Test info log" {
    local msg="This is a test message"
    NVIM_DEV=false
    run debug "${msg}"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "${msg}" ]]
    [[ "$output" =~ "INFO" ]]
}

@test "Test success log" {
    local msg="This is a test message"
    NVIM_DEV=false
    run debug "${msg}"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "${msg}" ]]
    [[ "$output" =~ "SUCCESS" ]]
}
