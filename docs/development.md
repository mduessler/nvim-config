# Development

This document holds all information needed for the Development process. Read it
carefully before you execute the command to install the dependencies to execute
the development environments.

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

## Install

To install dependencies needed to run the development environments simply
run `make install-dev`. This executed `./install dev`.

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
