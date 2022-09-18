{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  lspVimrcConfig = builtins.readFile ./base-neovim-config.lua;

  extraConfig = builtins.readFile ./extra-neovim-config.vim;

  vimrc = ''
    lua << EOF
    ${lspVimrcConfig}
    EOF

    ${extraConfig};
  '';

  # bat.vim syntax highlighting:
  bat-vim = pkgs.vimUtils.buildVimPlugin {
    name = "bat.vim";
    src = pkgs.fetchFromGitHub {
      owner = "jamespwilliams";
      repo = "bat.vim";
      rev = "e2319b07ed6e74cdd70df2be6e8bf066377e22f7";
      sha256 = "0bmlvziha1crk7x7p1yzdsb55bvpsj434sc28r7xspin9kfnd6y9";
    };
  };

  overriden-neovim =
    pkgs.neovim.override {
      configure = {
        customRC = vimrc;
        packages.packages = with pkgs.vimPlugins; {
          start = [
            bat-vim
            nvim-lspconfig
            (nvim-treesitter.withPlugins (
              plugins: with plugins; [
                tree-sitter-go
              ]
            ))
            sensible
          ];
        }; 
      };     
    };
in
mkShell {
  nativeBuildInputs = [
    go_1_18
    gopls
    overriden-neovim
    tmux
  ];
}
