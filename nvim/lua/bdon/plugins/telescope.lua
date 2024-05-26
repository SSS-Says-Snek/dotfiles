return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.7",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {'<leader>ff', '<cmd>Telescope find_files<cr>'},
    {'<leader>fg', '<cmd>Telescope git_files<cr>'},
    {'<leader>fs', '<cmd>Telescope grep_string<cr>'},
    {'<leader>lg', '<cmd>Telescope live_grep<cr>'},
    {'<leader>b', '<cmd>Telescope buffers<cr>'},
  },
  config = {
    defaults = {
      file_ignore_patterns = {
        "node_modules"
      }
    }
  },
  lazy = false
}
