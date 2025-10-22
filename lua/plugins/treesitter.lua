return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    branch = "master",
    lazy = false,
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = { "c", "markdown", "lua", "python", "javascript" },
            highlight = {
                enable = true,
            },
            indent = {
                enable = false,
            },
            fold = {
                enable = false,
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<c-space>",
                    node_incremental = "<c-space>",
                    scope_incremental = "<c-s>",
                    node_decremental = "<M-space>",
                },
            },
            textobjects = {
                select = {
                    enable = false,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer", -- select a function (outer)
                        ["if"] = "@function.inner", -- select inner function
                        ["ac"] = "@class.outer", -- select a class (outer)
                        ["ic"] = "@class.inner", -- select inner class
                        ["ap"] = "@parameter.outer", -- select a parameter (outer)
                        ["ip"] = "@parameter.inner", -- select inner parameter
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,   -- use jumplist
                    goto_next_start = {
                        ["]f"] = "@function.outer", -- Go to next function
                        ["]c"] = "@class.outer", -- Go to next class
                    },
                    goto_next_end = {
                        ["]F"] = "@function.outer", -- Go to next function end
                        ["]C"] = "@class.outer", -- Go to next class end
                    },
                    goto_previous_start = {
                        ["[f"] = "@function.outer", -- Go to previous function
                        ["[c"] = "@class.outer", -- Go to previous class
                    },
                    goto_previous_end = {
                        ["[F"] = "@function.outer", -- Go to previous function end
                        ["[C"] = "@class.outer", -- Go to previous class end
                    },
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ["<leader>N"] = "@parameter.inner", -- Swap next parameter
                    },
                    swap_previous = {
                        ["<leader>P"] = "@parameter.inner", -- Swap previous parameter
                    },
                },
            },
        })

        vim.filetype.add({
            extension = {
                tf = "terraform",
                tfvars = "terraform",
                pipeline = "groovy",
                multibranch = "groovy",
                tex = "latex",
            },
        })
    end,
}
