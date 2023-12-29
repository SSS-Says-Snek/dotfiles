vim.g.mapleader = " "

local keymap = vim.keymap

-- Searching
keymap.set("n", "<leader>s", "<cmd>noh<cr>")

-- General
keymap.set("i", "jk", "<ESC>")
keymap.set("n", "<C-d>", "<C-d>M")
keymap.set("n", "<C-u>", "<C-u>M")
keymap.set("n", "\\\\", "<cmd>qa!<cr>")
keymap.set("n", "<C-q>", "<cmd>q!<cr>")
keymap.set("n", "<leader>o", "o<ESC>k")
keymap.set("n", "<leader>O", "O<ESC>j")
