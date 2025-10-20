return {
  "neovim/nvim-lspconfig",

  event = { "BufReadPost", "BufWritePost", "BufNewFile" },

  dependencies = {
    'saghen/blink.cmp',
    { "antosha417/nvim-lsp-file-operations", config = true },
  },

  opts = {
    servers = {
      eslint = {},
      ts_ls = {},
      cssls = {},
      clangd = {},
      pyright = {},
      mesonlsp = {},
      marksman = {},
      ruff = {},

      lua_ls = {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
              path ~= vim.fn.stdpath('config')
              and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
            then
              return
            end
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              version = 'LuaJIT',
              path = {
                'lua/?.lua',
                'lua/?/init.lua',
              },
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME
              }
            }
          })
        end,

        settings = {
          Lua = {}
        }
      },

      svelte = {
        filetypes = { "svelte", "html" },
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
    }
  },

  config = function(_, opts)
    local keymap = vim.keymap


    -- Supply opts config into lspconfig
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    for server, config in pairs(opts.servers) do
      config.capabilities = capabilities
      vim.lsp.config(server, config)
      vim.lsp.enable({server})
    end

    -- Keymaps
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        local options = {buffer = ev.buf}

        keymap.set('n', 'gD', vim.lsp.buf.declaration, options)
        keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', options)
        keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<cr>', options)
        keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<cr>', options)
        keymap.set('n', 'gt', '<cmd>Telescope lsp_type_definitions<cr>', options)
        keymap.set('n', '<leader>rn', '<cmd>Lspsaga rename<cr>', options)
      end
    })
  end,
}
