return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "clangd", "pyright", "vtsls", "emmet_ls", "tailwindcss" }
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            lspconfig.clangd.setup {
                capabilites=capabilities
            }
            lspconfig.pyright.setup {
                capabilites=capabilities
            }
            lspconfig.lua_ls.setup {
                capabilites=capabilities
            }
            lspconfig.vtsls.setup {
                capabilites=capabilities
            }
            lspconfig.emmet_ls.setup {
                capabilites=capabilities
            }
            lspconfig.tailwindcss.setup {
                capabilites=capabilities
            }
        end
    }
}
