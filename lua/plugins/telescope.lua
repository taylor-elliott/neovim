-- vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "#1e1e2e" })
-- vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "#1e1e2e", fg = "#1e1e2e" })
-- vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "#313244" })
-- vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "#313244", fg = "#313244" })
-- vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "#313244", fg = "#cdd6f4" })
-- vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "#1e1e2e" })
-- vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = "#1e1e2e", fg = "#1e1e2e" })
-- vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { bg = "#1e1e2e", fg = "#cdd6f4" })
-- vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "#1e1e2e" })
-- vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "#1e1e2e", fg = "#1e1e2e" })
-- vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { bg = "#1e1e2e", fg = "#cdd6f4" })

local actions = require("telescope.actions")

return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-lua/plenary.nvim",
    },
    cmd = "Telescope",
    opts = {
        defaults = {
            mappings = {
                i = {
                    ["<Esc>"] = function(prompt_bufnr)
                        actions.close(prompt_bufnr)
                    end,
                },
                n = {
                    ["<Esc>"] = function(prompt_bufnr)
                        actions.close(prompt_bufnr)
                    end,
                    ["q"] = function(prompt_bufnr)
                        actions.close(prompt_bufnr)
                    end,
                },
            },
            file_ignore_patterns = {
                "node_modules/.*",
                "%.env",
                "yarn.lock",
                "package-lock.json",
                "lazy-lock.json",
                "init.sql",
                "target/.*",
                ".gitignore",
                ".git/.*",
            },
            layout_config = {
                width = 0.9,
                height = 0.9,
            },
            sorting_strategy = "ascending",
            prompt_prefix = "🔍 ",
            selection_caret = " ",
        },
        pickers = {
            find_files = {
                hidden = true,
                find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
                theme = "dropdown",
            },
        },
    },
    config = function(_, opts)
        local telescope = require("telescope")
        telescope.setup(opts)

        local builtin = require("telescope.builtin")
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local action_state = require("telescope.actions.state")

        vim.keymap.set("n", "<leader>tc", function()
            builtin.colorscheme({ enable_preview = true })
        end, { desc = "Pick Colorscheme (Preview)" })

        -- Action picker after image selection
        local function image_action_picker(selected_image)
            local cmd = ""
            local options = {
                "Original Image",
                "Resize 50%",
                "Rounded Border",
                "White Background",
                "White Background and Resize",
                "White Background and Rounded Border",
                "White Background, Resize, Rounded Border",
                "Cancel",
            }

            pickers.new({}, {
                prompt_title = "Choose Action for Image",
                finder = finders.new_table {
                    results = options,
                },
                sorter = conf.generic_sorter({}),
                attach_mappings = function(prompt_bufnr, map)
                    local function on_select()
                        local selection = action_state.get_selected_entry().value
                        actions.close(prompt_bufnr)

                        local input_path = "/home/telliott/Pictures/Code/" .. selected_image
                        local output_path = input_path
                        if selection ~= "Original Image" then
                            output_path = input_path:gsub("(%.%w+)$", "_edited%1")
                        end

                        if selection == "Original Image" then
                            cmd = string.format([[
echo '[Done] Press Enter to continue...'; read
]], vim.fn.shellescape(input_path))
                        elseif selection == "Rounded Border" then
                            cmd = string.format([[
magick %s -bordercolor white -border 10 \
\( +clone -alpha extract -draw "fill black polygon 0,0 0,15 15,0 fill white circle 15,15 15,0" \
   \( +clone -flip \) -compose Multiply -composite \
   \( +clone -flop \) -compose Multiply -composite \
\) -alpha off -compose CopyOpacity -composite %s; echo '[Done] Press Enter to continue...'; read
]], vim.fn.shellescape(input_path), vim.fn.shellescape(output_path))
                        elseif selection == "White Background" then
                            cmd = string.format([[
magick %s -background white -alpha remove -alpha off %s; \
echo '[Done] Press Enter to continue...'; read
]], vim.fn.shellescape(input_path), vim.fn.shellescape(output_path))
                        elseif selection == "White Background and Rounded Border" then
                            cmd = string.format([[
magick %s \
\( +clone -alpha extract -draw "fill black polygon 0,0 0,20 20,0 fill white circle 20,20 20,0" \
   \( +clone -flip \) -compose Multiply -composite \
   \( +clone -flop \) -compose Multiply -composite \
\) -alpha off -compose CopyOpacity -composite \
-background white -alpha remove -alpha off \
-bordercolor white -border 10 \
%s; echo '[Done] Press Enter to continue...'; read
]], vim.fn.shellescape(input_path), vim.fn.shellescape(output_path))
                        elseif selection == "Resize 50%" then
                            cmd = string.format([[
magick %s -resize 50%% %s; \
echo '[Done] Press Enter to continue...'; read
]], vim.fn.shellescape(input_path), vim.fn.shellescape(output_path))
                        elseif selection == "White Background, Resize, Rounded Border" then
                            cmd = string.format([[
magick %s -resize 50%% -bordercolor white -border 10 \
\( +clone -alpha extract -draw "fill black polygon 0,0 0,15 15,0 fill white circle 15,15 15,0" \
   \( +clone -flip \) -compose Multiply -composite \
   \( +clone -flop \) -compose Multiply -composite \
\) -alpha off -compose CopyOpacity -composite %s; echo '[Done] Press Enter to continue...'; read
]], vim.fn.shellescape(input_path), vim.fn.shellescape(output_path))
                        elseif selection == "White Background and Resize" then
                            cmd = string.format([[
magick %s \
\( +clone -alpha extract -draw "fill black polygon 0,0 0,15 15,0 fill white circle 15,15 15,0" \
   \( +clone -flip \) -compose Multiply -composite \
   \( +clone -flop \) -compose Multiply -composite \
\) -alpha off -compose CopyOpacity -composite %s; echo '[Done] Press Enter to continue...'; read
]], vim.fn.shellescape(input_path), vim.fn.shellescape(output_path))
                        elseif selection == "Cancel" then
                            print("Action cancelled.")
                        end

                        local origin_buf = vim.api.nvim_get_current_buf()
                        local origin_win = vim.api.nvim_get_current_win()

                        local term_buf = vim.api.nvim_create_buf(false, true)
                        local width = math.floor(vim.o.columns * 0.8)
                        local height = math.floor(vim.o.lines * 0.6)
                        local row = math.floor((vim.o.lines - height) / 2)
                        local col = math.floor((vim.o.columns - width) / 2)

                        local term_win = vim.api.nvim_open_win(term_buf, true, {
                            relative = "editor",
                            width = width,
                            height = height,
                            row = row,
                            col = col,
                            style = "minimal",
                            border = "rounded",
                        })
                        if cmd ~= "" then
                            vim.fn.termopen({ "bash", "-c", cmd }, {
                                on_exit = function()
                                    vim.schedule(function()
                                        if vim.api.nvim_win_is_valid(term_win) then
                                            vim.api.nvim_win_close(term_win, true)
                                        end
                                        vim.api.nvim_set_current_win(origin_win)
                                        vim.api.nvim_set_current_buf(origin_buf)

                                        local markdown_link = "![](" .. output_path .. ")"
                                        vim.api.nvim_put({ markdown_link }, "c", true, true)
                                    end)
                                end,
                            })

                            vim.cmd("startinsert")
                        end
                    end

                    map("i", "<CR>", on_select)
                    map("n", "<CR>", on_select)
                    return true
                end,
            }):find()
        end

        local function paste_image_picker()
            pickers.new({}, {
                prompt_title = "Select Image to Edit and Insert",
                finder = finders.new_oneshot_job({
                    "rg",
                    "--files",
                    "--hidden",
                    "--glob", "!**/.git/*",
                    "--glob", "*.jpg",
                    "--glob", "*.png",
                    "--glob", "*.jpeg",
                    "--glob", "*.gif",
                }, { cwd = "/home/telliott/Pictures/Code" }),
                sorter = conf.file_sorter({}),
                attach_mappings = function(prompt_bufnr, map)
                    local function on_select()
                        local selection = action_state.get_selected_entry()
                        actions.close(prompt_bufnr)
                        if not selection then return end

                        image_action_picker(selection[1])
                    end

                    map("i", "<CR>", on_select)
                    map("n", "<CR>", on_select)
                    return true
                end,
            }):find()
        end



        vim.keymap.set("n", "<leader>ti", paste_image_picker, { desc = "Pick + Edit + Insert Image" })
    end,
}
