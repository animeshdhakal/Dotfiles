local fzf = require("fzf-lua")

-- ============================================================================
-- 1. HELPERS & UTILITIES
-- ============================================================================

local function workspace_root()
    return vim.fs.root(0, { ".git", ".hg", "lazyverilog.toml", "pyproject.toml", "Cargo.toml", "package.json" })
        or vim.fn.getcwd()
end

-- Yazi File Manager (Native Floating Window)
local function open_yazi(target_path)
    local target
    if type(target_path) == "string" and target_path ~= "" then
        target = target_path
    elseif target_path == true then
        target = vim.fn.getcwd()
    else
        target = vim.api.nvim_buf_get_name(0)
        if target == "" or vim.bo.buftype ~= "" then
            target = vim.fn.getcwd()
        end
    end

    local tmp = vim.fn.tempname()
    local width = math.floor(vim.o.columns * 0.85)
    local height = math.floor(vim.o.lines * 0.85)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
    })

    vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = buf, nowait = true })

    local cmd = string.format("yazi %s --chooser-file=%s", vim.fn.fnameescape(target), vim.fn.fnameescape(tmp))

    vim.fn.termopen(cmd, {
        on_exit = function()
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
            if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_delete(buf, { force = true })
            end

            if vim.fn.filereadable(tmp) == 1 then
                local lines = vim.fn.readfile(tmp)
                for _, file in ipairs(lines) do
                    if file ~= "" then
                        vim.cmd.edit(vim.fn.fnameescape(file))
                    end
                end
                vim.fn.delete(tmp)
            end
        end,
    })

    vim.cmd("startinsert")
end

-- Terminal Toggle
local term_buf, term_win
local function toggle_terminal()
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_hide(term_win)
        term_win = nil
    else
        vim.cmd("botright 15split")
        if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
            vim.api.nvim_win_set_buf(0, term_buf)
        else
            vim.cmd("terminal")
            term_buf = vim.api.nvim_get_current_buf()
        end
        term_win = vim.api.nvim_get_current_win()
        vim.cmd("startinsert")
    end
end

vim.keymap.set({ "n", "t" }, "<leader>tt", toggle_terminal, { desc = "Toggle terminal" })

-- ============================================================================
-- 2. HELIX SPACE MODE (<leader>)
-- ============================================================================

-- Files & File Explorers (Helix: Space f, F, e, .)
vim.keymap.set("n", "<leader>f", function() fzf.files({ cwd = workspace_root() }) end, { desc = "File picker (workspace root)" })
vim.keymap.set("n", "<leader>F", function() fzf.files({ cwd = vim.fn.getcwd() }) end, { desc = "File picker (cwd)" })
vim.keymap.set("n", "<leader>e", function() open_yazi(workspace_root()) end, { desc = "File explorer (workspace root)" })
vim.keymap.set("n", "<leader>.", function() open_yazi(vim.fn.expand("%:p:h")) end, { desc = "File explorer (buffer dir)" })
vim.keymap.set("n", "<leader>E", function() open_yazi(vim.fn.getcwd()) end, { desc = "File explorer (cwd)" })

-- Buffers & Jumplist (Helix: Space b, Space j)
vim.keymap.set("n", "<leader>b", fzf.buffers, { desc = "Buffer picker" })
vim.keymap.set("n", "<leader>B", function() require("mini.bufremove").delete(0, false) end, { desc = "Close buffer" })
vim.keymap.set("n", "<leader>j", fzf.jumps, { desc = "Jumplist picker" })

