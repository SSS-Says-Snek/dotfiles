return {
  'akinsho/bufferline.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  -- after = "catppuccin",
  config = function()
    -- vim.api.nvim_set_hl(0, 'BufferLineFill', {bg = '#1e1e2e'})
    -- vim.api.nvim_set_hl(0, 'BufferLineBufferVisible', {bg = '#ffff00'})

    require('bufferline').setup{
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

        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end
      }
    }
  end,
}
