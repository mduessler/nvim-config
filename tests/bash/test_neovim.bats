#!/usr/bin/env bats

@test "Test if script '${NVIM_CONFIG}/installs/neovim' exists." {
    [ -f "${NVIM_CONFIG}"/installs/neovim ]
}

setup() {
    source "${NVIM_CONFIG}/dependencies"
    source "${NVIM_CONFIG}/installs/neovim"
    unset XDG_DATA_HOME
}

@test "install_nvim: Function executed successfully." {
    mkdir -p "${HOME}/.local/share/src/neovim"
    dir_is_git_repo() { return 0; }
    pull_git_dir() { return 0; }
    cd() { return 0; }
    git() { return 0; }
    make() { return 0; }
    sudo() { return 0; }

    run install_nvim

    echo ${status}
    [ ${status} -eq 0 ]
    [[ ${output} == *"Installed NVIM v${NVIM_MAJOR_REQ}.${NVIM_MINOR_REQ}.${NVIM_PATCH_REQ}."* ]]
}

@test "install_nvim: Can not install neovim - directory exists and is not a git repo." {
    local dir="${HOME}/.local/share/src/neovim"
    mkdir -p "${dir}"
    dir_is_git_repo() { return 1; }

    run install_nvim

    [ ${status} -eq 1 ]
    [[ ${output} == *"Directory ${dir} already exists and is no git repo."* ]]
}

@test "install_nvim: Can not install neovim - can not pull git dir." {
    mkdir -p "${HOME}/.local/share/src/neovim"
    dir_is_git_repo() { return 0; }
    pull_git_dir() { return 1; }

    run install_nvim

    [ ${status} -eq 2 ]
    [[ ${output} == *"Neovim git repo exists. Pulling ..."* ]]
}

@test "install_nvim: Can not install neovim - can not clone git repo." {
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
    [[ ${output} == *"Can not clone repo."* ]]
}

@test "install_nvim: Can not install neovim - can not checkout to git branch." {
    mkdir -p "${HOME}/.local/share/src/neovim"
    dir_is_git_repo() { return 0; }
    pull_git_dir() { return 0; }
    git() { return 1; }

    run install_nvim

    [ ${status} -eq 4 ]
}

@test "install_nvim: Can not install neovim - can not create build with make." {
    mkdir -p "${HOME}/.local/share/src/neovim"
    dir_is_git_repo() { return 0; }
    pull_git_dir() { return 0; }
    git() { return 0; }
    make() { return 1; }

    run install_nvim

    [ ${status} -eq 5 ]
}

@test "install_nvim: Can not install neovim - can not install build with make." {
    mkdir -p "${HOME}/.local/share/src/neovim"
    dir_is_git_repo() { return 0; }
    pull_git_dir() { return 0; }
    git() { return 0; }
    make() { return 0; }
    sudo() { return 1; }

    run install_nvim

    [ ${status} -eq 6 ]
}

@test "check_nvim_version: Function executed successfully." {
    nvim() { echo "NVIM v${NVIM_MAJOR_REQ}.${NVIM_MINOR_REQ}.${NVIM_PATCH_REQ}" && return 0; }

    run check_nvim_version

    [ ${status} -eq 0 ]
    [[ ${output} == *"Installed nvim version is v${NVIM_MAJOR_REQ}.${NVIM_MINOR_REQ}.${NVIM_PATCH_REQ}."* ]]
}

@test "check_nvim_version: Invalid version number." {
    nvim() { echo "NVIM v${NVIM_MAJOR_REQ}.${NVIM_MINOR_REQ}" && return 0; }

    run check_nvim_version

    [ ${status} -eq 1 ]
    [[ ${output} == *"Invalid version format."* ]]
}

@test "check_nvim_version: Can not execute neovim." {
    PATH="" run check_nvim_version

    [ ${status} -eq 2 ]
    [[ ${output} == *"Can not execute neovim."* ]]
}

@test "check_nvim_version: Neovim version is to low." {
    local minor_patch=$((NVIM_MINOR_REQ - 1))
    nvim() { echo "NVIM v${NVIM_MAJOR_REQ}.${minor_patch}.${NVIM_PATCH_REQ}" && return 0; }

    run check_nvim_version

    [ ${status} -eq 3 ]
    [[ ${output} == *"Neovim version is v${NVIM_MAJOR_REQ}.${minor_patch}.${NVIM_PATCH_REQ}. But v${NVIM_MAJOR_REQ}.${NVIM_MINOR_REQ}.${NVIM_PATCH_REQ} is needed."* ]]
}
