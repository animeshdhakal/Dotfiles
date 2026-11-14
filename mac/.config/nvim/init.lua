-- ============================================================================
-- NEOVIM CONFIGURATION
-- Modular architecture:
--   lua/options.lua  -> Editor settings, vim.o / vim.g, core autocommands
--   lua/plugins.lua  -> vim.pack.add plugins, colorscheme, which-key, mini, obsidian
--   lua/lsp.lua      -> LSP servers, diagnostics UI, blink.cmp, conform.nvim
--   lua/keymaps.lua  -> Helix keymaps (Space, g, ], [, m, z), window mgmt, general
-- ============================================================================

require("options")
require("plugins")
require("lsp")
require("keymaps")
