local M = {}

local floating_buf = nil
local floating_win = nil


function M.select_github_repo(callback)
    local output = vim.fn.system("gh repo list --limit 100 --json name,sshUrl,visibility")
    if vim.v.shell_error ~= 0 then
        print("Error fetching repos. Is 'gh' installed and authenticated?")
        return
    end

    local repos = vim.fn.json_decode(output)
    local choices = {}
    for _, repo in ipairs(repos) do
        table.insert(choices, string.format("%s [%s]", repo.name, repo.visibility))
    end

    vim.ui.select(choices, { prompt = "Select a GitHub repo:" }, function(choice, idx)
        if choice then
            local repo = repos[idx]
            callback(repo)
        else
            print("No repo selected")
        end
    end)
end

function M.create_readme(repo)
    local readme_file = vim.fn.getcwd() .. "/README.md"
    local readme_exists = vim.fn.filereadable(readme_file) == 1

    if not readme_exists then
        local f = io.open(readme_file, "w")
        if f then
            f:write("# " .. repo.name .. "\n")
            f:close()
            print("Created README.md for initial commit")
        else
            print("Failed to create README.md")
        end
    end
end

function M.create_gitignore()
    local git_file = vim.fn.getcwd() .. "/.gitignore"
    local git_exists = vim.fn.filereadable(git_file) == 1
    if not git_exists then
        local f = io.open(git_file, "w")
        if f then
            f:write([[
# Compiled source #
###################
*.com
*.class
*.dll
*.exe
*.o
*.so

# Packages #
############
*.7z
*.dmg
*.gz
*.iso
*.jar
*.rar
*.tar
*.zip

# Logs and databases #
######################
*.log
*.sql
*.sqlite

# OS generated files #
######################
.DS_Store
Thumbs.db

# OTHER #
#########
.env
.yaml

]])
            f:close()
            print("Created .gitignore")
        else
            print("Failed to create .gitignore")
        end
    end
end

local function get_staged_files(callback)
    vim.fn.jobstart("git diff --cached --name-only", {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data then
                callback(vim.tbl_filter(function(line)
                    return line ~= ""
                end, data))
            end
        end,
    })
end

local function get_unstaged_files(callback)
    vim.fn.jobstart("git diff --name-only", {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data then
                callback(vim.tbl_filter(function(line)
                    return line ~= ""
                end, data))
            end
        end,
    })
end

local function toggle_stage(filename, is_staged)
    local cmd = is_staged and { "git", "reset", "HEAD", filename } or { "git", "add", filename }
    vim.fn.jobstart(cmd, {
        on_exit = function()
            vim.schedule(function()
                M.interactive_git_toggle_ui() -- refresh UI
            end)
        end,
    })
end

local function commit_all()
    vim.ui.input({ prompt = "Commit message:" }, function(input)
        if input and input ~= "" then
            vim.fn.jobstart({ "git", "commit", "-m", input }, {
                stdout_buffered = true,
                on_stdout = function(_, data)
                    vim.schedule(function()
                        vim.notify(table.concat(data, "\n"), vim.log.levels.INFO)
                    end)
                end,
            })
        else
            vim.notify("❌ Commit message required.", vim.log.levels.WARN)
        end
    end)
end

