return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    term_colors = true,
    -- transparent_background = true,
    dim_inactive = {
      enabled = false,
      shade = "dark",
      percentage = 0.15,
    },

    integrations = {
      bufferline = false,
    },
    lazy = false
  }
}


