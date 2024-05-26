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