function M.interactive_git_toggle_ui()
    get_staged_files(function(staged_files)
        get_unstaged_files(function(unstaged_files)
            -- Create an ordered list of ALL files (staged + unstaged), no duplicates, preserving initial order
            local all_files = {}
            local file_seen = {}

            for _, f in ipairs(staged_files) do
                table.insert(all_files, f)
                file_seen[f] = true
            end
            for _, f in ipairs(unstaged_files) do
                if not file_seen[f] then
                    table.insert(all_files, f)
                    file_seen[f] = true
                end
            end

            -- Create a lookup for staged status
            local staged_lookup = {}
            for _, f in ipairs(staged_files) do
                staged_lookup[f] = true
            end

            local buf = vim.api.nvim_create_buf(false, true)

            local total_cols = vim.o.columns
            local gap = 3 -- more breathing room

            local width = math.floor(total_cols * 0.3)
            local preview_width = math.floor(total_cols * 0.35)

            -- Adjust if total is too wide:
            if width + preview_width + gap > total_cols then
                preview_width = total_cols - width - gap
            end

            local height = math.min(#all_files + 30, math.floor(vim.o.lines * 0.6))
            local row = math.floor((vim.o.lines - height) / 2)
            local col = math.floor((total_cols - (width + preview_width + gap)) / 2)
            local win = vim.api.nvim_open_win(buf, true, {
                relative = "editor",
                width = width,
                height = height,
                row = row,
                col = col,
                style = "minimal",
                border = "rounded",
            })

            vim.api.nvim_buf_set_option(buf, "filetype", "git")
            vim.api.nvim_buf_set_option(buf, "modifiable", false)

            -- Setup highlight group for commit line (make sure to define it once)

            local preview_buf = vim.api.nvim_create_buf(false, true)
            local preview_height = height
            local preview_row = row
            local preview_col = col + width + gap

            local preview_win = vim.api.nvim_open_win(preview_buf, false, {
                relative = "editor",
                width = preview_width,
                height = preview_height,
                row = preview_row,
                col = preview_col,
                style = "minimal",
                border = "rounded",
            })
            vim.api.nvim_buf_set_option(preview_buf, "filetype", "diff")
            vim.api.nvim_buf_set_option(preview_buf, "modifiable", false)
            local function close_both_windows()
                if vim.api.nvim_win_is_valid(preview_win) then
                    vim.api.nvim_win_close(preview_win, true)
                end
                if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                end
            end

            vim.api.nvim_command("highlight CommitLineEnabled guifg=#A9DFBF guibg=#1E2F1E")
            vim.api.nvim_command("highlight CommitLineDisabled guifg=#7F8C8D guibg=#1C1C1C")

            vim.api.nvim_buf_set_keymap(preview_buf, "n", "q", "", {
                noremap = true,
                silent = true,
                callback = close_both_windows,
            })

            vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
                noremap = true,
                silent = true,
                callback = close_both_windows,
            })
            local committed = false
            local function build_lines()
                local lines = {}
                for _, f in ipairs(all_files) do
                    local mark = staged_lookup[f] and "[✓]" or "[ ]"
                    table.insert(lines, mark .. " " .. f)
                end
                table.insert(lines, "")
                if committed then
                    table.insert(lines, "➡ Push Changes")
                else
                    table.insert(lines, "➡ Commit Staged Changes")
                end
                return lines
            end

            local function refresh_display()
                vim.api.nvim_buf_set_option(buf, "modifiable", true)
                local lines = build_lines()
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                vim.api.nvim_buf_set_option(buf, "modifiable", false)

                vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)

                local commit_line = #lines - 1 -- last line index (0-based)
                if next(staged_lookup) ~= nil then
                    -- Enabled highlight
                    vim.api.nvim_buf_add_highlight(buf, -1, "CommitLineEnabled", commit_line, 0, -1)
                else
                    if committed then
                        vim.api.nvim_buf_add_highlight(buf, -1, "CommitLineEnabled", commit_line, 0, -1)
                    else
                        vim.api.nvim_buf_add_highlight(buf, -1, "CommitLineDisabled", commit_line, 0, -1)
                    end
                end
            end

            local function update_preview(filename)
                if not filename then
                    -- Clear preview if no file selected
                    vim.api.nvim_buf_set_option(preview_buf, "modifiable", true)
                    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, { "" })
                    vim.api.nvim_buf_set_option(preview_buf, "modifiable", false)
                    return
                end

                vim.fn.jobstart({ "git", "diff", "--cached", filename }, {
                    stdout_buffered = true,
                    on_stdout = function(_, data)
                        vim.schedule(function()
                            if data and #data > 0 then
                                -- Filter out empty lines, or keep them? Here we keep as-is.
                                -- But if only empty lines, replace with message
                                local filtered = vim.tbl_filter(function(line)
                                    return line ~= ""
                                end, data)
                                if #filtered == 0 then
                                    filtered = { "No staged changes for this file." }
                                end

                                vim.api.nvim_buf_set_option(preview_buf, "modifiable", true)
                                vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, filtered)
                                vim.api.nvim_buf_set_option(preview_buf, "modifiable", false)
                            else
                                vim.api.nvim_buf_set_option(preview_buf, "modifiable", true)
                                vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false,
                                    { "No staged changes for this file." })
                                vim.api.nvim_buf_set_option(preview_buf, "modifiable", false)
                            end
                        end)
                    end,
                })
            end

            -- Cursor moved autocmd in the toggle window to update preview dynamically
            vim.api.nvim_create_autocmd({ "CursorMoved" }, {
                buffer = buf,
                callback = function()
                    local line = vim.api.nvim_get_current_line()
                    local filename = line:match("%[.-%]%s(.+)")
                    update_preview(filename)
                end,
            })

            -- Scroll preview window down by 1 line
            -- Scroll preview window down by 1 line (Ctrl+j)
            vim.api.nvim_buf_set_keymap(buf, "n", "<C-j>", "", {
                noremap = true,
                silent = true,
                callback = function()
                    if vim.api.nvim_win_is_valid(preview_win) then
                        vim.api.nvim_win_call(preview_win, function()
                            vim.cmd("normal! j")
                        end)
                    end
                end,
            })

            -- Scroll preview window up by 1 line (Ctrl+k)
            vim.api.nvim_buf_set_keymap(buf, "n", "<C-k>", "", {
                noremap = true,
                silent = true,
                callback = function()
                    if vim.api.nvim_win_is_valid(preview_win) then
                        vim.api.nvim_win_call(preview_win, function()
                            vim.cmd("normal! k")
                        end)
                    end
                end,
            })

            -- <Tab> to toggle staged state without reordering
            vim.api.nvim_buf_set_keymap(buf, "n", "<Tab>", "", {
                noremap = true,
                callback = function()
                    local line = vim.api.nvim_get_current_line()
                    local filename = line:match("%[.-%]%s(.+)")
                    if not filename then
                        return
                    end

                    local currently_staged = staged_lookup[filename]

                    if currently_staged then
                        -- Unstage
                        vim.fn.jobstart({ "git", "reset", filename }, {
                            on_exit = function()
                                staged_lookup[filename] = nil
                                vim.schedule(refresh_display)
                            end,
                        })
                    else
                        -- Stage
                        vim.fn.jobstart({ "git", "add", filename }, {
                            on_exit = function()
                                staged_lookup[filename] = true
                                vim.schedule(refresh_display)
                            end,
                        })
                    end
                end,
            })

            -- <CR> to show diff or commit
            vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
                noremap = true,
                callback = function()
                    local line = vim.api.nvim_get_current_line()
                    local filename = line:match("%[.-%]%s(.+)")
                    if filename then
                        vim.fn.jobstart({ "git", "diff", "--cached", filename }, {
                            stdout_buffered = true,
                            on_stdout = function(_, data)
                                vim.schedule(function()
                                    local diff_buf = vim.api.nvim_create_buf(false, true)
                                    vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, data)
                                    vim.api.nvim_buf_set_option(diff_buf, "filetype", "diff")

                                    local diff_win = vim.api.nvim_open_win(diff_buf, false, {
                                        relative = "editor",
                                        width = math.floor(vim.o.columns * 0.8),
                                        height = math.floor(vim.o.lines * 0.7),
                                        row = 3,
                                        col = 5,
                                        style = "minimal",
                                        border = "rounded",
                                    })
                                    vim.api.nvim_buf_set_keymap(diff_buf, "n", "q", "", {
                                        noremap = true,
                                        silent = true,
                                        callback = function()
                                            if vim.api.nvim_win_is_valid(diff_win) then
                                                vim.api.nvim_win_close(diff_win, true)
                                            end
                                        end,
                                    })
                                end)
                            end,
                        })
                    elseif line:match("Commit Staged Changes") then
                        if next(staged_lookup) == nil then
                            return
                        end

                        vim.ui.input({ prompt = "Commit message: " }, function(input)
                            if not input or input == "" then
                                print("❌ Commit message required.")
                                return
                            end

                            vim.cmd("!git commit -m " .. vim.fn.shellescape(input))
                            staged_lookup = {}
                            committed = true
                            vim.schedule(function()
                                refresh_display()
                                update_preview(nil)
                            end)
                        end)
                    elseif line:match("➡ Push Changes") then
                        vim.fn.jobstart({ "git", "push" }, {
                            on_exit = function()
                                vim.schedule(function()
                                    print("Pushed changes!")
                                    committed = false
                                    refresh_display()
                                    close_both_windows()
                                end)
                            end,
                        })
                    end
                end,
            })

            refresh_display()
            update_preview(nil)
        end)
    end)
