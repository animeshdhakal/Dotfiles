vim.g.mapleader = " "
vim.g.netrw_banner = 0
vim.g.netrw_altv = 1
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 0 


vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set({"n", "v"}, "<leader>p", "\"+p")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- LSP Keymaps
vim.keymap.set("n", "<leader>ft", vim.lsp.buf.format, {})
vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})

-- Barebone Setup
vim.keymap.set("n", "<leader>e", ":Ex<CR>")
vim.keymap.set("n", "<leader>b", ":25Lex<CR>")

-- Easy Split
vim.keymap.set("n", "<leader>v", ":vsplit<CR>")
vim.keymap.set("n", "<leader>s", ":split<CR>")

-- Buffer Navigation
vim.keymap.set("n", "<Tab>", ":bn<CR>")
vim.keymap.set("n", "<S-Tab>", ":bp<CR>")
vim.keymap.set("n", "<leader>d", ":bd!<CR>")

-- Split Navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")

-- Solit Size
vim.keymap.set("n", "<C-Left>", ":vertical resize +3<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize -3<CR>")
vim.keymap.set("n", "<C-Up>", ":horizontal resize +3<CR>")
vim.keymap.set("n", "<C-Down>", ":horizontal resize -3<CR>")

-- Automatically close brackets
vim.keymap.set("i", "'", "''<left>")
vim.keymap.set("i", "\"", "\"\"<left>")
vim.keymap.set("i", "(", "()<left>")
vim.keymap.set("i", "[", "[]<left>")
vim.keymap.set("i", "{", "{}<left>")
vim.keymap.set("i", "{;", "{};<left><left>")
vim.keymap.set("i", "/*", "/**/<left><left>")

-- Comments
vim.keymap.set({"n", "v"}, "<leader>s", "gc", {remap = true})
vim.keymap.set({"n"}, "<leader>ss", "gcc", {remap = true})  

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
