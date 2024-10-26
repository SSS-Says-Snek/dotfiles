local opt = vim.opt -- Reassign for cool

-- Line number stuff
opt.relativenumber = true
opt.number = true

-- Tabs
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- Line wrap
opt.wrap = false

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Backspace?
opt.backspace = "indent,eol,start"

-- Clipboard (YESSS)
opt.clipboard:append("unnamedplus")

-- Misc
opt.iskeyword:append("-")
opt.showmode = false
opt.termguicolors = true
opt.scrolloff = 8
-- opt.autochdir = true

-- vim.cmd [[
-- :augroup cdpwd
-- :    autocmd!
-- :    autocmd BufEnter * cd $PWD
-- :augroup END
-- ]]
--
-- if vim.fn.isdirectory(vim.v.argv[2]) == 1 then
--   print("wow")
--   vim.api.nvim_set_current_dir(vim.v.argv[2])
-- end
--
-- vim.api.nvim_create_autocmd({"VimEnter"}, {
--   pattern = '*',
--   callback = function()
--     vim.api.nvim_set_current_dir()
--   end
-- })

