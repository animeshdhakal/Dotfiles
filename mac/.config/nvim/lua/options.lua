-- ============================================================================
-- OPTIONS & CORE SETTINGS
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Line numbers & cursor
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.signcolumn = "yes"

-- Indentation & tabs
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.g.verilog_indent_modules = 1
vim.g.systemverilog_indent_modules = 1

-- Search & scrolling
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8

-- Splits & undo
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.undofile = true
vim.o.updatetime = 300
vim.o.wrap = false

-- Appearance & keywords
vim.opt.diffopt:append("linematch:60")
vim.opt.fillchars = { eob = " " }
vim.opt.iskeyword:append("-")

-- Folds (Treesitter)
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99

-- VimTeX setting
vim.g.vimtex_view_method = "general"

-- ============================================================================
-- CORE AUTOCOMMANDS
-- ============================================================================
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.conceallevel = 2
    end,
})
