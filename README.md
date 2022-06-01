# neovim-go-nix-develop

[![asciicast](https://asciinema.org/a/498457.svg)](https://asciinema.org/a/498457)

Get a neovim-based Go development environment in one command, using Nix. First, 
[install Nix](https://nix.dev/tutorials/install-nix) and [enable Nix
flakes](https://nixos.wiki/wiki/Flakes#Installing_flakes). Then:

```
nix develop github:jamespwilliams/neovim-go-nix-develop
```

### Components

The development environment provides:

* go (at the time of writing, version 1.18.2)
* gopls (the official Go language server)
* neovim
* nvim-lspconfig
    * and configuration to get it to work with gopls
    * plus configuration to automatically fix up imports
* nvim-treesitter configuration for go code
* [bat.vim](https://github.com/jamespwilliams/bat.vim), my own Vim theme, which
  has extra rules for highlighting treesitter-parsed Go files
* [vim-sensible](https://github.com/tpope/vim-sensible), Tim Pope's set of sane
  defaults for Vim

The neovim configuration is deliberately minimal. My hope is that this
repository gives you something to base your own environments on - I
encourage you to fork this repo and make your own changes! I've tried to make it
easy to modify `shell.nix` - you should just be able to add configuration to
`extraConfig` in `shell.nix`.
