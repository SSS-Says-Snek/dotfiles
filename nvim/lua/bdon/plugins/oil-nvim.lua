return {
  'stevearc/oil.nvim',
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {"-", "<cmd>Oil --float<cr>", desc = "Oil.nvim"}
  },
  opts = {
    default_file_explorer = true,
    columns = {
      "size",
      "icon",
    },
    view_options = {
      show_hidden = true
    },
    delete_to_trash = true,
    float = {
      padding = 5
    }
  },
  lazy = false
}
