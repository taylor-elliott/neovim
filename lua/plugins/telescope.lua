return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-lua/plenary.nvim",
    },
    cmd = "Telescope",
    opts = {
        defaults = {
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

        vim.keymap.set("n", "<leader>tc", function()
            builtin.colorscheme({ enable_preview = true })
        end, { desc = "Pick Colorscheme (Preview)" })
    end,
}
