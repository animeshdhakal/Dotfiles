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
            local esp_idf_path = os.getenv("IDF_PATH")
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            if esp_idf_path then
                local clangd = vim.fn.expand('/home/animesh/.espressif/tools/esp-clang/*/esp-clang/bin/clangd')
                lspconfig.clangd.setup {
                    cmd = { clangd, '--background-index', '--query-driver=**', },
                    capabilites=capabilities
                }
            else
                lspconfig.clangd.setup {
                capabilites=capabilities
                }
            end

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
