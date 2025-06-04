return {
  "ray-x/lsp_signature.nvim",
  event = "InsertEnter",
  opts = {
    bind = true,
    hint_prefix = {
      above = "↙ ",  -- when the hint is on the line above the current line
      current = "← ",  -- when the hint is on the same line
      below = "↖ "
    },

    handler_opts = {
      border = "rounded"
    }
  },
}
