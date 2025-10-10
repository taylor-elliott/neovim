local M = {}

local api = vim.api
local buf = vim.lsp.buf
local fn = vim.fn

-- vim.api.nvim_buf_get_lines(buf, firstline, new_lastline, true)


local function map(mode, lhs, rhs, opts)
    local default = {
        silent = true,  -- don't show command in cmdline
        noremap = true, -- non-recursive mapping
        desc = nil,     -- description for which-key or keymap listing
    }

    opts = vim.tbl_deep_extend("force", default, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
end
local function X()
    local diagnostics = vim.diagnostic.get(0)
    if vim.tbl_isempty(diagnostics) then
        vim.notify("No diagnostics found", vim.log.levels.INFO)
        return
    end

    table.sort(diagnostics, function(a, b)
        return a.lnum < b.lnum
    end)

    local lines = {}
    local positions = {} -- store lnum/col per line
    for i, d in ipairs(diagnostics) do
        local msg = string.format(
            "%d. %s:%d:%d: %s",
            i,
            vim.fn.fnamemodify(vim.fn.bufname(d.bufnr), ":t"),
            d.lnum + 1,
            d.col + 1,
            d.message
        )
        table.insert(lines, msg)
        positions[i] = { bufnr = d.bufnr, lnum = d.lnum, col = d.col }
    end

    local buf_x = api.nvim_create_buf(false, true)

    api.nvim_buf_set_lines(buf_x, 0, -1, false, lines)

    local height = math.min(#lines, 15)
    local width = math.max(unpack(vim.tbl_map(vim.fn.strdisplaywidth, lines))) + 4

    local win = api.nvim_open_win(buf_x, true, {
        relative = "editor",
        width = width,
        height = height,
        row = (vim.o.lines - height) / 2,
        col = (vim.o.columns - width) / 2,
        style = "minimal",
        border = "rounded",
        title = "Diagnostics",
        title_pos = "center",
    })

    vim.wo[win].cursorline = true

    api.nvim_buf_set_keymap(buf_x, "n", "q", "<cmd>bd!<CR>", { noremap = true, silent = true })
    api.nvim_buf_set_keymap(
        buf_x,
        "n",
        "<CR>",
        string.format(
            "<cmd>lua local pos=%s vim.api.nvim_win_close(%d,true) vim.api.nvim_set_current_buf(pos.bufnr) vim.api.nvim_win_set_cursor(0,{pos.lnum+1,pos.col})<CR>",
            vim.inspect(positions[1]),
            win
        ),
        { noremap = true, silent = true }
    )
    api.nvim_buf_set_keymap(buf_x, "n", "<CR>", "", {
        noremap = true,
        silent = true,
        callback = function()
            local cursor = api.nvim_win_get_cursor(0)
            local line = cursor[1]
            local pos = positions[line]
            if pos then
                api.nvim_win_close(win, true)
                api.nvim_set_current_buf(pos.bufnr)
                api.nvim_win_set_cursor(0, { pos.lnum + 1, pos.col })
            end
        end,
    })
end

local function convert_function_to_arrow()
    -- Step 1: Convert function declaration line (async optional)
    vim.cmd([[silent! s/^\s*\(async \)\?function \(\w\+\)(\(.*\))\(:[^)]*\)\? {$/const \2 = \1(\3)\4 => {/]])

    -- Step 2: Move to next line and replace single-line return if it exists
    vim.cmd("normal! j")
    vim.cmd([[silent! s/^\s*return \(.*\);\?$/\1/e]])

    -- Step 3: Move back to the function declaration line and try to remove braces if simple body
    vim.cmd("normal! k")
    vim.cmd([[silent! s/{\s*\n\s*\(.*\)\n\s*}/\1/]])
end

local function get_current_theme()
    local config_file = vim.fn.expand("~/.config/nvim-configs/themes.lua")
    local f = io.open(config_file, "r")
    if not f then
        return nil
    end
    local content = f:read("*a")
    f:close()

    -- Extract the theme name using pattern matching
    local current = content:match('current%s*=%s*"(.-)"')
    return current
end

local function set_theme()
    local theme = get_current_theme()
    if theme and theme:match("^rose%-pine") then
        vim.opt.runtimepath:append("~/.config/nvim-te/pack/themes/start/rose-pine")
        require("rose-pine").setup({
            variant = theme == "rose-pine" and "main" or theme:match("moon") and "moon" or "dawn",
            dark_variant = theme:match("moon") and "moon" or "main",
        })
    end
    pcall(vim.cmd.colorscheme, theme)
end

-- location of themes: ~/.local/share/nvim/lazy/gruvbox.nvim/colors/gruvbox.vim
local function pick_theme()
    -- Ensure we have a proper array of strings
    local themes_raw = vim.fn.getcompletion("", "color") or {}
    local themes = {}
    for _, t in ipairs(themes_raw) do
        if type(t) == "string" then
            table.insert(themes, t)
        end
    end

    vim.ui.select(themes, { prompt = "Choose a theme:" }, function(choice, _)
        if choice then
            local ok, err = pcall(vim.cmd.colorscheme, choice)
            if not ok then
                print("Error applying theme:", err)
                return
            end
            print("Switched to theme: " .. choice)

            -- save permanently
            local config_file = vim.fn.expand("~/.config/nvim-configs/themes.lua")
            local f = io.open(config_file, "w")
            if f then
                f:write('return { current = "' .. choice .. '" }\n')
                f:close()
            end
        end
    end)
end

local function get_binary()
    -- Assumes your Makefile outputs bin/<project_name>
    local handle = io.popen("basename $(pwd)")
    if not handle then
        return nil, "Failed to open process"
    end

    local result = handle:read("*a")
    handle:close()
    return "bin/" .. result:gsub("%s+", "") -- remove trailing newline
end

local print_macros = {
    "int",
    "string",
    "log",
    "char",
    "long",
    "q (quit)",
}
-- Map macro type to printf format
local fmt_map = {
    int = "%d",
    string = "%s",
    log = "%s",
    char = "%c",
    long = "%ld",
}

local function get_c_asserts()
    local asserts = {
        " == NULL",
        " != NULL",
        " == 0",
        " != 0",
        " > 0",
        " < 0",
    }
    return asserts
end

local function insert_below()
    local word = vim.fn.expand("<cword>")
    if word == "" then
        print("No variable under cursor")
        return
    end

    vim.ui.select(print_macros, {
        prompt = "Select print macro: ",
    }, function(print_macro)
        if not print_macro or print_macro == "" or print_macro == "q (quit)" then
            return
        end

        local cursor = vim.api.nvim_win_get_cursor(0)
        local cur_row = cursor[1] -- 1-indexed row
        -- local cur_col = cursor[2] -- 0-indexed column

        -- Determine the correct format
        local fmt = fmt_map[print_macro] or "%s"

        -- Build the printf line
        local line = string.format('printf("%s: %s\\n", %s);', word, fmt, word)

        -- Insert the line **below the current line**
        vim.api.nvim_buf_set_lines(0, cur_row, cur_row, false, { line })

        -- Move cursor to the end of the inserted line
        vim.api.nvim_win_set_cursor(0, { cur_row + 1, #line })

        -- Optional: format the new line
        if vim.lsp.buf.format then
            vim.lsp.buf.format()
        end
    end)
end

local function get_python_asserts()
    local asserts = {
        { display = " is None",             msg = "Check if variable is None" },
        { display = " is not None",         msg = "Check if variable is not None" },
        { display = " is True",             msg = "Check if variable is True" },
        { display = " is False",            msg = "Check if variable is False" },
        { display = " == 0",                msg = "Check if variable is 0" },
        { display = " != 0",                msg = "Check if variable is not 0" },
        { display = " > 0",                 msg = "Check if variable is greater than 0" },
        { display = " < 0",                 msg = "Check if variable is less than 0" },
        { display = " == ''",               msg = "Check if variable is an empty string" },
        { display = " != ''",               msg = "Check if variable is not an empty string" },
        { display = " is empty string",     msg = "Check if variable is an empty string" },
        { display = " is not empty string", msg = "Check if variable is not an empty string" },
    }
    return asserts
end

local function get_ml_values()
    if vim.bo.filetype == "python" then
        return {
            { display = "Standard Scalar",     import = "from sklearn.preprocessing import StandardScaler" },
            { display = "Train Test Split",    import = "from sklearn.model_selection import train_test_split" },
            { display = "Logistic Regression", import = "from sklearn.linear_model import LogisticRegression" },
            { display = "PCA",                 import = "from sklearn.decomposition import PCA" },
            { display = "Confusion Matrix",    import = "from sklearn.metrics import confusion_matrix" },
        }
    elseif vim.bo.filetype == "typescript" or vim.bo.filetype == "typescriptreact" then
        return {
            { display = "useState",            import = 'import { useState } from "react"' },
            { display = "useEffect",           import = 'import { useEffect } from "react"' },
            { display = "useRef",              import = 'import { useEffect } from "react"' },
            { display = "useCallback",         import = 'import { useCallback } from "react"' },
            { display = "useMemo",             import = 'import { useMemo } from "react"' },
            { display = "useStart/Effect/Ref", import = 'import { useState, useRef, useEffect } from "react"' },
        }
    else
        return {}
    end
end

local function get_visual_values()
    return {
        { display = "Histogram",        fn = nil },
        { display = "Scatter Plot",     fn = nil },
        { display = "Spree Plot",       fn = nil },
        { display = "Mean",             fn = nil },
        { display = "Mode",             fn = nil },
        { display = "Median",           fn = nil },
        { display = "Standard Dev",     fn = nil },
        { display = "Variance",         fn = nil },
        { display = "Confusion Matrix", fn = nil },
    }
end

local function get_import_values(ft)
    if ft == "python" then
        return {
            { display = "os",         import = "import os" },
            { display = "tensorflow", import = "import tensorflow as tf" },
            { display = "pyplot",     import = "import matplotlib.pyplot as plt" },
            { display = "numpy",      import = "import numpy as np" },
            { display = "sklearn",    import = "import sklearn" },
            { display = "logging",    import = "import logging" },
        }
    elseif ft == "typescript" or ft == "typescriptreact" then
        return {
            { display = "useState",            import = 'import { useState } from "react"' },
            { display = "useEffect",           import = 'import { useEffect } from "react"' },
            { display = "useRef",              import = 'import { useEffect } from "react"' },
            { display = "useCallback",         import = 'import { useCallback } from "react"' },
            { display = "useMemo",             import = 'import { useMemo } from "react"' },
            { display = "useStart/Effect/Ref", import = 'import { useState, useRef, useEffect } from "react"' },
        }
    else
        return {}
    end
end

_G.SetConditionalBreakpoint = function()
    local condition = vim.fn.input("Breakpoint condition: ")
    if condition ~= "" then
        require("dap").set_breakpoint(condition)
    else
        require("dap").set_breakpoint()
    end
end

_G.MultiToggleBreakpoints = function(buf_bp)
    buf_bp = buf_bp or api.nvim_get_current_buf()

    api.nvim_set_current_buf(buf_bp)

    local opts_mtb = { noremap = true, silent = true, buffer = buf_bp }

    map("n", "<CR>", function()
        vim.cmd("DapToggleBreakpoint")
    end, opts_mtb)

    map("n", "r", function()
        vim.keymap.del("n", "<CR>", opts_mtb)
        vim.keymap.del("n", "r", opts_mtb)
        vim.keymap.del("n", "q", opts_mtb)
        RunContinue(buf_bp)
    end, opts_mtb)

    map("n", "q", function()
        vim.keymap.del("n", "<CR>", opts_mtb)
        vim.keymap.del("n", "r", opts_mtb)
        vim.keymap.del("n", "q", opts_mtb)
        print("Exited multi-toggle breakpoint mode")
    end, opts_mtb)

    print("Multi-Toggle Mode: move to any line and press <Enter> to toggle, 'r' to run debugger, 'q' to quit")
end

_G.RunContinue = function(buf_continue)
    buf = buf or api.nvim_get_current_buf()

    api.nvim_set_current_buf(buf_continue)

    local opts_ = { noremap = true, silent = true, buffer = buf }

    map("n", "<CR>", function()
        require("dap").continue()
    end, opts_)

    map("n", "q", function()
        vim.keymap.del("n", "<CR>", { buffer = buf_continue })
        vim.keymap.del("n", "q", { buffer = buf_continue })
        print("Exiting debugger...")
    end, opts_)

    print("Press <Enter> to continue, 'q' to stop")
end

local function get_debug_values()
    return {
        { display = "Continue",          cmd = "DapContinue" },
        { display = "Toggle breakpoint", cmd = "" },
        {
            display = "Set condition",
            cmd = "lua SetConditionalBreakpoint()",
        },
        { display = "New",       cmd = "DapNew" },
        { display = "Stop",      cmd = "DapStop" },
        { display = "Step Over", cmd = "DapStepOver" },
        { display = "Step Into", cmd = "DapSetInto" },
        { display = "Toggle UI", cmd = 'lua require("dapui").toggle()' },
    }
end

local function get_test_values()
    return {
        { display = "Run Nox",                                  cmd = "!make test" },
        { display = "Run Format",                               cmd = "!make format" },
        { display = "Run Lint",                                 cmd = "!make lint" },
        { display = "Run Lint ",                                cmd = "!make lint-fix" },
        { display = "Run Typecheck",                            cmd = "!make typecheck" },
        { display = "Run Full Check (Format, Lint, Typecheck)", cmd = "!make check" },
    }
end

local function get_datastructures()
    return {
        { display = "Hash Map", cmd = "" },
        { display = "LL",       cmd = "" },
    }
end

local function get_algos()
    return {
        { display = "Prefix Array", cmd = "" },
    }
end

local function get_techniques()
    return { { display = "Sliding Window", cmd = "" }, { display = "Two-Pointer", cmd = "" } }
end

local function get_menu(ft)
    local menus = {
        { title = "Imports",        fn = function() return get_import_values(ft) end },
        { title = "Debug",          fn = get_debug_values },
        { title = "Test",           fn = get_test_values },
        { title = "Asserts",        fn = get_python_asserts },
        -- { title = "Lint", fn = get_lint_values },
        { title = "Datastructures", fn = get_datastructures },
        { title = "Algorithms",     fn = get_algos },
        { title = "Techniques",     fn = get_techniques },
        { title = "ML",             fn = get_ml_values },
        { title = "Visual",         fn = get_visual_values },
        { title = "Quit",           fn = nil },
    }

    local main = {}
    for _, m in ipairs(menus) do
        table.insert(main, { title = m.title })
    end

    local function getSub(item)
        for _, m in ipairs(menus) do
            if m.title == item then
                local items = m.fn and m.fn() or {}
                if item ~= "Quit" then
                    table.insert(items, { display = "← Back" })
                end
                return items
            end
        end
        return {}
    end

    return main, getSub
end

local function move_cursor_in_win(win, direction)
    if not api.nvim_win_is_valid(win) then
        return
    end
    local buf_ = api.nvim_win_get_buf(win)
    local row = api.nvim_win_get_cursor(win)[1]
    local line_count = api.nvim_buf_line_count(buf_)

    if direction == "down" then
        row = row + 1
        if row > line_count then
            row = 1
        end
    else
        row = row - 1
        if row < 1 then
            row = line_count
        end
    end

    api.nvim_win_set_cursor(win, { row, 0 })
end

local function create_window(lines, opts)
    opts = opts or {}
    local buf__ = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(buf__, 0, -1, false, lines)
    vim.bo[buf__].modifiable = false
    vim.api.nvim_set_hl(0, "TestHi", { fg = "#D3A04D" })
    local test_t = { { "Menu", "TestHi" } }
    local win = api.nvim_open_win(buf__, true, {
        relative = opts.relative or "editor",
        row = opts.row or 5,
        col = opts.col or 10,
        width = opts.width or 40,
        height = opts.height or #lines,
        style = "minimal",
        border = opts.border or "rounded",
        title = test_t,
        title_pos = "center",
    })

    vim.wo[win].cursorline = true
    vim.wo[win].winblend = 0
    vim.wo[win].winhl = "Normal:Normal,FloatBorder:Normal"

    if #lines > 0 then
        api.nvim_win_set_cursor(win, { 1, 0 })
    end
    -- buffer-local mappings (use map with buffer option)
    -- Tab -> next, Shift-Tab -> prev. Use the win handle so we always move the right window.
    -- map("n", "<Tab>", function()
    -- 	move_cursor_in_win(win, "down")
    -- end, { buffer = buf, noremap = true, silent = true })
    --
    map("n", "<S-Tab>", function()
        move_cursor_in_win(win, "up")
    end, { buffer = buf__, noremap = true, silent = true })

    -- fallback for terminals that don't send <S-Tab> (optional)
    map("n", "<C-Tab>", function()
        move_cursor_in_win(win, "down")
    end, { buffer = buf__, noremap = true, silent = true })

    -- close mappings
    map("n", "q", function()
        if api.nvim_win_is_valid(win) then
            api.nvim_win_close(win, true)
        end
    end, { buffer = buf__, noremap = true, silent = true })
    map("n", "<Esc>", function()
        if api.nvim_win_is_valid(win) then
            api.nvim_win_close(win, true)
        end
    end, { buffer = buf__, noremap = true, silent = true })

    return buf__, win
end

local function highlight_existing_imports(subBuf, subActions, edit_buf)
    -- Create a unique namespace for highlights
    local ns_id = vim.api.nvim_create_namespace("existing_imports")

    -- Get all lines in the main buffer
    local existing_lines = vim.api.nvim_buf_get_lines(edit_buf, 0, -1, false)

    -- Loop over subActions and highlight those that already exist
    for i, action_item in ipairs(subActions) do
        if action_item.import then
            for _, line in ipairs(existing_lines) do
                if line == action_item.import then
                    vim.highlight.range(subBuf, ns_id, "Comment", { i - 1, 0 }, { i - 1, -1 }, { inclusive = true })
                    break
                end
            end
        end
    end
end

local function close_all_windows(main_win, sub_win)
    if main_win and vim.api.nvim_win_is_valid(main_win) then
        vim.api.nvim_win_close(main_win, true)
    end
    if sub_win and vim.api.nvim_win_is_valid(sub_win) then
        vim.api.nvim_win_close(sub_win, true)
    end
end

local function handle_asserts(action, edit_buf, indent_str, word, current_line)
    local assert_line = ""
    if action.display == "is not empty string" then
        assert_line = string.format('%sassert %s, "%s"', indent_str, word, action.msg)
    elseif action.display == "is empty string" then
        assert_line = string.format('%sassert %s == "", "%s"', indent_str, word, action.msg)
    else
        assert_line = string.format('%sassert %s%s, "%s"', indent_str, word, action.display, action.msg)
    end

    -- Insert the assert line right below the current line
    vim.api.nvim_buf_set_lines(edit_buf, current_line + 1, current_line + 1, false, { assert_line })
end

local function handle_imports(action, edit_buf)
    local was_modifiable = vim.bo[edit_buf].modifiable

    if not was_modifiable then
        vim.bo[edit_buf].modifiable = true
    end

    -- Get all existing lines in the buffer
    local import_lines = vim.api.nvim_buf_get_lines(edit_buf, 0, -1, false)
    local import_line = string.format("%s", action.import)

    -- Check if the import line already exists
    local already_exists = false
    for _, line in ipairs(import_lines) do
        if line == import_line then
            already_exists = true
            break
        end
    end

    if not already_exists then
        -- Save cursor
        local win_id = vim.fn.bufwinid(edit_buf)
        local pos = { 1, 0 }
        if win_id ~= -1 then
            pos = vim.api.nvim_win_get_cursor(win_id)
        end
        local import_row, col = pos[1], pos[2]

        -- Insert import at top
        vim.api.nvim_buf_set_lines(edit_buf, 0, 0, false, { import_line })

        -- Restore cursor
        if win_id ~= -1 then
            vim.api.nvim_win_set_cursor(win_id, { import_row + 1, col })
        end
    else
        -- Optional: annotate existing import instead of re-adding
        -- local ns_id = vim.api.nvim_create_namespace("existing_imports")
        -- for i, line in ipairs(import_lines) do
        -- 	if line == import_line then
        -- 		vim.api.nvim_buf_set_extmark(edit_buf, ns_id, i - 1, 0, {
        -- 			virt_text = { { "✓", "WarningMsg" } },
        -- 			virt_text_pos = "eol",
        -- 		})
        -- 		break
        -- 	end
        -- end
        vim.notify("Import already exists: " .. import_line)
    end

    -- Restore modifiable state
    if not was_modifiable then
        vim.bo[edit_buf].modifiable = false
    end
end

local function handle_debug(action, edit_buf, main_win, sub_win)
    if action.display == "Toggle breakpoint" then
        api.nvim_set_current_buf(edit_buf)
        vim.cmd("lua MultiToggleBreakpoints(" .. edit_buf .. ")")
        close_all_windows(main_win, sub_win)
    elseif action.display == "Continue" then
        api.nvim_set_current_buf(edit_buf)
        vim.cmd("lua RunContinue(" .. edit_buf .. ")")
        close_all_windows(main_win, sub_win)
    elseif action.display == "Toggle UI" then
        api.nvim_set_current_buf(edit_buf)
        local opts_tui = { noremap = true, silent = true, buffer = edit_buf }
        map("n", "q", function()
            require("dapui").toggle()
            vim.keymap.del("n", "q", { buffer = edit_buf })
        end, opts_tui)
        close_all_windows(main_win, sub_win)
        vim.cmd(action.cmd)
    else
        api.nvim_set_current_buf(edit_buf)
        close_all_windows(main_win, sub_win)
        vim.cmd(action.cmd)
    end
end

local function handle_lint(action, win, sub_win)
    close_all_windows(win, sub_win)
    vim.cmd(action.cmd)
end

local function handle_test(action, main_win, sub_win)
    close_all_windows(main_win, sub_win)
    vim.cmd(action.cmd)
end

local function run_selection(
    index,
    actions,
    getSub,
    main_win,
    sub_win,
    edit_buf,
    indent_str,
    current_line,
    word,
    parent_title
)
    local selection = actions[index]
    if not selection then
        return
    end

    -- quit main menu
    if selection.title == "Quit" then
        if main_win and api.nvim_win_is_valid(main_win) then
            api.nvim_win_close(main_win, true)
        end
        return
    end

    -- if we're in main menu -> process submenu
    if not parent_title then
        local subActions = getSub(selection.title)
        if #subActions == 0 then
            return
        end

        -- format submenu lines
        local subLines = {}
        for i, s in ipairs(subActions) do
            table.insert(subLines, string.format("%d. %s", i, s.display))
        end

        local sub_buf
        sub_buf, sub_win = create_window(subLines, { title = selection.title .. " Options", row = 5, col = 48 })
        highlight_existing_imports(sub_buf, subActions, edit_buf)

        for i, _ in ipairs(subActions) do
            map("n", tostring(i), function()
                run_selection(
                    i,
                    subActions,
                    nil,
                    main_win,
                    sub_win,
                    edit_buf,
                    indent_str,
                    current_line,
                    word,
                    selection.title
                )
            end, { buffer = sub_buf })
        end

        map("n", "<CR>", function()
            local subRow = api.nvim_win_get_cursor(sub_win)[1]
            run_selection(
                subRow,
                subActions,
                nil,
                main_win,
                sub_win,
                edit_buf,
                indent_str,
                current_line,
                word,
                selection.title
            )
        end, { buffer = sub_buf })

        return
    end

    if selection.display == "← Back" then
        if sub_win and api.nvim_win_is_valid(sub_win) then
            api.nvim_win_close(sub_win, true)
        end
        return
    end

    -- Handle by parent menu
    if parent_title == "Imports" then
        handle_imports(selection, edit_buf)
    elseif parent_title == "ML" then
        handle_imports(selection, edit_buf)
    elseif parent_title == "Asserts" then
        handle_asserts(selection, edit_buf, indent_str, word, current_line)
    elseif parent_title == "Debug" then
        handle_debug(selection, edit_buf, main_win, sub_win)
    elseif parent_title == "Lint" then
        handle_lint(selection, main_win, sub_win)
    elseif parent_title == "Test" then
        handle_test(selection, main_win, sub_win)
    end
end

local function main_menu()
    local word = fn.expand("<cword>")
    local current_line = api.nvim_win_get_cursor(0)[1] - 1
    local main_buf_line = api.nvim_get_current_line()
    local indent_str = (main_buf_line:match("^%s*") or "") .. "    "
    local edit_buf = api.nvim_get_current_buf()
    local ft = vim.bo.filetype
    local main, getSub = get_menu(ft)

    local lines = {}
    for i, a in ipairs(main) do
        table.insert(lines, string.format("%d. %s", i, a.title))
    end

    local main_buf, main_win = create_window(lines, { title = "Main Menu", row = 5, col = 5 })

    -- Map number keys
    for i = 1, #main do
        map("n", tostring(i), function()
            run_selection(i, main, getSub, main_win, nil, edit_buf, indent_str, current_line, word)
        end, { buffer = main_buf, noremap = true, silent = true })
    end

    -- Map Enter key
    map("n", "<CR>", function()
        local row = api.nvim_win_get_cursor(main_win)[1]
        run_selection(row, main, getSub, main_win, nil, edit_buf, indent_str, current_line, word)
    end, { buffer = main_buf, noremap = true, silent = true })
end

local assert_macros = {
    "ASSERT_OK",
    "ASSERT_NOT_ERR",
    "ASSERT_STRLEN_GT_0",
    "ASSERT_NOT_NULL",
    "ASSERT_NOT_EMPTY_STR",
    "ASSERT_EQ_STR",
    "ASSERT_IN_RANGE_INCLUSIVE",
    "ASSERT_IN_RANGE_EXCLUSIVE",
    "ASSERT_EQ",
    "ASSERT_GE",
    "ASSERT_LE",
    "ASSERT_GT",
    "ASSERT_LT",
    "q (quit)",
}

local function insert_assertion_at_function_start()
    local word = vim.fn.expand("<cword>")
    if word == "" then
        print("No variable under cursor")
        return
    end

    vim.ui.select(assert_macros, {
        prompt = "Select assert macro: ",
    }, function(assert_macro)
        if assert_macro == nil or assert_macro == "" or assert_macro == "q (quit)" then
            return
        end

        local bufnr = 0
        local cur_row = vim.api.nvim_win_get_cursor(0)[1]
        local total_lines = vim.api.nvim_buf_line_count(bufnr)

        local balance = 0
        local brace_line = nil

        for i = cur_row, 1, -1 do
            local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]

            for c in line:gmatch(".") do
                if c == "}" then
                    balance = balance + 1
                elseif c == "{" then
                    if balance == 0 then
                        brace_line = i
                        break
                    else
                        balance = balance - 1
                    end
                end
            end

            if brace_line then
                break
            end
        end

        if not brace_line then
            local max_search = math.min(total_lines, cur_row + 5)
            for i = cur_row, max_search do
                local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
                if line:match("{") then
                    brace_line = i
                    break
                end
            end
        end

        if not brace_line then
            print("Could not find opening brace '{' near cursor")
            return
        end

        local assertion_line = ""

        if assert_macro == "ASSERT_IN_RANGE" or assert_macro == "ASSERT_IN_RANGE_EXCLUSIVE" then
            -- For these macros, you need extra input for min and max
            vim.ui.input({ prompt = "Enter min value:" }, function(min_val)
                if not min_val or min_val == "" then
                    print("No min value provided")
                    return
                end
                vim.ui.input({ prompt = "Enter max value:" }, function(max_val)
                    if not max_val or max_val == "" then
                        print("No max value provided")
                        return
                    end
                    assertion_line = string.format("%s(%s, %s, %s);", assert_macro, word, min_val, max_val)
                    -- Insert and format now that we have the full assertion line
                    vim.api.nvim_buf_set_lines(0, brace_line, brace_line, false, { assertion_line })
                    vim.api.nvim_win_set_cursor(0, { brace_line + 1, 0 })
                    vim.cmd("normal! gg=G")
                end)
            end)
            return -- early return because async input
        elseif
            assert_macro == "ASSERT_GE"
            or assert_macro == "ASSERT_LE"
            or assert_macro == "ASSERT_GT"
            or assert_macro == "ASSERT_LT"
        then
            -- Need threshold input
            vim.ui.input({ prompt = "Enter threshold value:" }, function(threshold)
                if not threshold or threshold == "" then
                    print("No threshold provided")
                    return
                end
                assertion_line = string.format("%s(%s, %s);", assert_macro, word, threshold)
                vim.api.nvim_buf_set_lines(0, brace_line, brace_line, false, { assertion_line })
                vim.api.nvim_win_set_cursor(0, { brace_line + 1, 0 })
                vim.cmd("normal! gg=G")
            end)
            return
        elseif assert_macro == "ASSERT_EQ_STR" or assert_macro == "ASSERT_EQ" then
            vim.ui.input({ prompt = "Enter cmp value:" }, function(threshold)
                if not threshold or threshold == "" then
                    print("No value provided")
                    return
                end
                assertion_line = string.format('%s(%s,"%s");', assert_macro, word, threshold)
                vim.api.nvim_buf_set_lines(0, brace_line, brace_line, false, { assertion_line })
                vim.api.nvim_win_set_cursor(0, { brace_line + 1, 0 })
                vim.cmd("normal! gg=G")
            end)
            return
        else
            assertion_line = string.format("%s(%s);", assert_macro, word)
            vim.api.nvim_buf_set_lines(0, brace_line, brace_line, false, { assertion_line })
            vim.api.nvim_win_set_cursor(0, { brace_line + 1, 0 })
            vim.lsp.buf.format()
        end
    end)
end

local function reload_module(name)
    local full_name = "config." .. name
    package.loaded[full_name] = nil
    require(full_name)
    print(full_name .. " reloaded!")
end

local function reload_command(opts)
    local modules = { "keymaps", "autocmds" }

    if opts.args == "" or opts.args == "all" then
        for _, mod in ipairs(modules) do
            reload_module(mod)
        end
    else
        reload_module(opts.args)
    end
end

local function reload_completion(ArgLead)
    local modules = { "all", "keymaps", "autocmds" }
    local matches = {}
    for _, mod in ipairs(modules) do
        if mod:match("^" .. ArgLead) then
            table.insert(matches, mod)
        end
    end
    return matches
end

local function open_builtin_code_action_at_quickfix()
    local qflist = vim.fn.getqflist()
    local line = vim.fn.line(".")
    local entry = qflist[line]

    if not entry or not entry.bufnr then
        print("No quickfix entry under cursor")
        return
    end

    -- jump to the quickfix entry without opening new windows
    vim.cmd("cclose")
    vim.cmd("cc " .. line)

    vim.defer_fn(function()
        vim.lsp.buf.code_action()
    end, 0)
end

local function get_print()
    local word = fn.expand("<cword>")
    local current_line = api.nvim_win_get_cursor(0)[1] - 1
    local line = api.nvim_get_current_line()
    local s_col = string.find(line, word, 1, true) or 1
    local lines = ""
    if vim.bo.filetype == "python" then
        local indent_str = line:sub(1, s_col - 1):gsub("%S", "")
        lines = indent_str .. 'print("' .. word .. ' =", ' .. word .. ")"
    else
        local indent_str = line:sub(1, s_col - 2):gsub("%S", "")
        lines = indent_str .. 'printf("' .. word .. ' = %d\\n", ' .. word .. ");"
    end

    api.nvim_buf_set_lines(0, current_line + 1, current_line + 1, false, { lines })
end


local function execute_file()
    if vim.bo.filetype == "python" then
        vim.cmd("write")
        local filepath = fn.expand("%:p")
        vim.cmd("belowright 10split | terminal python3 " .. filepath)
        vim.defer_fn(function()
            local bufnr = api.nvim_get_current_buf()
            map("n", "q", "<cmd>bd!<CR>", {
                buffer = bufnr,
                silent = true,
                desc = "Close terminal",
            })
        end, 100)
    elseif vim.bo.filetype == "c" then
        vim.cmd("belowright 10split | terminal bash -c 'bear -- make clean all > /dev/null 2>&1 && ./run.sh'")
    else
        print("UNKNOWN FILETYPE")
    end
end
local function offset()
    local offset = vim.fn.input("Offset: ")
    local rel = tonumber(offset)
    if rel then
        local cur_line = vim.api.nvim_win_get_cursor(0)[1]
        local target = math.max(1, cur_line + rel) -- prevent going before line 1
        vim.api.nvim_win_set_cursor(0, { target, 0 })
        vim.cmd("normal! @a")
    end
end
local function repeat_cmd()
    local off = vim.fn.input("Offset: ")
    local reg = vim.fn.input("Macro register: ")
    local rel = tonumber(off)
    if rel and reg ~= "" then
        local cur_line = vim.api.nvim_win_get_cursor(0)[1]
        local target = math.max(1, cur_line + rel)
        vim.api.nvim_win_set_cursor(0, { target, 0 })
        vim.cmd("normal! @" .. reg)
    end
end
local function run_binary()
    vim.cmd("silent !make -s > /dev/null 2>&1")
    -- get binary path
    local binary = get_binary()
    -- open terminal running the binary
    vim.cmd("botright split | resize 15 | terminal valgrind --leak-check=full --show-leak-kinds=all " .. binary)
end

local function goto_explore()
    local is_diag_open = false

    -- Check if a quickfix, Trouble, or diagnostic window is open
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf2 = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[buf2].filetype

        if ft == "qf" or ft == "Trouble" or ft == "diagnostic" then
            is_diag_open = true
            break
        end
    end

    local current_ft = vim.bo.filetype

    -- If in netrw or empty buffer, open explorer
    if current_ft == "netrw" or current_ft == "" then
        vim.cmd("Ex")
        return
    end
    local buffers = vim.fn.getbufinfo({ buflisted = 1 })
    local normal_bufs = vim.tbl_filter(function(buf3)
        local ft = vim.fn.getbufvar(buf.bufnr, "&filetype")
        return buf3.name ~= "" and ft ~= "qf" and ft ~= "Trouble" and ft ~= "diagnostic"
    end, buffers)

    -- No real buffers at all → open explorer
    if #normal_bufs == 0 then
        vim.cmd("Ex")
        return
    end

    if not is_diag_open then
        if #normal_bufs == 1 then
            -- Only one buffer → don’t close, just open explorer
            vim.cmd("Ex")
        else
            -- More than one real buffer → close and go to next
            -- vim.cmd("bd")
            vim.cmd("bnext") -- Switch to next buffer
        end
    else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>w", true, false, true), "n", false)
    end
end

local function add_print()
    local word = fn.expand("<cword>")
    local current_line = api.nvim_win_get_cursor(0)[1] - 1
    local line = api.nvim_get_current_line()
    local s_col = string.find(line, word, 1, true) or 1
    local lines = ""
    if vim.bo.filetype == "python" then
        local indent_str = line:sub(1, s_col - 1):gsub("%S", "")
        lines = indent_str .. 'print("' .. word .. ' =", ' .. word .. ")"
    else
        local indent_str = line:sub(1, s_col - 2):gsub("%S", "")
        lines = indent_str .. 'printf("' .. word .. ' = %d\\n", ' .. word .. ");"
    end

    api.nvim_buf_set_lines(0, current_line + 1, current_line + 1, false, { lines })
end
local function insert_assert()
    -- Get the current word under the cursor
    local word = fn.expand("<cword>")
    local current_line = api.nvim_win_get_cursor(0)[1] - 1
    local line = api.nvim_get_current_line()
    local s_col = string.find(line, word, 1, true) or 1
    -- Choose the correct assertion list based on the filetype
    local assertions = vim.bo.filetype == "python" and h.get_python_asserts() or h.get_c_asserts()
    local display_options = {}
    for _, assertion in ipairs(assertions) do
        if type(assertion) == "table" then
            -- Extract the description (first element of the pair) for display
            table.insert(display_options, assertion[1])
        else
            -- For C, just insert the assertion string as is
            table.insert(display_options, assertion)
        end
    end
    -- Show a popup for the user to select an assertion
    ui.select(display_options, {
        prompt = "Choose an assertion:",
        confirm = "Select",
    }, function(selected_assertion)
        if selected_assertion then
            local lines = ""
            local indent_str = line:sub(1, s_col - 1):gsub("%S", "")
            local assertion, message = nil, nil
            for _, item in ipairs(assertions) do
                if type(item) == "table" then
                    if item[1] == selected_assertion then
                        assertion, message = item[1], item[2]
                        break
                    end
                elseif item == selected_assertion then
                    assertion = item
                    message = nil
                    break
                end
            end
            if vim.bo.filetype == "python" then
                if selected_assertion == "is not empty string" then
                    lines = indent_str .. "   assert " .. word .. ', "' .. message .. '"'
                elseif selected_assertion == "is empty string" then
                    lines = indent_str .. "   assert " .. word .. ' == "", "' .. message .. '"'
                else
                    lines = indent_str .. "   assert " .. word .. assertion .. ', "' .. message .. '"'
                end
                api.nvim_buf_set_lines(0, current_line + 1, current_line + 1, false, { lines })
            else
                lines = indent_str .. "      assert(" .. word .. selected_assertion .. ");"
                api.nvim_buf_set_lines(0, current_line + 2, current_line + 2, false, { lines })
            end
        end
    end)
end

local function search_for_pattern()
    local success, _ = pcall(vim.cmd, "normal! nzzzv")
    if not success then
        vim.notify("Pattern not found", vim.log.levels.WARN)
    end
end

local function add_fun()
    local ts = vim.treesitter
    local query = require("vim.treesitter.query")
    local parsers = require("nvim-treesitter.parsers")

    local bufnr = vim.api.nvim_get_current_buf()
    local lang = parsers.get_buf_lang(bufnr) -- "c"
    local parser = ts.get_parser(bufnr, lang)
    if not parser then
        return nil
    end
    local tree = parser:parse()[1]
    local root = tree:root()

    local c_query = [[
  (function_definition
    declarator: (function_declarator
      declarator: (identifier) @func_name
      (parameter_list) @params
    )
  ) @func_def
]]

    local parsed_query = query.parse(lang, c_query)

    for id, node, metadata in parsed_query:iter_captures(root, bufnr, 0, -1) do
        local capture_name = parsed_query.captures[id]
        local text = ts.get_node_text(node, bufnr)
        if capture_name == "func_name" then
            print("Function name: " .. text)
        elseif capture_name == "params" then
            print("Parameters: " .. text)
        elseif capture_name == "func_def" then
            -- 	print("Function body:\n" .. text)
            -- 	print("-----")
        end
    end
end
local function close_quickfix_window()
    -- Check if any quickfix window is open
    for _, win in ipairs(vim.fn.getwininfo()) do
        if win.quickfix == 1 then
            vim.cmd("cclose")
            return
        end
    end
    vim.api.nvim_feedkeys("q", "n", false)
end


local function show_action_window()
    local ft = vim.bo.filetype

    if ft == "c" or ft == "h" then
        require("actions-preview").code_actions()
    else
        require("telescope.builtin").diagnostics({
            bufnr = 0,
            sorter = require("telescope.sorters").get_fzy_sorter(),
        })
    end
end

local function set_telescope_buffers_config()
    require("telescope.builtin").buffers({
        sort_mru = true,
        ignore_current_buffer = true,
        previewer = true,
    })
end

local function paste_system_clipboard()
    vim.notify("Pasting from clipboard", vim.log.levels.INFO, { title = "Insert Mode Paste" })
    local keys = vim.api.nvim_replace_termcodes("<C-r>+", true, false, true)
    vim.api.nvim_feedkeys(keys, "i", false)
end

local function list_concat(A, B)
    local t = {}
    for _, value in ipairs(A) do
        table.insert(t, value)
    end
    for _, value in ipairs(B) do
        table.insert(t, value)
    end
    return t
end

local function set_import(component_name)
    local pattern = [[^import%s*{([^}]*)}%s*from%s*['"]%.?/components['"];?]]
    local import_line = string.format("import { %s } from './components';", component_name)
    local existing_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local insert_line = 0
    local found_line_index = nil
    local existing_imports = {}

    for i, line in ipairs(existing_lines) do
        if line:match(pattern) then
            found_line_index = i
            -- parse existing imports inside { ... }
            local imports_str = line:match(pattern)
            for name in imports_str:gmatch("[^,%s]+") do
                existing_imports[name] = true
            end
            break
        end
        if not line:match("^import") then
            insert_line = i - 1
            break
        end
    end

    -- add the new component to the existing imports if found
    if found_line_index then
        existing_imports[component_name] = true
        -- rebuild the import statement
        local import_list = {}
        for name in pairs(existing_imports) do
            table.insert(import_list, name)
        end
        table.sort(import_list) -- optional
        import_line = string.format("import { %s } from './components';", table.concat(import_list, ", "))
        -- replace the line with the updated import
        vim.api.nvim_buf_set_lines(0, found_line_index - 1, found_line_index, false, { import_line })
    else
        -- insert a new import line at the calculated position
        vim.api.nvim_buf_set_lines(0, insert_line, insert_line, false, { import_line, "" })
    end
end

local function set_barrel()
    local start_pos = vim.fn.getpos("v")
    local end_pos = vim.fn.getpos(".")
    local ls = math.min(start_pos[2], end_pos[2])
    local le = math.max(start_pos[2], end_pos[2])

    local lines = vim.api.nvim_buf_get_lines(0, ls - 1, le, false)
    if #lines == 0 or lines[1]:match("^%s*$") then
        print("No selection!")
        return
    end

    -- prompt for component name
    local component_name = vim.fn.input("Component name: ")
    if component_name == "" then
        print("No name given.")
        return
    end

    -- new file path
    local path = "src/components/" .. component_name .. ".tsx"
    local folder = vim.fn.fnamemodify(path, ":h")
    if vim.fn.isdirectory(folder) == 0 then
        vim.fn.mkdir(folder, "p")
    end

    local found_export = false
    for _, l in ipairs(lines) do
        if l:match("^%s*export%s+") then
            found_export = true
            break
        end
    end

    if not found_export then
        table.insert(lines, "export { " .. component_name .. " };")
    end

    vim.fn.writefile(lines, path)

    local index_file = "src/components/index.ts"
    local export_line = string.format("export { %s } from './%s';", component_name, component_name)
    if vim.fn.filereadable(index_file) == 1 then
        local index_lines = vim.fn.readfile(index_file)
        local exists = false
        for _, l in ipairs(index_lines) do
            if l:find(export_line, 1, true) then
                exists = true
                break
            end
        end
        if not exists then
            table.insert(index_lines, export_line)
            vim.fn.writefile(index_lines, index_file)
            print("Updated barrel file: " .. index_file)
        else
            print("Already in barrel file")
        end
    else
        vim.fn.writefile({ export_line }, index_file)
        print("Created new barrel file: " .. index_file)
    end

    set_import(component_name)

    -- remove selection from current file
    vim.api.nvim_buf_set_lines(0, ls - 1, le, false, {})
end

local function getLines()
    local start_pos = vim.fn.getpos("v")
    local end_pos = vim.fn.getpos(".")
    local ls = math.min(start_pos[2], end_pos[2])
    local le = math.max(start_pos[2], end_pos[2])

    local lines = vim.api.nvim_buf_get_lines(0, ls - 1, le, false)
    if #lines == 0 or lines[1]:match("^%s*$") then
        print("No selection!")
        return
    end
    return lines, ls - 1, le
end

local function getFilename()
    local filename = vim.fn.input("Filename (without extension): ")
    if filename == "" then
        return ""
    end
    return filename
end

local function setTsx(component_name, lines, ls, le)
    local path = "src/components/" .. component_name .. ".tsx"
    local folder = vim.fn.fnamemodify(path, ":h")
    if vim.fn.isdirectory(folder) == 0 then
        vim.fn.mkdir(folder, "p")
    end

    -- Add named export if needed
    local found_export = false
    for _, l in ipairs(lines) do
        if l:match("^%s*export%s+") then
            found_export = true
            break
        end
    end

    if not found_export then
        table.insert(lines, "export { " .. component_name .. " };")
    end

    -- Write to new file
    vim.fn.writefile(lines, path)

    -- Remove selection from current file
    vim.api.nvim_buf_set_lines(0, ls - 1, le, false, {})

    -- Add import statement at top
    local import_line = string.format("import { %s } from './components/%s';", component_name, component_name)
    local existing_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local insert_line = 0
    for i, line in ipairs(existing_lines) do
        if not line:match("^import") then
            insert_line = i - 1
            break
        end
    end
    vim.api.nvim_buf_set_lines(0, insert_line, insert_line, false, { import_line, "" })

    -- Open new file in split
    vim.cmd("vsplit " .. path)

    print("Extracted selection to " .. path)
end

local function guard_name(filename)
    return filename:upper() .. "_H"
end

local function extract_prototypes_from_lines(lines)
    local prototypes = {}
    local in_function = false
    local func_lines = {}

    for _, line in ipairs(lines) do
        -- Accumulate lines that look like function declarations
        if not in_function and line:match("^[%w_%*%s]-[%w_]+%s*%b()%s*{?%s*$") then
            in_function = true
            table.insert(func_lines, line)
            if line:find("{") then
                -- single-line function
                local prototype = line:gsub("{.*", ""):gsub("%s+$", "") .. ";"
                table.insert(prototypes, prototype)
                in_function = false
                func_lines = {}
            end
        elseif in_function then
            table.insert(func_lines, line)
            if line:find("{") then
                -- function signature complete
                local joined = table.concat(func_lines, " ")
                local prototype = joined:gsub("{.*", ""):gsub("%s+$", "") .. ";"
                table.insert(prototypes, prototype)
                in_function = false
                func_lines = {}
            end
        end
    end

    return prototypes
end

local stdlib_headers = {
    printf = "<stdio.h>",
    fprintf = "<stdio.h>",
    FILE = "<stdio.h>",
    fopen = "<stdio.h>",
    fclose = "<stdio.h>",
    fgets = "<stdio.h>",
    strtok = "<string.h>",
    strcmp = "<string.h>",
    strcpy = "<string.h>",
    strncpy = "<string.h>",
    malloc = "<stdlib.h>",
    free = "<stdlib.h>",
    exit = "<stdlib.h>",
    memset = "<string.h>",
    memcpy = "<string.h>",
}
local function setPython(filename, lines, start_line, end_line)
    local current_dir = vim.fn.expand("%:p:h")
    local new_file_path = current_dir .. "/" .. filename .. ".py"

    local existing_lines = {}
    -- file already exists, just append selected text to it
    if vim.fn.filereadable(new_file_path) == 1 then
        existing_lines = vim.fn.readfile(new_file_path)
    end
    for _, line in ipairs(lines) do
        table.insert(existing_lines, line)
    end

    vim.fn.writefile(existing_lines, new_file_path)
    local import_line = "import " .. filename
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local has_import = false
    for _, line in ipairs(buf_lines) do
        if line:match("^%s*" .. import_line) then
            has_import = true
            break
        end
    end
    if not has_import then
        vim.api.nvim_buf_set_lines(0, 0, 0, false, { import_line })
    end

    -- Delete the original lines
    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, {})
end

local function scanForHeaders(lines, existing_headers)
    local used_headers = {}
    local used = {}
    for _, line in ipairs(lines) do
        for word, header in pairs(stdlib_headers) do
            local include_line = "#include " .. header
            if line:find(word, 1, true) and not used[header] and not existing_headers[include_line] then
                table.insert(used_headers, include_line)
                used[header] = true
            end
        end
    end
    return used_headers, lines
end

local function setC(filename, lines, start_line, end_line)
    local h_file = filename .. ".h"
    local h_path = "include/" .. h_file
    local c_path = "src/" .. filename .. ".c"
    local macro = guard_name(filename)

    vim.fn.mkdir("include", "p")
    vim.fn.mkdir("src", "p")

    local existing_c_lines = {}
    local existing_headers = {}
    if vim.fn.filereadable(c_path) == 1 then
        existing_c_lines = vim.fn.readfile(c_path)
        for _, line in ipairs(existing_c_lines) do
            if line:match("^#include") then
                existing_headers[line] = true
            end
        end
    end

    -- Split existing C file into headers and body
    local existing_body = {}
    for _, line in ipairs(existing_c_lines) do
        if not line:match("^#include") then
            table.insert(existing_body, line)
        end
    end

    local headers_to_add, function_lines = scanForHeaders(lines, existing_headers)

    local final_c_lines = {}

    for header_line, _ in pairs(existing_headers) do
        table.insert(final_c_lines, header_line)
    end

    -- Add new headers
    for _, header in ipairs(headers_to_add) do
        if not existing_headers[header] then
            table.insert(final_c_lines, header)
        end
    end

    -- Add empty line between headers and functions
    if #existing_headers > 0 or #headers_to_add > 0 then
        table.insert(final_c_lines, "")
    end

    -- Append existing body
    vim.list_extend(final_c_lines, existing_body)

    -- Append new function lines
    vim.list_extend(final_c_lines, function_lines)

    -- Write .c file
    vim.fn.writefile(final_c_lines, c_path)

    -- -------------------------
    -- Handle .h file
    -- -------------------------
    local existing_prototypes = {}
    if vim.fn.filereadable(h_path) == 1 then
        local h_lines = vim.fn.readfile(h_path)
        for _, line in ipairs(h_lines) do
            if line:match("%w+%s*%b()%s*;") then
                existing_prototypes[line] = true
            end
        end
    end

    local new_prototypes = extract_prototypes_from_lines(lines)
    if #new_prototypes == 0 then
        table.insert(new_prototypes, "// TODO: Add function declarations")
    end

    -- Merge prototypes avoiding duplicates
    for _, proto in ipairs(new_prototypes) do
        existing_prototypes[proto] = true
    end

    -- Rebuild header file
    local header_lines = { "#ifndef " .. macro, "#define " .. macro, "" }
    for proto, _ in pairs(existing_prototypes) do
        table.insert(header_lines, proto)
    end
    table.insert(header_lines, "")
    table.insert(header_lines, "#endif /* " .. macro .. " */")
    vim.fn.writefile(header_lines, h_path)

    -- -------------------------
    -- Remove selected lines from buffer
    -- -------------------------
    vim.api.nvim_buf_set_lines(0, start_line, end_line, false, {})

    -- -------------------------
    -- Insert #include "file.h" in buffer if missing
    -- -------------------------
    local include_line = '#include "' .. h_file .. '"'
    local existing_lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
    local already_included = false
    for _, line in ipairs(existing_lines) do
        if line == include_line then
            already_included = true
            break
        end
    end

    if not already_included then
        local insert_line = 0
        for i, line in ipairs(existing_lines) do
            if not line:match("^#include") then
                insert_line = i - 1
                break
            end
        end
        vim.api.nvim_buf_set_lines(0, insert_line, insert_line, false, { include_line, "" })
    end

    -- -------------------------
    -- Open .c and .h files in splits
    -- -------------------------
    vim.cmd("vsplit " .. c_path)
    vim.cmd("split " .. h_path)

    print("Extracted to " .. c_path .. " and updated prototypes in " .. h_path)
end


local function create_component(type)
    -- get start and end of visual selection
    local lines, start_line, end_line = getLines()
    if not lines then
        return
    end
    local filename = getFilename()
    if filename == "" then
        return
    end
    if type == "tsx" then
        setTsx(filename, lines, start_line, end_line)
    elseif type == "c" then
        setC(filename, lines, start_line, end_line)
    elseif type == "python" then
        setPython(filename, lines, start_line, end_line)
    end
end


M.list_concat = list_concat
M.set_import = set_import
M.set_barrel = set_barrel
M.create_component = create_component
M.paste_system_clipboard = paste_system_clipboard
M.set_telescope_buffers_config = set_telescope_buffers_config
M.show_action_window = show_action_window
M.close_quickfix_window = close_quickfix_window
M.add_fun = add_fun
M.insert_assert = insert_assert
M.search_for_pattern = search_for_pattern
M.add_print = add_print
M.run_binary = run_binary
M.goto_explore = goto_explore
M.repeat_cmd = repeat_cmd
M.offset = offset
M.map = map
M.execute_file = execute_file
M.get_print = get_print
M.open_builtin_code_action_at_quickfix = open_builtin_code_action_at_quickfix
M.main_menu = main_menu
M.run_selection = run_selection
M.handle_test = handle_test
M.handle_lint = handle_lint
M.handle_debug = handle_debug
M.handle_imports = handle_imports
M.handle_asserts = handle_asserts
M.close_all_windows = close_all_windows
M.highlight_existing_imports = highlight_existing_imports
M.create_window = create_window
M.move_cursor_in_win = move_cursor_in_win
M.get_menu = get_menu
M.get_techniques = get_techniques
M.get_algos = get_algos
M.get_datastructures = get_datastructures
M.get_test_values = get_test_values
M.get_debug_values = get_debug_values
M.get_import_values = get_import_values
M.convert_function_to_arrow = convert_function_to_arrow
M.pick_theme = pick_theme
M.set_theme = set_theme
M.get_binary = get_binary
M.insert_below = insert_below
M.get_c_asserts = get_c_asserts
M.insert_assertion_at_function_start = insert_assertion_at_function_start
M.reload_command = reload_command
M.reload_completion = reload_completion
M.X = X

return M
