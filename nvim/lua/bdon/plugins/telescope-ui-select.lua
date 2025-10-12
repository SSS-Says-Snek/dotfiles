return {
  'nvim-telescope/telescope-ui-select.nvim',
  opts = {},
  config = function()
    require("telescope").load_extension("ui-select")
  end
}
