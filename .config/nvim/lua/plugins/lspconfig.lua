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
                ensure_installed = { "pyright",  "ts_ls", "clangd", "lua_ls"  }
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")
            local capabilities = require('cmp_nvim_lsp').default_capabilities()


            lspconfig.pyright.setup {
                capabilities = capabilities
            }
            lspconfig.clangd.setup {
                capabilities = capabilities
            }
            lspconfig.lua_ls.setup {
                capabilities = capabilities
            }
            lspconfig.ts_ls.setup {
                capabilities = capabilities
            }
            
        end
    }
}
