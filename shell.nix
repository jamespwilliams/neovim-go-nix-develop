{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  lspVimrcConfig = ''
    lua <<EOF

    local lspconfig          = require 'lspconfig'
    local treesitter_configs = require 'nvim-treesitter.configs'

    treesitter_configs.setup {
      ensure_installed = {'go'},
      highlight = {
        enable = true,
      },
    }

    -- Mappings (adapted from https://github.com/neovim/nvim-lspconfig#suggested-configuration)
    -- See `:help vim.diagnostic.*` for documentation on any of the below functions
    local opts = { noremap=true, silent=true }
    vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
    
    -- Use an on_attach function to only map the following keys
    -- after the language server attaches to the current buffer
    local on_attach = function(client, bufnr)
      -- Enable completion triggered by <c-x><c-o>
      vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    
      -- Mappings.
      -- See `:help vim.lsp.*` for documentation on any of the below functions
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    end

    lspconfig.gopls.setup {
      on_attach = on_attach,
    }

    -- https://github.com/golang/tools/blob/1f10767725e2be1265bef144f774dc1b59ead6dd/gopls/doc/vim.md#imports
    function OrgImports(wait_ms)
      local params = vim.lsp.util.make_range_params()
      params.context = {only = {"source.organizeImports"}}
      local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
      for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
          if r.edit then
            vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
          else
            vim.lsp.buf.execute_command(r.command)
          end
        end
      end
    end

    EOF

    autocmd BufWritePre *.go lua OrgImports(1000)
    autocmd BufWritePre *.go lua vim.lsp.buf.formatting_sync()
  '';

  extraConfig = ''
    " Insert your own config here...

    filetype indent plugin on
    syntax enable

    packloadall

    " Fix syntax highlighting in tmux:
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set t_Co=256

    set termguicolors

    set background=dark
    colorscheme bat
  '';

  vimrc = lspVimrcConfig + extraConfig;

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
