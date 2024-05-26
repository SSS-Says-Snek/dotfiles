return {
  "neovim/nvim-lspconfig",

  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },

  config = function()
    local lspconfig = require("lspconfig")
    local keymap = vim.keymap

    lspconfig.pyright.setup {}
    lspconfig.lua_ls.setup {
      settings = {
        Lua = {
          diagnostics = {
            globals = {'vim'}
          }
        }
      }
    }
    lspconfig.eslint.setup {}
    lspconfig.tsserver.setup {}
    lspconfig.cssls.setup {}
    lspconfig.eslint.setup {}
    lspconfig.svelte.setup {
      filetypes = { "svelte" },
      on_attach = function(client, bufnr)
        if client.name == 'svelte' then
          vim.api.nvim_create_autocmd("BufWritePost", {
            pattern = { "*.js", "*.ts", "*.svelte" },
            callback = function(ctx)
              client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
            end,
          })
        end
        if vim.bo[bufnr].filetype == "svelte" then
          vim.api.nvim_create_autocmd("BufWritePost", {
            pattern = { "*.js", "*.ts", "*.svelte" },
            callback = function(ctx)
              client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
            end,
          })
        end
      end
    }
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        local opts = {buffer = ev.buf}

        keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', opts)
        keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<cr>', opts)
        keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<cr>', opts)
        keymap.set('n', 'gt', '<cmd>Telescope lsp_type_definitions<cr>', opts)
        keymap.set({ 'n', 'v' }, '<leader>ca', '<cmd>Lspsaga code_action<cr>', opts)
        keymap.set('n', '<leader>rn', '<cmd>Lspsaga rename<cr>', opts)
      end
    })
  end
}
