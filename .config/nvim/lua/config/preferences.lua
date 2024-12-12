vim.g.mapleader = " "
vim.g.netrw_banner = 0
vim.g.netrw_altv = 1
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 0

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.cmd.colorscheme("tokyonight-storm")
