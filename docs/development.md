# Development

This document holds all information needed for the Development process. Read it
carefully before you execute the command to install the dependencies to execute
the development environments.

## Process

The following development process must be taken into account during
development. Each issue is developed on its own branch. There exist four types
of issues. The *feature*, *refactor*, *fix* and *hotfix*. The steps of the
default development process consist of the following steps. First create an
issue. After it, create a new branch from the current dev branch. Once a
problem has been fixed, a pull request must be submitted. Only once this has
been confirmed may the problem be transferred to the dev branch. Except the
issue was a *hotfix*. This issue has to be merged directly with the main branch.
Whenever a new version of Neovim is created, it must be tested on the current
dev branch and merged with the main branch. A new version of the Neovim config
is then created from the main branch.

- **feature** -- represents new function of the configuration. After the issue
  is finished and the pull request succeeds the branch of the issue is merged
  with the *dev* branch.
- **refactor** -- represents the revision of code. After the process is finished
  and the pull request succeeds the branch is merged with the *dev* branch.
- **fix** -- represents the correction of errors. After the error is fixed and
  the pull request succeeds the fix will be merged with *dev*.
- **hotfix** -- represents an error that must be corrected urgently. After the
  pull request succeeds it will be merged with the *main* branch.

## Install

To install the dependencies required to run the development environments,
simply run `make install-dev`. This will execute `./install dev`.

## Dependencies

All dependencies are stored in the file `dependencies` in the root of the
project. In this file exists **production** dependencies and requirements.
These dependencies are always needed to run the NVIM configuration.
The variables `NVIM_MAJOR_REQ`, `NVIM_MINOR_REQ` and `NVIM_PATCH_REQ`
are combined, representing the required NVIM version to run this config.
The 3 variables represent a NVIM version like this
`v${NVIM_MAJOR_REQ}.{$NVIM_MINOR_REQ}.${NVIM_PATCH_REQ}`.

The **development** dependencies only needed to run tests or to run the
development environment.

The file `dependencies` contains these bash arrays, which list the
dependencies:

1. *production*
   - **DEPS** -- Dependencies independent of the systems package manager.
   - **APT_DEPS** -- Dependencies installed by apt-get package manager.
   - **DNF_DEPS** -- Dependencies installed by dnf package manger.
   - **LUA_REQ** -- Requirements installed with luarocks.
   - **RUST_REQ** -- Requirements installed with cargo.
2. *development*
   - **APT_DEPS** -- Dependencies installed by apt-get package manager.
   - **DNF_DEV_DEPS** -- Dependencies installed by dnf package manger.
   - **LUA_DEV_REQ** -- Requirements installed with luarocks.

## Tests

There exists two types of tests. Both tests will be executed on Fedora and
Ubuntu.

1. **Environment tests** -- Running the installation script in an isolated
   environment to verify the installation of all required dependencies and
   requirements.
   - `make fedora-install-tests-local` -- Runs install script in a fedora
     environment.
   - `make ubuntu-install-tests-local` -- Runs install script in a ubuntu
     environment.
2. **Unit tests**. -- Running tests in an environment with all dependencies
   and requirements installed.
   - `make fedora-unit-tests-local` -- Runs unit tests in a fedora
     environment.
   - `make ubuntu-unit-tests-local` -- Runs unit tests in a ubuntu
     environment.
3. **Remote tests** -- *Environment test* and *unit tests* are also executed
   with github actions during a pull request to main or dev.
   - `make fedora-build-remote` -- Builds and uploads the fedora environment
     for the github action tests. This image is also used to perform linting
     with pre-commit.
   - `make ubuntu-build-remote` -- Builds and uploads the ubuntu environment
     for the github action test
   - `make build-remote` -- Builds and uploads the fedora and ubuntu
     environment for the github action test

### Naming

All functions must be tested in ascending order of return value.

1. **Bash tests** -- Syntax: `<Identifier>: <Description> - <Note>`.
   - *Identifier* is the name of the function to be tested.
   - *Description* is a brief description of the function result to be tested
     with this test.
   - *Notes* are additional information.
   - Examples:
     1. `rust_installer: Function executed successfully - rust has been installed`
     2. `install_prod: Function cannot install production requirements`

## Commands

### Named Commands

Named commands for the initialization are stored under `lua/configs/cmd.lua`

1. **InitNVIM** -- The operations of the command are only executed in headless
   mode. The command executes the `Lazy sync` command to download and install
   all plugins. After it all defined language servers, defined in
   `lua/lsp/servers.lua` will be installed. Next all formater and linter which
   are defined in the file `lua/plugins/mason.lua` in the tables *formater*
   and *linter* will be installed with mason-tools-installer. At the end, the
   languages of Treesitter will be installed.
