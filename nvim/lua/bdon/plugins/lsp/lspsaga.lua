return {
  'nvimdev/lspsaga.nvim',
  config = function()
    require('lspsaga').setup({
      ui = {
        code_action = ''
      },
      lightbulb = { enable = false, sign = false }
    })
  end,
  lazy = false,

  keys = {
    {"K", "<cmd>Lspsaga hover_doc<cr>"},
    -- {"<leader>ca", "<cmd>Lspsaga code_action<cr>"},
    {"<leader>rn", "<cmd>Lspsaga rename<cr>"}
  }
}
