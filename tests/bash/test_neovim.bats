#!/usr/bin/env bats

@test "Test if script '${NVIM_CONFIG}/installs/neovim' exists." {
    [ -f "${NVIM_CONFIG}"/installs/neovim ]
}

setup() {
    source "${NVIM_CONFIG}/dependencies"
    source "${NVIM_CONFIG}/installs/neovim"
    unset XDG_DATA_HOME
}

@test "[TEST]: install_nvim - is dir but no git dir" {
    mkdir -p "${HOME}/.local/share/src/neovim"
    dir_is_git_repo() { return 1; }

    run install_nvim
    [ ${status} -eq 1 ]
}

@test "[TEST]: install_nvim - pull_git_dir_fails" {
    mkdir -p "${HOME}/.local/share/src/neovim"
    dir_is_git_repo() { return 0; }
    pull_git_dir() { return 1; }

    run install_nvim
    [ ${status} -eq 2 ]
}

@test "[TEST]: install_nvim - clone_git_dir_fails" {
    rm -rf "${HOME}/.local/share/src/neovim"
    mkdir -p "${HOME}/.local/share/src/"
    dir_is_git_repo() { return 0; }
    read() { return 1; }
    clone_repo() {
        echo 45 "test/"
        return 0
    }

    run install_nvim
    [ ${status} -eq 3 ]
}

@test "[TEST]: install_nvim - checkout fails" {
    mkdir -p "${HOME}/.local/share/src/neovim"
    dir_is_git_repo() { return 0; }
    pull_git_dir() { return 0; }
    git() { return 1; }

    run install_nvim
    [ ${status} -eq 4 ]
}

@test "[TEST]: install_nvim - make build fails" {
    mkdir -p "${HOME}/.local/share/src/neovim"
    dir_is_git_repo() { return 0; }
    pull_git_dir() { return 0; }
    git() { return 0; }
    make() { return 1; }

    run install_nvim
    [ ${status} -eq 5 ]
}

@test "[TEST]: install_nvim - make install fails" {
    mkdir -p "${HOME}/.local/share/src/neovim"
    dir_is_git_repo() { return 0; }
    pull_git_dir() { return 0; }
    git() { return 0; }
    make() { return 0; }
    sudo() { return 1; }

    run install_nvim
    [ ${status} -eq 6 ]
}

@test "[TEST]: check_nvim_version - version machtes" {
    nvim() { echo "NVIM v${NVIM_MAJOR_REQ}.${NVIM_MINOR_REQ}.${NVIM_PATCH_REQ}" && return 0; }

    run check_nvim_version

    [ ${status} -eq 0 ]
    [[ "${output}" == *"Installed nvim version is v${NVIM_MAJOR_REQ}.${NVIM_MINOR_REQ}.${NVIM_PATCH_REQ}."* ]]
}

@test "[TEST]: check_nvim_version - invalid version" {
    nvim() { echo "NVIM v${NVIM_MAJOR_REQ}.${NVIM_MINOR_REQ}" && return 0; }

    run check_nvim_version
    [ ${status} -eq 1 ]
    [[ "${output}" == *"Invalid version format."* ]]
}

@test "[TEST]: check_nvim_version - neovim is not installed" {
    PATH="" run check_nvim_version
    echo $status
    [ ${status} -eq 2 ]
    [[ "${output}" == *"Can not execute neovim."* ]]
}

@test "[TEST]: check_nvim_version - version is to low" {
    local minor_patch=$((NVIM_MINOR_REQ - 1))
    nvim() { echo "NVIM v${NVIM_MAJOR_REQ}.${minor_patch}.${NVIM_PATCH_REQ}" && return 0; }

    run check_nvim_version
    [ ${status} -eq 3 ]
    [[ "${output}" == *"Neovim version is v${NVIM_MAJOR_REQ}.${minor_patch}.${NVIM_PATCH_REQ}. But v${NVIM_MAJOR_REQ}.${NVIM_MINOR_REQ}.${NVIM_PATCH_REQ} is needed."* ]]
}
