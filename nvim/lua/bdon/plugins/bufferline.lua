return {
  'akinsho/bufferline.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },

  event = "VeryLazy",

  keys = {
    { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
    { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
    { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
    { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
    { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
  },

  -- after = "catppuccin",
  opts = {
    highlights = {
      fill = {
        bg = "#181826",
        bold = false,
        italic = false
      },
      separator = {
        bg = "#181826",
        bold = false,
        fg = "#181826",
        italic = false
      },
      separator_selected = {
        bg = "#1e1e2f",
        bold = false,
        fg = "#181826",
        italic = false
      },
      separator_visible = {
        bg = "#181826",
        bold = false,
        fg = "#181826",
        italic = false
      },
    },

    options = {
      numbers = "ordinal",
      diagnostics = "nvim_lsp",
      themable = false,
      indicator = {
        icon = '󱋱 ',
        style = 'underline'
      },
      separator_style = "slope",
      -- highlights = require("catppuccin.groups.integrations.bufferline").get(),
      -- highlights = { indicator_selected = { bg = '#ff0000'} },

      diagnostics_indicator = function(count, level, _, _)
        local icon = level:match("error") and " " or " "
        return " " .. icon .. count
      end
    }
  }
}

