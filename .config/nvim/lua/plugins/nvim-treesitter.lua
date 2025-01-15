return {
    "nvim-treesitter/nvim-treesitter",
    config = function()
        local configs = require("nvim-treesitter.configs")
        configs.setup({
            ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "javascript", "html", "tsx" },
            sync_install = false,
            highlight = { enable = true },
        })
    end
}
