return {
  'stevearc/overseer.nvim',
  opts = {
    task_list = {
      max_height = { 60, 0.8 },
    }
  },
  keys = {
    { "<F10>", "<cmd>OverseerRun<cr>", desc = "Execute Task (Overseer)" },
    { "<leader>te", "<cmd>OverseerRun<cr>", desc = "Execute Task (Overseer)" },
    { "<leader>tt", "<cmd>OverseerToggle<cr>", desc = "Toggle (Overseer)" }
  }
}
