local opt = vim.opt -- Reassign for cool

-- Line number stuff
opt.relativenumber = true
opt.number = true

-- Tabs
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
-- opt.softtabstop = 2

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

opt.diffopt = {
  "internal",
  "filler",
  "closeoff",
  "context:12",
  "algorithm:histogram",
  "linematch:200",
  "indent-heuristic",
  "iwhite"
}

-- So that svelte can comment out html stuff
local get_option = vim.filetype.get_option
vim.filetype.get_option = function(filetype, option)
  return option == "commentstring"
    and require("ts_context_commentstring.internal").calculate_commentstring()
    or get_option(filetype, option)
end