-- Pickers & Search (Helix: Space g, Space /, Space ?, Space ')
vim.keymap.set("n", "<leader>g", fzf.git_status, { desc = "Changed file picker" })
vim.keymap.set("n", "<leader>/", function() fzf.live_grep({ cwd = workspace_root() }) end, { desc = "Global search (workspace root)" })
vim.keymap.set("n", "<leader>?", fzf.commands, { desc = "Command palette" })
vim.keymap.set("n", "<leader>'", fzf.resume, { desc = "Last picker" })

-- LSP & Diagnostics (Helix: Space k, s, S, d, D, r, a, h)
vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, { desc = "Show documentation (hover)" })
vim.keymap.set("n", "<leader>s", fzf.lsp_document_symbols, { desc = "Document symbols picker" })
vim.keymap.set("n", "<leader>S", fzf.lsp_live_workspace_symbols, { desc = "Workspace symbols picker" })
vim.keymap.set("n", "<leader>d", fzf.diagnostics_document, { desc = "Document diagnostics picker" })
vim.keymap.set("n", "<leader>D", fzf.diagnostics_workspace, { desc = "Workspace diagnostics picker" })
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set({ "n", "v" }, "<leader>a", fzf.lsp_code_actions, { desc = "Code action" })
vim.keymap.set("n", "<leader>h", fzf.lsp_references, { desc = "Select symbol references" })

-- Comments (Helix: Space c, Space C)
vim.keymap.set("n", "<leader>c", function() require("mini.comment").toggle_lines(vim.fn.line("."), vim.fn.line(".")) end, { desc = "Toggle line comment" })
vim.keymap.set("x", "<leader>c", function()
    local s = vim.fn.line("v")
    local e = vim.fn.line(".")
    if s > e then s, e = e, s end
    require("mini.comment").toggle_lines(s, e)
    vim.cmd("normal! \27")
end, { desc = "Toggle comment" })
vim.keymap.set("n", "<leader>C", function() require("mini.comment").toggle_lines(vim.fn.line("."), vim.fn.line(".")) end, { desc = "Toggle block comment" })
vim.keymap.set("x", "<leader>C", function()
    local s = vim.fn.line("v")
    local e = vim.fn.line(".")
    if s > e then s, e = e, s end
    require("mini.comment").toggle_lines(s, e)
    vim.cmd("normal! \27")
end, { desc = "Toggle block comment" })

-- System clipboard (Helix: Space y, Y, p, P, R)
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste after from clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>P", [["+P]], { desc = "Paste before from clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>R", [["_d"+P]], { desc = "Replace with clipboard" })

-- Git Submenu (fzf-lua pickers under <leader>G)
vim.keymap.set("n", "<leader>Gf", fzf.git_files, { desc = "Git files" })
vim.keymap.set("n", "<leader>Gs", fzf.git_status, { desc = "Git status" })
vim.keymap.set("n", "<leader>Gc", fzf.git_commits, { desc = "Git commits" })
vim.keymap.set("n", "<leader>Gb", fzf.git_branches, { desc = "Git branches" })

-- Flash jumps (s, S)
vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash jump" })
vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash treesitter" })

-- ============================================================================
-- 3. HELIX GOTO MODE (g)
-- ============================================================================

-- Line and screen navigation (Helix: gh, gl, gs, ge, gt, gc, gb, gj, gk, g|)
vim.keymap.set({ "n", "x", "o" }, "gh", "0", { desc = "Goto line start" })
vim.keymap.set({ "n", "x", "o" }, "gl", "$", { desc = "Goto line end" })
vim.keymap.set({ "n", "x", "o" }, "gs", "^", { desc = "Goto first non-whitespace" })
vim.keymap.set({ "n", "x", "o" }, "ge", "G", { desc = "Goto last line of file" })
vim.keymap.set({ "n", "x", "o" }, "gt", "H", { desc = "Goto window top" })
vim.keymap.set({ "n", "x", "o" }, "gc", "M", { desc = "Goto window center" })
vim.keymap.set({ "n", "x", "o" }, "gb", "L", { desc = "Goto window bottom" })
vim.keymap.set({ "n", "x" }, "gj", "j", { desc = "Move down textual line" })
vim.keymap.set({ "n", "x" }, "gk", "k", { desc = "Move up textual line" })
vim.keymap.set({ "n", "x" }, "g|", function()
    local count = vim.v.count
    if count > 0 then
        vim.cmd("normal! " .. count .. "|")
    else
        vim.cmd("normal! 0")
    end
end, { desc = "Goto column <n> or line start" })

