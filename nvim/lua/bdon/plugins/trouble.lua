return {
  "folke/trouble.nvim",
  opts = {
    focus = true,
    follow = true,
    auto_preview = false,
    -- modes = {
    --   diagnostics = {
    --     mode = "diagnostics",
    --     preview = {
    --       type = "split",
    --       relative = "win",
    --       position = "right",
    --       size = 0.4
    --     },
    --   },
    -- },
    -- modes = {
    --   preview_float = {
    --     mode = "diagnostics",
    --     preview = {
    --       type = "float",
    --       relative = "editor",
    --       border = "rounded",
    --       title = "Preview",
    --       title_pos = "center",
    --       position = { 0, -2 },
    --       size = { width = 0.3, height = 0.3 },
    --       zindex = 200,
    --     },
    --   },
    -- },
  },
  cmd = "Trouble",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>dg", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)" },
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
    { "<leader>cs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols (Trouble)" },
    { "<leader>cS", "<cmd>Trouble lsp toggle<cr>",                      desc = "LSP references/definitions/... (Trouble)" },
    { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location List (Trouble)" },
    { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix List (Trouble)" },
  },
}
