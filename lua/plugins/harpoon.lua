return {
    "theprimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")

        harpoon:setup({
            settings = {
                save_on_toggle = true,
            },
            menu = {
                width = vim.api.nvim_win_get_width(0) - 4,
            },
        })

        local harpoon_extensions = require("harpoon.extensions")
        harpoon:extend(harpoon_extensions.builtins.highlight_current_file())
    end,
    keys = {
        {
            "<leader>va",
            function()
                require("harpoon"):list():add()
            end,
            desc = "harpoon file",
        },
        {
            "<leader>vv",
            function()
                local harpoon = require("harpoon")
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end,
            desc = "harpoon quick menu",
        },
        {
            "J",
            function()
                if vim.bo.filetype == "harpoon" then
                    local curr = vim.fn.line(".")
                    local last = vim.fn.line("$")
                    if curr == last then
                        return
                    end -- don't move down past last line

                    local line = vim.fn.getline(curr)
                    local next_line = vim.fn.getline(curr + 1)

                    vim.fn.setline(curr, next_line)
                    vim.fn.setline(curr + 1, line)
                    vim.cmd("normal! j") -- move cursor to new location				else
                else
                    vim.cmd("normal! mzJ`z")
                end
            end,
            desc = "Smart J (move Harpoon down or join line)",
        },
        {
            "K",
            function()
                if vim.bo.filetype == "harpoon" then
                    local curr = vim.fn.line(".")
                    if curr == 1 then
                        return
                    end -- don't move above first line

                    local line = vim.fn.getline(curr)
                    local prev_line = vim.fn.getline(curr - 1)

                    vim.fn.setline(curr, prev_line)
                    vim.fn.setline(curr - 1, line)
                    vim.cmd("normal! k") -- move cursor to new location		else
                else
                    local clients = vim.tbl_filter(function(client)
                        local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
                        return client.config and client.config.filetypes and
                        vim.tbl_contains(client.config.filetypes, buf_ft)
                    end, vim.lsp.get_clients())
                    if #clients > 0 then
                        vim.lsp.buf.hover()
                    end
                end
            end,
        },

        {
            "<F1>",
            function()
                require("harpoon"):list():select(1)
            end,
            desc = "harpoon to file 1",
        },
        {
            "<F2>",
            function()
                require("harpoon"):list():select(2)
            end,
            desc = "harpoon to file 2",
        },
        {
            "<F3>",
            function()
                require("harpoon"):list():select(3)
            end,
            desc = "harpoon to file 3",
        },
        {
            "<F4>",
            function()
                require("harpoon"):list():select(4)
            end,
            desc = "harpoon to file 4",
        },
    },
}