-- Word jump (Helix: gw -> Jump mode)
vim.keymap.set({ "n", "x", "o" }, "gw", function() require("flash").jump() end, { desc = "Goto word (Flash jump)" })

-- LSP Navigation (Helix: gd, gD, gy, gi, gr)
vim.keymap.set("n", "gd", fzf.lsp_definitions, { desc = "Goto definition" })
vim.keymap.set("n", "gD", fzf.lsp_declarations, { desc = "Goto declaration" })
vim.keymap.set("n", "gy", fzf.lsp_typedefs, { desc = "Goto type definition" })
vim.keymap.set("n", "gi", fzf.lsp_implementations, { desc = "Goto implementation" })
vim.keymap.set("n", "gr", fzf.lsp_references, { desc = "Goto references" })

-- Buffers & History (Helix: ga, gm, gn, gp, g.)
vim.keymap.set("n", "ga", function()
    if vim.fn.bufnr("#") ~= -1 then
        vim.cmd("buffer #")
    else
        vim.notify("No alternate file", vim.log.levels.INFO)
    end
end, { desc = "Goto last accessed file" })

local last_modified_buf = nil
vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged" }, {
    callback = function(ev)
        if vim.bo[ev.buf].buftype == "" and vim.api.nvim_buf_get_name(ev.buf) ~= "" then
            last_modified_buf = ev.buf
        end
    end,
})

vim.keymap.set("n", "gm", function()
    local cur = vim.api.nvim_get_current_buf()
    if last_modified_buf and vim.api.nvim_buf_is_valid(last_modified_buf) and last_modified_buf ~= cur then
        vim.api.nvim_set_current_buf(last_modified_buf)
    elseif vim.fn.bufnr("#") ~= -1 then
        vim.cmd("buffer #")
    else
        vim.notify("No last modified file", vim.log.levels.INFO)
    end
end, { desc = "Goto last modified file" })

vim.keymap.set("n", "gn", "<cmd>bnext<CR>", { desc = "Goto next buffer" })
vim.keymap.set("n", "gp", "<cmd>bprevious<CR>", { desc = "Goto previous buffer" })
vim.keymap.set("n", "g.", "g;", { desc = "Goto last modification" })

-- ============================================================================
-- 4. HELIX UNIMPAIRED BRACKET NAVIGATION (] / [)
-- ============================================================================

-- Diagnostics (Helix: ]d / [d, ]D / [D)
vim.keymap.set({ "n", "x" }, "]d", function() vim.diagnostic.goto_next({ count = vim.v.count1, float = false }) end, { desc = "Next diagnostic" })
vim.keymap.set({ "n", "x" }, "[d", function() vim.diagnostic.goto_prev({ count = vim.v.count1, float = false }) end, { desc = "Previous diagnostic" })

