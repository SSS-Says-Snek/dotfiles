return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {'<leader>ff', '<cmd>Telescope find_files<cr>'},
    {'<leader>fs', '<cmd>Telescope grep_string<cr>'}
  },
  lazy = false
}
