vim.g.mapleader = " "

local keymap = vim.keymap

-- Searching
keymap.set("n", "<leader>s", "<cmd>noh<cr>")

-- General
keymap.set("i", "jk", "<ESC>")
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "\\\\", "<cmd>qa!<cr>")
keymap.set("n", "<C-q>", "<cmd>q!<cr>")
keymap.set("n", "<leader>o", "o<ESC>k", { desc = "Add blank line below" })
keymap.set("n", "<leader>O", "O<ESC>j", { desc = "Add blank line above" })
keymap.set("n", "<leader>lz", "<cmd>Lazy<cr>", { desc = "Open Lazy" })

keymap.set("n", "<BS>", "<C-6>")
keymap.set("n", "<Tab>", "<cmd>bn<cr>")
keymap.set("n", "<S-Tab>", "<cmd>bp<cr>")

keymap.set("v", ">", ">gv")
keymap.set("v", "<", "<gv")

keymap.del("n", "grr")
keymap.del("n", "gri")
keymap.del("n", "gra")
keymap.del("n", "grn")
keymap.del("n", "grt")

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")

vim.keymap.set("n", "<C-Right>", [[<cmd>vertical resize +5<cr>]]) -- make the window biger vertically
vim.keymap.set("n", "<C-Left>", [[<cmd>vertical resize -5<cr>]]) -- make the window smaller vertically
vim.keymap.set("n", "<C-Up>", [[<cmd>horizontal resize +2<cr>]]) -- make the window bigger horizontally by pressing shift and =
vim.keymap.set("n", "<C-Down>", [[<cmd>horizontal resize -2<cr>]]) -- make the window smaller horizontally by pressing shift and -
