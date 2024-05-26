vim.opt.termguicolors = true
vim.cmd.colorscheme "catppuccin"

vim.api.nvim_set_hl(0, 'LineNrAbove', {fg = "#6c7086", bold = true, bg = "#181825" })
vim.api.nvim_set_hl(0, 'LineNr', { fg = "#cdd6f4", bold = true, bg = "#181825" })
vim.api.nvim_set_hl(0, 'LineNrBelow', { fg = "#6c7086", bold = true, bg = "#181825" })