local function goto_diagnostic(which)
    local diagnostics = vim.diagnostic.get(0)
    if #diagnostics == 0 then return end
    table.sort(diagnostics, function(a, b)
        if a.lnum ~= b.lnum then return a.lnum < b.lnum end
        return a.col < b.col
    end)
    local target = which == "last" and diagnostics[#diagnostics] or diagnostics[1]
    vim.cmd("normal! m'")
    vim.api.nvim_win_set_cursor(0, { target.lnum + 1, target.col })
    vim.cmd("normal! zvzz")
end

vim.keymap.set({ "n", "x" }, "]D", function() goto_diagnostic("last") end, { desc = "Last diagnostic" })
vim.keymap.set({ "n", "x" }, "[D", function() goto_diagnostic("first") end, { desc = "First diagnostic" })

-- Git Changes / Hunks (Helix: ]g / [g, ]G / [G via mini.diff)
vim.keymap.set({ "n", "x" }, "]g", function() require("mini.diff").goto_hunk("next") end, { desc = "Next git change" })
vim.keymap.set({ "n", "x" }, "[g", function() require("mini.diff").goto_hunk("prev") end, { desc = "Previous git change" })
vim.keymap.set({ "n", "x" }, "]G", function() require("mini.diff").goto_hunk("last") end, { desc = "Last git change" })
vim.keymap.set({ "n", "x" }, "[G", function() require("mini.diff").goto_hunk("first") end, { desc = "First git change" })

-- Paragraphs (Helix: ]p / [p)
vim.keymap.set({ "n", "x" }, "]p", "}", { desc = "Next paragraph" })
vim.keymap.set({ "n", "x" }, "[p", "{", { desc = "Previous paragraph" })

-- Blank Lines (Helix: ]Space / [Space)
vim.keymap.set("n", "] ", function()
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(0, lnum, lnum, false, { "" })
end, { desc = "Add newline below" })
vim.keymap.set("n", "[ ", function()
    local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
    vim.api.nvim_buf_set_lines(0, lnum, lnum, false, { "" })
end, { desc = "Add newline above" })

-- Tree-sitter & Semantic Navigation (Helix: ]f, ]t, ]a, ]c, ]e, ]T, ]x)
local function ts_jump(target, forward)
    local bufnr = vim.api.nvim_get_current_buf()
    local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr)
    local found_positions = {}

    if ok_parser and parser then
        local ok_parse, trees = pcall(function() return parser:parse() end)
        if ok_parse and trees and trees[1] then
            local root = trees[1]:root()
            local matcher
            if target == "function" then
                matcher = function(n)
                    local t = n:type()
                    return (t:match("function") or t:match("method"))
                        and not t:match("call") and not t:match("statement") and not t:match("signature") and t ~= "function"
                end
            elseif target == "class" then
                matcher = function(n)
                    local t = n:type()
                    return t:match("class") or t:match("struct") or t:match("enum") or t:match("interface")
                        or t:match("type_declaration") or t:match("type_spec") or t:match("impl_item")
                end
            elseif target == "parameter" then
                matcher = function(n)
                    local t = n:type()
                    return (t:match("parameter") or t == "param") and not t:match("list")
                end
            elseif target == "comment" then
                matcher = function(n) return n:type():match("comment") ~= nil end
            elseif target == "entry" then
                matcher = function(n)
                    local t = n:type()
                    return t:match("field") or t:match("pair") or t:match("entry") or t:match("property")
                end
            elseif target == "test" then
                matcher = function(n)
                    local t = n:type()
                    if (t:match("function") or t:match("method")) and not t:match("call") and not t:match("statement") and t ~= "function" then
                        local text = vim.treesitter.get_node_text(n, bufnr) or ""
                        local first = vim.split(text, "\n")[1] or ""
                        return first:lower():match("test") ~= nil
                    end
                    return false
                end
            elseif target == "xml" then
                matcher = function(n)
                    local t = n:type()
                    return t:match("element") or t:match("tag")
                end
            end

            if matcher then
                local seen = {}
                local function traverse(node)
                    if matcher(node) then
                        local r, c = node:start()
                        local key = r .. ":" .. c
                        if not seen[key] then
                            seen[key] = true
                            table.insert(found_positions, { row = r, col = c })
                        end
                    end
                    for child in node:iter_children() do
                        traverse(child)
                    end
                end
                traverse(root)
            end
        end
    end

    table.sort(found_positions, function(a, b)
        if a.row ~= b.row then return a.row < b.row end
        return a.col < b.col
    end)

    local cur = vim.api.nvim_win_get_cursor(0)
    local cur_row, cur_col = cur[1] - 1, cur[2]
    local count = vim.v.count1

    if #found_positions > 0 then
        if forward then
            local hits = 0
            for _, pos in ipairs(found_positions) do
                if pos.row > cur_row or (pos.row == cur_row and pos.col > cur_col) then
                    hits = hits + 1
                    if hits == count then
                        vim.cmd("normal! m'")
                        vim.api.nvim_win_set_cursor(0, { pos.row + 1, pos.col })
                        vim.cmd("normal! zvzz")
                        return
                    end
                end
            end
            if hits > 0 then
                local last = found_positions[#found_positions]
                vim.cmd("normal! m'")
                vim.api.nvim_win_set_cursor(0, { last.row + 1, last.col })
                vim.cmd("normal! zvzz")
                return
            end
            vim.notify("No more " .. target .. " forwards", vim.log.levels.INFO)
        else
            local hits = 0
            for i = #found_positions, 1, -1 do
                local pos = found_positions[i]
                if pos.row < cur_row or (pos.row == cur_row and pos.col < cur_col) then
                    hits = hits + 1
                    if hits == count then
                        vim.cmd("normal! m'")
                        vim.api.nvim_win_set_cursor(0, { pos.row + 1, pos.col })
                        vim.cmd("normal! zvzz")
                        return
                    end
                end
            end
            if hits > 0 then
                local first = found_positions[1]
                vim.cmd("normal! m'")
                vim.api.nvim_win_set_cursor(0, { first.row + 1, first.col })
                vim.cmd("normal! zvzz")
                return
            end
            vim.notify("No more " .. target .. " backwards", vim.log.levels.INFO)
        end
    else
        local patterns = {
            ["function"] = [[\v^\s*(function|local function|def|fn|func|pub fn|async def)\s+]],
            ["class"] = [[\v^\s*(class|struct|enum|interface|type)\s+]],
            ["comment"] = [[\v(\/\/|#|--|\/\*)]],
            ["test"] = [[\v^\s*(def\s+test_|fn\s+test_|test\(|it\(|describe\()]],
        }
        local pat = patterns[target]
        if pat then
            local flags = forward and "W" or "bW"
            for _ = 1, count do
                local found = vim.fn.search(pat, flags)
                if found == 0 then break end
            end
            vim.cmd("normal! zvzz")
        else
            vim.notify("No " .. target .. " found", vim.log.levels.INFO)
        end
    end
end

-- Helix Tree-sitter & AST jumps
vim.keymap.set({ "n", "x" }, "]f", function() ts_jump("function", true) end, { desc = "Next function" })
vim.keymap.set({ "n", "x" }, "[f", function() ts_jump("function", false) end, { desc = "Previous function" })
vim.keymap.set({ "n", "x" }, "]t", function() ts_jump("class", true) end, { desc = "Next type / class" })
vim.keymap.set({ "n", "x" }, "[t", function() ts_jump("class", false) end, { desc = "Previous type / class" })
vim.keymap.set({ "n", "x" }, "]a", function() ts_jump("parameter", true) end, { desc = "Next argument / parameter" })
vim.keymap.set({ "n", "x" }, "[a", function() ts_jump("parameter", false) end, { desc = "Previous argument / parameter" })
vim.keymap.set({ "n", "x" }, "]c", function() ts_jump("comment", true) end, { desc = "Next comment" })
vim.keymap.set({ "n", "x" }, "[c", function() ts_jump("comment", false) end, { desc = "Previous comment" })
vim.keymap.set({ "n", "x" }, "]e", function() ts_jump("entry", true) end, { desc = "Next entry" })
vim.keymap.set({ "n", "x" }, "[e", function() ts_jump("entry", false) end, { desc = "Previous entry" })
vim.keymap.set({ "n", "x" }, "]T", function() ts_jump("test", true) end, { desc = "Next test" })
vim.keymap.set({ "n", "x" }, "[T", function() ts_jump("test", false) end, { desc = "Previous test" })
vim.keymap.set({ "n", "x" }, "]x", function() ts_jump("xml", true) end, { desc = "Next XML / HTML element" })
vim.keymap.set({ "n", "x" }, "[x", function() ts_jump("xml", false) end, { desc = "Previous XML / HTML element" })

-- Buffers & Quickfix
vim.keymap.set({ "n", "x" }, "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set({ "n", "x" }, "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set({ "n", "x" }, "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
vim.keymap.set({ "n", "x" }, "[q", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item" })

-- ============================================================================
-- 5. HELIX MATCH (m) & VIEW (z) MODES
-- ============================================================================

-- Match Mode (Helix: mm -> Jump to matching bracket)
vim.keymap.set({ "n", "x", "o" }, "mm", "%", { desc = "Jump to matching bracket (Helix mm)" })

-- View Mode (Helix: z)
vim.keymap.set({ "n", "x" }, "zj", "<C-e>", { desc = "Scroll view down" })
vim.keymap.set({ "n", "x" }, "zk", "<C-y>", { desc = "Scroll view up" })
vim.keymap.set({ "n", "x" }, "z.", "zz", { desc = "Center view vertically" })
vim.keymap.set("n", "zv", "<cmd>vsplit<CR>", { desc = "Vertical split (View mode)" })
vim.keymap.set("n", "zs", "<cmd>split<CR>", { desc = "Horizontal split (View mode)" })

-- ============================================================================
-- 6. TREE-SITTER SELECTION EXPANSION (Helix: Alt-o / Alt-i)
-- ============================================================================
local ts_selection_stack = {}

local function ts_select_range(sr, sc, er, ec)
    vim.cmd("normal! \27")
    vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
    vim.cmd("normal! v")
    local target_ec = math.max(0, ec - 1)
    vim.api.nvim_win_set_cursor(0, { er + 1, target_ec })
end

local function ts_expand()
    local bufnr = vim.api.nvim_get_current_buf()
    local mode = vim.fn.mode()
    local node

    if mode:match("^[vV\22]") then
        local vpos = vim.fn.getpos("v")
        local curpos = vim.fn.getpos(".")
        local sr, sc = vpos[2] - 1, vpos[3] - 1
        local er, ec = curpos[2] - 1, curpos[3]
        if sr > er or (sr == er and sc > ec) then
            sr, sc, er, ec = er, curpos[3] - 1, sr, vpos[3]
        end

        local current_node = vim.treesitter.get_node({ bufnr = bufnr })
        node = current_node
        while node do
            local n_sr, n_sc, n_er, n_ec = node:range()
            if (n_sr < sr or (n_sr == sr and n_sc < sc)) or (n_er > er or (n_er == er and n_ec > ec)) then
                break
            end
            node = node:parent()
        end
    else
        node = vim.treesitter.get_node({ bufnr = bufnr })
        ts_selection_stack[bufnr] = {}
    end

    if not node then return end

    local sr, sc, er, ec = node:range()
    ts_selection_stack[bufnr] = ts_selection_stack[bufnr] or {}
    table.insert(ts_selection_stack[bufnr], { sr = sr, sc = sc, er = er, ec = ec })

    ts_select_range(sr, sc, er, ec)
end

local function ts_shrink()
    local bufnr = vim.api.nvim_get_current_buf()
    local stack = ts_selection_stack[bufnr]
    if not stack or #stack <= 1 then
        vim.cmd("normal! \27")
        ts_selection_stack[bufnr] = {}
        return
    end

    table.remove(stack)
    local prev = stack[#stack]
    ts_select_range(prev.sr, prev.sc, prev.er, prev.ec)
end

vim.keymap.set({ "n", "x" }, "<A-o>", ts_expand, { desc = "Expand selection to parent node (Helix Alt-o)" })
vim.keymap.set("x", "<A-i>", ts_shrink, { desc = "Shrink selection to child node (Helix Alt-i)" })

-- ============================================================================
-- 7. HELIX WINDOW MANAGEMENT (<leader>w / Ctrl-w)
-- ============================================================================
local function map_win(keys, cmd, desc)
    for _, k in ipairs(keys) do
        vim.keymap.set("n", "<leader>w" .. k, cmd, { desc = desc })
    end
end

map_win({ "v", "<C-v>" }, "<cmd>vsplit<CR>", "Vertical split")
map_win({ "s", "<C-s>" }, "<cmd>split<CR>", "Horizontal split")
map_win({ "h", "<C-h>", "<Left>" }, "<C-w>h", "Move to left window")
map_win({ "j", "<C-j>", "<Down>" }, "<C-w>j", "Move to window below")
map_win({ "k", "<C-k>", "<Up>" }, "<C-w>k", "Move to window above")
map_win({ "l", "<C-l>", "<Right>" }, "<C-w>l", "Move to right window")
map_win({ "w", "<C-w>" }, "<C-w>w", "Next window")
map_win({ "q", "<C-q>" }, "<cmd>close<CR>", "Close current window")
map_win({ "o", "<C-o>" }, "<cmd>only<CR>", "Only keep current window")
map_win({ "H" }, "<C-w>H", "Swap window left")
map_win({ "J" }, "<C-w>J", "Swap window down")
map_win({ "K" }, "<C-w>K", "Swap window up")
map_win({ "L" }, "<C-w>L", "Swap window right")
map_win({ "t", "<C-t>" }, "<C-w>x", "Transpose adjacent splits")
map_win({ "=" }, "<C-w>=", "Equalize windows")
map_win({ "f" }, "<C-w>f", "Goto file in horizontal split")
map_win({ "F" }, "<cmd>vertical wincmd f<CR>", "Goto file in vertical split")

-- ============================================================================
-- 8. OBSIDIAN.NVIM & NOTES (<leader>o)
-- ============================================================================
vim.keymap.set("n", "<leader>on", "<cmd>ObsidianNew<CR>", { desc = "New note" })
vim.keymap.set("n", "<leader>of", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Find note" })
vim.keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<CR>", { desc = "Search notes" })
vim.keymap.set("n", "<leader>od", "<cmd>ObsidianToday<CR>", { desc = "Today's daily note" })
vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianTags<CR>", { desc = "Search tags" })
vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>", { desc = "Backlinks" })
vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianOpen<CR>", { desc = "Open in Obsidian app" })

-- ============================================================================
-- 9. LATEX / VIMTEX (<leader>l)
-- ============================================================================
vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<CR>", { desc = "Compile LaTeX document" })
vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<CR>", { desc = "View PDF" })
vim.keymap.set("n", "<leader>lc", "<cmd>VimtexClean<CR>", { desc = "Clean aux files" })
vim.keymap.set("n", "<leader>le", "<cmd>VimtexErrors<CR>", { desc = "Show errors / log" })
vim.keymap.set("n", "<leader>lt", "<cmd>VimtexTocToggle<CR>", { desc = "Toggle TOC" })
vim.keymap.set("n", "<leader>ls", "<cmd>VimtexStatus<CR>", { desc = "Compilation status" })

-- ============================================================================
-- 10. GENERAL KEYMAPS
-- ============================================================================

-- Save & Quit
vim.keymap.set("n", "<leader>W", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>qq", "<cmd>q<CR>", { desc = "Quit window" })
vim.keymap.set("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Force quit all" })

-- Navigation & Centering
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Buffer Navigation
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })

-- Indentation
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Line Joining
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })

-- Search & Replace
vim.keymap.set("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })
vim.keymap.set("v", "<leader>sr", [["hy:%s/<C-r>h//gI<Left><Left><Left>]], { desc = "Replace selection" })

-- Formatting & Inlay Hints
vim.keymap.set({ "n", "v" }, "<leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, { desc = "Format buffer / selection" })
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show line diagnostic" })
vim.keymap.set("n", "<leader>th", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, { desc = "Toggle inlay hints" })

-- Quickfix Navigation (Centering)
vim.keymap.set("n", "[q", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item" })
vim.keymap.set("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
vim.keymap.set("n", "<leader>qo", "<cmd>copen<CR>", { desc = "Open quickfix list" })
vim.keymap.set("n", "<leader>qc", "<cmd>cclose<CR>", { desc = "Close quickfix list" })

-- Terminal Mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Window Focus
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focus bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focus top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })

-- Splits Management (window resizing; see <leader>w for splitting)
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Move Lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move current line down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move current line up" })

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>x", [["_d]], { desc = "Delete without yanking" })
