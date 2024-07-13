return {
  'akinsho/bufferline.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    -- vim.api.nvim_set_hl(0, 'BufferLineFill', {bg = '#1e1e2e'})
    -- vim.api.nvim_set_hl(0, 'BufferLineBufferVisible', {bg = '#ffff00'}) 
    require('bufferline').setup{
      options = {
        numbers = "ordinal",
        diagnostics = "nvim_lsp",
        separator_style = "slant",
        themable = false,
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end
      }
    }
  end
}
