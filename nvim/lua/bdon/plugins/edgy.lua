return {
  "folke/edgy.nvim",
  event = "VeryLazy",
  init = function()
    vim.opt.laststatus = 3
    vim.opt.splitkeep = "screen"
  end,

  opts = {
    bottom = {
      { ft = "dapui_console", size = { height = 0.2 }, title = " Debug Console" },
      { ft = "dap-repl", size = { height = 0.2 }, title = " Debug REPL" },
      {
        ft = "trouble",
        title = " Diagnostics",
        size = { height = 0.3 },
      },
    },

    left = {
      { ft = "neo-tree", title = " Filetree" },
      { ft = "dapui_scopes", title = " Scopes" },
      { ft = "dapui_watches", title = " Watches" },
      { ft = "dapui_stacks", title = " Stacks" },
      { ft = "dapui_breakpoints", title = " Breakpoints" },
    },

    animate = {
      enabled = false
    },

    options = {
      left = { size = 40 },
      bottom = { size = 10 },
      right = { size = 30 },
      top = { size = 10 },
    },

    keys = {
      -- increase width
      ["<C-Right>"] = function(win)
        win:resize("width", 2)
      end,
      -- decrease width
      ["<C-Left>"] = function(win)
        win:resize("width", -2)
      end,
      -- increase height
      ["<C-Up>"] = function(win)
        win:resize("height", 2)
      end,
      -- decrease height
      ["<C-Down>"] = function(win)
        win:resize("height", -2)
      end,
      -- reset all custom sizing
      ["<c-w>="] = function(win)
        win.view.edgebar:equalize()
      end,
    }
  }
}
