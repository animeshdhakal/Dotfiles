vim.g.mapleader = " "
vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>")
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>ft", vim.lsp.buf.format, {})
