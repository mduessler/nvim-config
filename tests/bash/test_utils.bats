#!/usr/bin/env bats

@test "[TEST]: '${NVIM_CONFIG}/installs/utils' exists " {
    [ -f "${NVIM_CONFIG}"/installs/utils ]
}

setup() {
    source "${NVIM_CONFIG}/installs/utils"
}

@test "get_log_color: Verify that the debug colour is correct." {
    run get_log_color "DEBUG"
    [ ${status} -eq 0 ]
    [ "${output}" = $'\033[37m' ]
}

@test "[TEST]: info color" {
    run get_log_color "INFO"
    [ ${status} -eq 0 ]
    [ "${output}" = $'\033[34m' ]
}

@test "[TEST]: success color" {
    run get_log_color "SUCCESS"
    [ ${status} -eq 0 ]
    [ "${output}" = $'\033[32m' ]
}

@test "[TEST]: warning color" {
    run get_log_color "WARNING"
    [ ${status} -eq 0 ]
    [ "${output}" = $'\033[33m' ]
}

@test "[TEST]: error color" {
    run get_log_color "ERROR"
    [ ${status} -eq 0 ]
    [ "${output}" = $'\033[31m' ]
}

@test "[TEST]: wrong color" {
    run get_log_color "WRONG"
    [ ${status} -eq 0 ]
    [ "${output}" = $'\033[0m' ]
}

@test "[TEST]: debug log NVIM_DEV=false" {
    local msg="This is a test message"
    NVIM_DEV=false
    run debug "${msg}"
    [ ${status} -eq 0 ]
    [ -z ${output} ]
}

@test "[TEST]: debug log NVIM_DEV=true" {
    local msg="This is a test message"
    NVIM_DEV=true
    run debug "${msg}"
    [ ${status} -eq 0 ]
    [[ ${output} =~ "${msg}" ]]
    [[ ${output} =~ "DEBUG" ]]
}

@test "[TEST]: info log" {
    local msg="This is a test message"
    run info "${msg}"
    [ ${status} -eq 0 ]
    [[ ${output} =~ "${msg}" ]]
    [[ ${output} =~ "INFO" ]]
}

@test "[TEST]: success log" {
    local msg="This is a test message"
    run success "${msg}"
    [ ${status} -eq 0 ]
    [[ ${output} =~ "${msg}" ]]
    [[ ${output} =~ "SUCCESS" ]]
}

@test "[TEST]: warning log" {
    local msg="This is a test message"
    run warning "${msg}"
    [ ${status} -eq 0 ]
    [[ ${output} =~ "${msg}" ]]
    [[ ${output} =~ "WARNING" ]]
}

@test "[TEST]: error log" {
    local msg="This is a test message"
    run error "${msg}"
    [ ${status} -eq 0 ]
    [[ ${output} =~ "${msg}" ]]
    [[ ${output} =~ "ERROR" ]]
}

@test "[TEST]: check_command returns 0 for existing command" {
    check_command ls
    status=$?
    [ ${status} -eq 0 ]
}

@test "[TEST]: check_command returns 1 for non-existing command" {
    run check_command fakecmd123
    [ ${status} -eq 1 ]
}

@test "[TEST]: dir_is_git_repo - no argument given" {
    run dir_is_git_repo

    [ ${status} -eq 2 ]
    [[ ${output} == *"Function needs exactly one 'path' argument."* ]]
}

@test "[TEST]: dir_is_git_repo - two arguments given" {
    run dir_is_git_repo "${HOME}" "test"

    [ ${status} -eq 2 ]
    [[ ${output} == *"Function needs exactly one 'path' argument."* ]]
}

@test "[TEST]: dir_is_git_repo - test path exists." {
    run dir_is_git_repo "fake/pater/aasd"

    [ ${status} -eq 3 ]
    [[ ${output} == *"Path 'fake/pater/aasd' does not exist."* ]]
}

@test "[TEST]: dir_is_git_repo - is a git repo" {
    git() { return 0; }
    run dir_is_git_repo "${HOME}"

    [ ${status} -eq 0 ]
    [[ ${output} == *"Path '${HOME}' is a git repo."* ]]
}

@test "[TEST]: dir_is_git_repo - is not a git repo" {
    run dir_is_git_repo "${HOME}"

    [ ${status} -eq 1 ]
    [[ ${output} == *"Path '${HOME}' is not a git repo."* ]]
}

@test "[TEST]: pull_git_dir - no argument given" {
    run pull_git_dir

    [ ${status} -eq 2 ]
    [[ ${output} == *"Function needs exactly one 'path' argument."* ]]
}

