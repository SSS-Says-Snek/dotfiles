return {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "jay-babu/mason-nvim-dap.nvim",
    "theHamsta/nvim-dap-virtual-text",
  },

  keys = {
    { "<leader>da", "<cmd>DapContinue<cr>", desc = "Continue (DAP)" },
    { "<F5>", "<cmd>DapContinue<cr>", desc = "Continue (DAP)" },
    { "<leader>dd", "<cmd>DapStepOver<cr>", desc = "Step Over (DAP)" },
    { "<leader>df", "<cmd>DapStepInto<cr>", desc = "Step Into (DAP)" },
    { "<leader>dh", "<cmd>DapStepOut<cr>", desc = "Step Out (DAP)" },
    { "<leader>ds", "<cmd>DapPause<cr>", desc = "Pause (DAP)" },
    { "<leader>dt", function() require('dapui').toggle() end, desc = "Toggle UI (DAP)" },
    { "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle Breakpoint (DAP)" },
    { "<leader>dw", function() require('dap.ui.widgets').hover() end, desc = "Expand Widgets (DAP)"}
  },


  config = function() 
    local mason_dap = require("mason-nvim-dap")
    local dap = require("dap")
    local ui = require("dapui")
    local dap_virtual_text = require("nvim-dap-virtual-text")

    dap_virtual_text.setup()

    mason_dap.setup({
      ensure_installed = { "codelldb" },
      automatic_installation = true,
      handlers = {
        function(config)
          require("mason-nvim-dap").default_setup(config)
        end,
      },
    })

    dap.adapters.codelldb = {
      type = "executable",
      command = "codelldb"
    }

    -- Configurations
    dap.configurations = {
      cpp = {
        {
          name = "Launch File",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
        },
      },
    }

    -- Dap UI

    ui.setup({
      layouts = { {
        elements = { {
            id = "scopes",
            size = 0.25
          }, {
            id = "breakpoints",
            size = 0.25
          }, {
            id = "stacks",
            size = 0.25
          }, {
            id = "watches",
            size = 0.25
          } },
        position = "left",
        size = 60
      }, {
        elements = { {
            id = "repl",
            size = 0.5
          }, {
            id = "console",
            size = 0.5
          } },
        position = "bottom",
        size = 30
      } }
    })

    vim.api.nvim_set_hl(0, 'DapBreakpoint', { ctermbg = 0, fg = '#f38ba8', bg = '#1e1e2e' })
    vim.api.nvim_set_hl(0, 'DapLogPoint', { ctermbg = 0, fg = '#89b4fa', bg = '#1e1e2e' })
    vim.api.nvim_set_hl(0, 'DapStopped', { ctermbg = 0, fg = '#a6e3a1', bg = '#1e1e2e' })

    vim.fn.sign_define('DapBreakpoint', { text='', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl='DapBreakpoint' })
    vim.fn.sign_define('DapBreakpointCondition', { text='ﳁ', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl='DapBreakpoint' })
    vim.fn.sign_define('DapBreakpointRejected', { text='', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl= 'DapBreakpoint' })
    vim.fn.sign_define('DapLogPoint', { text='', texthl='DapLogPoint', linehl='DapLogPoint', numhl= 'DapLogPoint' })
    vim.fn.sign_define('DapStopped', { text='', texthl='DapStopped', linehl='DapStopped', numhl= 'DapStopped' })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "dap-float",
      callback = function()
        vim.keymap.set("n", "q", "<cmd>close!<CR>", { buffer = true, silent = true })
      end,
    })

    dap.listeners.before.attach.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      ui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      ui.close()
    end
  end
}
