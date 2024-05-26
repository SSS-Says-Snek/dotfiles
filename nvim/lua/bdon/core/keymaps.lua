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
keymap.set("n", "<leader>o", "o<ESC>k")
keymap.set("n", "<leader>O", "O<ESC>j")

keymap.set("n", "]b", "<cmd>bnext<cr>")
keymap.set("n", "[b", "<cmd>bprev<cr>")
keymap.set("n", "[d", "<cmd>bd<cr>")

keymap.set("v", ">", ">gv")
keymap.set("v", "<", "<gv")
