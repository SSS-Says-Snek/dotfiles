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
    {"<leader>rn", "<cmd>Lspsaga rename<cr>"}
  }
}
