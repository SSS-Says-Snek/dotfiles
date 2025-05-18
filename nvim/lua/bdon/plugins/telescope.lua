return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {'<leader>ff', '<cmd>Telescope find_files<cr>'},
    {'<leader>fg', '<cmd>Telescope git_files<cr>'},
    {'<leader>fs', '<cmd>Telescope grep_string<cr>'},
    {'<leader>lg', '<cmd>Telescope live_grep<cr>'},
    {'<leader>fb', '<cmd>Telescope buffers<cr>'},
  },
  config = {
    defaults = {
      file_ignore_patterns = {
        "node_modules"
      },

      mappings = {
        i = {
          ["<esc>"] = require("telescope.actions").close
        },
      },
    }
  },
}