@test "[TEST]: pull_git_dir - test path exists." {
    run pull_git_dir "fake/pater/aasd"

    [ ${status} -eq 3 ]
}

@test "[TEST]: pull_git_dir - success" {
    git() { return 0; }
    cd() { return 0; }
    run pull_git_dir "${HOME}"

    [ ${status} -eq 0 ]
    [[ ${output} == *"Pulled repo at '${HOME}'."* ]]
}

@test "[TEST]: pull_git_dir - fail" {
    git() { return 1; }
    cd() { return 0; }
    run pull_git_dir "${HOME}"

    [ ${status} -eq 1 ]
    [[ ${output} == *"Can not pull repo at '${HOME}'."* ]]
}

@test "[TEST]: clone_repo - two arguments needed" {
    run clone_repo

    [ ${status} -eq 2 ]
    [[ ${output} == *"Function needs exactly two arguments, 'repo-url' and 'dest-dir'."* ]]
}

@test "[TEST]: clone_repo - clone success" {
    git() {
        echo "mock git called with: $*"
        sleep 1
        return 0
    }
    run clone_repo "https://github.com/mduessler/nvim-config.git" "simply-the-best"

    echo ${output}
    pid=$(echo ${output} | awk '{print $1}' | xargs)
    tmpfile=$(echo ${output} | awk '{print $2}' | xargs)

    [ ${status} -eq 0 ]
    [[ ${pid} =~ ^[0-9]+$ ]]
    [[ -f "${tmpfile}" ]]
}

@test "[TEST]: clone_repo - clone fails" {
    git() {
        echo "mock git called with: $*"
        sleep 1
        return 1
    }
    run clone_repo "https://github.com/mduessler/nvim-config.git" "simply-the-best"

    echo ${output}
    pid=$(echo ${output} | awk '{print $1}' | xargs)
    tmpfile=$(echo ${output} | awk '{print $2}' | xargs)

    [ ${status} -eq 0 ]
    [[ ${pid} =~ ^[0-9]+$ ]]
    [[ -f "${tmpfile}" ]]
}

@test "[TEST]: wait_for_clone_process - two arguments needed" {
    run wait_for_clone_process

    [ ${status} -eq 2 ]
    [[ ${output} == *"Function needs exactly two arguments, 'pid' and 'tmpfile'."* ]]
}

@test "[TEST]: wait_for_clone_process - success" {
    tmpfile=$(mktemp)
    pid=12345

    tail() {
        echo "mock tail $*"
        return 0
    }
    wait() {
        echo "mock wait $*"
        return 0
    }

    run wait_for_clone_process "$pid" "$tmpfile"

    [ ${status} -eq 0 ]
    [[ ${output} == *"Waiting for clone process $pid to finish."* ]]

    rm -f "$tmpfile"
}

@test "[TEST]: wait_for_clone_process - tail fails" {
    tmpfile=$(mktemp)
    pid=12345

    tail() {
        echo "mock tail $*"
        return 1
    }
    wait() {
        echo "mock wait $*"
        return 0
    }

    run wait_for_clone_process "$pid" "$tmpfile"

    [ ${status} -eq 3 ]
    [[ ${output} == *"Can not tail ${tmpfile}."* ]]

    rm -f "$tmpfile"
}

@test "[TEST]: wait_for_clone_process - wait fails" {
    tmpfile=$(mktemp)
    pid=12345

    tail() {
        echo "mock tail $*"
        return 0
    }
    wait() {
        echo "mock wait $*"
        return 1
    }

    run wait_for_clone_process "$pid" "$tmpfile"

    [ ${status} -eq 1 ]
    [[ ${output} == *"Can not wait ${pid}."* ]]

    rm -f "$tmpfile"
}

@test "[TEST]: kill_clone_process - one argument needed" {
    run kill_clone_process

    [ ${status} -eq 2 ]
    [[ ${output} == *"Function needs exactly one 'pid' argument."* ]]
}

@test "[TEST]: kill_clone_process - success" {
    kill() { return 0; }
    pid=12345
    run kill_clone_process ${pid}

    [ ${status} -eq 0 ]
    [[ ${output} == *"Killed process ${pid}."* ]]
}

@test "[TEST]: kill_clone_process - fails" {
    kill() { return 1; }
    pid=12345
    run kill_clone_process ${pid}

    [ ${status} -eq 1 ]
    [[ ${output} == *"Can not kill nerd-fonts process '${pid}'."* ]]
}
