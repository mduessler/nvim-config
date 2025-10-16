#!/usr/bin/env bats

@test "[TEST]: '${NVIM_HOME}/installs/utils' exists " {
    [ -f "${NVIM_HOME}"/installs/utils ]
}

setup() {
    source "${NVIM_HOME}/installs/utils"
}

@test "[TEST]: debug color" {
    run get_log_color "DEBUG"
    [ "$status" -eq 0 ]
    [ "$output" = $'\033[37m' ]
}

@test "[TEST]: info color" {
    run get_log_color "INFO"
    [ "$status" -eq 0 ]
    [ "$output" = $'\033[34m' ]
}

@test "[TEST]: success color" {
    run get_log_color "SUCCESS"
    [ "$status" -eq 0 ]
    [ "$output" = $'\033[32m' ]
}

@test "[TEST]: warning color" {
    run get_log_color "WARNING"
    [ "$status" -eq 0 ]
    [ "$output" = $'\033[33m' ]
}

@test "[TEST]: error color" {
    run get_log_color "ERROR"
    [ "$status" -eq 0 ]
    [ "$output" = $'\033[31m' ]
}

@test "[TEST]: wrong color" {
    run get_log_color "WRONG"
    [ "$status" -eq 0 ]
    [ "$output" = $'' ]
}

@test "[TEST]: debug log NVIM_DEV=false" {
    local msg="This is a test message"
    NVIM_DEV=false
    run debug "${msg}"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "[TEST]: debug log NVIM_DEV=true" {
    local msg="This is a test message"
    NVIM_DEV=true
    run debug "${msg}"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "${msg}" ]]
    [[ "$output" =~ "DEBUG" ]]
}

@test "[TEST]: info log" {
    local msg="This is a test message"
    run info "${msg}"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "${msg}" ]]
    [[ "$output" =~ "INFO" ]]
}

@test "[TEST]: success log" {
    local msg="This is a test message"
    run success "${msg}"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "${msg}" ]]
    [[ "$output" =~ "SUCCESS" ]]
}

@test "[TEST]: warning log" {
    local msg="This is a test message"
    run warning "${msg}"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "${msg}" ]]
    [[ "$output" =~ "WARNING" ]]
}

@test "[TEST]: error log" {
    local msg="This is a test message"
    run error "${msg}"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "${msg}" ]]
    [[ "$output" =~ "ERROR" ]]
}

@test "[TEST]: check_command returns 0 for existing command" {
    check_command ls
    status=$?
    [ "$status" -eq 0 ]
}

@test "[TEST]: check_command returns 1 for non-existing command" {
    check_command fakecmd123
    status=$?
    [ "$status" -eq 1 ]
}
