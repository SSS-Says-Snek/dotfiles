return {
  "folke/trouble.nvim",
  opts = {
    focus = true,
    modes = {
    preview_float = {
      mode = "diagnostics",
      preview = {
        type = "float",
        relative = "editor",
        border = "rounded",
        title = "Preview",
        title_pos = "center",
        position = { 0, -2 },
        size = { width = 0.3, height = 0.3 },
        zindex = 200,
      },
    },
  },
  },
  cmd = "Trouble",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {"<leader>dg", "<cmd>Trouble diagnostics toggle<cr>"}
  },
}
