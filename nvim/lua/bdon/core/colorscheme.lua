vim.cmd.colorscheme "catppuccin"

vim.api.nvim_set_hl(0, 'LineNrAbove', { fg = "#6c7086", bold = true, bg = "#181825" })
vim.api.nvim_set_hl(0, 'LineNr', { fg = "#cdd6f4", bold = true, bg = "#181825" })
vim.api.nvim_set_hl(0, 'LineNrBelow', { fg = "#6c7086", bold = true, bg = "#181825" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "#181825" })

vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#6c7086", bg = "#1e1e2e" })

local colors = require("catppuccin.palettes").get_palette()
local TelescopeColor = {
  TelescopeMatching = { fg = colors.flamingo },
  TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true},

  -- TelescopePromptPrefix = { bg = colors.surface0 },
  -- TelescopePromptNormal = { bg = colors.surface0 },
  -- TelescopeResultsNormal = { bg = colors.mantle },
  -- TelescopePreviewNormal = { bg = colors.mantle },
  -- TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
  -- TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
  -- TelescopePreviewBorder = { bg = colors.mantle, fg = colors.mantle },
  -- TelescopePromptTitle = { bg = colors.lavender, fg = colors.mantle },
  -- TelescopeResultsTitle = { fg = colors.mantle },
  -- TelescopePreviewTitle = { bg = colors.green, fg = colors.mantle },

  -- TelescopePromptPrefix = { bg = colors.surface0 },
  -- TelescopePromptNormal = { bg = colors.surface0 },
  -- TelescopeResultsNormal = { bg = colors.surface0 },
  -- TelescopePreviewNormal = { bg = colors.surface0 },
  -- TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
  -- TelescopeResultsBorder = { bg = colors.base, fg = colors.base },
  -- TelescopePreviewBorder = { bg = colors.base, fg = colors.base },
  -- TelescopePromptTitle = { bg = colors.lavender, fg = colors.surface0 },
  -- TelescopeResultsTitle = { fg = colors.surface0 },
  -- TelescopePreviewTitle = { bg = colors.green, fg = colors.surface0 },
}

for hl, col in pairs(TelescopeColor) do
  vim.api.nvim_set_hl(0, hl, col)
end

-- vim.api.nvim_set_hl(0, 'NormalFloat', { fg = "#ff0000" })