end

function M.check_git_ahead_behind()
    vim.fn.jobstart({ "git", "rev-list", "--left-right", "--count", "HEAD...origin/main" }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data and data[1] ~= "" then
                local ahead, behind = unpack(vim.split(data[1], "%s+"))
                local msg = string.format("🔼 Ahead: %s commits | 🔽 Behind: %s commits", ahead, behind)
                vim.schedule(function()
                    vim.notify(msg, vim.log.levels.INFO, { title = "Git Status" })
                end)
            end
        end,
        on_stderr = function(_, err)
            if err then
                vim.schedule(function()
                    vim.notify("Git error: " .. table.concat(err, "\n"), vim.log.levels.ERROR)
                end)
            end
        end,
    })
end

function M.open_floating_window(lines, opts, on_enter)
    opts = opts or {}
    if not floating_buf or not vim.api.nvim_buf_is_valid(floating_buf) then
        floating_buf = vim.api.nvim_create_buf(false, true)
    end
    local bufw = floating_buf

    vim.api.nvim_buf_set_option(bufw, "modifiable", true)
    vim.api.nvim_buf_set_lines(bufw, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(bufw, "modifiable", false)
    vim.api.nvim_buf_set_option(bufw, "bufhidden", "wipe")

    local width = opts.width or 100
    local height = opts.height or 20
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)


    vim.api.nvim_set_hl(0, "MyFloat", { bg = "#1e222a", fg = "#ffffff" })
    vim.api.nvim_set_hl(0, "MyFloatBorder", { fg = "#61afef", bg = "#1e222a" })


    if not floating_win or not vim.api.nvim_win_is_valid(floating_win) then
        floating_win = vim.api.nvim_open_win(bufw, true, {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
            style = "minimal",
            border = "rounded",
        })
    else
        vim.api.nvim_win_set_buf(floating_win, bufw)
    end
    vim.api.nvim_win_set_option(floating_win, "winhl", "Normal:MyFloat,FloatBorder:MyFloatBorder")

    vim.keymap.set("n", "q", function()
        if floating_win and vim.api.nvim_win_is_valid(floating_win) then
            vim.api.nvim_win_close(floating_win, true)
        end
    end, { buffer = bufw, nowait = true, silent = true })

    if on_enter then
        vim.keymap.set("n", "<CR>", function()
            local line = vim.api.nvim_get_current_line()
            on_enter(line)
            if floating_win and vim.api.nvim_win_is_valid(floating_win) then
                vim.api.nvim_win_close(floating_win, true)
            end
        end, { buffer = bufw, nowait = true })
    end
