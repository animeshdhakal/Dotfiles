-- ============================================================================
-- TREESITTER INDENTATION
-- ============================================================================
-- Neovim 0.12 starts Treesitter highlighting automatically for installed parsers.
-- Enable Treesitter indentation where available.
vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        pcall(function()
            if vim.treesitter.get_parser(0) then
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
        end)
    end,
})

-- ============================================================================
-- COMPLETION (blink.cmp)
-- ============================================================================
require("blink.cmp").setup({
    keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },
    appearance = {
        nerd_font_variant = "mono",
    },
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },
    snippets = {
        preset = "default", -- Uses Neovim 0.10+ native vim.snippet
    },
})

-- ============================================================================
-- FORMATTING (conform.nvim)
-- ============================================================================
require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
        rust = { "rustfmt" },
    },
    format_on_save = {
        timeout_ms = 2000,
        lsp_fallback = true,
    },
})

-- ============================================================================
-- LSP CONFIGURATION & SERVERS
-- ============================================================================
vim.lsp.config("lazyverilog", {
    cmd = { "lazyverilog-lsp" },
    filetypes = { "verilog", "systemverilog" },
    root_markers = { "lazyverilog.toml", ".git" },
})

vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.lsp.enable({
    "pyright",
    "clangd",
    "rust_analyzer",
    "texlab",
    "lazyverilog",
    "asm_lsp",
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
        end
    end,
})

-- ============================================================================
-- DIAGNOSTICS & UI
-- ============================================================================
local diagnostic_signs = {
    Error = "\u{f057} ",
    Warn  = "\u{f071} ",
    Hint  = "\u{ea61} ",
    Info  = "\u{f05a} ",
}

vim.diagnostic.config({
    virtual_text = { prefix = "●", spacing = 4 },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
            [vim.diagnostic.severity.WARN]  = diagnostic_signs.Warn,
            [vim.diagnostic.severity.INFO]  = diagnostic_signs.Info,
            [vim.diagnostic.severity.HINT]  = diagnostic_signs.Hint,
        },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = true,
    },
})

do
    local orig = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or "rounded"
        return orig(contents, syntax, opts, ...)
    end
end
