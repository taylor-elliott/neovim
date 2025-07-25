return {
    "ray-x/lsp_signature.nvim",
    lazy = true,
    config = function()
        require("lsp_signature").setup({
            bind = true,
            floating_window = true,
            floating_window_above_cur_line = true,
            hint_enable = true,
            handler_opts = { border = "rounded" },
            hint_prefix = "",
            focusable = true,
            max_height = 6,
            max_width = 40,
            doc_lines = 0,
            transparency = 100,
        })
    end,
}
