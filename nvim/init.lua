-- Core configs
require("bdon.core.options")
require("bdon.core.keymaps")
require("bdon.core.misc")

-- Lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(
  {
    { import = "bdon.plugins" },
    { import = "bdon.plugins.lsp" },

    ui = {
      border = "rounded",
      size = {
        width = 0.8,
        height = 0.8,
      },
    },
  }
)

-- At the end, register catppuccin
require("bdon.core.colorscheme")
require("bdon.core.hover").setup();
