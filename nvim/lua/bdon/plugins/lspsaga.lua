return {
  'nvimdev/lspsaga.nvim',
  config = function()
    require('lspsaga').setup({})
  end,

  keys = {
    {"K", "<cmd>Lspsaga hover_doc<cr>"}
  }
}
