return {
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets', 'onsails/lspkind.nvim', { 'L3MON4D3/LuaSnip', version = 'v2.*' } },

  version = '1.*',

  lazy = true,

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    -- keymap = { preset = 'default' },
    keymap = {
      preset = 'none',

      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
      ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

      ['<Tab>'] = { 'select_next', 'fallback_to_mappings' },
      ['<S-Tab>'] = { 'select_prev', 'fallback_to_mappings' },

      ['<C-a>'] = { 'select_and_accept' },
      ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
    },

    -- General appearance
    appearance = {
      nerd_font_variant = 'mono'
    },

    -- Autocompletion menus (incl documentation)
    completion = {
      documentation = {
        auto_show = true, -- Shows documentation all the time or not
        auto_show_delay_ms = 0,
        window = { border = "rounded" }
      },

      -- Icon configuration
      menu = {
        border = "rounded",

        draw = {
          columns = {
            { "kind_icon", "label", gap = 1 },
            { "kind", gap = 10 },
          },
          components = {
            kind_icon = {
              text = function(ctx)
                local icon = ctx.kind_icon
                if vim.tbl_contains({ "Path" }, ctx.source_name) then
                  local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                  if dev_icon then
                    icon = dev_icon
                  end
                else
                  icon = require("lspkind").symbolic(ctx.kind, {
                    mode = "symbol",
                  })
                end

                return icon .. ctx.icon_gap
              end,

              -- Optionally, use the highlight groups from nvim-web-devicons
              -- You can also add the same function for `kind.highlight` if you want to
              -- keep the highlight groups in sync with the icons.
              highlight = function(ctx)
                local hl = ctx.kind_hl
                if vim.tbl_contains({ "Path" }, ctx.source_name) then
                  local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                  if dev_icon then
                    hl = dev_hl
                  end
                end
                return hl
              end,
            }
          }
        }
      },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'cmdline' },
    },

    snippets = { preset = 'luasnip' },

    cmdline = {
      keymap = { preset = 'inherit' },
      sources = function()
        local type = vim.fn.getcmdtype()
        -- Only allow : and @ to have autocompletion, screw you / and ?
        if type == ':' or type == '@' then return { 'cmdline' } end

        return {}
      end,

      completion = {
        menu = { auto_show = true },
        -- list = { selection = { preselect = false, auto_insert = true } }
      },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
}
