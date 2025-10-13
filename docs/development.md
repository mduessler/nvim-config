# Development

This document holds all information needed for the Development process.

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
