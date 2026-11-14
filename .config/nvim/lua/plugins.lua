-- ============================================================================
-- PLUGIN MANAGER (Neovim 0.11+)
-- ============================================================================
vim.pack.add {
    'https://github.com/folke/tokyonight.nvim',
    'https://github.com/nvim-mini/mini.nvim',
    'https://github.com/ibhagwan/fzf-lua',
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/folke/which-key.nvim',
    'https://github.com/folke/flash.nvim',
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/lervag/vimtex',
    'https://github.com/stevearc/conform.nvim',
    { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('*') },
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/epwalsh/obsidian.nvim',
}

-- ============================================================================
-- COLORSCHEME
-- ============================================================================
vim.cmd.colorscheme("tokyonight-storm")

-- ============================================================================
-- WHICH-KEY SETUP
-- ============================================================================
local wk = require("which-key")
wk.setup()
wk.add({
    -- Leader groups (Helix Space mode)
    { "<leader>w", group = "Windows (Helix)" },
    { "<leader>G", group = "Git" },
    { "<leader>l", group = "LaTeX / VimTeX" },
    { "<leader>o", group = "Obsidian / Notes" },
    { "<leader>q", group = "Quickfix" },
    { "<leader>t", group = "Toggle" },
    -- Helix Navigation & Jumps
    { "g", group = "Goto (Helix)" },
    { "]", group = "Next (Helix)" },
    { "[", group = "Prev (Helix)" },
    { "m", group = "Match / Surround (Helix)" },
    { "z", group = "View mode (Helix)" },
})

-- ============================================================================
-- MINI.NVIM MODULES
-- ============================================================================
require("mini.ai").setup()
require("mini.surround").setup({
    mappings = {
        add = "ms",            -- Add surrounding in Normal and Visual modes (Helix: ms)
        delete = "md",         -- Delete surrounding (Helix: md)
        find = "",             -- Find surrounding (to the right)
        find_left = "",        -- Find surrounding (to the left)
        highlight = "",        -- Highlight surrounding
        replace = "mr",        -- Replace surrounding (Helix: mr)
        update_n_lines = "",   -- Update `n_lines`
        suffix_last = "l",     -- Suffix to search with "prev" method
        suffix_next = "n",     -- Suffix to search with "next" method
    },
})
require("mini.icons").setup()
require("mini.statusline").setup()
require("mini.pairs").setup()
require("mini.indentscope").setup()
require("mini.trailspace").setup()
require("mini.bufremove").setup()
require("mini.diff").setup({
    source = require("mini.diff").gen_source.git(),
})
require("mini.comment").setup({
    mappings = {
        comment = "",
        comment_line = "",
        comment_visual = "",
        textobject = "",
    },
})

-- ============================================================================
-- FLASH
-- ============================================================================
require("flash").setup()

-- ============================================================================
-- OBSIDIAN.NVIM SETUP
-- ============================================================================
local obsidian_path = vim.fn.expand("~/vault")
if vim.fn.isdirectory(obsidian_path) == 0 then
    vim.fn.mkdir(obsidian_path, "p")
end

local ok_obs, obs = pcall(require, "obsidian")
if ok_obs then
    obs.setup({
        workspaces = {
            {
                name = "personal",
                path = obsidian_path,
            },
        },
        ui = { enable = false },
        mappings = {},
    })
end
