# My NVIM config

This is my NVIM config which uses lazy as plugin manager. This config was
developed with NVIM v0.11.4.

## Goals

1. Development and implementation of a NVIM configuration to provide an
   integrated development environment (IDE) for software projects.
2. Developing my own UI for NVIM, implemented in Lua, to extend the
   IDE functionality and improve the user experience.
3. Keep a clean, structured and simple NVIM config, which can be easily
   maintained.

## Dependencies

- NVIM v0.11.4 or higher
- [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) - Need for UI

## Installation

### Before Installation

1. You can set `$RUSTUP_HOME` and `$CARGO_HOME` to specify the installation
   directory of rust and its package manager cargo. But you need to set
   `$CARGO_HOME/bin` in your `PATH`.

### Actual Installation

To install everything, except *Nerd Fonts*, simply run `./install`. You can
also install it with Nerd Fonts, but this process takes a very long time
because it clones the whole Nerd Fonts git repo. For this simply run
`./install --nerd-fonts`.

Currently, only an automatic installation for Fedora and Ubuntu is implemented.
The installation script has been tested on Fedora 42 and Ubuntu 24.04. The
installation should also work on distributions with the same package manager.

### After Installation

1. To allow *mason-tools-installer* to update and install new tools, ensure that
   `$CARGO_HOME/bin` is in your `PATH`.

## Configuration

1. **Remote-Nvim** -- The path can be set using the variable `$SSH_CONFIG`.
   Otherwise, `$HOME/.ssh/config` is used.

## Development

Information about the development process is stored under [docs/development.md](docs/development.md)

## Notes & Feedback 🎉

Enjoy using the config and thank you for using it 😊

If you notice any errors or inconsistencies, please open an issue – feedback
is always welcome 🙃
