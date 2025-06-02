return {
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets' },

  version = '1.*',

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

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    completion = {
      documentation = { auto_show = true }, -- Shows documentation all the time or not
      -- list = { selection = { preselect = false, auto_insert = true } }
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'cmdline' },
    },

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
