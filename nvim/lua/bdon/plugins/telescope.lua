return {
  "nvim-telescope/telescope.nvim",
  branch = '0.1.x',
  commit = 'b4da76be54691e854d3e0e02c36b0245f945c2c7',
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find files (Telescope)' },
    { '<leader>fg', '<cmd>Telescope git_files<cr>',  desc = 'Find from git files (Telescope)' },
    -- { '<leader>fs', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', desc = 'Find Symbols from Workspace (Telescope)' },
    { '<leader>lv', '<cmd>Telescope live_grep<cr>',  desc = 'Live Grep (Telescope)' },
    { '<leader>fb', '<cmd>Telescope buffers<cr>',    desc = 'Find Buffers (Telescope)' },
  },
  config = function()
    local telescope = require('telescope.builtin')
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    require('telescope').setup {
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
    }

    local function workspace_symbols_project_only()
      telescope.lsp_workspace_symbols({
        attach_mappings = function(prompt_bufnr, map)
          -- Use default mappings
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col })
            end
          end)
          return true
        end,
        -- Filter function to exclude system headers
        entry_maker = function(entry)
          local make_entry = require('telescope.make_entry')
          local default_entry = make_entry.gen_from_lsp_symbols({})(entry)

          if default_entry then
            local filename = default_entry.filename or ''

            -- Exclude system include directories
            if filename:match('/usr/include/') or
                filename:match('/usr/local/include/') or
                filename:match('\\mingw64\\include\\') or
                filename:match('\\msys64\\include\\') or
                filename:match('/Library/Developer/') or -- macOS system headers
                filename:match('/Applications/Xcode.app/') then
              return nil
            end

            return default_entry
          end
          return nil
        end,
      })
    end

    vim.keymap.set('n', '<leader>fs', workspace_symbols_project_only,
      { desc = 'Find Symbols from Workspace (Telescope)' })
  end
}
