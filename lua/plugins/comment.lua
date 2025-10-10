return {
    "numToStr/Comment.nvim",
    lazy = false,
    opts = {
        mappings = {
            basic = true,
            extra = true,
            extended = true,
        },
    },
    config = function(_, opts)
        require("Comment").setup(opts)

        vim.keymap.del("n", "gb")
        vim.keymap.del("x", "gb")
        vim.keymap.del("n", "gbc")
        -- Map gb to go back (like <C-o>)
        vim.keymap.set("n", "gb", "<C-o>", { desc = "Go back after jump", noremap = true, silent = true })

        -- Remap Comment.nvim blockwise toggle to gB (normal and visual modes)
        vim.api.nvim_set_keymap("n", "gB", "<Plug>(comment_toggle_blockwise)", { noremap = false, silent = true })
        vim.api.nvim_set_keymap("x", "gB", "<Plug>(comment_toggle_blockwise_visual)", { noremap = false, silent = true })
    end,
}
