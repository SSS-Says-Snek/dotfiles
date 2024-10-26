return {
  'akinsho/bufferline.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  after = "catppuccin",
  config = function()
    -- vim.api.nvim_set_hl(0, 'BufferLineFill', {bg = '#1e1e2e'})
    -- vim.api.nvim_set_hl(0, 'BufferLineBufferVisible', {bg = '#ffff00'})

    require('bufferline').setup{
      -- highlights = {
      --   fill = {
      --     bg = '#181825',
      --   },
      --   tab = {
      --     bg = '#ff0000',
      --     fg = '#00ff00'
      --   }
      -- },
      highlights = {
        duplicate_visible = {
          bg = "#181826",
          bold = true,
          fg = "#45475b",
          italic = true
        },
        error = {
          bg = "#181826",
          bold = false,
          fg = "#f38ba9",
          italic = false
        },
        error_diagnostic = {
          bg = "#181826",
          bold = false,
          fg = "#f38ba9",
          italic = false
        },
        error_diagnostic_selected = {
          bg = "#1e1e2f",
          bold = false,
          fg = "#f38ba9",
          italic = false
        },
        error_diagnostic_visible = {
          bg = "#181826",
          bold = false,
          fg = "#f38ba9",
          italic = false
        },
        error_selected = {
          bg = "#1e1e2f",
          bold = true,
          fg = "#f38ba9",
          italic = true
        },
        error_visible = {
          bg = "#181826",
          bold = false,
          fg = "#f38ba9",
          italic = false
        },
        fill = {
          bg = "#181826",
          bold = false,
          italic = false
        },
        hint = {
          bg = "#181826",
          bold = false,
          fg = "#94e2d6",
          italic = false
        },
        hint_diagnostic = {
          bg = "#181826",
          bold = false,
          fg = "#94e2d6",
          italic = false
        },
        hint_diagnostic_selected = {
          bg = "#1e1e2f",
          bold = false,
          fg = "#94e2d6",
          italic = false
        },
        hint_diagnostic_visible = {
          bg = "#181826",
          bold = false,
          fg = "#94e2d6",
          italic = false
        },
        hint_selected = {
          bg = "#1e1e2f",
          bold = true,
          fg = "#94e2d6",
          italic = true
        },
        hint_visible = {
          bg = "#181826",
          bold = false,
          fg = "#94e2d6",
          italic = false
        },
        indicator_selected = {
          bg = "#1e1e2f",
          bold = true,
          fg = "#fab388",
          italic = true
        },
        indicator_visible = {
          bg = "#181826",
          bold = true,
          fg = "#fab388",
          italic = true
        },
        info = {
          bg = "#181826",
          bold = false,
          fg = "#89dcec",
          italic = false
        },
        info_diagnostic = {
          bg = "#181826",
          bold = false,
          fg = "#89dcec",
          italic = false
        },
        info_diagnostic_selected = {
          bg = "#1e1e2f",
          bold = false,
          fg = "#89dcec",
          italic = false
        },
        info_diagnostic_visible = {
          bg = "#181826",
          bold = false,
          fg = "#89dcec",
          italic = false
        },
        info_selected = {
          bg = "#1e1e2f",
          bold = true,
          fg = "#89dcec",
          italic = true
        },
        info_visible = {
          bg = "#181826",
          bold = false,
          fg = "#89dcec",
          italic = false
        },
        modified = {
          bg = "#181826",
          bold = false,
          fg = "#fab388",
          italic = false
        },
        modified_selected = {
          bg = "#1e1e2f",
          bold = false,
          fg = "#fab388",
          italic = false
        },
        modified_visible = {
          bg = "#181826",
          bold = false,
          fg = "#fab388",
          italic = false
        },
        numbers = {
          bg = "#181826",
          bold = false,
          fg = "#a6adc9",
          italic = false
        },
        numbers_selected = {
          bg = "#1e1e2f",
          bold = true,
          fg = "#a6adc9",
          italic = true
        },
        numbers_visible = {
          bg = "#181826",
          bold = false,
          fg = "#a6adc9",
          italic = false
        },
        offset_separator = {
          bg = "#1e1e2f",
          bold = false,
          -- fg = "#11111c",
          fg = "#181826",
          italic = false
        },
        separator = {
          bg = "#181826",
          bold = false,
          -- fg = "#11111c",
          fg = "#181826",
          italic = false
        },
        separator_selected = {
          bg = "#1e1e2f",
          bold = false,
          -- fg = "#11111c",
          fg = "#181826",
          italic = false
        },
        separator_visible = {
          bg = "#181826",
          bold = false,
          -- fg = "#11111c",
          fg = "#181826",
          italic = false
        },
        tab = {
          -- bg = "#181826",
          -- bg = "#585b70",
          bg = "#ff0000",
          bold = false,
          fg = "#45475b",
          italic = false
        },
        tab_close = {
          -- bg = "#181826",
          -- bg = "#585b70",
          bg = "#ff0000",
          bold = false,
          fg = "#f38ba9",
          italic = false
        },
        tab_selected = {
          -- bg = "#585b70",
          bg = "#ff0000",
          bold = false,
          fg = "#89dcec",
          italic = false
        },
        tab_separator = {
          bg = "#181826",
          bold = false,
          -- fg = "#11111c",
          fg = "#45475a",
          italic = false
        },
        tab_separator_selected = {
          bg = "#1e1e2f",
          bold = false,
          -- fg = "#11111c",
          fg = "#45475a",
          italic = false
        },
        warning = {
          bg = "#181826",
          bold = false,
          fg = "#f9e2b0",
          italic = false
        },
        warning_diagnostic = {
          bg = "#181826",
          bold = false,
          fg = "#f9e2b0",
          italic = false
        },
        warning_diagnostic_selected = {
          bg = "#1e1e2f",
          bold = false,
          fg = "#f9e2b0",
          italic = false
        },
        warning_diagnostic_visible = {
          bg = "#181826",
          bold = false,
          fg = "#f9e2b0",
          italic = false
        },
        warning_selected = {
          bg = "#1e1e2f",
          bold = true,
          fg = "#f9e2b0",
          italic = true
        },
        warning_visible = {
          bg = "#181826",
          bold = false,
          fg = "#f9e2b0",
          italic = false
        }
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
  end
}