end

function M.run_git_cmd(cmd, on_line_select)
    if type(cmd) == "string" then
        cmd = vim.split(cmd, " ")
    end

    local output_lines = {}

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,

        on_stdout = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    if line and line:match("%S") then
                        table.insert(output_lines, line)
                    end
                end
            end
        end,

        on_stderr = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    if line and line:match("%S") then
                        table.insert(output_lines, line)
                    end
                end
            end
        end,

        on_exit = function(_, exit_code)
            vim.schedule(function()
                if #output_lines == 0 then
                    output_lines = { "No output" }
                end
                on_line_select = on_line_select or function() end
                M.open_floating_window(output_lines, { height = 20, width = 100 }, on_line_select)
            end)
        end,
    })
end

function M.get_git_values()
    return {
        {
            display = "Interactive: Commit & Push Staged",
            cmd = function()
                M.interactive_git_toggle_ui()
            end,
        },
        { display = "Status",                                  cmd = "git status" },
        { display = "Show unstaged changes",                   cmd = "git diff" },
        { display = "Show staged changed files [next commit]", cmd = "git diff --cached" },
        { display = "Show staged changed names [next commit]", cmd = "git diff --cached --name-only" },
        {
            display = "Commit & Push",
            cmd = function()
                vim.ui.input({ prompt = "Commit message: " }, function(input)
                    if input and input ~= "" then
                        vim.cmd("!git commit -m " .. vim.fn.shellescape(input))
                        vim.cmd("!git push")
                    else
                        print("❌ Commit message required.")
                    end
                end)
            end,
        },
        {
            display = "Commit Staged changes",
            cmd = function()
                vim.ui.input({ prompt = "Commit message: " }, function(input)
                    if input and input ~= "" then
                        vim.cmd("!git commit -m " .. vim.fn.shellescape(input))
                    else
                        print("❌ Commit message required.")
                    end
                end)
            end,
        },
        { display = "Push",        cmd = "git push" },
        { display = "Pull",        cmd = "git pull" },
        { display = "Add Current", cmd = "git add %" },
        { display = "Add All",     cmd = "git add ." },
        { display = "Fetch",       cmd = "git fetch" },
        {
            display = "History",
            cmd = "git rev-list --all --pretty --full-history",
        },
        {
            display = "Jump Commits",
            cmd = function()
                M.run_git_cmd({
                    "git",
                    "log",
                    "--oneline",
                    "--graph",
                    "--all",
                }, function(line)
                    local hash = line:match("[*|\\ ]*([a-f0-9]+)")
                    if not hash then
                        print("❌ Could not extract commit hash")
                        return
                    end
                    vim.fn.jobstart({ "git", "checkout", hash }, {
                        on_exit = function(_, code)
                            vim.schedule(function()
                                if code == 0 then
                                    print("Checked out commit: " .. hash)
                                    vim.cmd("checktime")
                                else
                                    print("Failed to checkout commit: " .. hash)
                                end
                            end)
                        end,
                    })
                end)
            end,
        },
        {
            display = "Ahead Behind Count",
            cmd = "git rev-list --left-right --count HEAD...origin/main",
        },
    }
end

local function close_all_windows(main_win, sub_win)
    if main_win and vim.api.nvim_win_is_valid(main_win) then
        vim.api.nvim_win_close(main_win, true)
    end
    if sub_win and vim.api.nvim_win_is_valid(sub_win) then
        vim.api.nvim_win_close(sub_win, true)
    end
end

function M.handle_git(action, win, sub_win)
    close_all_windows(win, sub_win)

    if not action or not action.cmd then
        print("❌ No Git command selected.")
        return
    end

    if type(action.cmd) == "string" or type(action.cmd) == "table" then
        M.run_git_cmd(action.cmd)
    elseif type(action.cmd) == "function" then
        action.cmd()
    else
        print("❌ Invalid command.")
    end
end

return M
