return {
  "nvim-telescope/telescope.nvim", branch = '0.1.x', commit = 'b4da76be54691e854d3e0e02c36b0245f945c2c7',
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {'<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find files (Telescope)'},
    {'<leader>fg', '<cmd>Telescope git_files<cr>', desc = 'Find from git files (Telescope)'},
    {'<leader>fs', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', desc = 'Find Symbols from Workspace (Telescope)'},
    {'<leader>lv', '<cmd>Telescope live_grep<cr>', desc = 'Live Grep (Telescope)'},
    {'<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Find Buffers (Telescope)'},
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
    },
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown {
          -- even more opts
        }
      }
    },

    pickers = {
        find_files = {
          prompt_prefix = " ",
      }
    }
  },
}
