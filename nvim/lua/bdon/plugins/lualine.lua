return {
 'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      component_separators = { left = '󰇙', right = '󱋱'},
      section_separators = { left = '', right = ''},
      extensions = {'oil', 'trouble'},
      ignore_focus = {
        'dapui_watches',
        'dapui_breakpoints',
        'dapui_scopes',
        'dapui_console',
        'dapui_stacks',
        'dap-repl'
      }
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff'},
      lualine_c = {
        {'filetype', separator = "", padding = {left = 1, right = 0}, icon_only = true},
        {'filename', padding = 0}
      },

      lualine_x = {{
        'diagnostics',
        update_in_insert = true,
        symbols = {
          error = " ",
          warn = " ",
          info = "󰌵 ",
          hint = "󰌵 "
        }
      }},
      lualine_y = {'progress',
        function()
          local linenum = vim.api.nvim_win_get_cursor(0)[1]
          local column = vim.api.nvim_win_get_cursor(0)[2]
          return "Ln " .. linenum .. " Col " .. column
        end
      },
      lualine_z = {{'windows', mode = 1}}
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {'filename'},
      lualine_y = {},
      lualine_z = {}
    },
    tabline = {
      -- lualine_a = {
      --   {
      --     'tabs',
      --     mode = 2
      --   }
      -- }
    },
    winbar = {},
    inactive_winbar = {},
    extensions = {},
  }
}
