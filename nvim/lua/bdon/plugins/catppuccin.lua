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
      bufferline = true,
      blink_cmp = true,
      lsp_saga = true,
      gitsigns = {
        enabled = true,
        -- align with the transparent_background option by default
        transparent = false,
      },
      notify = true
    },
    lazy = false
  }
}
